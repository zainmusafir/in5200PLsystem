
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aui_aurorarxctrl is
  port (
    -- Clock Signal
    mclk                 : in  std_logic;
    -- Reset Signal. This signal is active HIGH
    rst                  : in  std_logic;
    m_axi_rx_tdata       : in  std_logic_vector(31 downto 0);
    m_axi_rx_tkeep       : in  std_logic_vector(3 downto 0);
    m_axi_rx_tlast       : in  std_logic;
    m_axi_rx_tvalid      : in  std_logic;
    access_loop_ena      : in  std_logic;
    fifo_tx_write_enable : in  std_logic;
    ps_txfifo_count      : in  std_logic_vector(8 downto 0);
    ps_txfifo_data       : in  std_logic_vector(31 downto 0);
    ps_txfifo_data_rd    : out std_logic;
    ps_rxfifo_wr         : out std_logic;
    rx_data              : out std_logic_vector(31 downto 0)
  );  
end aui_aurorarxctrl;

