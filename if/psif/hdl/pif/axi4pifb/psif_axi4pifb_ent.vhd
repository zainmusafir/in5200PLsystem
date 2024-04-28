------------------------------------------------------------------------------
-- File        : <project>/if/psif/hdl/pif/axi4pifb/psif_axi4pifb_ent.vhd
-- Author      : Roar Skogstrom
-- Company     : (c) Kongsberg Defence & Aerospace 
-- Created     : 2020-07-13
-- Project     : mla
-- Standard    : VHDL 2008
------------------------------------------------------------------------------
-- Description : 
-- 	Master Lab Answer unit
------------------------------------------------------------------------------
-- Revisions   :  
-- Date        Version  Author          Description   
-- 2020-07-13  1.0      Roar Skogstrom  Created
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library psif_lib;
use psif_lib.psif_pck.all;

entity psif_axi4pifb is

  generic (
   -- Width of PIF data bus
    PIF_DATA_WIDTH	: integer	:= PSIF_DATA_LENGTH;
    -- Width of PIF address bus
    PIF_ADDR_WIDTH	: integer	:= PSIF_ADDRESS_LENGTH;
    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH	: integer	:= 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH	: integer	:= 32
  );
	
  port (
    -- AXI4LITE interface
    -- Global Clock Signal
    s_axi_aclk           : in std_logic;
    -- Global Reset Signal. This Signal is Active HIGH
    s_axi_areset         : in std_logic;
    -- Write address (issued by master, accepted by Slave)
    s_axi_awaddr	 : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0); 
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    s_axi_awprot         : in std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    s_axi_awvalid        : in std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    s_axi_awready	 : out std_logic;
    -- Write data (issued by master, accepted by Slave) 
    s_axi_wdata	         : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    s_axi_wstrb	         : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    s_axi_wvalid	 : in std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    s_axi_wready	 : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    s_axi_bresp          : out std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    s_axi_bvalid 	 : out std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    s_axi_bready	 : in std_logic;
    -- Read address (issued by master, accepted by Slave)
    s_axi_araddr	 : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    s_axi_arprot	 : in std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    s_axi_arvalid	 : in std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    s_axi_arready	 : out std_logic;
    -- Read data (issued by slave)
    s_axi_rdata	         : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    s_axi_rresp	         : out std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    s_axi_rvalid 	 : out std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    s_axi_rready	 : in std_logic;

    -- Register and memory processor interface (PIF)
    -- Reset signal, active HIGH and equal to inverted s_axi_areset 
    -- Register chip select
    pif_regcs            : out std_logic_vector(31 downto 0); 
    -- Memory chip select
    pif_memcs            : out std_logic_vector(31 downto 0); 
    -- Write address
    pif_addr             : out std_logic_vector(PIF_ADDR_WIDTH-1 downto 0); 
    -- Write data 
    pif_wdata            : out std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    -- Read enable strobe
    pif_re	         : out std_logic_vector(0 downto 0);
    -- Write enable strobe
    pif_we	         : out std_logic_vector(0 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold valid data. 
    -- There is one write strobe bit for each eight bits of the write data bus.    
    pif_be	         : out std_logic_vector((PIF_DATA_WIDTH/8)-1 downto 0);
    
    -- Data and ack signals from register odi
    rdata_odi2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    ack_odi2pif   : in std_logic;
    -- Data and ack signals from register dti
    rdata_dti2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    ack_dti2pif   : in std_logic;
    -- Data and ack signals from register zu
    rdata_zu2pif  : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    ack_zu2pif    : in std_logic;
    -- Data and ack signals from register scu
    rdata_scu2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    ack_scu2pif   : in std_logic;
    -- Data and ack signals from register aui
    rdata_aui2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    ack_aui2pif   : in std_logic;
    
  
    -- Data from RAM modules
    mdata_dtispirxfifo2pif    : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    mdata_zupacket2pif        : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
    mdata_zukey2pif           : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0);    
    mdata_auiaurorarxfifo2pif : in std_logic_vector(PIF_DATA_WIDTH-1 downto 0)    
  );
  
end psif_axi4pifb;

