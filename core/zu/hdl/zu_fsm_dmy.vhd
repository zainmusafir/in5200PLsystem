
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.zu_pck.all;

architecture dmy of zu_fsm is

begin

    done                 <= '1';
    zu_tdata_cnt_str     <= '0';
    zu_tdata_cnt         <= (others => '0'); 
    inv_chiper_rst_n     <= '1';
    inv_chiper_start_str <= '0';

end dmy;
