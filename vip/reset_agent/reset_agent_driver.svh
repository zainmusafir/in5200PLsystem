
//----------------------------------------------------------------------
// reset_agent_driver
//----------------------------------------------------------------------
class reset_agent_driver extends uvm_driver #(reset_agent_item);

   // factory registration macro
   `uvm_component_utils(reset_agent_driver);
      
   // Configuration object
   reset_agent_config   m_cfg; 
   reset_agent_item     m_req;

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "reset_agent_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new


   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     m_cfg= reset_agent_config::type_id::create("m_cfg");
   endfunction : build_phase
     

   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);

      // Calls init_signals task
      init_signals();
      
      forever begin

   	seq_item_port.get_next_item(m_req);

        m_cfg.reset_if.rst <= m_req.rst;

	seq_item_port.item_done();
      end
      
   endtask: run_phase
   

   task init_signals();
      m_cfg.reset_if.rst <= 1'b1; // active high reset
   endtask // init_signals

   
endclass: reset_agent_driver

