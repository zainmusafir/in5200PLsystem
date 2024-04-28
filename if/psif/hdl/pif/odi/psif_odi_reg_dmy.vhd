
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture dmy of odi_reg is
begin

   oled_init_str <= (others => '0');
   rdata_2pif	 <= (others => '0');
   ack_2pif      <= '0';

end dmy;
