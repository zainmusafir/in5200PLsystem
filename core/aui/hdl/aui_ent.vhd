
library ieee;
use ieee.std_logic_1164.all;

library psif_lib;
use psif_lib.psif_pck.all;

entity aui is
  port(
    -- Master clock and reset
    mclk              : in  std_logic;                         -- Master clock
    rst               : in  std_logic;                         -- Master reset, asynch
    clk_62m5          : in  std_logic;                         -- 62.5 MHz clock used as Aurora IP init_clk_in

    -- AXI4 clock and reset needed for RAM access
    pif_clk           : in  std_logic;                         -- AXI clock
    pif_rst           : in  std_logic;                         -- AXI Reset

    -- Register and memory access from black CPU
    pif_addr          : in  std_logic_vector(31 downto 0);     -- Memory address 
    pif_be            : in  std_logic_vector(3 downto 0);      -- Write byte enable
    pif_re            : in  std_logic_vector(0 downto 0);      -- Read enable strobe
    pif_regcs         : in  std_logic;                         -- Module select      
    pif_wdata         : in  std_logic_vector(31 downto 0);     -- Register/Memory data
    pif_we            : in  std_logic_vector(0 downto 0);      -- Write enable strobe
    rdata_aui2pif     : out std_logic_vector(31 downto 0);     -- Register Read Data
    ack_aui2pif       : out std_logic;                         -- Read access acknowledge

    -- Memory chip select and read data
    pif_memcs             : in  std_logic_vector(PSIF_MEMSEL_AUIAURORARXFIFO downto PSIF_MEMSEL_AUIAURORATXFIFO);  -- Memory chip selects
    mdata_auiaurorarxfifo2pif : out std_logic_vector(31 downto 0); -- Aurora read data

    -- Aurora IP interface signals
    rf_gt_refclk1_p   : in  std_logic;                         -- Aurora IP ref clock p signal
    rf_gt_refclk1_n   : in  std_logic;                         -- Aurora IP ref clock n signal
    rf_rxp            : in  std_logic;                         -- Aurora IP rxp signal
    rf_rxn            : in  std_logic;                         -- Aurora IP rxn signal 
    rf_txp            : out std_logic;                         -- Aurora IP txp signal 
    rf_txn            : out std_logic                          -- Aurora IP txn signal 
  );
  
end aui;

