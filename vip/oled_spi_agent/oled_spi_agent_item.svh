
//----------------------------------------------------------------------
// oled_spi_agent_item
//----------------------------------------------------------------------

class oled_spi_agent_item extends uvm_sequence_item;

   logic [7:0] write_data;
  
   // UVM component utility for simple component with field automation macros        
   // factory registration macro // See page 34 in Doulos UVM Adopter course for comments
   `uvm_object_utils_begin(oled_spi_agent_item);
     `uvm_field_int(write_data, UVM_DEFAULT);
   `uvm_object_utils_end;

  function new (string name = "oled_spi_agent_item" );
    super.new(name);
  endfunction: new

  virtual function void displayAll();
    `uvm_info("Item data", $sformatf("Write Data = %0h ", write_data), UVM_MEDIUM)
  endfunction: displayAll   

endclass: oled_spi_agent_item

