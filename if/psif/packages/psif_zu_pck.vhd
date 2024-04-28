
library ieee;
use ieee.std_logic_1164.all;

package zu_pck is

  -- ZU MODULE --


  -- Register addresses
  constant ZU_DECRYPTION_BYPASS                         : std_logic_vector(31 downto 0) := x"00000000";  -- RW U8,1
  constant ZU_START_DECRYPTION                          : std_logic_vector(31 downto 0) := x"00000004";  -- WS U8,1
  constant ZU_DONE_DECRYPTION                           : std_logic_vector(31 downto 0) := x"00000008";  -- RO U8,1
  constant ZU_FSM_RST                                   : std_logic_vector(31 downto 0) := x"0000000C";  -- RW U8,1

end zu_pck;
