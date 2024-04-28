
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library PSIF_lib;
use PSIF_lib.scu_pck.all;
use PSIF_lib.PSIF_pck.all;


architecture rtl of scu_reg is

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit PIF_DATA_LENGTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB                   : integer := (PSIF_DATA_LENGTH/32)+ 1;        
  constant OPT_MEM_ADDR_BITS          : integer := 6;
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
  signal scu_zu_data_ena_i              : std_logic_vector(0 downto 0);
  signal scu_dti_read_ena_i             : std_logic_vector(0 downto 0);
  signal scu_fsm_rst_i                  : std_logic_vector(0 downto 0);
  signal scu_alarm_ack_button_i         : std_logic_vector(0 downto 0);
  signal scu_oledbyte3_0_i              : std_logic_vector(31 downto 0);
  signal scu_oledbyte7_4_i              : std_logic_vector(31 downto 0);
  signal scu_oledbyte11_8_i             : std_logic_vector(31 downto 0);
  signal scu_oledbyte15_12_i            : std_logic_vector(31 downto 0);
  signal scu_zu_tdata_cnt_i             : std_logic_vector(7 downto 0);
  signal scu_zu_byte_cnt_error_i        : std_logic_vector(0 downto 0);
  signal scu_temperature_test_ena_i     : std_logic_vector(0 downto 0);
  signal scu_temperature_test_digit0_i  : std_logic_vector(3 downto 0);
  signal scu_temperature_test_digit1_i  : std_logic_vector(3 downto 0);

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
      scu_zu_data_ena_i               <= b"0";
      scu_dti_read_ena_i              <= b"0";
      scu_fsm_rst_i                   <= b"0";
      scu_oledbyte3_0_i               <= x"0000_0000";
      scu_oledbyte7_4_i               <= x"0000_0000";
      scu_oledbyte11_8_i              <= x"0000_0000";
      scu_oledbyte15_12_i             <= x"0000_0000";
      scu_temperature_test_ena_i      <= b"0";
      scu_temperature_test_digit0_i   <= x"0";
      scu_temperature_test_digit1_i   <= x"0";
      regwrack_2pif <= '0';

    elsif rising_edge(pif_clk) then
      --DefaultValues

      if (pif_regcs_d1='1' and pif_we_i(0) = '1') then
        -- Register write acknowledge
        regwrack_2pif <= '1';          
        loc_addr := pif_addr_i(ADDR_LSB_OPT_MEM_ADDR_BITS - 1 downto ADDR_LSB);
  
        --InterruptRegisterWrite 

        --Register Write 
        -- SCU_ZU_DATA_ENA
        if loc_addr = SCU_ZU_DATA_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_ZU_DATA_ENA)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_zu_data_ena_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- SCU_DTI_READ_ENA
        if loc_addr = SCU_DTI_READ_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_DTI_READ_ENA)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_dti_read_ena_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- SCU_FSM_RST
        if loc_addr = SCU_FSM_RST(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_FSM_RST)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_fsm_rst_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- SCU_OLEDBYTE3_0
        if loc_addr = SCU_OLEDBYTE3_0(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_OLEDBYTE3_0)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_oledbyte3_0_i(7 downto 0) <= std_logic_vector(pif_wdata_i(7 downto 0));
          end if;
          if pif_be_i(byteIndex+1) = '1' then
            scu_oledbyte3_0_i(15 downto 8) <= std_logic_vector(pif_wdata_i(15 downto 8));
          end if;
          if pif_be_i(byteIndex+2) = '1' then
            scu_oledbyte3_0_i(23 downto 16) <= std_logic_vector(pif_wdata_i(23 downto 16));
          end if;
          if pif_be_i(byteIndex+3) = '1' then
            scu_oledbyte3_0_i(31 downto 24) <= std_logic_vector(pif_wdata_i(31 downto 24));
          end if;
        end if;  
        -- SCU_OLEDBYTE7_4
        if loc_addr = SCU_OLEDBYTE7_4(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_OLEDBYTE7_4)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_oledbyte7_4_i(7 downto 0) <= std_logic_vector(pif_wdata_i(7 downto 0));
          end if;
          if pif_be_i(byteIndex+1) = '1' then
            scu_oledbyte7_4_i(15 downto 8) <= std_logic_vector(pif_wdata_i(15 downto 8));
          end if;
          if pif_be_i(byteIndex+2) = '1' then
            scu_oledbyte7_4_i(23 downto 16) <= std_logic_vector(pif_wdata_i(23 downto 16));
          end if;
          if pif_be_i(byteIndex+3) = '1' then
            scu_oledbyte7_4_i(31 downto 24) <= std_logic_vector(pif_wdata_i(31 downto 24));
          end if;
        end if;  
        -- SCU_OLEDBYTE11_8
        if loc_addr = SCU_OLEDBYTE11_8(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_OLEDBYTE11_8)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_oledbyte11_8_i(7 downto 0) <= std_logic_vector(pif_wdata_i(7 downto 0));
          end if;
          if pif_be_i(byteIndex+1) = '1' then
            scu_oledbyte11_8_i(15 downto 8) <= std_logic_vector(pif_wdata_i(15 downto 8));
          end if;
          if pif_be_i(byteIndex+2) = '1' then
            scu_oledbyte11_8_i(23 downto 16) <= std_logic_vector(pif_wdata_i(23 downto 16));
          end if;
          if pif_be_i(byteIndex+3) = '1' then
            scu_oledbyte11_8_i(31 downto 24) <= std_logic_vector(pif_wdata_i(31 downto 24));
          end if;
        end if;  
        -- SCU_OLEDBYTE15_12
        if loc_addr = SCU_OLEDBYTE15_12(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_OLEDBYTE15_12)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_oledbyte15_12_i(7 downto 0) <= std_logic_vector(pif_wdata_i(7 downto 0));
          end if;
          if pif_be_i(byteIndex+1) = '1' then
            scu_oledbyte15_12_i(15 downto 8) <= std_logic_vector(pif_wdata_i(15 downto 8));
          end if;
          if pif_be_i(byteIndex+2) = '1' then
            scu_oledbyte15_12_i(23 downto 16) <= std_logic_vector(pif_wdata_i(23 downto 16));
          end if;
          if pif_be_i(byteIndex+3) = '1' then
            scu_oledbyte15_12_i(31 downto 24) <= std_logic_vector(pif_wdata_i(31 downto 24));
          end if;
        end if;  
        -- SCU_TEMPERATURE_TEST_ENA
        if loc_addr = SCU_TEMPERATURE_TEST_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_TEMPERATURE_TEST_ENA)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_temperature_test_ena_i <= std_logic_vector(pif_wdata_i(byteIndex*8+0 downto byteIndex*8));
          end if;
        end if;  
        -- SCU_TEMPERATURE_TEST_DIGIT0
        if loc_addr = SCU_TEMPERATURE_TEST_DIGIT0(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_TEMPERATURE_TEST_DIGIT0)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_temperature_test_digit0_i <= std_logic_vector(pif_wdata_i(byteIndex*8+3 downto byteIndex*8));
          end if;
        end if;  
        -- SCU_TEMPERATURE_TEST_DIGIT1
        if loc_addr = SCU_TEMPERATURE_TEST_DIGIT1(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB) then
          byteIndex := to_integer(unsigned(SCU_TEMPERATURE_TEST_DIGIT1)) mod 4;
          if pif_be_i(byteIndex) = '1' then
            scu_temperature_test_digit1_i <= std_logic_vector(pif_wdata_i(byteIndex*8+3 downto byteIndex*8));
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
        -- SCU_ZU_DATA_ENA
        if loc_addr = std_logic_vector(SCU_ZU_DATA_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_zu_data_ena_i;
        end if;
        -- SCU_DTI_READ_ENA
        if loc_addr = std_logic_vector(SCU_DTI_READ_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_dti_read_ena_i;
        end if;
        -- SCU_FSM_RST
        if loc_addr = std_logic_vector(SCU_FSM_RST(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_fsm_rst_i;
        end if;
        -- SCU_ALARM_ACK_BUTTON
        if loc_addr = std_logic_vector(SCU_ALARM_ACK_BUTTON(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_alarm_ack_button_i;
        end if;
        -- SCU_OLEDBYTE3_0
        if loc_addr = std_logic_vector(SCU_OLEDBYTE3_0(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(31 downto 0) <= scu_oledbyte3_0_i;
        end if;
        -- SCU_OLEDBYTE7_4
        if loc_addr = std_logic_vector(SCU_OLEDBYTE7_4(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(31 downto 0) <= scu_oledbyte7_4_i;
        end if;
        -- SCU_OLEDBYTE11_8
        if loc_addr = std_logic_vector(SCU_OLEDBYTE11_8(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(31 downto 0) <= scu_oledbyte11_8_i;
        end if;
        -- SCU_OLEDBYTE15_12
        if loc_addr = std_logic_vector(SCU_OLEDBYTE15_12(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(31 downto 0) <= scu_oledbyte15_12_i;
        end if;
        -- SCU_ZU_TDATA_CNT
        if loc_addr = std_logic_vector(SCU_ZU_TDATA_CNT(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(7 downto 0) <= scu_zu_tdata_cnt_i;
        end if;
        -- SCU_ZU_BYTE_CNT_ERROR
        if loc_addr = std_logic_vector(SCU_ZU_BYTE_CNT_ERROR(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_zu_byte_cnt_error_i;
        end if;
        -- SCU_TEMPERATURE_TEST_ENA
        if loc_addr = std_logic_vector(SCU_TEMPERATURE_TEST_ENA(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(0 downto 0) <= scu_temperature_test_ena_i;
        end if;
        -- SCU_TEMPERATURE_TEST_DIGIT0
        if loc_addr = std_logic_vector(SCU_TEMPERATURE_TEST_DIGIT0(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(3 downto 0) <= scu_temperature_test_digit0_i;
        end if;
        -- SCU_TEMPERATURE_TEST_DIGIT1
        if loc_addr = std_logic_vector(SCU_TEMPERATURE_TEST_DIGIT1(ADDR_LSB_OPT_MEM_ADDR_BITS-1 downto ADDR_LSB)) then
          reg_data_out(3 downto 0) <= scu_temperature_test_digit1_i;
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
  zu_data_ena                   <= scu_zu_data_ena_i;
  dti_read_ena                  <= scu_dti_read_ena_i;
  fsm_rst                       <= scu_fsm_rst_i;
  scu_alarm_ack_button_i           <= alarm_ack_button;
  oledbyte3_0                   <= scu_oledbyte3_0_i;
  oledbyte7_4                   <= scu_oledbyte7_4_i;
  oledbyte11_8                  <= scu_oledbyte11_8_i;
  oledbyte15_12                 <= scu_oledbyte15_12_i;
  scu_zu_tdata_cnt_i               <= zu_tdata_cnt;
  scu_zu_byte_cnt_error_i          <= zu_byte_cnt_error;
  temperature_test_ena          <= scu_temperature_test_ena_i;
  temperature_test_digit0       <= scu_temperature_test_digit0_i;
  temperature_test_digit1       <= scu_temperature_test_digit1_i;
  

  -- Add user logic here:

  -- Add user logic ends

end rtl;
