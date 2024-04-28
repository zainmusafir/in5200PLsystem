-------------------------------------------------------------------------------
-- File        : $HOME/IN5200_INF5430/IN5200_lab/lab_H20/lab_answer/top/hdl/top_str.vhd
-- Author      : Roar Skogstrom
-- Company     : UiO
-- Created     : 2019-08-01
-- Standard    : VHDL 2008
-------------------------------------------------------------------------------
-- Description : 
--   Top level for Master Lab Answer (MLA) FPGA.
-------------------------------------------------------------------------------
-- Revisions   :
-- Date        Version  Author  Description
-- 2019-08-01  1.0      roarsk  Created
-------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VCOMPONENTS.all;

library psif_lib;
use psif_lib.psif_pck.all;

library mla_lib;
use mla_lib.target_pck.all;

architecture str of top is

  -- External clock generation
  component clk_wiz_0
  port
     ( -- Clock in ports
       clk_in1           : in     std_logic;
       -- Clock out ports
       clk_out1          : out    std_logic;
       -- Status and control signals
       reset             : in     std_logic;
       locked            : out    std_logic
     );
  end component;

  component cru is
    port (
      refclk           : in  std_logic;   -- External clock
      fpga_rst         : in  std_logic;   -- External reset
      psif_axi_aclk    : in  std_logic;   -- PSIF AXI4 clocks
      psif_axi_aresetn : in  std_logic;   -- PSIF AXI4 reset, active low
      rst              : out std_logic;   -- Synchronized main clock reset
      psif_axi_rst     : out std_logic);  -- PSIF AXI4 reset,  active high
  end component cru;
    
  -- Programmable Logic Core module
  component core is
    generic (
      TARGET          : string;
      HLSMODULE       : string;
      SIMULATION_MODE : string);
    port (
      psif_axi_aclk         : in  std_logic;
      psif_axi_areset       : in  std_logic;
      psif_axi_awaddr       : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      psif_axi_awprot       : in  std_logic_vector(2 downto 0);
      psif_axi_awvalid      : in  std_logic;
      psif_axi_awready      : out std_logic;
      psif_axi_wdata        : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      psif_axi_wstrb        : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      psif_axi_wvalid       : in  std_logic;
      psif_axi_wready       : out std_logic;
      psif_axi_bresp        : out std_logic_vector(1 downto 0);
      psif_axi_bvalid       : out std_logic;
      psif_axi_bready       : in  std_logic;
      psif_axi_araddr       : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      psif_axi_arprot       : in  std_logic_vector(2 downto 0);
      psif_axi_arvalid      : in  std_logic;
      psif_axi_arready      : out std_logic;
      psif_axi_rdata        : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      psif_axi_rresp        : out std_logic_vector(1 downto 0);
      psif_axi_rvalid       : out std_logic;
      psif_axi_rready       : in  std_logic;
      rst                   : in  std_logic;  -- FPGA reset
      mclk                  : in  std_logic;  -- Reference (master) clock
      psif_irq              : out std_logic_vector(31 downto 0);  -- Interrupts to CPU
      dti_ce                : out std_logic;
      dti_sclk              : out std_logic;
      dti_sdi               : out std_logic;
      dti_sdo               : in  std_logic;
      oled_sdin             : out std_logic;
      oled_sclk             : out std_logic;
      oled_dc               : out std_logic;
      oled_res              : out std_logic;
      oled_vbat             : out std_logic;
      oled_vdd              : out std_logic;
      led_alarm             : out std_logic;
      alarm_ack_btn         : in  std_logic);   
    end component core;

  -- Clock and reset signals
  signal mclk         : std_logic;
  signal axi_aclk     : std_logic;
  signal areset_n     : std_logic;
  signal pl_rst       : std_logic;
  signal psif_axi_rst : std_logic;
  signal locked       : std_logic;

  -- PSIF AXI4-Lite interface
  signal psif_axi_araddr  : std_logic_vector(31 downto 0);
  signal psif_axi_arprot  : std_logic_vector(2 downto 0);
  signal psif_axi_arready : std_logic;
  signal psif_axi_arvalid : std_logic;
  signal psif_axi_awaddr  : std_logic_vector(31 downto 0);
  signal psif_axi_awprot  : std_logic_vector(2 downto 0);
  signal psif_axi_awready : std_logic;
  signal psif_axi_awvalid : std_logic;
  signal psif_axi_bready  : std_logic;
  signal psif_axi_bresp   : std_logic_vector(1 downto 0);
  signal psif_axi_bvalid  : std_logic;
  signal psif_axi_rdata   : std_logic_vector(31 downto 0);
  signal psif_axi_rready  : std_logic;
  signal psif_axi_rresp   : std_logic_vector(1 downto 0);
  signal psif_axi_rvalid  : std_logic;
  signal psif_axi_wdata   : std_logic_vector(31 downto 0);
  signal psif_axi_wready  : std_logic;
  signal psif_axi_wstrb   : std_logic_vector(3 downto 0);
  signal psif_axi_wvalid  : std_logic;
  
  signal psif_irq     : std_logic_vector(31 downto 0);

  -- PS to PL GPIO interface
  signal pl_gpio      : std_logic_vector(3 downto 0);

  -- SCU signal declarations
  signal led_alarm    : std_logic;

  -- Misc. signal declarations
  signal led          : std_logic;

  -- PS signals
  signal iic_mux_scl_i  : std_logic_vector(1 downto 0);
  signal iic_mux_scl_o  : std_logic_vector(1 downto 0);
  signal iic_mux_scl_t  : std_logic;
  signal iic_mux_sda_i  : std_logic_vector(1 downto 0);
  signal iic_mux_sda_o  : std_logic_vector(1 downto 0);
  signal iic_mux_sda_t  : std_logic;
   
