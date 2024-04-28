
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.zu_pck.all;

entity zu_fsm is
  port (
    -- Clock signal
    mclk                 : in  std_logic;
    -- Reset signal. This signal is active HIGH
    rst                  : in  std_logic;
    -- KDF register signals
    fsm_rst              : in  std_logic;
    start_str            : in  std_logic;
    done                 : out std_logic;
    -- Chiper IP data count 
    zu_tdata_cnt_str     : out std_logic;
    zu_tdata_cnt         : out std_logic_vector(7 downto 0);
    -- Chiper IP signals
    inv_chiper_rst_n     : out std_logic;
    inv_chiper_start_str : out std_logic;
    inv_chiper_tvalid    : in  std_logic;
    inv_chiper_tready    : in  std_logic;
    inv_chiper_done_str  : in  std_logic;
    inv_chiper_idle      : in  std_logic
  );
end zu_fsm;
