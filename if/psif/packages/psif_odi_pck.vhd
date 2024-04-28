
library ieee;
use ieee.std_logic_1164.all;

package odi_pck is

  -- ODI MODULE --


  -- Register addresses
  constant ODI_OLEDBYTE3_0                              : std_logic_vector(31 downto 0) := x"00000060";  -- RW U32,32
  constant ODI_OLEDBYTE7_4                              : std_logic_vector(31 downto 0) := x"00000064";  -- RW U32,32
  constant ODI_OLEDBYTE11_8                             : std_logic_vector(31 downto 0) := x"00000068";  -- RW U32,32
  constant ODI_OLEDBYTE15_12                            : std_logic_vector(31 downto 0) := x"0000006C";  -- RW U32,32
  constant ODI_PS_ACCESS_ENA                            : std_logic_vector(31 downto 0) := x"00000088";  -- RW U8,1

end odi_pck;
