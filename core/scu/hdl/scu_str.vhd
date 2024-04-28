library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture str of scu is

  component scu_reg is
    generic (
      DEBUG_READBACK : boolean);
    port (
      zu_data_ena  : out std_logic_vector(0 downto 0);
      dti_read_ena : out std_logic_vector(0 downto 0);
      fsm_rst      : out std_logic_vector(0 downto 0);
      alarm_ack_button  : in  std_logic_vector(0 downto 0);
      oledbyte3_0  : out std_logic_vector(31 downto 0);
      oledbyte7_4  : out std_logic_vector(31 downto 0);
      oledbyte11_8 : out std_logic_vector(31 downto 0);
      oledbyte15_12     : out std_logic_vector(31 downto 0);
      zu_tdata_cnt      : in  std_logic_vector(7 downto 0);
      zu_byte_cnt_error : in  std_logic_vector(0 downto 0);
      temperature_test_ena    : out std_logic_vector(0 downto 0);
      temperature_test_digit0 : out std_logic_vector(3 downto 0);
      temperature_test_digit1 : out std_logic_vector(3 downto 0);
      pif_clk      : in  std_logic;
      pif_rst      : in  std_logic;
      pif_regcs    : in  std_logic;
      pif_addr     : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata    : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re       : in  std_logic_vector(0 downto 0);
      pif_we       : in  std_logic_vector(0 downto 0);
      pif_be       : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif   : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif     : out std_logic);
  end component scu_reg;

  component scu_fsm is
    generic (
      SIMULATION_MODE : string);
    port (
      mclk                : in  std_logic;
      rst                 : in  std_logic;
      zu_data_ena         : in  std_logic;
      dti_read_ena        : in  std_logic;
      fsm_rst             : in  std_logic;
      alarm_acknowledge   : out std_logic;      
      zu_byte_cnt_error   : out std_logic;
      temperature_test_ena    : in std_logic;
      temperature_test_digit0 : in std_logic_vector(3 downto 0);
      temperature_test_digit1 : in std_logic_vector(3 downto 0);    
      dti_spi_instruction : out std_logic_vector(15 downto 0);
      dti_spi_rd_str      : out std_logic;
      dti_spi_busy        : in  std_logic;
      dti_spi_rdata       : in  std_logic_vector(7 downto 0);
      zu_tdata_cnt_str    : in  std_logic;
      zu_tdata_cnt        : in  std_logic_vector(7 downto 0);
      zu_tdata            : in  std_logic_vector(7 downto 0);
      zu_tvalid           : in  std_logic;
      ps_oledbyte3_0      : in  std_logic_vector(31 downto 0);
      ps_oledbyte7_4      : in  std_logic_vector(31 downto 0);
      ps_oledbyte11_8     : in  std_logic_vector(31 downto 0);
      zu_tready           : out std_logic;
      oledbyte3_0         : out std_logic_vector(31 downto 0);
      oledbyte7_4         : out std_logic_vector(31 downto 0);
      oledbyte11_8        : out std_logic_vector(31 downto 0);
      oledbyte15_12       : out std_logic_vector(31 downto 0);
      led_alarm           : out std_logic;
      alarm_ack_btn       : in  std_logic);
  end component scu_fsm;

  signal scu_fsm_rst  : std_logic;
  signal zu_data_ena  : std_logic;
  signal dti_read_ena : std_logic;

  signal ps_oledbyte3_0  : std_logic_vector(31 downto 0);
  signal ps_oledbyte7_4  : std_logic_vector(31 downto 0);
  signal ps_oledbyte11_8 : std_logic_vector(31 downto 0);

  signal alarm_acknowledge : std_logic;

  signal zu_byte_cnt_error : std_logic;

  signal temperature_test_ena    : std_logic;
  signal temperature_test_digit0 : std_logic_vector(3 downto 0);
  signal temperature_test_digit1 : std_logic_vector(3 downto 0);

  signal alarm_ack_btn_s1    : std_logic;
  signal alarm_ack_btn_s2    : std_logic;    
  signal ackbutton_timeout   : std_logic;
  signal ackbutton_timer_ena : std_logic;
  signal ackbutton_on        : std_logic;
  signal ackbutton_off       : std_logic;
  
