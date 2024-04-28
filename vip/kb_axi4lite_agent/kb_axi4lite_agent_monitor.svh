
//----------------------------------------------------------------------
// kb_axi4lite_agent_monitor
//----------------------------------------------------------------------
class kb_axi4lite_agent_monitor extends uvm_monitor;
  
  // factory registration macro
  `uvm_component_utils(kb_axi4lite_agent_monitor)
  
  // external interfaces
  uvm_analysis_port  #(kb_axi4lite_agent_item) ap;
  
  // variables
  kb_axi4lite_agent_item  mon_txn;
  kb_axi4lite_agent_item  t;
 
  // interface  
  virtual kb_axi4lite_agent_if  vif;


  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------     
  function new (string name = "kb_axi4lite_agent_monitor",
                uvm_component parent = null);
    super.new(name,parent);
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------     
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    ap = new("ap",this);          
       
  endfunction: build_phase


  //--------------------------------------------------------------------
  // run_phase
  //--------------------------------------------------------------------  
  virtual task run_phase(uvm_phase phase);
  
    mon_txn = kb_axi4lite_agent_item::type_id::create("mon_txn");
    monitor_dut();

  endtask: run_phase

  //--------------------------------------------------------------------
  // monitor_dut
  //--------------------------------------------------------------------    

  task monitor_dut();
  // Monitor transactions from the interface
    forever begin
      @(negedge vif.ACLK);
      if (vif.ARESETn) begin
        if (vif.WVALID == 1) begin
          mon_txn.m_wr_data = vif.WDATA;
          mon_txn.m_addr    = vif.AWADDR;
          mon_txn.m_strb    = vif.WSTRB;
          mon_txn.m_read_or_write = AXI4LITE_WRITE;
          mon_txn.m_transaction_size = vif.m_transaction_size;
          mon_txn.m_status = AXI4LITE_OK;
          $cast(t, mon_txn.clone());
          t.displayAll();
          ap.write(t);
        end
        if (vif.RVALID == 1) begin
          mon_txn.m_rd_data = vif.RDATA;
          mon_txn.m_addr    = vif.ARADDR;
          mon_txn.m_read_or_write = AXI4LITE_READ; 
          mon_txn.m_transaction_size = vif.m_transaction_size;
          mon_txn.m_status = AXI4LITE_OK;          
          $cast(t, mon_txn.clone());
          t.displayAll();
	  `uvm_info(get_type_name(),$psprintf("Monitor read value: 0x%0h",vif.RDATA), UVM_DEBUG);
          ap.write(t);
        end

      end      
    end
  endtask: monitor_dut

endclass: kb_axi4lite_agent_monitor

