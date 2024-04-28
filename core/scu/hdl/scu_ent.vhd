
library ieee;
use ieee.std_logic_1164.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.scu_pck.all;

entity scu is
  generic (
    SIMULATION_MODE : string);
  port (mclk            : in  std_logic;
    rst                 : in  std_logic;
    pif_regcs           : in  std_logic;
    pif_addr            : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
    pif_wdata           : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
    pif_re              : in  std_logic_vector(0 downto 0);
    pif_we              : in  std_logic_vector(0 downto 0);
    pif_be              : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
    rdata_2pif          : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
    ack_2pif            : out std_logic;  
    dti_spi_instruction : out std_logic_vector(15 downto 0);
    dti_spi_rd_str      : out std_logic;
    dti_spi_busy        : in  std_logic;
    dti_spi_rdata       : in  std_logic_vector(7 downto 0);
    zu_tdata_cnt_str    : in  std_logic;
    zu_tdata_cnt        : in  std_logic_vector(7 downto 0);
    zu_tdata            : in  std_logic_vector(7 downto 0);
    zu_tvalid           : in  std_logic;
    zu_tready           : out std_logic;
    odi_oledbyte3_0     : out std_logic_vector(31 downto 0);
    odi_oledbyte7_4     : out std_logic_vector(31 downto 0);
    odi_oledbyte11_8    : out std_logic_vector(31 downto 0);
    odi_oledbyte15_12   : out std_logic_vector(31 downto 0);
    led_alarm           : out std_logic;
    alarm_ack_btn       : in  std_logic);
end scu;
