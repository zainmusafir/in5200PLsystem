
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.aui_pck.all;

architecture str of aui is

  component aui_reg is
    generic (
      DEBUG_READBACK : boolean);
    port (
      reset                       : out std_logic_vector(0 downto 0);
      aurora_core_status          : in  std_logic_vector(12 downto 0);
      aurora_loopback             : out std_logic_vector(2 downto 0);
      aurora_reset                : out std_logic_vector(0 downto 0);
      aurora_gt_reset             : out std_logic_vector(0 downto 0);
      aurora_ps_txfifo_count      : in  std_logic_vector(8 downto 0);
      aurora_ps_rxfifo_count      : in  std_logic_vector(8 downto 0);
      aurora_fifo_tx_write_enable : out std_logic_vector(0 downto 0);
      aurora_access_loop_ena      : out std_logic_vector(0 downto 0);
      pif_clk                     : in  std_logic;
      pif_rst                     : in  std_logic;
      pif_regcs                   : in  std_logic;
      pif_addr                    : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata                   : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re                      : in  std_logic_vector(0 downto 0);
      pif_we                      : in  std_logic_vector(0 downto 0);
      pif_be                      : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif                  : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif                    : out std_logic
    );
  end component aui_reg;

  component fifo_512x32bit
    port (
      rst           : in  STD_LOGIC;
      wr_clk        : in  STD_LOGIC;
      rd_clk        : in  STD_LOGIC;
      din           : in  STD_LOGIC_VECTOR (31 downto 0);
      wr_en         : in  STD_LOGIC;
      rd_en         : in  STD_LOGIC;
      dout          : out STD_LOGIC_VECTOR (31 downto 0);
      full          : out STD_LOGIC;
      empty         : out STD_LOGIC;
      rd_data_count : out STD_LOGIC_VECTOR (8 downto 0));
  end component;

  component aurora_8b10b_0
    port (
      s_axi_tx_tdata : in std_logic_vector(31 downto 0);
      s_axi_tx_tkeep : in std_logic_vector(3 downto 0);
      s_axi_tx_tlast : in std_logic;
      s_axi_tx_tvalid : in std_logic;
      s_axi_tx_tready : out std_logic;
      m_axi_rx_tdata : out std_logic_vector(31 downto 0);
      m_axi_rx_tkeep : out std_logic_vector(3 downto 0);
      m_axi_rx_tlast : out std_logic;
      m_axi_rx_tvalid : out std_logic;
      hard_err : out std_logic;
      soft_err : out std_logic;
      frame_err : out std_logic;
      channel_up : out std_logic;
      lane_up : out std_logic;
      txp : out std_logic;
      txn : out std_logic;
      reset : in std_logic;
      gt_reset : in std_logic;
      loopback : in std_logic_vector(2 downto 0);
      rxp : in std_logic;
      rxn : in std_logic;
      crc_valid : out std_logic;
      crc_pass_fail_n : out std_logic;
      gt0_drpaddr : in std_logic_vector(9 downto 0);
      gt0_drpen : in std_logic;
      gt0_drpdi : in std_logic_vector(15 downto 0);
      gt0_drprdy : out std_logic;
      gt0_drpdo : out std_logic_vector(15 downto 0);
      gt0_drpwe : in std_logic;
      power_down : in std_logic;
      tx_lock : out std_logic;
      tx_resetdone_out : out std_logic;
      rx_resetdone_out : out std_logic;
      link_reset_out : out std_logic;
      init_clk_in : in std_logic;
      user_clk_out : out std_logic;
      pll_not_locked_out : out std_logic;
      sys_reset_out : out std_logic;
      gt_refclk1_p : in std_logic;
      gt_refclk1_n : in std_logic;
      sync_clk_out : out std_logic;
      gt_reset_out : out std_logic;
      gt_refclk1_out : out std_logic;
      gt_powergood : out std_logic_vector(0 downto 0));
  end component;

  component aui_auroratxctrl is
    port (
      mclk                 : in  std_logic;
      rst                  : in  std_logic;
      access_loop_ena      : in  std_logic;
      fifo_tx_write_enable : in  std_logic;
      ps_txfifo_count      : in  std_logic_vector(8 downto 0);
      ps_txfifo_data       : in  std_logic_vector(31 downto 0);
      ps_txfifo_rd         : out std_logic;
      s_axi_tx_tready      : in  std_logic;
      s_axi_tx_tdata       : out std_logic_vector(31 downto 0);
      s_axi_tx_tkeep       : out std_logic_vector(3 downto 0);
      s_axi_tx_tlast       : out std_logic;
      s_axi_tx_tvalid      : out std_logic);
  end component aui_auroratxctrl;

  component aui_aurorarxctrl is
    port (
      mclk                 : in  std_logic;
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
      rx_data              : out std_logic_vector(31 downto 0));
  end component aui_aurorarxctrl;
  
  signal aui_reset                 : std_logic;
  signal channel_select            : std_logic;
  signal tx_data                   : std_logic_vector(31 downto 0);
  signal rx_data                   : std_logic_vector(31 downto 0);
  signal aurora_fifo_tx_write_enable : std_logic;
  signal aurora_access_loop_ena      : std_logic;
  signal aurora_txfifo_loop_data_rd  : std_logic;
  signal ps_txfifo_rd              : std_logic;
  signal ps_txfifo_rd_final        : std_logic;
  signal ps_rxfifo_wr              : std_logic;
  signal aurora_ps_txfifo_count    : std_logic_vector(8 downto 0);
  signal aurora_ps_rxfifo_count    : std_logic_vector(8 downto 0);
  signal aurora_ps_txfifo_data     : std_logic_vector(31 downto 0);
  signal aurora_ps_rxfifo_data     : std_logic_vector(31 downto 0);

  -- Aurora IP signals
  signal aurora_s_axi_tx_tdata     : std_logic_vector(31 downto 0);
  signal aurora_s_axi_tx_tkeep     : std_logic_vector(3 downto 0);
  signal aurora_s_axi_tx_tlast     : std_logic;
  signal aurora_s_axi_tx_tvalid    : std_logic;
  signal aurora_s_axi_tx_tready    : std_logic;
  signal aurora_m_axi_rx_tdata     : std_logic_vector(31 downto 0);
  signal aurora_m_axi_rx_tkeep     : std_logic_vector(3 downto 0);
  signal aurora_m_axi_rx_tlast     : std_logic;
  signal aurora_m_axi_rx_tvalid    : std_logic;

  signal hard_err           : std_logic;
  signal soft_err           : std_logic;
  signal frame_err          : std_logic;
  signal channel_up         : std_logic;
  signal lane_up            : std_logic;
  signal crc_valid          : std_logic;
  signal crc_pass_fail_n    : std_logic;
  signal tx_lock            : std_logic;
  signal tx_resetdone_out   : std_logic;
  signal rx_resetdone_out   : std_logic;
  signal link_reset_out     : std_logic;
  signal clk_aurora         : std_logic;
  signal pll_not_locked_out : std_logic;
  signal sys_reset_out      : std_logic;
  signal gt_powergood       : std_logic;

  signal aurora_core_status     : std_logic_vector(12 downto 0);  
  signal aurora_core_status_s1  : std_logic_vector(12 downto 0);  
  signal aurora_core_status_s2  : std_logic_vector(12 downto 0);  
  signal aurora_loopback        : std_logic_vector(2 downto 0);  
  signal aurora_loopback_s1     : std_logic_vector(2 downto 0);  
  signal aurora_loopback_s2     : std_logic_vector(2 downto 0);  
  signal aurora_reset           : std_logic;
  signal aurora_reset_s1        : std_logic;
  signal aurora_reset_s2        : std_logic;
  signal aurora_gt_reset        : std_logic;
  signal aurora_gt_reset_s1     : std_logic;
  signal aurora_gt_reset_s2     : std_logic;
  signal rst_aurora_s1          : std_logic;
  signal rst_aurora_s2          : std_logic;
 
