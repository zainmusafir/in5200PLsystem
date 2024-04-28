package tb_env_base_pkg;
//`define SETUP_KBAXI4LITE 1  
   import uvm_pkg::*;
   import reset_agent_pkg::*;
//   import interrupt_handler_pkg::*;

`ifdef SETUP_KBAXI4LITE
     import kb_axi4lite_agent_pkg::*;
  `else
     import mvc_pkg::*;
     import mgc_axi4_v1_0_pkg::*;
  `endif

  `include "uvm_macros.svh";
  `include "scoreboard_base.sv"
  `include "scoreboard_override.sv"
  `include "coverage_base.svh"
  `include "coverage_override.svh"
  `include "tb_env_base.svh";
   
endpackage // tb_env_base_pkg
   
