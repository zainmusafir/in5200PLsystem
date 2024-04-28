
class tb_env #(int AXI4_ADDRESS_WIDTH   = 32, 
               int AXI4_RDATA_WIDTH     = 32,
	       int AXI4_WDATA_WIDTH     = 32,
	       int AXI4_ID_WIDTH        = 4,
	       int AXI4_USER_WIDTH      = 4,
	       int AXI4_REGION_MAP_SIZE = 16 
	     ) extends tb_env_base ;
   
   `uvm_component_utils(tb_env);
   

   typedef oled_spi_agent  oled_spi_agent_t;
   oled_spi_agent_t        m_oled_spi_agent;

//   typedef spi_4wire_agent spi_4wire_agent_t;
//   spi_4wire_agent_t       m_spi_4wire_agent;
   
   // Declare the DNIC agent interface
   typedef kb_axi4stream_agent kb_axi4stream_agent_t;
   kb_axi4stream_agent_t  m_kb_axi4stream_agent;

   // Declare OLED SPI scoreboard base class
   scoreboard_oled_spi_base m_scoreboard_oled_spi_base;
   
   // Declare OLED SPI coverage_base class 
   // Removed to reduce complextity of OLED_SPI and SCU testcases
   // coverage_oled_spi_base   m_coverage_oled_spi_base;

   // Declare DTI SPI scoreboard base class
//   scoreboard_dti_spi_base m_scoreboard_dti_spi_base;

   // Declare DTI SPI coverage_base class 
//   coverage_dti_spi_base    m_coverage_dti_spi_base;

   // Declare ZU scoreboard base class
   scoreboard_zu_base       m_scoreboard_zu_base;

     
   function new( string name="tb_env", uvm_component parent=null );
      super.new( name , parent );
   endfunction


   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_oled_spi_agent       = oled_spi_agent_t::type_id::create("m_oled_spi_agent",this);     
      // m_spi_4wire_agent      = spi_4wire_agent_t::type_id::create("m_spi_4wire_agent",this);     
      m_kb_axi4stream_agent  = kb_axi4stream_agent_t::type_id::create("m_kb_axi4stream_agent",this);     

      m_scoreboard_oled_spi_base  = scoreboard_oled_spi_base::type_id::create("m_scoreboard_oled_spi_base", this);
      // Removed to reduce complextity of OLED_SPI and SCU testcases
      // m_coverage_oled_spi_base    = coverage_oled_spi_base::type_id::create("m_coverage_oled_spi_base", this);

      // m_scoreboard_dti_spi_base   = scoreboard_dti_spi_base::type_id::create("m_scoreboard_dti_spi_base", this);
      // m_coverage_dti_spi_base     = coverage_dti_spi_base::type_id::create("m_coverage_dti_spi_base", this);

      m_scoreboard_zu_base   = scoreboard_zu_base::type_id::create("m_scoreboard_zu_base", this);
     
   endfunction // build_phase


   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      m_oled_spi_agent.m_monitor.ap.connect(m_scoreboard_oled_spi_base.oled_spi_monitor_out.analysis_export);
      // Removed to reduce complextity of OLED_SPI and SCU testcases
      // m_oled_spi_agent.m_monitor.ap.connect(m_coverage_oled_spi_base.analysis_export);

      // m_spi_4wire_agent.m_monitor.ap.connect(m_scoreboard_dti_spi_base.dti_spi_monitor_out.analysis_export);
      // m_spi_4wire_agent.m_monitor.ap.connect(m_coverage_dti_spi_base.analysis_export);      
      
   endfunction // connect_phase
   
endclass

