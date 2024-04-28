
//----------------------------------------------------------------------
// reset_agent
//----------------------------------------------------------------------
class reset_agent extends uvm_agent;

  // factory registration macro
  `uvm_component_utils(reset_agent)   

  // configuration object
  reset_agent_config m_cfg;

  // internal components
  reset_agent_driver  m_driver;
  uvm_sequencer #(reset_agent_item) sequencer;

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "reset_agent", 
               uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    
    if(!uvm_config_db #(reset_agent_config)::get(this, "", "reset_agent_config", m_cfg)) begin
      `uvm_error("build_phase", "reset_agent_config not found")
    end    
   
    // Driver and Sequencer only built if agent is active
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver   = reset_agent_driver::type_id::create("m_driver",this);
      sequencer  = uvm_sequencer #(reset_agent_item)::type_id::create("sequencer",this); 
      m_cfg.sequencer=sequencer;
    end 
  endfunction: build_phase

  //--------------------------------------------------------------------
  // connect_phase
  //--------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    
    // Driver and Sequencer only connected if agent is active    
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver.m_cfg=m_cfg; // The virtual interface is included in the m_cfg class!!!
      m_driver.seq_item_port.connect(sequencer.seq_item_export);   
    end     
    
  endfunction: connect_phase

endclass: reset_agent

