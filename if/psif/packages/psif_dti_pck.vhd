
library ieee;
use ieee.std_logic_1164.all;

package dti_pck is

  -- DTI MODULE --


  -- Register addresses
  constant DTI_SPI_FIFO_TX_WRITE_ENABLE                 : std_logic_vector(31 downto 0) := x"00000060";  -- RW U8,1
  constant DTI_SPI_ACTIVE                               : std_logic_vector(31 downto 0) := x"00000064";  -- RO U8,1
  constant DTI_SPI_TX_FIFO_COUNT                        : std_logic_vector(31 downto 0) := x"00000068";  -- RO U16,9
  constant DTI_SPI_RX_FIFO_COUNT                        : std_logic_vector(31 downto 0) := x"0000006C";  -- RO U16,9
  constant DTI_SPI_LOOP_ENA                             : std_logic_vector(31 downto 0) := x"00000070";  -- RW U8,1
  constant DTI_SPI_PS_ACCESS_ENA                        : std_logic_vector(31 downto 0) := x"00000074";  -- RW U8,1

end dti_pck;
