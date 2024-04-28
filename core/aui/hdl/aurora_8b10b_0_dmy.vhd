library ieee;
use ieee.std_logic_1164.all;

entity aurora_8b10b_0 is
  port (
    s_axi_tx_tdata : in std_logic_vector ( 31 downto 0 );
    s_axi_tx_tkeep : in std_logic_vector ( 3 downto 0 );
    s_axi_tx_tvalid : in std_logic;
    s_axi_tx_tlast : in std_logic;
    s_axi_tx_tready : out std_logic;
    m_axi_rx_tdata : out std_logic_vector ( 31 downto 0 );
    m_axi_rx_tkeep : out std_logic_vector ( 3 downto 0 );
    m_axi_rx_tvalid : out std_logic;
    m_axi_rx_tlast : out std_logic;
    rxp : in std_logic;
    rxn : in std_logic;
    txp : out std_logic;
    txn : out std_logic;
    gt_refclk1_p : in std_logic;
    gt_refclk1_n : in std_logic;
    gt_refclk1_out : out std_logic;
    frame_err : out std_logic;
    hard_err : out std_logic;
    soft_err : out std_logic;
    lane_up : out std_logic;
    channel_up : out std_logic;
    crc_pass_fail_n : out std_logic;
    crc_valid : out std_logic;
    user_clk_out : out std_logic;
    sync_clk_out : out std_logic;
    gt_reset : in std_logic;
    reset : in std_logic;
    sys_reset_out : out std_logic;
    gt_reset_out : out std_logic;
    power_down : in std_logic;
    loopback : in std_logic_vector ( 2 downto 0 );
    tx_lock : out std_logic;
    init_clk_in : in std_logic;
    tx_resetdone_out : out std_logic;
    rx_resetdone_out : out std_logic;
    link_reset_out : out std_logic;
    gt0_drpaddr : in std_logic_vector ( 9 downto 0 );
    gt0_drpdi : in std_logic_vector ( 15 downto 0 );
    gt0_drpdo : out std_logic_vector ( 15 downto 0 );
    gt0_drpen : in std_logic;
    gt0_drprdy : out std_logic;
    gt0_drpwe : in std_logic;
    gt_powergood : out std_logic_vector ( 0 to 0 );
    pll_not_locked_out : out std_logic
  );
end aurora_8b10b_0;

architecture dmy of aurora_8b10b_0 is
begin
  
  s_axi_tx_tready <= '0';
  m_axi_rx_tdata <= (others => '0');
  m_axi_rx_tkeep <= (others => '0');
  m_axi_rx_tvalid <= '0';
  m_axi_rx_tlast <= '0';
  txp <= '0';
  txn <= '1';
  gt_refclk1_out <= '0';
  frame_err <= '0';
  hard_err <= '1';
  soft_err <= '1';
  lane_up <= '0';
  channel_up <= '0';
  crc_pass_fail_n <= '0';
  crc_valid <= '0';
  user_clk_out <= '0';
  sync_clk_out <= '0';
  sys_reset_out <= '0';
  gt_reset_out <= '0';
  tx_lock <= '0';
  tx_resetdone_out <= '0';
  rx_resetdone_out <= '0';
  link_reset_out <= '0';
  gt0_drpdo <= (others => '0');
  gt0_drprdy <= '0';
  gt_powergood <= (others => '1');
  pll_not_locked_out <= '1';

end dmy;
