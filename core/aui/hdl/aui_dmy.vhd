
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture dmy of aui is
begin

  rdata_aui2pif             <= (others => '0');
--  ack_aui2pif               <= '0';
  ack_aui2pif               <= pif_regcs; -- To avoid AXI4LITE timeout
  mdata_auiaurorarxfifo2pif <= (others => '0');
  rf_txp                    <= '0';
  rf_txn                    <= '1';
  
end architecture dmy;

