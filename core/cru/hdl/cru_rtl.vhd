-------------------------------------------------------------------------------
-- File        : $HOME/IN5200_INF5430/IN5200_lab/lab_H20/lab_answer/core/cru/cru_rtl.vhd
-- Author      : Roar Skogstrom
-- Company     : (c) Kongsberg Defence & Aerospace
-- Created     : 2019-08-01
-- Standard    : VHDL 2008
-------------------------------------------------------------------------------
-- Description : 
--   Architecture of the Clock and Reset Unit
-------------------------------------------------------------------------------
-- Revisions   :
-- Date        Version  Author  Description
-- 2019-08-01  1.0      roarsk  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.VCOMPONENTS.all;

architecture rtl of cru is
    
  -- Signal Declarations
  signal rst_s1          : std_logic;
  signal rst_s2          : std_logic;
  signal rst_psif        : std_logic;
  signal rst_i           : std_logic;
  signal psif_axi_rst_s1 : std_logic;
  signal psif_axi_rst_s2 : std_logic;
  signal psif_axi_rst_s3 : std_logic;
  signal psif_axi_rst_i  : std_logic;
  
begin

  -- Synchronize deactivation of main reset
  P_RESET_0: process (refclk, fpga_rst, psif_axi_aresetn)
  begin
    if (fpga_rst = '1' or psif_axi_aresetn='0') then
      rst_s1     <= '1';
      rst_s2     <= '1';
      rst_psif   <= '1';
    elsif rising_edge(refclk) then
      rst_s1     <= '0';
      rst_s2     <= rst_s1;
      rst_psif   <= rst_s2;
    end if;
  end process P_RESET_0;
    
  -- Synchronize deactivation of psif axi reset
  P_RST_SYNCH_PSIF_AXI_ACLK: process(psif_axi_aclk)
  begin
    if rising_edge(psif_axi_aclk) then
      psif_axi_rst_s1 <= rst_psif;  -- Cascaded with the external reset rst_psif
      psif_axi_rst_s2 <= psif_axi_rst_s1;
      psif_axi_rst_s3 <= psif_axi_rst_s2;
    end if;
  end process P_RST_SYNCH_PSIF_AXI_ACLK;

  -- Global buffer for main refclk reset signal  
  BUFG_0: BUFG
    port map (
    I => rst_s2,
    O => rst_i);

  -- Global buffer for AXI PSIF reset signal  
  BUFG_1: BUFG
    port map (
    I => psif_axi_rst_s3,
    O => psif_axi_rst_i);     

  -- Assign outgoing signals
  rst          <= rst_i;
  psif_axi_rst <= psif_axi_rst_i;

end architecture rtl;
