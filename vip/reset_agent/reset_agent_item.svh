
//----------------------------------------------------------------------
// reset_agent_item
//----------------------------------------------------------------------

class reset_agent_item extends uvm_sequence_item;

   rand bit rst;
  
   // UVM component utility for simple component with field automation macros        
   // factory registration macro
   `uvm_object_utils_begin(reset_agent_item);
     `uvm_field_int(rst, UVM_DEFAULT);
   `uvm_object_utils_end;

  function new (string name = "reset_agent_item" );
    super.new(name);
  endfunction: new

endclass: reset_agent_item

