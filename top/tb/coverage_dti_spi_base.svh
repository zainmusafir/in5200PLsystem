   import uvm_pkg::*;
   `include "uvm_macros.svh";

 class coverage_dti_spi_base extends uvm_subscriber #(spi_4wire_agent_item);
    `uvm_component_utils(coverage_dti_spi_base);

    function new(string name="", uvm_component parent=null);
      super.new(name, parent);
    endfunction // new

    typedef enum {FALSE, TRUE} bool;      

    function void write(spi_4wire_agent_item t);

      // Empty

    endfunction : write
   
  endclass : coverage_dti_spi_base
