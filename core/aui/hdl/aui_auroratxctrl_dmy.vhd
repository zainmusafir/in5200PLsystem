
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture dmy of aui_auroratxctrl is
begin

  ps_txfifo_rd      <= '0';
  s_axi_tx_tdata    <= (others => '0');
  s_axi_tx_tkeep    <= (others => '0');
  s_axi_tx_tlast    <= '0';
  s_axi_tx_tvalid   <= '0';
  
end dmy;
