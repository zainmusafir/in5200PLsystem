
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of scu_edge_regenerator is

  signal ena_level      : std_logic;
  signal ena_level_s1   : std_logic;
  signal ena_level_s2   : std_logic;
  signal ena_level_next : std_logic;
  
begin

  P_FAST_DOMAIN: process(rst_fast, clk_fast) is
  begin

    -- TBD

  end process P_FAST_DOMAIN;

  P_SLOW_DOMAIN: process(rst_slow, clk_slow) is
  begin

    -- TBD
    
  end process P_SLOW_DOMAIN;

  -- Concurrent signal assignment
  -- NOTE: Slow clock domain
  ena_slowclk_str <= ena_level_next xor ena_level_s2;  

end rtl;
