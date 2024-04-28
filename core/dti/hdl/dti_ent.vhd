
library ieee;
use ieee.std_logic_1164.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.dti_pck.all;

entity dti is
  port (mclk                   : in  std_logic;
        rst                    : in  std_logic;
        pif_clk                : in  std_logic;
        pif_rst                : in  std_logic;
        pif_regcs              : in  std_logic;
        pif_memcs              : in  std_logic_vector(1 downto 0); 
        pif_addr               : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
        pif_wdata              : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        pif_re                 : in  std_logic_vector(0 downto 0);
        pif_we                 : in  std_logic_vector(0 downto 0);
        pif_be                 : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
        rdata_2pif             : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        ack_2pif               : out std_logic;  
        mdata_dtispirxfifo2pif : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        dti_spi_instruction    : in  std_logic_vector(15 downto 0);
        dti_spi_rd_str         : in  std_logic;
        dti_spi_busy           : out std_logic;
        dti_spi_rdata          : out std_logic_vector(7 downto 0);
        dti_ce                 : out std_logic;
        dti_sclk               : out std_logic;
        dti_sdi                : out std_logic;
        dti_sdo                : in  std_logic);
end dti;                  
                          
                          
