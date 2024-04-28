
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aui_auroratxctrl is
  port (
    -- Clock Signal
    mclk                 : in  std_logic;
    -- Reset Signal. This signal is active HIGH
    rst                  : in  std_logic;
    access_loop_ena      : in  std_logic;
    fifo_tx_write_enable : in  std_logic;
    ps_txfifo_count      : in  std_logic_vector(8 downto 0);
    ps_txfifo_data       : in  std_logic_vector(31 downto 0);
    ps_txfifo_rd         : out std_logic;
    irq_ps_tx_sent       : out std_logic;
    s_axi_tx_tready      : in  std_logic;
    s_axi_tx_tdata       : out std_logic_vector(31 downto 0);
    s_axi_tx_tkeep       : out std_logic_vector(3 downto 0);
    s_axi_tx_tlast       : out std_logic;
    s_axi_tx_tvalid      : out std_logic
  );  
end aui_auroratxctrl;

