-------------------------------------------------------------------------------
-- File        : $HOME/IN5200_INF5430/IN5200_lab/lab_H20/lab_answer/core/hdl
-- Author      : Roar Skogstrom
-- Company     : UiO
-- Created     : 2019-08-01
-- Standard    : VHDL 2008
-------------------------------------------------------------------------------
-- Description : 
--   Core PL module for Master Lab Answer (MLA) FPGA.
-------------------------------------------------------------------------------
-- Revisions   :
-- Date        Version  Author  Description
-- 2019-08-01  1.0      roarsk  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library mla_lib;
--use mla_lib.revision_pck.all;

library psif_lib;
use psif_lib.psif_pck.all;
use psif_lib.odi_pck.all;
use psif_lib.dti_pck.all;

architecture str of core is

  ----------------------------
  -- Component declarations --
  ----------------------------
  
  component psif_axi4pifb is
    generic (
      PIF_DATA_WIDTH     : integer;
      PIF_ADDR_WIDTH     : integer;
      C_S_AXI_DATA_WIDTH : integer;
      C_S_AXI_ADDR_WIDTH : integer);
    port (
      s_axi_aclk    : in  std_logic;
      s_axi_areset  : in  std_logic;
      s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_awprot  : in  std_logic_vector(2 downto 0);
      s_axi_awvalid : in  std_logic;
      s_axi_awready : out std_logic;
      s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      s_axi_wvalid  : in  std_logic;
      s_axi_wready  : out std_logic;
      s_axi_bresp   : out std_logic_vector(1 downto 0);
      s_axi_bvalid  : out std_logic;
      s_axi_bready  : in  std_logic;
      s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_arprot  : in  std_logic_vector(2 downto 0);
      s_axi_arvalid : in  std_logic;
      s_axi_arready : out std_logic;
      s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in  std_logic;
      pif_regcs     : out std_logic_vector(31 downto 0);
      pif_memcs     : out std_logic_vector(31 downto 0);
      pif_addr      : out std_logic_vector(PIF_ADDR_WIDTH-1 downto 0);
      pif_wdata     : out std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      pif_re        : out std_logic_vector(0 downto 0);
      pif_we        : out std_logic_vector(0 downto 0);
      pif_be        : out std_logic_vector((PIF_DATA_WIDTH/8)-1 downto 0);
      rdata_odi2pif : in  std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      ack_odi2pif   : in  std_logic;
      rdata_dti2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      ack_dti2pif   : in std_logic;
      rdata_zu2pif  : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      ack_zu2pif    : in std_logic;
      rdata_scu2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      ack_scu2pif   : in std_logic;
      rdata_aui2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      ack_aui2pif   : in std_logic;
      mdata_dtispirxfifo2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      mdata_zupacket2pif     : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
      mdata_zukey2pif        : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);    
      mdata_auiaurorarxfifo2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0));    
  end component psif_axi4pifb;

  component odi is
    generic (
      SIMULATION_MODE : string);
    port (
      mclk              : in  std_logic;
      rst               : in  std_logic;
      pif_regcs         : in  std_logic;
      pif_addr          : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata         : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re            : in  std_logic_vector(0 downto 0);
      pif_we            : in  std_logic_vector(0 downto 0);
      pif_be            : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif        : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif          : out std_logic;
      odi_oledbyte3_0   : in  std_logic_vector(31 downto 0);
      odi_oledbyte7_4   : in  std_logic_vector(31 downto 0);
      odi_oledbyte11_8  : in  std_logic_vector(31 downto 0);
      odi_oledbyte15_12 : in  std_logic_vector(31 downto 0);
      oled_sdin         : out std_logic;
      oled_sclk         : out std_logic;
      oled_dc           : out std_logic;
      oled_res          : out std_logic;
      oled_vbat         : out std_logic;
      oled_vdd          : out std_logic);
  end component odi;

  component dti is
    port (
      mclk                   : in  std_logic;
      rst                    : in  std_logic;
      pif_clk                : in  std_logic;
      pif_rst                : in  std_logic;
      pif_regcs              : in  std_logic;
      pif_memcs              : in  std_logic_vector(1 downto 0);
      pif_addr               : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata              : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re                 : in  std_logic_vector(0 downto 0);
      pif_we                 : in  std_logic_vector(0 downto 0);
      pif_be                 : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif             : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif               : out std_logic;
      mdata_dtispirxfifo2pif : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      dti_spi_instruction    : in  std_logic_vector(15 downto 0);
      dti_spi_rd_str         : in  std_logic;
      dti_spi_busy           : out std_logic;
      dti_spi_rdata          : out std_logic_vector(7 downto 0);
      dti_ce                 : out std_logic;
      dti_sclk               : out std_logic;
      dti_sdi                : out std_logic;
      dti_sdo                : in  std_logic);
  end component dti;

  component zu is
    port (
      mclk               : in  std_logic;
      rst                : in  std_logic;
      pif_clk            : in  std_logic;
      pif_rst            : in  std_logic;
      pif_regcs          : in  std_logic;
      pif_memcs          : in  std_logic_vector(1 downto 0);
      pif_addr           : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata          : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re             : in  std_logic_vector(0 downto 0);
      pif_we             : in  std_logic_vector(0 downto 0);
      pif_be             : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif         : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif           : out std_logic;
      mdata_zupacket2pif : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      mdata_zukey2pif    : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      zu_tdata_cnt_str   : out std_logic;
      zu_tdata_cnt       : out std_logic_vector(7 downto 0);
      zu_tdata           : out std_logic_vector(7 downto 0);
      zu_tvalid          : out std_logic;
      zu_tready          : in  std_logic);
  end component zu;

  component scu is
    generic (
      SIMULATION_MODE : string);
    port (
      mclk                : in  std_logic;
      rst                 : in  std_logic;
      pif_regcs           : in  std_logic;
      pif_addr            : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata           : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re              : in  std_logic_vector(0 downto 0);
      pif_we              : in  std_logic_vector(0 downto 0);
      pif_be              : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif          : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif            : out std_logic;
      dti_spi_instruction : out std_logic_vector(15 downto 0);
      dti_spi_rd_str      : out std_logic;
      dti_spi_busy        : in  std_logic;
      dti_spi_rdata       : in  std_logic_vector(7 downto 0);
      zu_tdata_cnt_str    : in  std_logic;
      zu_tdata_cnt        : in  std_logic_vector(7 downto 0);
      zu_tdata            : in  std_logic_vector(7 downto 0);
      zu_tvalid           : in  std_logic;
      zu_tready           : out std_logic;
      odi_oledbyte3_0     : out std_logic_vector(31 downto 0);
      odi_oledbyte7_4     : out std_logic_vector(31 downto 0);
      odi_oledbyte11_8    : out std_logic_vector(31 downto 0);
      odi_oledbyte15_12   : out std_logic_vector(31 downto 0);
      led_alarm           : out std_logic;
      alarm_ack_btn       : in  std_logic);
  end component scu;

  component aui is
    port (
      mclk                      : in  std_logic;
      rst                       : in  std_logic;
      clk_62m5                  : in  std_logic;
      pif_clk                   : in  std_logic;
      pif_rst                   : in  std_logic;
      pif_addr                  : in  std_logic_vector(31 downto 0);
      pif_be                    : in  std_logic_vector(3 downto 0);
      pif_re                    : in  std_logic_vector(0 downto 0);
      pif_regcs                 : in  std_logic;
      pif_wdata                 : in  std_logic_vector(31 downto 0);
      pif_we                    : in  std_logic_vector(0 downto 0);
      rdata_aui2pif             : out std_logic_vector(31 downto 0);
      ack_aui2pif               : out std_logic;
      pif_memcs                 : in  std_logic_vector(PSIF_MEMSEL_AUIAURORARXFIFO downto PSIF_MEMSEL_AUIAURORATXFIFO);
      mdata_auiaurorarxfifo2pif : out std_logic_vector(31 downto 0);
      rf_gt_refclk1_p           : in  std_logic;
      rf_gt_refclk1_n           : in  std_logic;
      rf_rxp                    : in  std_logic;
      rf_rxn                    : in  std_logic;
      rf_txp                    : out std_logic;
      rf_txn                    : out std_logic);
  end component aui;

  component ila_scu
  port (
	clk : in std_logic;
	probe0 : in std_logic_vector(31 downto 0); 
	probe1 : in std_logic_vector(31 downto 0); 
	probe2 : in std_logic_vector(31 downto 0); 
	probe3 : in std_logic_vector(31 downto 0); 
	probe4 : in std_logic_vector(0 downto 0); 
	probe5 : in std_logic_vector(0 downto 0); 
	probe6 : in std_logic_vector(3 downto 0); 
	probe7 : in std_logic_vector(31 downto 0);
	probe8 : in std_logic_vector(0 downto 0)
      );
  end component;  

  signal pif_regcs     : std_logic_vector(31 downto 0);
  signal pif_memcs     : std_logic_vector(31 downto 0);
  signal pif_addr      : std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
  signal pif_wdata     : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal pif_re        : std_logic_vector(0 downto 0);
  signal pif_we        : std_logic_vector(0 downto 0);
  signal pif_be        : std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);

  signal rdata_odi2pif          : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal ack_odi2pif            : std_logic;
  signal rdata_dti2pif          : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal ack_dti2pif            : std_logic;
  signal mdata_dtispirxfifo2pif : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);    
  signal rdata_zu2pif           : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal ack_zu2pif             : std_logic;
  signal mdata_zupacket2pif     : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);    
  signal mdata_zukey2pif        : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);    
  signal rdata_scu2pif          : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal ack_scu2pif            : std_logic;
  signal rdata_aui2pif          : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
  signal ack_aui2pif            : std_logic;
  signal mdata_auiaurorarxfifo2pif : std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);    

  signal dti_spi_instruction : std_logic_vector (15 downto 0);
  signal dti_spi_rd_str      : std_logic;
  signal dti_spi_busy        : std_logic;
  signal dti_spi_rdata       : std_logic_vector (7 downto 0);
  signal zu_tdata            : std_logic_vector (7 downto 0);
  signal zu_tvalid           : std_logic;
  signal zu_tready           : std_logic;
  signal odi_oledbyte3_0     : std_logic_vector(31 downto 0);
  signal odi_oledbyte7_4     : std_logic_vector(31 downto 0);
  signal odi_oledbyte11_8    : std_logic_vector(31 downto 0);
  signal odi_oledbyte15_12   : std_logic_vector(31 downto 0);
  signal zu_tdata_cnt_str    : std_logic;
  signal zu_tdata_cnt        : std_logic_vector(7 downto 0);

