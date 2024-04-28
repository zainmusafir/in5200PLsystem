package base_test_pkg;

//`define SETUP_KBAXI4LITE 1
   
   import uvm_pkg::*;
   
   `ifdef SETUP_KBAXI4LITE
      import kb_axi4lite_agent_pkg::*;
   `else
      import mvc_pkg::*;
      import mgc_axi4_v1_0_pkg::*;
   `endif
   
   import reset_agent_pkg::*;
   import oled_spi_agent_pkg::*;
   //import spi_4wire_agent_pkg::*;
   //import interrupt_handler_pkg::*;
   import tb_env_pkg::*;
   import axi4params_pkg::*;
   import kb_axi4stream_agent_pkg::*;

   import top_psif_vreguvm_pkg_uvm::*;
   import top_psif_vreguvm_pkg_uvm_rw::*;
   
   `include "uvm_macros.svh";
   
`ifndef SETUP_KBAXI4LITE
   
  // Typedef of mgc_axi4 with particular parameters
  typedef virtual mgc_axi4 #(AXI4_ADDRESS_WIDTH, 
                             AXI4_RDATA_WIDTH,
                             AXI4_WDATA_WIDTH,
                             AXI4_ID_WIDTH,
                             AXI4_USER_WIDTH,
                             AXI4_REGION_MAP_SIZE ) bfm_type;


   typedef axi4_master_read  #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE
                               ) read_item_t;

   typedef axi4_master_write #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE
                               ) write_item_t;

 `endif  
   

   `include "top_reset_seq.svh";
   `include "base_test.svh";
   
endpackage // base_test_pkg
   
