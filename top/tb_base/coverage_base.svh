   import uvm_pkg::*;
   `include "uvm_macros.svh";

   class coverage_base extends uvm_component;
    `uvm_component_utils(coverage_base);

    function new(string name="",uvm_component parent=null);
      super.new(name,parent);
    endfunction // new

    typedef enum {FALSE, TRUE} bool;      

  endclass : coverage_base