begin

  psif_axi4pifb_0: psif_axi4pifb
    generic map (
      PIF_DATA_WIDTH     => PSIF_DATA_LENGTH,
      PIF_ADDR_WIDTH     => PSIF_ADDRESS_LENGTH,
      C_S_AXI_DATA_WIDTH => PSIF_DATA_LENGTH,
      C_S_AXI_ADDR_WIDTH => PSIF_ADDRESS_LENGTH)
    port map (
      s_axi_aclk    => psif_axi_aclk,
      s_axi_areset  => psif_axi_areset,
      s_axi_awaddr  => psif_axi_awaddr,
      s_axi_awprot  => psif_axi_awprot,
      s_axi_awvalid => psif_axi_awvalid,
      s_axi_awready => psif_axi_awready,
      s_axi_wdata   => psif_axi_wdata,
      s_axi_wstrb   => psif_axi_wstrb,
      s_axi_wvalid  => psif_axi_wvalid,
      s_axi_wready  => psif_axi_wready,
      s_axi_bresp   => psif_axi_bresp,
      s_axi_bvalid  => psif_axi_bvalid,
      s_axi_bready  => psif_axi_bready,
      s_axi_araddr  => psif_axi_araddr,
      s_axi_arprot  => psif_axi_arprot,
      s_axi_arvalid => psif_axi_arvalid,
      s_axi_arready => psif_axi_arready,
      s_axi_rdata   => psif_axi_rdata,
      s_axi_rresp   => psif_axi_rresp,
      s_axi_rvalid  => psif_axi_rvalid,
      s_axi_rready  => psif_axi_rready,
      pif_regcs     => pif_regcs,
      pif_memcs     => pif_memcs,
      pif_addr      => pif_addr,
      pif_wdata     => pif_wdata,
      pif_re        => pif_re,
      pif_we        => pif_we,
      pif_be        => pif_be,    
      rdata_odi2pif => rdata_odi2pif,
      ack_odi2pif   => ack_odi2pif,
      rdata_dti2pif => rdata_dti2pif,          
      ack_dti2pif   => ack_dti2pif,
      rdata_zu2pif  => rdata_zu2pif,  
      ack_zu2pif    => ack_zu2pif,
      rdata_scu2pif => rdata_scu2pif,
      ack_scu2pif   => ack_scu2pif,
      rdata_aui2pif => rdata_aui2pif,
      ack_aui2pif   => ack_aui2pif,
      mdata_dtispirxfifo2pif => mdata_dtispirxfifo2pif,
      mdata_zupacket2pif     => mdata_zupacket2pif,
      mdata_zukey2pif        => mdata_zukey2pif,
      mdata_auiaurorarxfifo2pif => mdata_auiaurorarxfifo2pif);

  odi_0: odi
    generic map (
      SIMULATION_MODE => SIMULATION_MODE)
    port map (
      mclk              => mclk,
      rst               => rst,
      pif_regcs         => pif_regcs(PSIF_REGSEL_ODI),
      pif_addr          => pif_addr,
      pif_wdata         => pif_wdata,
      pif_re            => pif_re,
      pif_we            => pif_we,
      pif_be            => pif_be,
      rdata_2pif        => rdata_odi2pif,
      ack_2pif          => ack_odi2pif,
      odi_oledbyte3_0   => odi_oledbyte3_0,    
      odi_oledbyte7_4   => odi_oledbyte7_4,   
      odi_oledbyte11_8  => odi_oledbyte11_8,  
      odi_oledbyte15_12 => odi_oledbyte15_12,      
      oled_sdin         => oled_sdin,
      oled_sclk         => oled_sclk,
      oled_dc           => oled_dc,
      oled_res          => oled_res,
      oled_vbat         => oled_vbat,
      oled_vdd          => oled_vdd);

  dti_0: dti
    port map (
      mclk                   => mclk,
      rst                    => rst,
      pif_clk                => psif_axi_aclk,  
      pif_rst                => psif_axi_areset,
      pif_regcs              => pif_regcs(PSIF_REGSEL_DTI),
      pif_memcs              => pif_memcs(PSIF_MEMSEL_DTISPIRXFIFO downto PSIF_MEMSEL_DTISPITXFIFO),
      pif_addr               => pif_addr,
      pif_wdata              => pif_wdata,
      pif_re                 => pif_re,
      pif_we                 => pif_we,
      pif_be                 => pif_be,
      rdata_2pif             => rdata_dti2pif,
      ack_2pif               => ack_dti2pif,
      mdata_dtispirxfifo2pif => mdata_dtispirxfifo2pif,
      dti_spi_instruction    => dti_spi_instruction,
      dti_spi_rd_str         => dti_spi_rd_str,
      dti_spi_busy           => dti_spi_busy,
      dti_spi_rdata          => dti_spi_rdata,    
      dti_ce                 => dti_ce,
      dti_sclk               => dti_sclk,
      dti_sdi                => dti_sdi,
      dti_sdo                => dti_sdo);

  zu_0: zu
    port map (
      mclk               => mclk,
      rst                => rst,
      pif_clk            => psif_axi_aclk,
      pif_rst            => psif_axi_areset,
      pif_regcs          => pif_regcs(PSIF_REGSEL_ZU),
      pif_memcs          => pif_memcs(PSIF_MEMSEL_ZUKEY downto PSIF_MEMSEL_ZUPACKET),
      pif_addr           => pif_addr,
      pif_wdata          => pif_wdata,
      pif_re             => pif_re,
      pif_we             => pif_we,
      pif_be             => pif_be,
      rdata_2pif         => rdata_zu2pif,
      ack_2pif           => ack_zu2pif,
      mdata_zupacket2pif => mdata_zupacket2pif,
      mdata_zukey2pif    => mdata_zukey2pif,
      zu_tdata_cnt_str   => zu_tdata_cnt_str,
      zu_tdata_cnt       => zu_tdata_cnt,
      zu_tdata           => zu_tdata,  
      zu_tvalid          => zu_tvalid, 
      zu_tready          => zu_tready);

  scu_0: scu
    generic map (
      SIMULATION_MODE => SIMULATION_MODE)
    port map (
      mclk                => mclk,
      rst                 => rst,
      pif_regcs           => pif_regcs(PSIF_REGSEL_SCU),
      pif_addr            => pif_addr,
      pif_wdata           => pif_wdata,
      pif_re              => pif_re,
      pif_we              => pif_we,
      pif_be              => pif_be,
      rdata_2pif          => rdata_scu2pif,
      ack_2pif            => ack_scu2pif,
      dti_spi_instruction => dti_spi_instruction,
      dti_spi_rd_str      => dti_spi_rd_str,
      dti_spi_busy        => dti_spi_busy,
      dti_spi_rdata       => dti_spi_rdata,
      zu_tdata_cnt_str    => zu_tdata_cnt_str,
      zu_tdata_cnt        => zu_tdata_cnt,
      zu_tdata            => zu_tdata,
      zu_tvalid           => zu_tvalid,
      zu_tready           => zu_tready,
      odi_oledbyte3_0     => odi_oledbyte3_0,
      odi_oledbyte7_4     => odi_oledbyte7_4,
      odi_oledbyte11_8    => odi_oledbyte11_8,
      odi_oledbyte15_12   => odi_oledbyte15_12,
      led_alarm           => led_alarm,
      alarm_ack_btn       => alarm_ack_btn);

  aui_0: aui
    port map (
      mclk                      => mclk,
      rst                       => rst,
      clk_62m5                  => '0',
      pif_clk                   => psif_axi_aclk,
      pif_rst                   => psif_axi_areset,
      pif_addr                  => pif_addr,
      pif_be                    => pif_be,
      pif_re                    => pif_re,
      pif_regcs                 => pif_regcs(PSIF_REGSEL_AUI),
      pif_wdata                 => pif_wdata,
      pif_we                    => pif_we,
      rdata_aui2pif             => rdata_aui2pif,
      ack_aui2pif               => ack_aui2pif,
      pif_memcs                 => pif_memcs(PSIF_MEMSEL_AUIAURORARXFIFO downto PSIF_MEMSEL_AUIAURORATXFIFO),
      mdata_auiaurorarxfifo2pif => mdata_auiaurorarxfifo2pif,
      rf_gt_refclk1_p           => '0',
      rf_gt_refclk1_n           => '1',
      rf_rxp                    => '0',
      rf_rxn                    => '1',
      rf_txp                    => open,
      rf_txn                    => open);
  
--  ila_scu_0: ila_scu
--    port map (
--      clk       => psif_axi_aclk,
--      probe0    => pif_regcs,
--      probe1    => pif_memcs,
--      probe2    => pif_addr,
--      probe3    => pif_wdata,
--      probe4    => pif_re,
--      probe5    => pif_we,
--      probe6    => pif_be,
--      probe7    => rdata_scu2pif,
--      probe8(0) => ack_scu2pif);
  
  -- Concurrent statements
  -- TBD.  

end str;
