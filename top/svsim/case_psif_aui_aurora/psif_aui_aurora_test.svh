class psif_aui_aurora_test extends base_test;
   
   `uvm_component_utils(psif_aui_aurora_test);

   // Declare the virtual sequences
   psif_aui_aurora_seq_virtual  m_psif_aui_aurora_seq_virtual;
   
   
   function new( string name="psif_aui_aurora_test" , uvm_component parent=null );
      super.new( name , parent );
   endfunction

   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     // Set used coverage; i.e. override base coverage class created in tb_env_base.
// Currently not used:
//     factory.set_type_override_by_type(coverage_base::get_type(), psif_aui_aurora_coverage::get_type());
     // Create testbench environment
     m_env = tb_env_t::type_id::create("m_env",this);
   endfunction


   virtual function void end_of_elaboration_phase(uvm_phase phase);

      // Define log files declared in base test
      file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_aui_aurora/psif_aui_aurora_test.sim/psif_aui_aurora_test.log", "w");
      error_file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_aui_aurora/psif_aui_aurora_test.sim/psif_aui_aurora_test_error.log", "w");

   endfunction // end_of_elaboration_phase
   
      
   task run_phase(uvm_phase phase);

      // Create psif_aui_aurora_seq_virtual instance m_psif_aui_aurora_seq_virtual.
      m_psif_aui_aurora_seq_virtual= psif_aui_aurora_seq_virtual::type_id::create("m_psif_aui_aurora_seq_virtual");

      // Connect PSIF register and memory definitions to m_psif_aui_aurora_seq_virtual sequencer instance (i.e. psif_aui_aurora_seq_virtual)
      m_psif_aui_aurora_seq_virtual.m_psif_regs_all= m_psif_regs_all; 
      m_psif_aui_aurora_seq_virtual.m_psif_regs_rw= m_psif_regs_rw;

      // Assign value to the sequencers used in the virtual sequence. 
      // The m_rif_axi4_sqr and m_psif_axi4_sqr sequencer is declared in base_seq. 
      m_psif_aui_aurora_seq_virtual.m_psif_axi4_sqr= m_psif_axi4_sqr;

      m_psif_aui_aurora_seq_virtual.m_kb_axi4stream_sqr= m_kb_axi4stream_sqr;

      // Start the test!
// Currently not used: Objection removed due to objection in coverage class psif_aui_aurora_coverage; ref. factory override in build_phase.         
      phase.raise_objection(null,"Starting test");

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
                        
        m_psif_aui_aurora_seq_virtual.start(null);
                         
     // Test complete!          
// Currently not used: Simulation ends when coverage requirements in class psif_aui_aurora_coverage satisfied; ref. factory override in build_phase.         
     phase.drop_objection(null,"Test done, ending simulation");

   endtask // run_phase
   
endclass // psif_aui_aurora_test
