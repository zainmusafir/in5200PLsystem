
class tb_env_base #(int AXI4_ADDRESS_WIDTH   = 32, 
                    int AXI4_RDATA_WIDTH     = 32,
	            int AXI4_WDATA_WIDTH     = 32,
	            int AXI4_ID_WIDTH        = 4,
	            int AXI4_USER_WIDTH      = 4,
	            int AXI4_REGION_MAP_SIZE = 16 
	           ) extends uvm_env;

   `uvm_component_param_utils( tb_env_base ); // For parameterized components with no field macros.

  
`ifdef SETUP_KBAXI4LITE
 
    typedef kb_axi4lite_agent agent_t;

  `else

    typedef axi4_agent #(AXI4_ADDRESS_WIDTH,
                         AXI4_RDATA_WIDTH,
                         AXI4_WDATA_WIDTH,
                         AXI4_ID_WIDTH,
                         AXI4_USER_WIDTH,
                         AXI4_REGION_MAP_SIZE
                        ) agent_t;
   `endif

   agent_t            m_psif_axi4lite_master_agent;

   typedef reset_agent  reset_agent_t;
   reset_agent_t        m_reset_agent;

//   typedef interrupt_handler_agent #(32) irq_handler_t; // 32 interrupt lines        
//   irq_handler_t      m_psif_irq_handler;

   // Declare coverage base class to be used for type override in test
   coverage_override    coverage_override_h;

   // Declare scoreboard base class to be used for type override in test
   scoreboard_override  scoreboard_override_h;

  
   function new( string name="tb_env_base", uvm_component parent=null );
      super.new( name , parent );
   endfunction

   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
     m_psif_axi4lite_master_agent = agent_t::type_id::create("m_psif_axi4lite_master_agent", this);
//     m_psif_irq_handler           = irq_handler_t::type_id::create("m_psif_irq_handler",this);
     m_reset_agent                = reset_agent_t::type_id::create("m_reset_agent",this);     

     coverage_override_h          = coverage_override::type_id::create("coverage_override_h", this);
     scoreboard_override_h        = scoreboard_override::type_id::create("scoreboard_override_h", this);

   endfunction // build_phase
   

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      // TBD.
     
   endfunction // connect_phase
    
endclass

