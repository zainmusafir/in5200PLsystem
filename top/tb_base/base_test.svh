
import uvm_pkg::*;

`ifdef SETUP_KBAXI4LITE
    import typedef_pkg::*;
    import kb_axi4lite_agent_pkg::*;
  `else
    import mvc_pkg::*;
    import mgc_axi4_v1_0_pkg::*;
  `endif

import tb_env_pkg::*;

//import reset_agent_pkg::*;
//import interrupt_handler_pkg::*;

import top_psif_vreguvm_pkg_uvm::*;
import top_psif_vreguvm_pkg_uvm_rw::*;


`include "uvm_macros.svh";

class base_test extends uvm_test;
   `uvm_component_utils(base_test);

   typedef enum {FALSE, TRUE} boolean;
   

   typedef tb_env #(AXI4_ADDRESS_WIDTH,
                    AXI4_RDATA_WIDTH,
	 	    AXI4_WDATA_WIDTH,
		    AXI4_ID_WIDTH,
		    AXI4_USER_WIDTH,
	  	    AXI4_REGION_MAP_SIZE
                   ) tb_env_t;

   tb_env_t m_env;
   

`ifdef SETUP_KBAXI4LITE

     uvm_sequencer #(kb_axi4lite_agent_item) m_psif_axi4_sqr;    
     //uvm_sequencer #(spi_4wire_agent_item) m_spi_4wire_sqr;    
    
     typedef kb_axi4lite_agent_config config_t;
     typedef uvm_reg_predictor #(kb_axi4lite_agent_item) reg_predictor_t;
   
     reg2axi4lite_adapter m_psif_axi4lite_adapter_all;
     reg2axi4lite_adapter m_psif_axi4lite_adapter_rw;

   `else

     mvc_sequencer m_psif_axi4_sqr;    

     typedef axi4_vip_config #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE 
                               ) config_t;
    
     
     typedef axi4_master_rw_transaction #(AXI4_ADDRESS_WIDTH,
    					AXI4_RDATA_WIDTH,
    					AXI4_WDATA_WIDTH,
    					AXI4_ID_WIDTH,
    					AXI4_USER_WIDTH,
    					AXI4_REGION_MAP_SIZE)  axi4_rw_item_t;    
     
     typedef reg2axi4lite_adapter #(axi4_rw_item_t,
    				  AXI4_ADDRESS_WIDTH  , 
    				  AXI4_RDATA_WIDTH    ,
    				  AXI4_WDATA_WIDTH    ,
    				  AXI4_ID_WIDTH       ,
    				  AXI4_USER_WIDTH     ,
    				  AXI4_REGION_MAP_SIZE) reg2axi4lite_adapter_t;   
    
     typedef axi4lite_reg_predictor #(axi4_rw_item_t,
    				    AXI4_RDATA_WIDTH    ,
    				    AXI4_WDATA_WIDTH    ,
    				    AXI4_ID_WIDTH       ,
    				    AXI4_USER_WIDTH     ,
    				    AXI4_REGION_MAP_SIZE) reg_predictor_t;
        
     reg2axi4lite_adapter_t m_psif_axi4lite_adapter_all;
     reg2axi4lite_adapter_t m_psif_axi4lite_adapter_rw;

   `endif // !`ifdef SETUP_KBAXI4LITE

   config_t m_psif_master_cfg;
   
   //interrupt_handler_config#(32) m_psif_irq_handler_cfg;
   //uvm_sequencer #(interrupt_handler_item) m_irq_psif_sqr; 

   reg_predictor_t m_psif_reg_predictor_all;
   reg_predictor_t m_psif_reg_predictor_rw;

   uvm_table_printer m_printer;

   top_PSIF     m_psif_regs_all;
   top_PSIF_rw  m_psif_regs_rw;

   // Log files declared, but MUST be opened in the actual test case end_of_elaboration_phase 
   integer file_h;
   integer error_file_h;

   // Declare reset agent config
   reset_agent_config  m_reset_agent_cfg;

   // Declare reset sequencer
   uvm_sequencer #(reset_agent_item)  m_reset_agent_sqr; 

   // Declare reset test case sequences
   top_reset_seq   m_top_reset_seq;

    // KB_AXI4STREAM sequencer 
    uvm_sequencer #(kb_axi4stream_agent_item) m_kb_axi4stream_sqr;    

   // Declare oled_spi agent config
   oled_spi_agent_config  m_oled_spi_agent_cfg;

   // Declare spi_4wire agent config
   // spi_4wire_agent_config  m_spi_4wire_agent_cfg;
 
   // AXI4STREAM agent config      
   kb_axi4stream_agent_config m_kb_axi4stream_agent_cfg;
     
   function new( string name="tb_env" , uvm_component parent=null );
      super.new( name , parent );
      // Create reset sequence.
      m_top_reset_seq= top_reset_seq::type_id::create("m_top_reset_seq");
   endfunction


   function void build_phase(uvm_phase phase);

      //################################################
      //# Reset handler config
      //################################################

      m_reset_agent_cfg=reset_agent_config::type_id::create("m_reset_agent_cfg");
      
      // This statement sets the reset_if in m_reset_cfg called reset_if to the TOP_RESET_IF.
      if(!uvm_config_db #( virtual reset_agent_if )::get( this , "", "TOP_RESET_IF" , // NOTE: TOP_RESET_IF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file.
							  m_reset_agent_cfg.reset_if ))  // NOTE: reset_if is of type reset_agent_if declared in reset_agent config class.
         `uvm_error(get_type_name() , "uvm_config_db #(virtual reset_if::get cannot find resource TOP_RESET_IF" );      

      // Publish config for reset handler
      uvm_config_db #(reset_agent_config  )::set( this , "*m_env.m_reset_agent*" ,"reset_agent_config" , m_reset_agent_cfg );

      
      //################################################
      //# IRQ PSIF Interface Handler config
      //################################################

/* -----\/----- EXCLUDED -----\/-----
      m_psif_irq_handler_cfg=interrupt_handler_config#(32)::type_id::create("m_psif_irq_handler_cfg");
      
      // This statement sets the interrupt_if in m_psif_irq_handler_cfg called irq_if to the IRQ_HANDLER_PSIF.
      //   The interrupt irq_if from the DUT is assigned to the psif_interrupt_if  irq  pins in the tb_top_beh.sv file. 
      if(!uvm_config_db #( virtual interrupt_if#(32) )::get( this , "", "IRQ_HANDLER_PSIF" , // NOTE: IRQ_HANDLER_PSIF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file.
							     m_psif_irq_handler_cfg.irq_if ))  // NOTE: irq_if is of type interrupt_if declared in interrupt config class.
         `uvm_error(get_type_name() , "uvm_config_db #(virtual interrupt_if#(32)::get cannot find resource IRQ_HANDLER_PSIF" );      

      // Publish config for irq handler
      uvm_config_db #(interrupt_handler_config#(32)  )::set( this , "*m_env.m_psif_irq_handler*" ,"interrupt_handler_agent_config" ,m_psif_irq_handler_cfg );
 -----/\----- EXCLUDED -----/\----- */


      //################################################
      //# OLED_SPI handler config
      //################################################

      m_oled_spi_agent_cfg=oled_spi_agent_config::type_id::create("m_oled_spi_agent_cfg");
      
      // This statement sets the oled_spi_if in m_oled_spi_cfg called oled_spi_if to the TOP_OLED_SPI_IF.
      if(!uvm_config_db #( virtual oled_spi_agent_if )::get( this , "", "TOP_OLED_SPI_IF" , // NOTE: TOP_OLED_SPI_IF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file.
							  m_oled_spi_agent_cfg.oled_spi_if ))  // NOTE: oled_spi_if is of type oled_spi_agent_if declared in oled_spi_agent config class.
         `uvm_error(get_type_name() , "uvm_config_db #(virtual oled_spi_if::get cannot find resource TOP_OLED_SPI_IF" );      

      // Publish config for oled_spi handler
      uvm_config_db #(oled_spi_agent_config  )::set( this , "*m_env.m_oled_spi_agent*" ,"oled_spi_agent_config" , m_oled_spi_agent_cfg );


      //################################################
      //# SPI_4WIRE handler config
      //################################################

/* -----\/----- EXCLUDED -----\/-----
      m_spi_4wire_agent_cfg=spi_4wire_agent_config::type_id::create("m_spi_4wire_agent_cfg");
      
      // This statement sets the spi_4wire_if in m_spi_4wire_cfg called spi_4wire_if to the TOP_SPI_4WIRE_IF.
      if(!uvm_config_db #( virtual spi_4wire_agent_if )::get( this , "", "TOP_SPI_4WIRE_IF" , // NOTE: TOP_SPI_4WIRE_IF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file.
							  m_spi_4wire_agent_cfg.spi_4wire_if ))  // NOTE: spi_4wire_if is of type spi_4wire_agent_if declared in spi_4wire_agent config class.
         `uvm_error(get_type_name() , "uvm_config_db #(virtual spi_4wire_if::get cannot find resource TOP_SPI_4WIRE_IF" );      

      // Publish config for spi_4wire handler
      uvm_config_db #(spi_4wire_agent_config  )::set( this , "*m_env.m_spi_4wire_agent*" ,"spi_4wire_agent_config" , m_spi_4wire_agent_cfg );
 -----/\----- EXCLUDED -----/\----- */


      //################################################
      //# KB_AXI4STREAM handler config
      //################################################

      m_kb_axi4stream_agent_cfg= kb_axi4stream_agent_config::type_id::create("m_kb_axi4stream_agent_cfg");
      
      // This statement sets the kb_axi4stream_if in m_kb_axi4stream_cfg called kb_axi4stream_if to the TOP_KB_AXI4STREAM_IF.
      if(!uvm_config_db #( virtual kb_axi4stream_agent_if )::get( this , "", "TOP_KB_AXI4STREAM_IF" , // NOTE: TOP_KB_AXI4STREAM_IF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file.
							     m_kb_axi4stream_agent_cfg.kb_axi4stream_if ))  // NOTE: kb_axi4stream_if is of type kb_axi4stream_agent_if declared in kb_axi4stream_agent config class.
         `uvm_error(get_type_name() , "uvm_config_db #(virtual kb_axi4stream_if::get cannot find resource TOP_KB_AXI4STREAM_IF" );      

      // Publish config for kb_axi4stream handler
      uvm_config_db #(kb_axi4stream_agent_config )::set( this , "*m_env.m_kb_axi4stream_agent*" ,"kb_axi4stream_agent_config" , m_kb_axi4stream_agent_cfg );



      //################################################
      //# AXI4 LITE CONFIG
      //################################################
      m_psif_master_cfg=config_t::type_id::create("m_psif_master_cfg");

`ifdef SETUP_KBAXI4LITE
      
      // Here is the DUT interface "connected" to the kb_axi4lite agent in the testbench!! 
      if(!uvm_config_db #(virtual kb_axi4lite_agent_if )::get( this , "", "PSIF_AXI4LITE_MASTER_IF" , // NOTE: PSIF_AXI4LITE_MASTER_IF name is registered in the uvm_config_db in the tb_top_beh.sv testbench file. 
							       m_psif_master_cfg.vif ))   // NOTE: vif is of type kb_axi4lite_agent_if
	      `uvm_error(get_type_name() , "Can't find resource PSIF_AXI4LITE_MASTER_IF" );      
      
      m_psif_master_cfg.is_active=UVM_ACTIVE;
      
      
      // Publish config for AXI4 master IF agents
      uvm_config_db #( kb_axi4lite_agent_config )::set( this , "*m_env.m_psif_axi4lite_master_agent*" ,
							"kb_axi4lite_agent_config" , m_psif_master_cfg);

   `else
     
      // Get virtual interface handles

      if(!uvm_config_db #( bfm_type )::get( this , "", "PSIF_AXI4LITE_MASTER_IF" , 
                                            m_psif_master_cfg.m_bfm ))
	`uvm_error(get_type_name() , "Can't find resource PSIF_AXI4LITE_MASTER_IF" );      

      // Configure our PSIF axi4 agent

      m_psif_master_cfg.agent_cfg.agent_type = AXI4_MASTER;
      m_psif_master_cfg.agent_cfg.if_type = AXI4_LITE;
      m_psif_master_cfg.agent_cfg.en_cvg.func = 1;
      m_psif_master_cfg.agent_cfg.en_cvg.wr_ch_toggle = 1;
      m_psif_master_cfg.agent_cfg.en_cvg.rd_ch_toggle = 1; 
      m_psif_master_cfg.agent_cfg.en_sb = 1'b0; 
      m_psif_master_cfg.delete_analysis_component("trans_ap","checker");

      m_psif_master_cfg.num_concurrent_iterations = 95;

      // Publish config for agent
      uvm_config_db #( uvm_object )::set( this , "*m_env.m_psif_axi4lite_master_agent*" , mvc_config_base_id , m_psif_master_cfg);

     
   `endif
    
      //################################################
      //# Create Env
      //################################################ 

         // Moved to class that uses base_test
