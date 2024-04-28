
//----------------------------------------------------------------------
// reset_agent_config
//----------------------------------------------------------------------

class reset_agent_config extends uvm_object;
   `uvm_object_utils(reset_agent_config);

   // agent configuration
   uvm_active_passive_enum is_active = UVM_ACTIVE;   
      
   // sequencer handle
   uvm_sequencer #(reset_agent_item) sequencer;
   
   // virtual interface handle:
   virtual reset_agent_if  reset_if;

   function new(string name = "reset_agent_config");
      super.new(name);
   endfunction: new

endclass: reset_agent_config