begin

  scu_reg_0: scu_reg
    generic map (
      DEBUG_READBACK => PSIF_DEBUG_READBACK_V)
    port map (
      fsm_rst(0)      => scu_fsm_rst,
      zu_data_ena(0)  => zu_data_ena,
      dti_read_ena(0) => dti_read_ena,
      alarm_ack_button(0) => alarm_acknowledge,
      oledbyte3_0     => ps_oledbyte3_0,    
      oledbyte7_4     => ps_oledbyte7_4,  
      oledbyte11_8    => ps_oledbyte11_8,       
      oledbyte15_12   => open,
      zu_tdata_cnt    => zu_tdata_cnt,
      zu_byte_cnt_error(0) => zu_byte_cnt_error,
      temperature_test_ena(0) => temperature_test_ena,    
      temperature_test_digit0 => temperature_test_digit0, 
      temperature_test_digit1 => temperature_test_digit1,      
      pif_clk         => mclk,
      pif_rst         => rst,
      pif_regcs       => pif_regcs,
      pif_addr        => pif_addr,
      pif_wdata       => pif_wdata,
      pif_re          => pif_re,
      pif_we          => pif_we,
      pif_be          => pif_be,
      rdata_2pif      => rdata_2pif,
      ack_2pif        => ack_2pif);

  scu_fsm_0: scu_fsm
    generic map (
      SIMULATION_MODE => SIMULATION_MODE)
    port map (
      mclk                => mclk,
      rst                 => rst,
      zu_data_ena         => zu_data_ena,
      dti_read_ena        => dti_read_ena,
      fsm_rst             => scu_fsm_rst,
      alarm_acknowledge   => alarm_acknowledge,
      zu_byte_cnt_error   => zu_byte_cnt_error,
      temperature_test_ena    => temperature_test_ena,    
      temperature_test_digit0 => temperature_test_digit0, 
      temperature_test_digit1 => temperature_test_digit1,      
      dti_spi_instruction => dti_spi_instruction,
      dti_spi_rd_str      => dti_spi_rd_str,
      dti_spi_busy        => dti_spi_busy,
      dti_spi_rdata       => dti_spi_rdata,
      ps_oledbyte3_0      => ps_oledbyte3_0, 
      ps_oledbyte7_4      => ps_oledbyte7_4, 
      ps_oledbyte11_8     => ps_oledbyte11_8,
      zu_tdata_cnt_str    => zu_tdata_cnt_str,
      zu_tdata_cnt        => zu_tdata_cnt,
      zu_tdata            => zu_tdata,
      zu_tvalid           => zu_tvalid,
      zu_tready           => zu_tready,
      oledbyte3_0         => odi_oledbyte3_0, 
      oledbyte7_4         => odi_oledbyte7_4, 
      oledbyte11_8        => odi_oledbyte11_8,
      oledbyte15_12       => odi_oledbyte15_12,
      led_alarm           => led_alarm,
      alarm_ack_btn       => ackbutton_on);

 
  -- Synchronizing the external alarm_ack_btn signal
  P_SYNCHRONIZE_ALARM_ACK: process(rst, mclk) is
  begin
    if (rst = '1') then
      alarm_ack_btn_s1   <= '0';
      alarm_ack_btn_s2   <= '0';
    elsif rising_edge(mclk) then
      alarm_ack_btn_s1   <= alarm_ack_btn;
      alarm_ack_btn_s2   <= alarm_ack_btn_s1;
    end if;
  end process P_SYNCHRONIZE_ALARM_ACK;


  P_FSM_ACKBUTTON:
  process (rst, mclk) is                          
    type fsm_state_type is (IDLE, ACKBUTTON_UNSTABLE, ACKBUTTON_STABLE, ACKBUTTON_END);
    variable fsm_state : fsm_state_type;
  begin
    
    if (rst = '1') then
      
      ackbutton_on  <= '0';
      ackbutton_off <= '0';
      ackbutton_timer_ena <= '0';
      fsm_state     := IDLE;     
      
    elsif rising_edge(mclk) then

      -- Default strobe values
      ackbutton_on  <= '0';
      ackbutton_off <= '0';

      case fsm_state is
        
        when IDLE =>          
          if alarm_ack_btn_s2='1' then
            ackbutton_on <= '1';
            ackbutton_timer_ena <= '1';
            fsm_state := ACKBUTTON_UNSTABLE;          
          end if;

        when ACKBUTTON_UNSTABLE => -- force minimum ack button on -> off 0.5 sek
          if ackbutton_timeout='1' then
            ackbutton_timer_ena <= '0';
            fsm_state := ACKBUTTON_STABLE;
          end if;
                  
        when ACKBUTTON_STABLE =>                    
          if alarm_ack_btn_s2='0' then
            ackbutton_off <= '1';
            ackbutton_timer_ena <= '1';
            fsm_state := ACKBUTTON_END;
          end if;
                    
        when others => -- ACKBUTTON_END state force minimum off -> on 0.5 sek
          if ackbutton_timeout='1' then
            ackbutton_timer_ena <= '0';
            fsm_state := IDLE;
          end if;
          
      end case;            
    end if;    
  end process P_FSM_ACKBUTTON;


  G_SIMULATION_MODE: if SIMULATION_MODE="ON" generate
    constant ACKBUTTON_STABLE : unsigned(8 downto 0):= (8 => '1', others => '0');
  begin
    
    -- Timer for acknowledge button logic
    P_ACKBUTTON_TIMER_SIM: process(rst, mclk)
      variable timer_cnt : unsigned(8 downto 0);
    begin
      if (rst = '1') then
  
        timer_cnt := (others => '0');
        ackbutton_timeout <= '0';
  
      elsif rising_edge(mclk) then
      
        if (ackbutton_timer_ena = '1') then
          timer_cnt := timer_cnt + 1;
        else
          timer_cnt := (others => '0');
        end if;
  
        -- Generating timeout signals
        ackbutton_timeout <= '0';  -- Default no timeout
        if timer_cnt = ACKBUTTON_STABLE then
          ackbutton_timeout <= '1';
        end if;  
  
      end if;
    end process P_ACKBUTTON_TIMER_SIM;
    
  end generate G_SIMULATION_MODE;
  
    
  G_TARGET_MODE: if SIMULATION_MODE="OFF" generate
         
    constant ACKBUTTON_STABLE : unsigned(28 downto 0):= (28 => '1', others => '0');

  begin
    
    -- Timer for acknowledge button logic
    P_ACKBUTTON_TIMER_TARGET: process(rst, mclk)
      variable timer_cnt : unsigned(28 downto 0);
    begin
      if (rst = '1') then
  
        timer_cnt := (others => '0');
        ackbutton_timeout <= '0';
  
      elsif rising_edge(mclk) then
      
        if (ackbutton_timer_ena = '1') then
          timer_cnt := timer_cnt + 1;
        else
          timer_cnt := (others => '0');
        end if;
  
        -- Generating timeout signals
        ackbutton_timeout <= '0';  -- Default no timeout
        if timer_cnt = ACKBUTTON_STABLE then
          ackbutton_timeout <= '1';
        end if;  
  
      end if;
      
    end process P_ACKBUTTON_TIMER_TARGET;

  end generate G_TARGET_MODE;
    
  
end str;
