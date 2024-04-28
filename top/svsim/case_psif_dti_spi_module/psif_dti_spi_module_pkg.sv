package psif_dti_spi_module_pkg;
   
   import uvm_pkg::*;

   import tb_env_pkg::*;
   import base_test_pkg::*;
   import base_seq_pkg::*;
   import spi_4wire_agent_pkg::*;
   import probe_pkg::*;
 
   `include "uvm_macros.svh";
   `include "psif_dti_spi_module_seq.svh";
   `include "psif_dti_spi_module_seq_virtual.svh";
   `include "psif_dti_spi_module_test.svh";
  
endpackage // psif_dti_spi_module_pkg
   
