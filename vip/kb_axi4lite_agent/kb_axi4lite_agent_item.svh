
//----------------------------------------------------------------------
// kb_axi4lite_agent_item
//----------------------------------------------------------------------

class kb_axi4lite_agent_item extends uvm_sequence_item;

  // user stimulus variables (rand)
   rand axi4lite_transaction_size_t m_transaction_size;
   rand bit [31:0] m_addr;
   rand bit[31:0] m_wr_data;
   rand bit[3:0] m_strb;
   rand axi4lite_status_t m_status;
   rand axi4lite_read_or_write_t m_read_or_write;
   
  // user response variables (non rand)
   bit[31:0] m_rd_data;
  
   // UVM component utility for simple component with field automation macros        
   // factory registration macro // Roarsk: See page 34 in Doulos UVM Adopter course for comments
   `uvm_object_utils_begin(kb_axi4lite_agent_item);
     `uvm_field_enum(axi4lite_transaction_size_t, m_transaction_size, UVM_DEFAULT);
     `uvm_field_enum(axi4lite_read_or_write_t, m_read_or_write, UVM_DEFAULT);
     `uvm_field_enum(axi4lite_status_t, m_status, UVM_DEFAULT);
     `uvm_field_int(m_addr, UVM_DEFAULT);
     `uvm_field_int(m_rd_data, UVM_DEFAULT);
     `uvm_field_int(m_wr_data, UVM_DEFAULT);
     `uvm_field_int(m_strb, UVM_DEFAULT);
   `uvm_object_utils_end;


  function new (string name = "kb_axi4lite_agent_item" );
    super.new(name);
  endfunction: new

  virtual function void displayAll();
    `uvm_info("Item data", $sformatf("Tr size = %s Addr = %0h Wr data = %0h \
                                      Wr strobe = %0h Status = %s Rd/Wr = %s \
                                      Rd data = %0h", m_transaction_size.name(),
                                      m_addr, m_wr_data, m_strb, m_status.name(), 
                                      m_read_or_write.name(), m_rd_data), UVM_DEBUG)
  endfunction: displayAll

endclass: kb_axi4lite_agent_item

