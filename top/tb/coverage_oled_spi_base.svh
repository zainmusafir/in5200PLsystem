   import uvm_pkg::*;
   `include "uvm_macros.svh";

 class coverage_oled_spi_base extends uvm_subscriber #(oled_spi_agent_item);
    `uvm_component_utils(coverage_oled_spi_base);

    function new(string name="", uvm_component parent=null);
      super.new(name, parent);
    endfunction // new

    typedef enum {FALSE, TRUE} bool;      

    function void write(oled_spi_agent_item t);

      // Empty

    endfunction : write
   
  endclass : coverage_oled_spi_base
