
library ieee;
use ieee.std_logic_1164.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.zu_pck.all;

entity zu is
  port (mclk               : in  std_logic;
        rst                : in  std_logic;
        pif_clk            : in  std_logic;
        pif_rst            : in  std_logic;
        pif_regcs          : in  std_logic;
        pif_memcs          : in  std_logic_vector(1 downto 0); 
        pif_addr           : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
        pif_wdata          : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        pif_re             : in  std_logic_vector(0 downto 0);
        pif_we             : in  std_logic_vector(0 downto 0);
        pif_be             : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
        rdata_2pif         : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        ack_2pif           : out std_logic;  
        mdata_zupacket2pif : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        mdata_zukey2pif    : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
        zu_tdata_cnt_str   : out std_logic;
        zu_tdata_cnt       : out std_logic_vector(7 downto 0);
        zu_tdata           : out std_logic_vector(7 downto 0);
        zu_tvalid          : out std_logic;
        zu_tready          : in  std_logic);
end zu;
