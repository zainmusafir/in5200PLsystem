
class kb_axi4stream_agent_item extends uvm_sequence_item;

   rand bit [31:0] tx_data;
        bit        tx_data_valid;
        bit        tx_data_last;
        bit [3:0]  tx_data_keep;
        bit        tx_data_ready;
   
   rand bit [31:0] rx_data;
        bit        rx_data_valid;
        bit        rx_data_last;   
        bit [3:0]  rx_data_keep;  
        bit        rx_data_ready;  

   
   // UVM component utility for simple component with field automation macros
   `uvm_object_utils_begin(kb_axi4stream_agent_item);
     `uvm_field_int(tx_data, UVM_DEFAULT);
     `uvm_field_int(tx_data_valid, UVM_DEFAULT);
     `uvm_field_int(tx_data_keep, UVM_DEFAULT);
     `uvm_field_int(tx_data_last, UVM_DEFAULT);
     `uvm_field_int(tx_data_ready, UVM_DEFAULT);
     `uvm_field_int(rx_data, UVM_DEFAULT);
     `uvm_field_int(rx_data_valid, UVM_DEFAULT);
     `uvm_field_int(rx_data_keep, UVM_DEFAULT);
     `uvm_field_int(rx_data_last, UVM_DEFAULT);
     `uvm_field_int(rx_data_ready, UVM_DEFAULT);
   `uvm_object_utils_end;


  function new (string name = "kb_axi4stream_agent_item");
    super.new(name);
  endfunction: new
   

  virtual function void displayAll();
    `uvm_info("TX item data", $sformatf("TX data = %h TX data valid = %0h \
                                         TX data last = %0h TX data keep = %0h TX data valid = %0h \
                                         RX data = %h  RX data valid = %0h \
                                         RX data last = %0h RX data keep = %0h RX data valid = %0h", 
                                         tx_data, tx_data_valid, 
                                         tx_data_last, tx_data_keep, tx_data_ready,
                                         rx_data, rx_data_valid, 
                                         rx_data_last, rx_data_keep, rx_data_ready), UVM_DEBUG)
  endfunction: displayAll 
  
   
  virtual function void displayAlltx();
    `uvm_info("TX item data", $sformatf("TX data = %h TX data valid = %0h \
                                         TX data last = %0h TX data keep = %0h TX data valid = %0h", 
                                         tx_data, tx_data_valid, 
                                         tx_data_last, tx_data_keep, tx_data_ready), UVM_DEBUG)
  endfunction: displayAlltx
   
      
  virtual function void displayAllrx();
    `uvm_info("RX item data", $sformatf("RX data = %h RX data last = %0h \
                                         RX data last = %0h RX data keep = %0h RX data valid = %0h", 
                                         rx_data, rx_data_valid,
                                         rx_data_last, rx_data_keep, rx_data_ready), UVM_DEBUG)
  endfunction: displayAllrx
   

endclass: kb_axi4stream_agent_item

