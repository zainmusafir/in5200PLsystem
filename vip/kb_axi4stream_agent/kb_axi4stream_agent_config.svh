
class kb_axi4stream_agent_config extends uvm_object;
   `uvm_object_utils(kb_axi4stream_agent_config);
   

   // Timeout used in driver
   time m_timeout = 10us;
   // agent configuration
   uvm_active_passive_enum is_active = UVM_ACTIVE;   
      
   // sequencer handle
   uvm_sequencer #(kb_axi4stream_agent_item)  m_sequencer;
   
   // virtual interface handle:
   virtual kb_axi4stream_agent_if  kb_axi4stream_if;

   function new(string name = "kb_axi4stream_agent_config");
      super.new(name);
   endfunction: new

endclass: kb_axi4stream_agent_config

