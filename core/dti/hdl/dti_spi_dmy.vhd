------------ -------------------------- ---------------------------------
--
-- File	   : dti_spi_dmy.vhd
-- Project : MLA
-- Designer: roarsk
--
-- Description: SPI for MAX31723.
--   The sclk is divided by 32; i.e. 100MHz master clock gives approx 3 MHz.
--   Single byte write operation.
--
--------------------------------------------------------------------------
  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture dmy of dti_spi is
  
begin
  
    rdata   <= (others => '0');
    busy    <= '0';
    sdi     <= '0';
    sclk    <= '0';
    ce      <= '0';
    
end dmy;