//       m_env = tb_env_t::type_id::create("m_env",this);

      //################################################
      //# Setup of register package
      //################################################

      // Include all types of coverage
      uvm_reg::include_coverage("*", UVM_CVR_ADDR_MAP);
      // Enable sampling on address coverage

      m_psif_regs_all = top_PSIF::type_id::create("m_psif_regs_all");
      // regs need a manual build()
      m_psif_regs_all.build();                   
      void'(m_psif_regs_all.set_coverage(UVM_CVR_ADDR_MAP));

      m_psif_regs_rw = top_PSIF_rw::type_id::create("m_psif_regs_rw");          
      // regs need a manual build()
      m_psif_regs_rw.build();                   
      void'(m_psif_regs_rw.set_coverage(UVM_CVR_ADDR_MAP));

      
      //################################################
      //# Adapter for register bus
      //################################################
`ifdef SETUP_KBAXI4LITE
      m_psif_axi4lite_adapter_all =reg2axi4lite_adapter::type_id::create("m_psif_axi4lite_adapter_all");
      m_psif_axi4lite_adapter_rw  =reg2axi4lite_adapter::type_id::create("m_psif_axi4lite_adapter_rw");
   `else
      m_psif_axi4lite_adapter_all =reg2axi4lite_adapter_t::type_id::create("m_psif_axi4lite_adapter_all");
      m_psif_axi4lite_adapter_rw  =reg2axi4lite_adapter_t::type_id::create("m_psif_axi4lite_adapter_rw");
   `endif
   
       //################################################
      //# Predictor for register bus
      //################################################
      m_psif_reg_predictor_all = reg_predictor_t::type_id::create("m_psif_reg_predictor_all", this);
      m_psif_reg_predictor_rw = reg_predictor_t::type_id::create("m_psif_reg_predictor_rw", this);

      //##############################################################
      //# Setup topology print (see page 20-21 and 102 in V.R. Cooper
      //##############################################################
      m_printer = new();
      m_printer.knobs.depth = 5;
 
   endfunction




   function void connect_phase(uvm_phase phase);

      // Get a pointer to the sequencers
      $cast(m_reset_agent_sqr, uvm_top.find("*m_env.m_reset_agent.sequencer"));
      $cast(m_psif_axi4_sqr, uvm_top.find("*m_env.m_psif_axi4lite_master_agent.sequencer"));
      // $cast(m_irq_psif_sqr, uvm_top.find("*m_env.m_psif_irq_handler.m_sequencer"));
      // $cast(m_spi_4wire_sqr, uvm_top.find("*m_env.m_spi_4wire_agent.sequencer"));
      $cast(m_kb_axi4stream_sqr, uvm_top.find("*m_env.m_kb_axi4stream_agent.sequencer"));      

      // Connect register components
      // direct connection to bus VIP

      // PSIF:

      m_psif_regs_all.top_if_map.set_sequencer(m_psif_axi4_sqr, m_psif_axi4lite_adapter_all); 
      m_psif_regs_rw.top_if_map.set_sequencer(m_psif_axi4_sqr, m_psif_axi4lite_adapter_rw); 

      m_psif_reg_predictor_all.map     = m_psif_regs_all.top_if_map;
      m_psif_reg_predictor_rw.map      = m_psif_regs_rw.top_if_map;

      m_psif_reg_predictor_all.adapter = m_psif_axi4lite_adapter_all;
      m_psif_reg_predictor_rw.adapter  = m_psif_axi4lite_adapter_rw;

      m_psif_regs_all.top_if_map.set_auto_predict(0); // Turn off autopredict; Use the uvm_reg_predictor !! 
      // m_psif_regs_all.top_if_map.set_check_on_read(.on(TRUE)); // This must be unused/commented out due to used in regr/regc tasks

      m_psif_regs_rw.top_if_map.set_auto_predict(0); // Turn off autopredict; Use the uvm_reg_predictor !! 
      // m_psif_regs_rw.top_if_map.set_check_on_read(.on(TRUE));  // This must be unused/commented out due to used in regr/regc tasks

      // Connect the predictor to the bus agent monitor analysis port
`ifdef SETUP_KBAXI4LITE
       m_env.m_psif_axi4lite_master_agent.m_monitor.ap.connect(m_psif_reg_predictor_all.bus_in);
       m_env.m_psif_axi4lite_master_agent.m_monitor.ap.connect(m_psif_reg_predictor_rw.bus_in);
    `else
       m_env.m_psif_axi4lite_master_agent.ap["trans_ap"].connect(m_psif_reg_predictor_all.bus_item_export);
       m_env.m_psif_axi4lite_master_agent.ap["trans_ap"].connect(m_psif_reg_predictor_rw.bus_item_export);
    `endif

   endfunction
   

   virtual function void start_of_simulation_phase(uvm_phase phase);

      // Set report severity
      uvm_top.set_report_default_file_hier(file_h);
      uvm_top.set_report_severity_file_hier(UVM_ERROR, error_file_h); // Errors logged here; comment out for errors in default log file!!
      uvm_top.set_report_severity_action_hier(UVM_INFO, UVM_LOG | UVM_LOG);
      uvm_top.set_report_severity_action_hier(UVM_WARNING, UVM_LOG | UVM_LOG);
      uvm_top.set_report_severity_action_hier(UVM_ERROR, UVM_DISPLAY | UVM_LOG);

      `uvm_info(get_type_name(), $sformatf("Printing the test topology :\n%s", this.sprint(m_printer)), UVM_MEDIUM); // May be set to UVM_DEBUG?
      factory.print();

   endfunction // end_of_elaboration_phase   

   
endclass // base_test
