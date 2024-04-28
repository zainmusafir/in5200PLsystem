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

library mla_lib;
--use mla_lib.mla_pck.all;
library psif_lib;
use psif_lib.psif_pck.all;

entity core is
  generic (
    TARGET          : string;
    HLSMODULE       : string;
    SIMULATION_MODE : string);
  port (
    -- External PSIF (PIF) processor interface
    -- AXI4 Global Clock Signal
    psif_axi_aclk    : in  std_logic;
    -- axi4 global reset signal. this Signal is Active LOW
    psif_axi_areset  : in  std_logic;
    -- write address (issued by master, acceped by Slave)
    psif_axi_awaddr  : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
    -- write channel protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    psif_axi_awprot  : in  std_logic_vector(2 downto 0);
    -- write address valid. this signal indicates that the master signaling
    -- valid write address and control information.
    psif_axi_awvalid : in  std_logic;
    -- write address ready. this signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    psif_axi_awready : out std_logic;
    -- write data (issued by master, acceped by Slave) 
    psif_axi_wdata   : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
    -- write strobes. this signal indicates which byte lanes hold
    -- valid data. there is one write strobe bit for each eight
    -- bits of the write data bus.    
    psif_axi_wstrb   : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
    -- write valid. this signal indicates that valid write
    -- data and strobes are available.
    psif_axi_wvalid  : in  std_logic;
    -- write ready. this signal indicates that the slave
    -- can accept the write data.
    psif_axi_wready  : out std_logic;
    -- write response. this signal indicates the status
    -- of the write transaction.
    psif_axi_bresp   : out std_logic_vector(1 downto 0);
    -- write response valid. this signal indicates that the channel
    -- is signaling a valid write response.
    psif_axi_bvalid  : out std_logic;
    -- response ready. this signal indicates that the master
    -- can accept a write response.
    psif_axi_bready  : in  std_logic;
    -- read address (issued by master, acceped by Slave)
    psif_axi_araddr  : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
    -- protection type. this signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    psif_axi_arprot  : in  std_logic_vector(2 downto 0);
    -- read address valid. this signal indicates that the channel
    -- is signaling valid read address and control information.
    psif_axi_arvalid : in  std_logic;
    -- read address ready. this signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    psif_axi_arready : out std_logic;
    -- read data (issued by slave)
    psif_axi_rdata   : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
    -- read response. this signal indicates the status of the
    -- read transfer.
    psif_axi_rresp   : out std_logic_vector(1 downto 0);
    -- read valid. this signal indicates that the channel is
    -- signaling the required read data.
    psif_axi_rvalid  : out std_logic;
    -- read ready. this signal indicates that the master can
    -- accept the read data and response information.
    psif_axi_rready  : in  std_logic;
    
    -- Clock, reset, interrupt
    rst       : in  std_logic;                         -- PL mclk core reset
    mclk      : in  std_logic;                         -- Main clock
    psif_irq  : out std_logic_vector(31 downto 0);     -- Interrupts to CPU

    -- Digital Thermometer Interface (DTI) module signals
    --   (i.e. SPI signals from MAX31723 circuit)
    dti_ce    : out std_logic;
    dti_sclk  : out std_logic;
    dti_sdi   : out std_logic;
    dti_sdo   : in  std_logic;
    
    -- OLED signals
    oled_sdin : out std_logic;
    oled_sclk : out std_logic;
    oled_dc   : out std_logic;
    oled_res  : out std_logic;
    oled_vbat : out std_logic;
    oled_vdd  : out std_logic;

    led_alarm     : out std_logic;
    alarm_ack_btn : in  std_logic    
  );
end core;
 
