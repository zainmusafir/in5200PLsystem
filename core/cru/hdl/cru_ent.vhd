-------------------------------------------------------------------------------
-- File        : $HOME/IN5200_INF5430/IN5200_lab/lab_H20/lab_answer/core/cru/cru_ent.vhd
-- Author      : Roar Skogstrom
-- Company     : UiO
-- Created     : 2019-08-01
-- Standard    : VHDL 2008
-------------------------------------------------------------------------------
-- Description : 
--   Entity of the Clock and Reset Unit
-------------------------------------------------------------------------------
-- Revisions   :
-- Date        Version  Author  Description
-- 2019-08-01  1.0      roarsk  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cru is
  port(
    -- External clocks and reset
    refclk           : in  std_logic;    -- External clock
    fpga_rst         : in  std_logic;    -- External reset

    -- PSIF AXI4 clock and reset
    psif_axi_aclk    : in  std_logic;    -- PSIF AXI4 clocks
    psif_axi_aresetn : in  std_logic;    -- PSIF AXI4 reset, active low 

    -- Internal clocks and reset
    rst              : out std_logic;    -- Synchronized main clock reset
    psif_axi_rst     : out std_logic     -- PSIF AXI4 reset, active high 
  ); 
end entity cru;
