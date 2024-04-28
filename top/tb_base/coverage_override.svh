   import uvm_pkg::*;
   `include "uvm_macros.svh";

   class coverage_override extends uvm_component;
    `uvm_component_utils(coverage_override);

    function new(string name="",uvm_component parent=null);
      super.new(name,parent);
    endfunction

    typedef enum {FALSE, TRUE} bool;      
      
  endclass : coverage_override
