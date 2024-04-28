class psif_dti_spi_module_test extends base_test;
   
   `uvm_component_utils(psif_dti_spi_module_test);

   // Declare the virtual sequences
   psif_dti_spi_module_seq_virtual  m_psif_dti_spi_module_seq_virtual;
   

   function new( string name="psif_dti_spi_module_test" , uvm_component parent=null );
      super.new( name , parent );
   endfunction

   
   function void build_phase(uvm_phase phase);      
     super.build_phase(phase);

     // Set used dti_spi scoreboard; i.e. override dti_spi base scoreboard class created in tb_env_base. 
     factory.set_type_override_by_type(scoreboard_dti_spi_base::get_type(), scoreboard_dti_spi::get_type());   
      
     // Set used dti_spi coverage; i.e. override dti_spi base coverage class created in tb_env_base. 
     factory.set_type_override_by_type(coverage_dti_spi_base::get_type(), coverage_dti_spi::get_type());  
              
     // Create testbench environment
     m_env = tb_env_t::type_id::create("m_env",this);
   endfunction   

   virtual function void end_of_elaboration_phase(uvm_phase phase);

      // Define log files declared in base test
      file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_dti_spi_module/psif_dti_spi_module_test.sim/psif_dti_spi_module_test.log", "w");
      error_file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_dti_spi_module/psif_dti_spi_module_test.sim/psif_dti_spi_module_test_error.log", "w");

   endfunction // end_of_elaboration_phase
   
      
   task run_phase(uvm_phase phase);

      // Create psif_dti_spi_module_seq instance m_psif_dti_spi_module_seq_virtual.
      m_psif_dti_spi_module_seq_virtual= psif_dti_spi_module_seq_virtual::type_id::create("m_psif_dti_spi_module_seq_virual");

      // Connect PSIF register and memory definitions to m_psif_dti_spi_module_seq_virtual sequencer instance (i.e. psif_dti_spi_module_seq_virtual)
      m_psif_dti_spi_module_seq_virtual.m_psif_regs_all= m_psif_regs_all; 
      m_psif_dti_spi_module_seq_virtual.m_psif_regs_rw= m_psif_regs_rw;

      // Assign value to the sequencers used in the virtual sequence. 
      // The m_psif_axi4_sqr sequencer is declared in base_seq. 
      m_psif_dti_spi_module_seq_virtual.m_psif_axi4_sqr= m_psif_axi4_sqr;
      m_psif_dti_spi_module_seq_virtual.m_spi_4wire_sqr= m_spi_4wire_sqr;

      // Start the test!
// Simulation length determined by the coverage_dti_spi class used
//      phase.raise_objection(null,"Starting test");

        // Print all registers in PSIF; both "all" and "rw"!
        m_psif_regs_all.print();
        m_psif_regs_rw.print();

        // Reset DUT. The m_reset_agent_sqr sequencer and the m_top_reset_seq sequence 
        //   are defined in base_test
        m_top_reset_seq.start(m_reset_agent_sqr);
 

        // Delay for MMCM setup. MMCM currently not used, but included for later MMCM usage ....
        #30us; // Wait for MMCM locked!!!!!!!!!!!!!!!

        // Sets the mirror and desired values to the reset value (i.e set by set_reset field in CSV register files).
        m_psif_regs_all.reset(); 
        m_psif_regs_rw.reset(); 
                        
        // Run the PSIF ODI module register tests
        m_psif_dti_spi_module_seq_virtual.start(null); 
                         
     // Test complete!          
//     phase.drop_objection(null,"Test done, ending simulation");

   endtask // run_phase
   
endclass // psif_dti_spi_module_test
