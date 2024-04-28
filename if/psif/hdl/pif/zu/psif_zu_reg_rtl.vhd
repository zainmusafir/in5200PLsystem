
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PSIF_lib;
use PSIF_lib.zu_pck.all;
use PSIF_lib.PSIF_pck.all;


architecture rtl of zu_reg is

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit PIF_DATA_LENGTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB                   : integer := (PSIF_DATA_LENGTH/32)+ 1;        
  constant OPT_MEM_ADDR_BITS          : integer := 4;
  constant ADDR_LSB_OPT_MEM_ADDR_BITS : integer := OPT_MEM_ADDR_BITS;

  ----------------------------------------------------
  ---- Signals for user logic register
  ----------------------------------------------------
  signal pif_regcs_s1 : std_logic;
  signal pif_regcs_s2 : std_logic;
  signal pif_regcs_s3 : std_logic;
  signal pif_regcs_d1 : std_logic;

  -- The direct_enable attributes ensures that the 
  -- enable pin is used in the clock domain crossing
  attribute direct_enable                 : string;
  attribute direct_enable of pif_regcs_s3 : signal is "yes";
  
  signal pif_addr_i   : std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
  signal pif_wdata_i  : std_logic_vector(PSIF_DATA_LENGTH-1 DOWNTO 0);
  signal pif_re_i     : std_logic_vector(0 downto 0);
  signal pif_we_i     : std_logic_vector(0 downto 0);
  signal pif_be_i     : std_logic_vector((PSIF_DATA_LENGTH/8)-1 DOWNTO 0);

  --Internal Registers 
  signal zu_decryption_bypass_i  : std_logic_vector(0 downto 0);
  signal zu_start_decryption_i   : std_logic_vector(0 downto 0);
  signal zu_start_decryption_tmp   : std_logic_vector(0 downto 0);
  signal zu_start_decryption_i_str   : std_logic_vector(0 downto 0);
  signal zu_done_decryption_i    : std_logic_vector(0 downto 0);
  signal zu_fsm_rst_i            : std_logic_vector(0 downto 0);

  signal reg_data_out	   : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);


  -- Register read and write access acknowledge
  signal regrdack_2pif     : std_logic;
  signal regwrack_2pif     : std_logic;

