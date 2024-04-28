
class kb_axi4stream_agent_monitor extends uvm_monitor;
  
  // factory registration macro
  `uvm_component_utils(kb_axi4stream_agent_monitor)
  
  // external interfaces
  uvm_analysis_port  #(kb_axi4stream_agent_item) ap;
  
  // variables
  kb_axi4stream_agent_item  mon_txn;
  kb_axi4stream_agent_item  t;
 
  // interface  
  virtual kb_axi4stream_agent_if  vif;


  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------     
  function new (string name = "kb_axi4stream_agent_monitor",
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
  
    mon_txn = kb_axi4stream_agent_item::type_id::create("mon_txn");
    monitor_dut();

  endtask: run_phase

  //--------------------------------------------------------------------
  // monitor_dut
  //--------------------------------------------------------------------    

  task monitor_dut();
  // Monitor transactions from the interface
    forever begin
      @(negedge vif.CLK);

      // TBD
         
      ap.write(t);
      
    end
     
  endtask: monitor_dut

endclass: kb_axi4stream_agent_monitor

