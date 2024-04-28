
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture dmy of psif_axi4pifb is
begin
    s_axi_awready <= '0';
    s_axi_wready  <= '0';
    s_axi_bresp   <= (others => '0');
    s_axi_bvalid  <= '0';
    s_axi_arready <= '0';
    s_axi_rdata   <= (others => '0');
    s_axi_rresp   <= (others => '0');
    s_axi_rvalid  <= '0';

    pif_regcs     <= (others => '0');
    pif_memcs     <= (others => '0');
    pif_addr      <= (others => '0');
    pif_wdata     <= (others => '0');
    pif_re	      <= (others => '0');
    pif_we	      <= (others => '0');
    pif_be	      <= (others => '0');
  
end dmy;
