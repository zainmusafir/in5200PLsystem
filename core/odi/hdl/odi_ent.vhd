
library ieee;
use ieee.std_logic_1164.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.odi_pck.all;

entity odi is
    generic (
      SIMULATION_MODE : string);
    port (  mclk              : in  std_logic;
            rst               : in  std_logic;
            pif_regcs         : in  std_logic;
            pif_addr          : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
            pif_wdata         : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
            pif_re            : in  std_logic_vector(0 downto 0);
            pif_we            : in  std_logic_vector(0 downto 0);
            pif_be            : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
            rdata_2pif        : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
            ack_2pif          : out std_logic;  
            odi_oledbyte3_0   : in  std_logic_vector(31 downto 0);
            odi_oledbyte7_4   : in  std_logic_vector(31 downto 0);
            odi_oledbyte11_8  : in  std_logic_vector(31 downto 0);
            odi_oledbyte15_12 : in  std_logic_vector(31 downto 0);
            oled_sdin         : out std_logic;
            oled_sclk         : out std_logic;
            oled_dc           : out std_logic;
            oled_res          : out std_logic;
            oled_vbat         : out std_logic;
            oled_vdd          : out std_logic);
end odi;
