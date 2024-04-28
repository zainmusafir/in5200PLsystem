   import uvm_pkg::*;
   `include "uvm_macros.svh";

class scoreboard_oled_spi_base extends uvm_scoreboard;
    `uvm_component_utils(scoreboard_oled_spi_base);

      // The FIFO must be declare here due to used in the connect statement
      //   in the tb_env class and all class'es that uses this class as a base class 
      //   (i.e. scoreboard_oled_spi) will inherit the FIFO.
     uvm_tlm_analysis_fifo #(oled_spi_agent_item) oled_spi_monitor_out;
    
    function new(string name="",uvm_component parent=null);
      super.new(name,parent);       
    endfunction // new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // The FIFO instance must be created here due to used in the connect statement
      //   in the tb_env class and all class'es that uses this class as a base class 
      //   (i.e. scoreboard_oled_spi) will inherit the FIFO.
      oled_spi_monitor_out= new("oled_spi_monitor_out", this);
       
    endfunction : build_phase
   
     
endclass : scoreboard_oled_spi_base
