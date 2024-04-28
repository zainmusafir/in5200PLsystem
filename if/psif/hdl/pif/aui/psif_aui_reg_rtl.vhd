
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PSIF_lib;
use PSIF_lib.aui_pck.all;
use PSIF_lib.PSIF_pck.all;


architecture rtl of aui_reg is

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit PIF_DATA_LENGTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB                   : integer := (PSIF_DATA_LENGTH/32)+ 1;        
  constant OPT_MEM_ADDR_BITS          : integer := 13;
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
  signal aui_reset_i                        : std_logic_vector(0 downto 0);
  signal aui_aurora_core_status_i           : std_logic_vector(12 downto 0);
  signal aui_aurora_loopback_i              : std_logic_vector(2 downto 0);
  signal aui_aurora_reset_i                 : std_logic_vector(0 downto 0);
  signal aui_aurora_gt_reset_i              : std_logic_vector(0 downto 0);
  signal aui_aurora_ps_txfifo_count_i       : std_logic_vector(8 downto 0);
  signal aui_aurora_ps_rxfifo_count_i       : std_logic_vector(8 downto 0);
  signal aui_aurora_fifo_tx_write_enable_i  : std_logic_vector(0 downto 0);
  signal aui_aurora_access_loop_ena_i       : std_logic_vector(0 downto 0);

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
      aui_reset_i                         <= b"0";
      aui_aurora_loopback_i               <= b"000";
      aui_aurora_reset_i                  <= b"1";
      aui_aurora_gt_reset_i               <= b"1";
      aui_aurora_fifo_tx_write_enable_i   <= b"0";
      aui_aurora_access_loop_ena_i        <= b"0";
      regwrack_2pif <= '0';

    elsif rising_edge(pif_clk) then
      --DefaultValues

      if (pif_regcs_d1='1' and pif_we_i(0) = '1') then
        -- Register write acknowledge
        regwrack_2pif <= '1';          
        loc_addr := pif_addr_i(ADDR_LSB_OPT_MEM_ADDR_BITS - 1 downto ADDR_LSB);
  
        --Register Write 
        -- AUI_RESET
        if loc_addr = AUI_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_RESET)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_reset_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- AUI_AURORA_LOOPBACK
        if loc_addr = AUI_AURORA_LOOPBACK(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_AURORA_LOOPBACK)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_aurora_loopback_i <= std_logic_vector(pif_wdata_i(byteIndex*8+2 downto byteIndex*8));
          end if;
        end if;  
        -- AUI_AURORA_RESET
        if loc_addr = AUI_AURORA_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_AURORA_RESET)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_aurora_reset_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- AUI_AURORA_GT_RESET
        if loc_addr = AUI_AURORA_GT_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_AURORA_GT_RESET)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_aurora_gt_reset_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- AUI_AURORA_FIFO_TX_WRITE_ENABLE
        if loc_addr = AUI_AURORA_FIFO_TX_WRITE_ENABLE(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_AURORA_FIFO_TX_WRITE_ENABLE)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_aurora_fifo_tx_write_enable_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- AUI_AURORA_ACCESS_LOOP_ENA
        if loc_addr = AUI_AURORA_ACCESS_LOOP_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(AUI_AURORA_ACCESS_LOOP_ENA)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            aui_aurora_access_loop_ena_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
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

        -- AUI_RESET
        if loc_addr = std_logic_vector(AUI_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= aui_reset_i;
        end if;
        -- AUI_AURORA_CORE_STATUS
        if loc_addr = std_logic_vector(AUI_AURORA_CORE_STATUS(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(12 downto 0) <= aui_aurora_core_status_i;
        end if;
        -- AUI_AURORA_LOOPBACK
        if loc_addr = std_logic_vector(AUI_AURORA_LOOPBACK(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(2 downto 0) <= aui_aurora_loopback_i;
        end if;
        -- AUI_AURORA_RESET
        if loc_addr = std_logic_vector(AUI_AURORA_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= aui_aurora_reset_i;
        end if;
        -- AUI_AURORA_GT_RESET
        if loc_addr = std_logic_vector(AUI_AURORA_GT_RESET(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= aui_aurora_gt_reset_i;
        end if;
        -- AUI_AURORA_PS_TXFIFO_COUNT
        if loc_addr = std_logic_vector(AUI_AURORA_PS_TXFIFO_COUNT(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(8 downto 0) <= aui_aurora_ps_txfifo_count_i;
        end if;
        -- AUI_AURORA_PS_RXFIFO_COUNT
        if loc_addr = std_logic_vector(AUI_AURORA_PS_RXFIFO_COUNT(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(8 downto 0) <= aui_aurora_ps_rxfifo_count_i;
        end if;
        -- AUI_AURORA_FIFO_TX_WRITE_ENABLE
        if loc_addr = std_logic_vector(AUI_AURORA_FIFO_TX_WRITE_ENABLE(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= aui_aurora_fifo_tx_write_enable_i;
        end if;
        -- AUI_AURORA_ACCESS_LOOP_ENA
        if loc_addr = std_logic_vector(AUI_AURORA_ACCESS_LOOP_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= aui_aurora_access_loop_ena_i;
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
  reset                             <= aui_reset_i;
  aui_aurora_core_status_i          <= aurora_core_status;
  aurora_loopback                   <= aui_aurora_loopback_i;
  aurora_reset                      <= aui_aurora_reset_i;
  aurora_gt_reset                   <= aui_aurora_gt_reset_i;
  aui_aurora_ps_txfifo_count_i      <= aurora_ps_txfifo_count;
  aui_aurora_ps_rxfifo_count_i      <= aurora_ps_rxfifo_count;
  aurora_fifo_tx_write_enable       <= aui_aurora_fifo_tx_write_enable_i;
  aurora_access_loop_ena            <= aui_aurora_access_loop_ena_i;
  

  -- Add user logic here:

  -- Add user logic ends

end rtl;
