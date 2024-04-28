package tb_env_pkg;

   import uvm_pkg::*;
   `include "uvm_macros.svh";

   import probe_pkg::*;
   import tb_top_core_odi_oled_ctrl_bind::*;   
//   import tb_top_core_dti_dti_spi_bind::*;   
//   import tb_top_core_dti_bind::*;   
   import tb_top_core_zu_aes128_bind::*;   
    
   import oled_spi_agent_pkg::*;
//   import spi_4wire_agent_pkg::*;
   import kb_axi4stream_agent_pkg::*;
   
   import tb_env_base_pkg::*;

//  `include "spi_4wire_seq.svh";

  `include "scoreboard_oled_spi_base.sv"
  `include "scoreboard_oled_spi.sv"
  `include "coverage_oled_spi_base.svh"
  `include "coverage_oled_spi.svh"

//  `include "scoreboard_dti_spi_base.sv"
//  `include "scoreboard_dti_spi.sv"
//  `include "coverage_dti_spi_base.svh"
//  `include "coverage_dti_spi.svh"

  `include "scoreboard_zu_base.sv"
  `include "scoreboard_zu_aes128.sv"
  `include "aurora_seq_base.svh"
  
  `include "tb_env.svh";
   
endpackage // tb_env_pkg
   