begin

  -- Synchronize the register chip select signal
  P_SYNCH_REGCS: process ( pif_rst, pif_clk )
  begin
    if pif_rst='1' then
      pif_regcs_s1 <= '0';
      pif_regcs_s2 <= '0';
      pif_regcs_s3 <= '0';
      pif_regcs_d1 <= '0';
    elsif rising_edge(pif_clk) then
      pif_regcs_s1 <= pif_regcs;
      pif_regcs_s2 <= pif_regcs_s1;
      pif_regcs_s3 <= pif_regcs_s2;       
      pif_regcs_d1 <= pif_regcs_s3;       
    end if;
  end process;

  P_SYNCH_BUS: process (pif_rst, pif_clk )
  begin
    if pif_rst = '1' then 
      pif_addr_i  <= (others => '0');
      pif_wdata_i <= (others => '0');
      pif_re_i    <= (others => '0');
      pif_we_i    <= (others => '0');
      pif_be_i    <= (others => '0');
    elsif rising_edge(pif_clk) then
      if pif_regcs_s3 = '1' then 
        pif_addr_i  <= pif_addr;
        pif_wdata_i <= pif_wdata;
        pif_re_i    <= pif_re;
        pif_we_i    <= pif_we;
        pif_be_i    <= pif_be;
      end if;
    end if;
  end process;


  
  -- Implement memory mapped register select and write logic generation
  -- Write strobes are used to select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active high) is applied.
        
  P_WRITE: process ( pif_rst, pif_clk )
    variable loc_addr : std_logic_vector(ADDR_LSB_OPT_MEM_ADDR_BITS -1 downto ADDR_LSB);
    variable byteIndex : integer range 0 to 3;

  begin
    if pif_rst = '1' then
      zu_decryption_bypass_i   <= b"1";
      zu_start_decryption_i    <= b"0";
      zu_start_decryption_i_str    <= b"0";
      zu_start_decryption_tmp    <= b"0";
      zu_fsm_rst_i             <= b"0";
      regwrack_2pif <= '0';

    elsif rising_edge(pif_clk) then
      --DefaultValues
      zu_start_decryption_i_str <= (others => '0');
      zu_start_decryption_tmp <= (others => '0');

      if (pif_regcs_d1='1' and pif_we_i(0) = '1') then
        -- Register write acknowledge
        regwrack_2pif <= '1';          
        loc_addr := pif_addr_i(ADDR_LSB_OPT_MEM_ADDR_BITS - 1 downto ADDR_LSB);
  
        --InterruptRegisterWrite 

        --Register Write 
        -- ZU_DECRYPTION_BYPASS
        if loc_addr = ZU_DECRYPTION_BYPASS(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(ZU_DECRYPTION_BYPASS)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            zu_decryption_bypass_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- ZU_FSM_RST
        if loc_addr = ZU_FSM_RST(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(ZU_FSM_RST)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            zu_fsm_rst_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
      
      -- WRITE STROBE       
      if loc_addr = ZU_START_DECRYPTION(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
        byteIndex := to_integer(unsigned(ZU_START_DECRYPTION)) mod 4;
        if pif_be_i(byteIndex) = '1' then
          zu_start_decryption_tmp <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          zu_start_decryption_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          zu_start_decryption_i_str <= (not zu_start_decryption_tmp(0  downto 0)) and std_logic_vector(pif_wdata_i(0 + byteIndex*8 downto byteIndex*8));
        end if;
      end if;
  
           
      elsif (pif_regcs_d1='0') then
        regwrack_2pif <= '0';
      end if;
    end if;      
  end process;
 


  -- Implement memory mapped register select and read logic generation
  P_READ: process ( all )
    variable loc_addr : std_logic_vector(ADDR_LSB_OPT_MEM_ADDR_BITS -1 downto ADDR_LSB);
    begin
      -- Address decoding for reading registers
      if ( pif_regcs_d1='1' and pif_re_i(0)='1' ) then
        loc_addr := pif_addr_i(ADDR_LSB_OPT_MEM_ADDR_BITS -1 downto ADDR_LSB);
        reg_data_out  <= (others => '0');

        --InterruptRegisterRead
        --Register Read Data
        -- ZU_DECRYPTION_BYPASS
        if loc_addr = std_logic_vector(ZU_DECRYPTION_BYPASS(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= zu_decryption_bypass_i;
        end if;
        -- ZU_START_DECRYPTION
        if loc_addr = std_logic_vector(ZU_START_DECRYPTION(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= zu_start_decryption_i;
        end if;
        -- ZU_DONE_DECRYPTION
        if loc_addr = std_logic_vector(ZU_DONE_DECRYPTION(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= zu_done_decryption_i;
        end if;
        -- ZU_FSM_RST
        if loc_addr = std_logic_vector(ZU_FSM_RST(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= zu_fsm_rst_i;
        end if;
    
      else
        reg_data_out  <= (others => '0');
      end if;
  end process P_READ;

  P_READ_SEQ: process( pif_rst, pif_clk  ) is
  begin
    if ( pif_rst = '1' )  then
      rdata_2pif  <= (others => '0');
      regrdack_2pif <= '0';
    elsif rising_edge (pif_clk) then
      if (pif_regcs_d1 = '1' and pif_re_i(0) = '1') then
        -- Register read data 
        rdata_2pif <= reg_data_out;
        -- Register read acknowledge          
        regrdack_2pif <= '1';          
      elsif (pif_regcs_d1 = '0') then
        rdata_2pif  <= (others => '0');
        regrdack_2pif <= '0';
      end if;   
    end if;
  end process;
  
  P_ACK_2PIF: process(pif_rst, pif_clk) is
  begin 
    if (pif_rst = '1') then 
      ack_2pif <= '0';
    elsif rising_edge(pif_clk) then
      ack_2pif <= regrdack_2pif or regwrack_2pif;
    end if;
  end process;

 
  
  -- RegisterPorts 
  decryption_bypass       <= zu_decryption_bypass_i;
  start_decryption_str    <= zu_start_decryption_i_str;
  zu_done_decryption_i      <= done_decryption;
  fsm_rst                 <= zu_fsm_rst_i;
  

  -- Add user logic here:

  -- Add user logic ends

end rtl;
