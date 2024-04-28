
//----------------------------------------------------------------------
// oled_spi_agent_config
//----------------------------------------------------------------------

class oled_spi_agent_config extends uvm_object;
   `uvm_object_utils(oled_spi_agent_config);

   // agent configuration
   uvm_active_passive_enum is_active = UVM_PASSIVE;   
      
   // sequencer handle
   uvm_sequencer #(oled_spi_agent_item) sequencer;
   
   // virtual interface handle:
   virtual oled_spi_agent_if  oled_spi_if;

   function new(string name = "oled_spi_agent_config");
      super.new(name);
   endfunction: new

endclass: oled_spi_agent_config

