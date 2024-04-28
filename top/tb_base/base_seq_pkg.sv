package base_seq_pkg;

//`define SETUP_KBAXI4LITE 1
   
   import uvm_pkg::*;
   
   `ifdef SETUP_KBAXI4LITE
      import kb_axi4lite_agent_pkg::*;
   `else
      import mvc_pkg::*;
      import mgc_axi4_v1_0_pkg::*;
   `endif
   
   import axi4params_pkg::*;
   //import interrupt_handler_pkg::*;
   import tb_env_pkg::*;

   import top_psif_vreguvm_pkg_uvm::*;
   import top_psif_vreguvm_pkg_uvm_rw::*;

   //import spi_4wire_agent_pkg::*;
   import kb_axi4stream_agent_pkg::*;
   
   `include "uvm_macros.svh";

   `include "base_seq.svh";
   //`include "interrupt_handler_base_isr_seq.svh";  
   //`include "interrupt_handler_psif_seq.svh";   
   
endpackage // base_seq_pkg
   
