-------------------------------------------------------------------------------
-- File        : $HOME/IN5200_INF5430/IN5200_lab/lab_H20/lab_answer/top/hdl/top_ent.vhd
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

library mla_lib;
use mla_lib.target_pck.all;

entity top is
  generic (
    TARGET          : string:= TARGET_DEFAULT;      -- Selects target implementation
    PSMODULE        : string:= PSMODULE_DEFAULT;    -- Selects PS (.bd) module
    HLSMODULE       : string:= HLSMODULE_DEFAULT;   -- Selects HLS design module
    SIMULATION_MODE : string:= "OFF");              -- "ON" in testbench; "OFF" in implementation 
  port (

    -- Fixed I/O
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
    hdmi_data         : out   std_logic_vector ( 15 downto 0 );
    hdmi_data_e       : out   std_logic;
    hdmi_hsync        : out   std_logic;
    hdmi_out_clk      : out   std_logic;
    hdmi_vsync        : out   std_logic;
    iic_mux_scl       : inout std_logic_vector (1 downto 0);
    iic_mux_sda       : inout std_logic_vector (1 downto 0);
    otg_resetn        : out   std_logic_vector (0 to 0);
    otg_vbusoc        : in    std_logic;
   
    -- External reference clock
    fpga_rst          : in    std_logic;  -- External reset
    refclk            : in    std_logic;  -- External reference clock
    
    -- PS LED signals
    led_8bit          : out   std_logic_vector(7 downto 0);

    -- Digital Thermometer Interface (DTI) module signals
    --   (i.e. SPI signals from MAX31723 circuit)
    dti_ce            : out std_logic;
    dti_sclk          : out std_logic;
    dti_sdi           : out std_logic;
    dti_sdo           : in  std_logic;
    
    -- OLED signals
    oled_sdin         : out std_logic;
    oled_sclk         : out std_logic;
    oled_dc           : out std_logic;
    oled_res          : out std_logic;
    oled_vbat         : out std_logic;
    oled_vdd          : out std_logic;

    -- RFI signals
    rf_gt_refclk1_p  : in  std_logic;
    rf_gt_refclk1_n  : in  std_logic;
    rf_rxp           : in  std_logic;
    rf_rxn           : in  std_logic;
    rf_txp           : out std_logic;
    rf_txn           : out std_logic;    

    alarm_ack_btn     : in  std_logic        
  );
end top;