begin

  aui_reg_0: aui_reg
    generic map (
      DEBUG_READBACK => PSIF_DEBUG_READBACK_V)
    port map (
      reset(0)                       => aui_reset,
      aurora_core_status             => aurora_core_status_s2, -- Synchronized with mclk
      aurora_loopback                => aurora_loopback,     
      aurora_reset(0)                => aurora_reset,    
      aurora_gt_reset(0)             => aurora_gt_reset, 
      aurora_ps_txfifo_count         => aurora_ps_txfifo_count, 
      aurora_ps_rxfifo_count         => aurora_ps_rxfifo_count, 
      aurora_fifo_tx_write_enable(0) => aurora_fifo_tx_write_enable,
      aurora_access_loop_ena(0)      => aurora_access_loop_ena,
      pif_clk                        => mclk,
      pif_rst                        => rst,
      pif_regcs                      => pif_regcs,
      pif_addr                       => pif_addr,
      pif_wdata                      => pif_wdata,
      pif_re                         => pif_re,
      pif_we                         => pif_we,
      pif_be                         => pif_be,
      rdata_2pif                     => rdata_aui2pif,
      ack_2pif                       => ack_aui2pif
    );

  aurora_8b10b_0_inst: aurora_8b10b_0
    port map (
      s_axi_tx_tdata     => aurora_s_axi_tx_tdata,
      s_axi_tx_tkeep     => aurora_s_axi_tx_tkeep,
      s_axi_tx_tlast     => aurora_s_axi_tx_tlast,
      s_axi_tx_tvalid    => aurora_s_axi_tx_tvalid,
      s_axi_tx_tready    => aurora_s_axi_tx_tready,
      m_axi_rx_tdata     => aurora_m_axi_rx_tdata,
      m_axi_rx_tkeep     => aurora_m_axi_rx_tkeep,
      m_axi_rx_tlast     => aurora_m_axi_rx_tlast,
      m_axi_rx_tvalid    => aurora_m_axi_rx_tvalid,
      hard_err           => hard_err,
      soft_err           => soft_err,
      frame_err          => frame_err,
      channel_up         => channel_up,
      lane_up            => lane_up,
      txp                => rf_txp,
      txn                => rf_txn,
      reset              => aurora_reset_s2,
      gt_reset           => aurora_gt_reset_s2,
      loopback           => aurora_loopback_s2,
      rxp                => rf_rxp,
      rxn                => rf_rxn,
      crc_valid          => crc_valid,
      crc_pass_fail_n    => crc_pass_fail_n,
      gt0_drpaddr        => (others => '0'),
      gt0_drpen          => '0',
      gt0_drpdi          => (others => '0'),
      gt0_drprdy         => open, 
      gt0_drpdo          => open,
      gt0_drpwe          => '0',
      power_down         => '0',
      tx_lock            => tx_lock,
      tx_resetdone_out   => tx_resetdone_out,
      rx_resetdone_out   => rx_resetdone_out,
      link_reset_out     => link_reset_out,
      init_clk_in        => clk_62m5,
      user_clk_out       => clk_aurora,
      pll_not_locked_out => pll_not_locked_out,
      sys_reset_out      => sys_reset_out,
      gt_refclk1_p       => rf_gt_refclk1_p,
      gt_refclk1_n       => rf_gt_refclk1_n,
      sync_clk_out       => open,
      gt_reset_out       => open,
      gt_refclk1_out     => open,
      gt_powergood(0)    => gt_powergood
  );

  aui_auroratxctrl_0: aui_auroratxctrl
    port map (
      mclk                 => clk_aurora,
      rst                  => rst_aurora_s2,
      access_loop_ena      => aurora_access_loop_ena,
      fifo_tx_write_enable => aurora_fifo_tx_write_enable,
      ps_txfifo_count      => aurora_ps_txfifo_count,
      ps_txfifo_data       => aurora_ps_txfifo_data,
      ps_txfifo_rd         => ps_txfifo_rd,
      s_axi_tx_tready      => aurora_s_axi_tx_tready,
      s_axi_tx_tdata       => aurora_s_axi_tx_tdata,
      s_axi_tx_tkeep       => aurora_s_axi_tx_tkeep,
      s_axi_tx_tlast       => aurora_s_axi_tx_tlast,
      s_axi_tx_tvalid      => aurora_s_axi_tx_tvalid);

  aui_aurora_ps_txfifo_512x32bit: fifo_512x32bit
    port map (
      rst           => rst_aurora_s2,
      wr_clk        => pif_clk,
      rd_clk        => clk_aurora,
      din           => pif_wdata,
      wr_en         => pif_we(0) and pif_memcs(PSIF_MEMSEL_AUIAURORATXFIFO),
      rd_en         => ps_txfifo_rd_final,
      dout          => aurora_ps_txfifo_data,
      full          => open,
      empty         => open,
      rd_data_count => aurora_ps_txfifo_count);
  
  aui_aurorarxctrl_0: aui_aurorarxctrl
    port map (
      mclk                 => clk_aurora,
      rst                  => rst_aurora_s2,
      m_axi_rx_tdata       => aurora_m_axi_rx_tdata,
      m_axi_rx_tkeep       => aurora_m_axi_rx_tkeep,
      m_axi_rx_tlast       => aurora_m_axi_rx_tlast,
      m_axi_rx_tvalid      => aurora_m_axi_rx_tvalid,
      access_loop_ena      => aurora_access_loop_ena,
      fifo_tx_write_enable => aurora_fifo_tx_write_enable,
      ps_txfifo_count      => aurora_ps_txfifo_count,
      ps_txfifo_data       => aurora_ps_txfifo_data,    
      ps_txfifo_data_rd    => aurora_txfifo_loop_data_rd, 
      ps_rxfifo_wr         => ps_rxfifo_wr,
      rx_data              => aurora_ps_rxfifo_data);
  
  aui_aurora_ps_rxfifo_512x32bit: fifo_512x32bit
    port map (
      rst           => rst_aurora_s2,
      wr_clk        => clk_aurora,
      rd_clk        => pif_clk,
      din           => aurora_ps_rxfifo_data,
      wr_en         => ps_rxfifo_wr,
      rd_en         => pif_re(0) and pif_memcs(PSIF_MEMSEL_AUIAURORARXFIFO),
      dout          => mdata_auiaurorarxfifo2pif,
      full          => open,
      empty         => open,
      rd_data_count => aurora_ps_rxfifo_count);
  
  -- Synchronize Aurora IP Core Status signals
  P_AURORA_CORE_STATUS_SYNCH: process (rst, mclk)
  begin
    if (rst='1' or aui_reset = '1') then
      aurora_core_status_s1 <= (others => '0');
      aurora_core_status_s2 <= (others => '0');
    elsif rising_edge(mclk) then
      aurora_core_status_s1 <= aurora_core_status;  
      aurora_core_status_s2 <= aurora_core_status_s1;  
    end if;
  end process P_AURORA_CORE_STATUS_SYNCH;

  -- Synchronize Aurora IP input signal and GT reset signal
  P_AURORA_CORE_INPUT_SYNCH_INIT_CLK: process (rst, clk_62m5)
  begin
    if (rst='1' or aui_reset='1') then
      aurora_gt_reset_s1 <= '1';
      aurora_gt_reset_s2 <= '1';
    elsif rising_edge(clk_62m5) then
      aurora_gt_reset_s1 <= aurora_gt_reset;  
      aurora_gt_reset_s2 <= aurora_gt_reset_s1;  
    end if;
  end process P_AURORA_CORE_INPUT_SYNCH_INIT_CLK;
  
  -- Synchronize Aurora IP reset signal
  P_AURORA_CORE_INPUT_SYNCH_USER_CLK: process (rst, clk_aurora)
  begin
    if (rst='1' or aui_reset='1') then
      aurora_reset_s1 <= '1';
      aurora_reset_s2 <= '1';
    elsif rising_edge(clk_aurora) then
      aurora_reset_s1 <= aurora_reset;  
      aurora_reset_s2 <= aurora_reset_s1;  
    end if;
  end process P_AURORA_CORE_INPUT_SYNCH_USER_CLK;
  
  -- Synchronize reset signal to Aurora IP Core clock signal
  P_AURORA_CORE_RST_SYNCH: process (rst, clk_aurora)
  begin
    if (rst='1' or aui_reset='1') then
      rst_aurora_s1 <= '1';
      rst_aurora_s2 <= '1';
      aurora_loopback_s1 <= (others => '0');
      aurora_loopback_s2 <= (others => '0');
    elsif rising_edge(clk_aurora) then
      rst_aurora_s1 <= '0';  
      rst_aurora_s2 <= rst_aurora_s1;  
      aurora_loopback_s1 <= aurora_loopback;  
      aurora_loopback_s2 <= aurora_loopback_s1;  
    end if;
  end process P_AURORA_CORE_RST_SYNCH;

  -- Concurrent Aurora statements  
  aurora_core_status(0)  <= channel_up;
  aurora_core_status(1)  <= crc_pass_fail_n;
  aurora_core_status(2)  <= crc_valid;
  aurora_core_status(3)  <= frame_err;
  aurora_core_status(4)  <= hard_err;
  aurora_core_status(5)  <= lane_up;
  aurora_core_status(6)  <= pll_not_locked_out;
  aurora_core_status(7)  <= rx_resetdone_out;
  aurora_core_status(8)  <= soft_err;
  aurora_core_status(9)  <= tx_lock;
  aurora_core_status(10) <= tx_resetdone_out;
  aurora_core_status(11) <= link_reset_out;
  aurora_core_status(12) <= gt_powergood;

  -- Aurora PS TX FIFO can be read to loop the data back to the Aurora PS RX FIFO
  ps_txfifo_rd_final <= ps_txfifo_rd or aurora_txfifo_loop_data_rd;
  
  -- Concurrent assignments
  -- TBD
  
end architecture str;

