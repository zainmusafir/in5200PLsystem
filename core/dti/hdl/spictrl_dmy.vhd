library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture dmy of spictrl is          
begin

  spi_active   <= '0';
  spitxfifo_rd <= '0';
  spirxfifo_wr <= '0';
  spi_rx_data  <= (others => '0');
  spi_wr_data  <= (others => 'Z'); -- NOTE: IMPORTANT that this signal is set
                                   -- til Z. This is required for function set_probe
                                   -- in probe_pkg (or the signal value will be 'U').
  spi_wr_str   <= 'Z'; -- NOTE: IMPORTANT that this signal is set
                       -- til Z. This is required for function set_probe
                       -- in probe_pkg (or the signal value will be 'U').
  spi_rd_str   <= 'Z'; -- NOTE: IMPORTANT that this signal is set
                       -- til Z. This is required for function set_probe
                       -- in probe_pkg (or the signal value will be 'U').   
end dmy;
