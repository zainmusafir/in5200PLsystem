
//----------------------------------------------------------------------
// kb_axi4lite_agent
//----------------------------------------------------------------------
class kb_axi4lite_agent extends uvm_agent;

  // configuration object
  kb_axi4lite_agent_config m_cfg;

  // factory registration macro
  `uvm_component_utils(kb_axi4lite_agent)   

  // external interfaces
  uvm_analysis_port #(kb_axi4lite_agent_item) ap;

  // internal components
  kb_axi4lite_agent_monitor  m_monitor;
  kb_axi4lite_agent_driver  m_driver;
  uvm_sequencer #(kb_axi4lite_agent_item)  sequencer;
  kb_axi4lite_agent_coverage_monitor  m_fcov_monitor; // Added by roarsk


  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "kb_axi4lite_agent", 
               uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    
    if(!uvm_config_db #(kb_axi4lite_agent_config)::get(this, "", "kb_axi4lite_agent_config", m_cfg)) begin
      `uvm_error("build_phase", "kb_axi4lite_agent_config not found")
    end    

    ap = new("ap", this);
    
    // Monitor is always built
    m_monitor = kb_axi4lite_agent_monitor::type_id::create("m_monitor", this);

    m_fcov_monitor =  kb_axi4lite_agent_coverage_monitor::type_id::create("m_fcov_monitor", this);  // Added by roarsk
    
    // Driver and Sequencer only built if agent is active
   if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver   = kb_axi4lite_agent_driver::type_id::create("m_driver",this);
//      sequencer  = uvm_sequencer #(kb_axi4lite_agent_item, kb_axi4lite_agent_item)::type_id::create("sequencer",this);
// Changed by roarsk due to same REQ (request) data item and RSP (respons) data item (i.e. kb_axi4lite_agent_item) in the sequencer???
      sequencer  = uvm_sequencer #(kb_axi4lite_agent_item)::type_id::create("sequencer",this); 
      m_cfg.m_sequencer=sequencer;
    end 
  endfunction: build_phase

  //--------------------------------------------------------------------
  // connect_phase
  //--------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    // Monitor is always connected
    m_monitor.ap.connect(ap);
    m_monitor.vif = m_cfg.vif;

    m_monitor.ap.connect(m_fcov_monitor.analysis_export);  // Added by roarsk
    
    // Driver and Sequencer only connected if agent is active    
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver.m_cfg=m_cfg; // The virtual interface is included in the m_cfg class!!!
      m_driver.seq_item_port.connect(sequencer.seq_item_export);   
    end     
    
  endfunction: connect_phase

endclass: kb_axi4lite_agent

