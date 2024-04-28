
class kb_axi4stream_agent_driver extends uvm_driver #(kb_axi4stream_agent_item);

   // factory registration macro
   `uvm_component_utils(kb_axi4stream_agent_driver);   

   // Configuration object
   kb_axi4stream_agent_config   m_cfg; 
   kb_axi4stream_agent_item     m_req;

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "kb_axi4stream_agent_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new


   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     m_cfg= kb_axi4stream_agent_config::type_id::create("m_cfg");
   endfunction : build_phase


   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);
      
      // Calls init_signals task
      init_signals();

      // Just wait for data to show up ...
      @(posedge m_cfg.kb_axi4stream_if.RX_TVALID);
      
      forever begin

   	seq_item_port.get_next_item(m_req);

          @(negedge m_cfg.kb_axi4stream_if.CLK);
           
          m_cfg.kb_axi4stream_if.TX_TDATA  = m_req.tx_data;        
          m_cfg.kb_axi4stream_if.TX_TVALID = m_req.tx_data_valid;  
          m_cfg.kb_axi4stream_if.TX_TLAST  = m_req.tx_data_last;   
          m_cfg.kb_axi4stream_if.TX_TKEEP  = m_req.tx_data_keep;     
          
          m_req.tx_data_ready = m_cfg.kb_axi4stream_if.TX_TREADY;
          
          m_cfg.kb_axi4stream_if.RX_TREADY = m_req.rx_data_ready;
           
          m_req.rx_data       = m_cfg.kb_axi4stream_if.RX_TDATA;
          m_req.rx_data_valid = m_cfg.kb_axi4stream_if.RX_TVALID; 
          m_req.rx_data_last  = m_cfg.kb_axi4stream_if.RX_TLAST; 
          m_req.rx_data_keep  = m_cfg.kb_axi4stream_if.RX_TKEEP; 

        seq_item_port.item_done();
         
      end // forever begin
      
   endtask: run_phase
      
   
   task init_signals();
      m_cfg.kb_axi4stream_if.TX_TDATA  = '0;
      m_cfg.kb_axi4stream_if.TX_TVALID = '0;
      m_cfg.kb_axi4stream_if.TX_TLAST  = '0;
      m_cfg.kb_axi4stream_if.TX_TKEEP  = '0;
   endtask // init_signals

   
endclass: kb_axi4stream_agent_driver

