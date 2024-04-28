package axi4params_pkg;
    
   `include "uvm_macros.svh";

   // Defining parameters for the AXI4lite interface
   
   // Constant: AXI4_ADDRESS_WIDTH
   //
   // The AXI4 read and write address bus widths 
   //
   localparam AXI4_ADDRESS_WIDTH = 32;

   // Constant: AXI4_RDATA_WIDTH
   //
   // The width of the RDATA signal 
   //
   localparam AXI4_RDATA_WIDTH   = 32;

   // Constant: AXI4_WDATA_WIDTH
   // 
   // The width of the WDATA signal 
   //
   localparam AXI4_WDATA_WIDTH   = 32;

   // Constant: AXI4_ID_WIDTH
   //
   // The width of the AWID/ARID signals 
   //

   // Not used by AXI4lite:

   localparam AXI4_ID_WIDTH      = 4;

   // Constant: AXI4_USER_WIDTH
   //
   // The width of the AWUSER, ARUSER, WUSER, RUSER and BUSER signals 
   //
   localparam AXI4_USER_WIDTH    = 4;

   // Constant: AXI4_REGION_MAP_SIZE
   //
   // The number of address-decode entries in the region map 
   //
   // The address-decode function is done by the interconnect, generating a 
   // value for <AWREGION> / <ARREGION> from the transaction address.
   // This parameter defines the size of the entries in the region map array, 
   // where each entry defines a mapping from address-range to region value.
   // See <config_region> for details of how it is used.
   //
   localparam AXI4_REGION_MAP_SIZE = 16;

  
endpackage // axi4params_pkg
   
