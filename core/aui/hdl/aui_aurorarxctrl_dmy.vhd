
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture dmy of aui_aurorarxctrl is
begin

  ps_txfifo_data_rd   <= '0';
  ps_rxfifo_wr        <= '0';
  rx_data             <= (others => '0');
  
end dmy;