begin
  
  ref_clk: clk_wiz_0
    port map (
      clk_in1  => refclk,
      clk_out1 => mclk,
      reset    => fpga_rst,
      locked   => locked);

  
  cru_0: cru
    port map (
      refclk           => mclk,            -- External clock
      fpga_rst         => fpga_rst,        -- External reset
      psif_axi_aclk    => axi_aclk,        -- PSIF AXI4 clocks
      psif_axi_aresetn => areset_n,        -- PSIF AXI4 reset, active low
      rst              => pl_rst,          -- Synchronized main clock reset
      psif_axi_rst     => psif_axi_rst);   -- PSIF AXI4 reset,  active high

  
  G_PS: if PSMODULE="FACERECON" generate

    component system is
      port (
        areset_n          : out   STD_LOGIC;
        axi_aclk          : out   STD_LOGIC;
        ddr_addr          : inout STD_LOGIC_VECTOR (14 downto 0);
        ddr_ba            : inout STD_LOGIC_VECTOR (2 downto 0);
        ddr_cas_n         : inout STD_LOGIC;
        ddr_ck_n          : inout STD_LOGIC;
        ddr_ck_p          : inout STD_LOGIC;
        ddr_cke           : inout STD_LOGIC;
        ddr_cs_n          : inout STD_LOGIC;
        ddr_dm            : inout STD_LOGIC_VECTOR (3 downto 0);
        ddr_dq            : inout STD_LOGIC_VECTOR (31 downto 0);
        ddr_dqs_n         : inout STD_LOGIC_VECTOR (3 downto 0);
        ddr_dqs_p         : inout STD_LOGIC_VECTOR (3 downto 0);
        ddr_odt           : inout STD_LOGIC;
        ddr_ras_n         : inout STD_LOGIC;
        ddr_reset_n       : inout STD_LOGIC;
        ddr_we_n          : inout STD_LOGIC;
        fixed_io_ddr_vrn  : inout STD_LOGIC;
        fixed_io_ddr_vrp  : inout STD_LOGIC;
        fixed_io_mio      : inout STD_LOGIC_VECTOR (53 downto 0);
        fixed_io_ps_clk   : inout STD_LOGIC;
        fixed_io_ps_porb  : inout STD_LOGIC;
        fixed_io_ps_srstb : inout STD_LOGIC;
        gpio_tri_o        : out   STD_LOGIC_VECTOR (3 downto 0);
        hdmi_data         : out   STD_LOGIC_VECTOR (15 downto 0);
        hdmi_data_e       : out   STD_LOGIC;
        hdmi_hsync        : out   STD_LOGIC;
        hdmi_out_clk      : out   STD_LOGIC;
        hdmi_vsync        : out   STD_LOGIC;
        iic_mux_scl_i     : in    STD_LOGIC_VECTOR (1 downto 0);
        iic_mux_scl_o     : out   STD_LOGIC_VECTOR (1 downto 0);
        iic_mux_scl_t     : out   STD_LOGIC;
        iic_mux_sda_i     : in    STD_LOGIC_VECTOR (1 downto 0);
        iic_mux_sda_o     : out   STD_LOGIC_VECTOR (1 downto 0);
        iic_mux_sda_t     : out   STD_LOGIC;
        otg_resetn        : out   STD_LOGIC_VECTOR (0 to 0);
        otg_vbusoc        : in    STD_LOGIC;
        psif_araddr       : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_arprot       : out   STD_LOGIC_VECTOR (2 downto 0);
        psif_arready      : in    STD_LOGIC;
        psif_arvalid      : out   STD_LOGIC;
        psif_awaddr       : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_awprot       : out   STD_LOGIC_VECTOR (2 downto 0);
        psif_awready      : in    STD_LOGIC;
        psif_awvalid      : out   STD_LOGIC;
        psif_bready       : out   STD_LOGIC;
        psif_bresp        : in    STD_LOGIC_VECTOR (1 downto 0);
        psif_bvalid       : in    STD_LOGIC;
        psif_rdata        : in    STD_LOGIC_VECTOR (31 downto 0);
        psif_rready       : out   STD_LOGIC;
        psif_rresp        : in    STD_LOGIC_VECTOR (1 downto 0);
        psif_rvalid       : in    STD_LOGIC;
        psif_wdata        : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_wready       : in    STD_LOGIC;
        psif_wstrb        : out   STD_LOGIC_VECTOR (3 downto 0);
        psif_wvalid       : out   STD_LOGIC);
    end component system;
    
  begin

    mla_ps: system
      port map (
        areset_n          => areset_n,
        axi_aclk          => axi_aclk,
        ddr_addr          => ddr_addr,
        ddr_ba            => ddr_ba,
        ddr_cas_n         => ddr_cas_n,
        ddr_ck_n          => ddr_ck_n,
        ddr_ck_p          => ddr_ck_p,
        ddr_cke           => ddr_cke,
        ddr_cs_n          => ddr_cs_n,
        ddr_dm            => ddr_dm,
        ddr_dq            => ddr_dq,
        ddr_dqs_n         => ddr_dqs_n,
        ddr_dqs_p         => ddr_dqs_p,
        ddr_odt           => ddr_odt,
        ddr_ras_n         => ddr_ras_n,
        ddr_reset_n       => ddr_reset_n,
        ddr_we_n          => ddr_we_n,
        fixed_io_ddr_vrn  => fixed_io_ddr_vrn,
        fixed_io_ddr_vrp  => fixed_io_ddr_vrp,
        fixed_io_mio      => fixed_io_mio,
        fixed_io_ps_clk   => fixed_io_ps_clk,
        fixed_io_ps_porb  => fixed_io_ps_porb,
        fixed_io_ps_srstb => fixed_io_ps_srstb,
        gpio_tri_o        => pl_gpio,
        hdmi_data         => hdmi_data,
        hdmi_data_e       => hdmi_data_e,
        hdmi_hsync        => hdmi_hsync,
        hdmi_out_clk      => hdmi_out_clk,
        hdmi_vsync        => hdmi_vsync,
        iic_mux_scl_i     => iic_mux_scl_i,
        iic_mux_scl_o     => iic_mux_scl_o,
        iic_mux_scl_t     => iic_mux_scl_t,
        iic_mux_sda_i     => iic_mux_sda_i,
        iic_mux_sda_o     => iic_mux_sda_o,
        iic_mux_sda_t     => iic_mux_sda_t,
        otg_resetn        => otg_resetn,
        otg_vbusoc        => otg_vbusoc,
        psif_araddr       => psif_axi_araddr,
        psif_arprot       => psif_axi_arprot,
        psif_arready      => psif_axi_arready,
        psif_arvalid      => psif_axi_arvalid,
        psif_awaddr       => psif_axi_awaddr,
        psif_awprot       => psif_axi_awprot,
        psif_awready      => psif_axi_awready,
        psif_awvalid      => psif_axi_awvalid,
        psif_bready       => psif_axi_bready,
        psif_bresp        => psif_axi_bresp,
        psif_bvalid       => psif_axi_bvalid,
        psif_rdata        => psif_axi_rdata,
        psif_rready       => psif_axi_rready,
        psif_rresp        => psif_axi_rresp,
        psif_rvalid       => psif_axi_rvalid,
        psif_wdata        => psif_axi_wdata,
        psif_wready       => psif_axi_wready,
        psif_wstrb        => psif_axi_wstrb,
        psif_wvalid       => psif_axi_wvalid);

  else generate
    
    -- Processor System (PS)
    component processor_system is
      port (
        ddr_addr          : inout std_logic_vector (14 downto 0);
        ddr_ba            : inout std_logic_vector (2 downto 0);
        ddr_cas_n         : inout std_logic;
        ddr_ck_n          : inout std_logic;
        ddr_ck_p          : inout std_logic;
        ddr_cke           : inout std_logic;
        ddr_cs_n          : inout std_logic;
        ddr_dm            : inout std_logic_vector (3 downto 0);
        ddr_dq            : inout std_logic_vector (31 downto 0);
        ddr_dqs_n         : inout std_logic_vector (3 downto 0);
        ddr_dqs_p         : inout std_logic_vector (3 downto 0);
        ddr_odt           : inout std_logic;
        ddr_ras_n         : inout std_logic;
        ddr_reset_n       : inout std_logic;
        ddr_we_n          : inout std_logic;
        fixed_io_ddr_vrn  : inout std_logic;
        fixed_io_ddr_vrp  : inout std_logic;
        fixed_io_mio      : inout std_logic_vector (53 downto 0);
        fixed_io_ps_clk   : inout std_logic;
        fixed_io_ps_porb  : inout std_logic;
        fixed_io_ps_srstb : inout std_logic;
        areset_n          : out   STD_LOGIC;
        axi_aclk          : out   STD_LOGIC;
        gpio_tri_o        : out   STD_LOGIC_VECTOR (3 downto 0);
        psif_araddr       : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_arprot       : out   STD_LOGIC_VECTOR (2 downto 0);
        psif_arready      : in    STD_LOGIC;
        psif_arvalid      : out   STD_LOGIC;
        psif_awaddr       : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_awprot       : out   STD_LOGIC_VECTOR (2 downto 0);
        psif_awready      : in    STD_LOGIC;
        psif_awvalid      : out   STD_LOGIC;
        psif_bready       : out   STD_LOGIC;
        psif_bresp        : in    STD_LOGIC_VECTOR (1 downto 0);
        psif_bvalid       : in    STD_LOGIC;
        psif_rdata        : in    STD_LOGIC_VECTOR (31 downto 0);
        psif_rready       : out   STD_LOGIC;
        psif_rresp        : in    STD_LOGIC_VECTOR (1 downto 0);
        psif_rvalid       : in    STD_LOGIC;
        psif_wdata        : out   STD_LOGIC_VECTOR (31 downto 0);
        psif_wready       : in    STD_LOGIC;
        psif_wstrb        : out   STD_LOGIC_VECTOR (3 downto 0);
        psif_wvalid       : out   STD_LOGIC);
    end component processor_system;  

  begin
    
    mla_ps: processor_system
      port map (
        ddr_addr          => ddr_addr,
        ddr_ba            => ddr_ba,
        ddr_cas_n         => ddr_cas_n,
        ddr_ck_n          => ddr_ck_n,
        ddr_ck_p          => ddr_ck_p,
        ddr_cke           => ddr_cke,
        ddr_cs_n          => ddr_cs_n,
        ddr_dm            => ddr_dm,
        ddr_dq            => ddr_dq,
        ddr_dqs_n         => ddr_dqs_n,
        ddr_dqs_p         => ddr_dqs_p,
        ddr_odt           => ddr_odt,
        ddr_ras_n         => ddr_ras_n,
        ddr_reset_n       => ddr_reset_n,
        ddr_we_n          => ddr_we_n,
        
        fixed_io_ddr_vrn  => fixed_io_ddr_vrn,
        fixed_io_ddr_vrp  => fixed_io_ddr_vrp,
        fixed_io_mio      => fixed_io_mio,
        fixed_io_ps_clk   => fixed_io_ps_clk,
        fixed_io_ps_porb  => fixed_io_ps_porb,
        fixed_io_ps_srstb => fixed_io_ps_srstb,
        
        areset_n          => areset_n,
        axi_aclk          => axi_aclk,
        
        gpio_tri_o        => pl_gpio,
        
        psif_araddr       => psif_axi_araddr,
        psif_arprot       => psif_axi_arprot,
        psif_arready      => psif_axi_arready,
        psif_arvalid      => psif_axi_arvalid,
        psif_awaddr       => psif_axi_awaddr,
        psif_awprot       => psif_axi_awprot,
        psif_awready      => psif_axi_awready,
        psif_awvalid      => psif_axi_awvalid,
        psif_bready       => psif_axi_bready,
        psif_bresp        => psif_axi_bresp,
        psif_bvalid       => psif_axi_bvalid,
        psif_rdata        => psif_axi_rdata,
        psif_rready       => psif_axi_rready,
        psif_rresp        => psif_axi_rresp,
        psif_rvalid       => psif_axi_rvalid,
        psif_wdata        => psif_axi_wdata,
        psif_wready       => psif_axi_wready,
        psif_wstrb        => psif_axi_wstrb,
        psif_wvalid       => psif_axi_wvalid
      );

      -- Dummy values
      hdmi_data     <= (others => '0');
      hdmi_data_e   <= '0';
      hdmi_hsync    <= '0';
      hdmi_out_clk  <= '0';
      hdmi_vsync    <= '0';
      iic_mux_scl_o <= (others => '0');
      iic_mux_scl_t <= '0';
      iic_mux_sda_o <= (others => '0');
      iic_mux_sda_t <= '0';
      otg_resetn    <= (others => '0');
        
  end generate G_PS;

  
  -- I2C bidir signal
  IOBUF_0: component IOBUF
    port map (
    I  => iic_mux_scl_o(0),
    IO => iic_mux_scl(0),
    O  => iic_mux_scl_i(0),
    T  => iic_mux_scl_t);

  -- I2C bidir signal
  IOBUF_1: component IOBUF
    port map (
    I  => iic_mux_scl_o(1),
    IO => iic_mux_scl(1),
    O  => iic_mux_scl_i(1),
    T  => iic_mux_scl_t);
  
  -- I2C bidir signal
  IOBUF_2: component IOBUF
    port map (
    I  => iic_mux_sda_o(0),
    IO => iic_mux_sda(0),
    O  => iic_mux_sda_i(0),
    T  => iic_mux_sda_t);

  -- I2C bidir signal
  IOBUF_3: component IOBUF
    port map (
    I  => iic_mux_sda_o(1),
    IO => iic_mux_sda(1),
    O  => iic_mux_sda_i(1),
    T  => iic_mux_sda_t);

  
  mla_pl: core
  generic map (
    TARGET          => TARGET,
    HLSMODULE       => HLSMODULE,
    SIMULATION_MODE => SIMULATION_MODE)
  port map (
    psif_axi_aclk       => axi_aclk,
    psif_axi_areset     => psif_axi_rst,
    psif_axi_awaddr     => psif_axi_awaddr,
    psif_axi_awprot     => psif_axi_awprot,
    psif_axi_awvalid    => psif_axi_awvalid,
    psif_axi_awready    => psif_axi_awready,
    psif_axi_wdata      => psif_axi_wdata,
    psif_axi_wstrb      => psif_axi_wstrb,
    psif_axi_wvalid     => psif_axi_wvalid,
    psif_axi_wready     => psif_axi_wready,
    psif_axi_bresp      => psif_axi_bresp,
    psif_axi_bvalid     => psif_axi_bvalid,
    psif_axi_bready     => psif_axi_bready,
    psif_axi_araddr     => psif_axi_araddr,
    psif_axi_arprot     => psif_axi_arprot,
    psif_axi_arvalid    => psif_axi_arvalid,
    psif_axi_arready    => psif_axi_arready,
    psif_axi_rdata      => psif_axi_rdata,
    psif_axi_rresp      => psif_axi_rresp,
    psif_axi_rvalid     => psif_axi_rvalid,
    psif_axi_rready     => psif_axi_rready,

    rst                 => pl_rst, 
    mclk                => mclk,

    psif_irq            => psif_irq,

    dti_ce              => dti_ce,
    dti_sclk            => dti_sclk,
    dti_sdi             => dti_sdi,
    dti_sdo             => dti_sdo,
    
    oled_sdin           => oled_sdin,   
    oled_sclk           => oled_sclk,   
    oled_dc             => oled_dc,     
    oled_res            => oled_res,    
    oled_vbat           => oled_vbat,   
    oled_vdd            => oled_vdd,
    led_alarm           => led_alarm,
    alarm_ack_btn       => alarm_ack_btn);


  -- LED logic assignments
  -- P_LED : process (pl_rst, mclk)
  P_LED : process (pl_rst, mclk)
    variable cnt : unsigned(26 downto 0);
  begin
    if (pl_rst = '1') then
      cnt := (others => '0');
      led <= '1';
    elsif rising_edge(mclk) then
      cnt := cnt + 1;
      led <= std_logic(cnt(26));      
    end if;                                                         
  end process P_LED;

  
  -- Output LED signal assignments
  led_8bit(3 downto 0) <= pl_gpio(3 downto 0);
  led_8bit(4) <= pl_rst;   
  led_8bit(5) <= led;   
  led_8bit(6) <= locked; 
  led_8bit(7) <= led_alarm;

end str;
