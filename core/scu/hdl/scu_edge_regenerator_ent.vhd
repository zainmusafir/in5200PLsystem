
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scu_edge_regenerator is
  port (
    -- Fast reset and clock signals
    rst_fast        : in  std_logic;
    clk_fast        : in  std_logic;

    -- Fast clock strobe signal
    ena_fastclk_str : in  std_logic;
    
    -- Slow reset and clock signals
    rst_slow        : in  std_logic;
    clk_slow        : in  std_logic;

    -- Slow clock strobe signal
    ena_slowclk_str : out  std_logic
  );
end scu_edge_regenerator;

