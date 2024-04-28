
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.zu_pck.all;

entity scu_fsm is
  generic (
    SIMULATION_MODE : string);
  port (
    -- Clock signal
    mclk                : in  std_logic;
    -- Reset signal. This signal is active HIGH
    rst                 : in  std_logic;
    -- SCU register signals
    zu_data_ena         : in  std_logic;
    dti_read_ena        : in  std_logic;
    fsm_rst             : in  std_logic;
    alarm_acknowledge   : out std_logic;
    zu_byte_cnt_error   : out std_logic;
    temperature_test_ena    : in std_logic;
    temperature_test_digit0 : in std_logic_vector(3 downto 0);
    temperature_test_digit1 : in std_logic_vector(3 downto 0);    
    -- DTI signals
    dti_spi_instruction : out std_logic_vector(15 downto 0);
    dti_spi_rd_str      : out std_logic;
    dti_spi_busy        : in  std_logic;
    dti_spi_rdata       : in  std_logic_vector(7 downto 0);
    ps_oledbyte3_0      : in  std_logic_vector(31 downto 0);
    ps_oledbyte7_4      : in  std_logic_vector(31 downto 0);
    ps_oledbyte11_8     : in  std_logic_vector(31 downto 0);
    -- ZU signals
    zu_tdata_cnt_str    : in  std_logic;
    zu_tdata_cnt        : in  std_logic_vector(7 downto 0);
    zu_tdata            : in  std_logic_vector(7 downto 0);
    zu_tvalid           : in  std_logic;
    zu_tready           : out std_logic;
    --ODI signals
    oledbyte3_0         : out std_logic_vector(31 downto 0);
    oledbyte7_4         : out std_logic_vector(31 downto 0);
    oledbyte11_8        : out std_logic_vector(31 downto 0);
    oledbyte15_12       : out std_logic_vector(31 downto 0);
    -- Primary I/O led and button signals
    led_alarm           : out std_logic;
    alarm_ack_btn       : in  std_logic
  );
end scu_fsm;

