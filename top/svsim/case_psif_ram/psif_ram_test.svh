class psif_ram_test extends base_test;
   
   `uvm_component_utils(psif_ram_test);

   // Declare the sequencers
   // Not necessary for RAM test.
   

   function new( string name="psif_ram_test" , uvm_component parent=null );
      super.new( name , parent );
   endfunction

   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     // Create testbench environment      
     m_env = tb_env_t::type_id::create("m_env",this);   
   endfunction
   

   virtual function void end_of_elaboration_phase(uvm_phase phase);

      // Define log files
      file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_ram/psif_ram_test.sim/psif_ram_test.log", "w");
      error_file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_ram/psif_ram_test.sim/psif_ram_test_error.log", "w");

   endfunction // end_of_elaboration_phase


   task run_phase(uvm_phase phase);

      uvm_mem_walk_seq  m_mem_walk_seq;

      m_mem_walk_seq=uvm_mem_walk_seq::type_id::create("m_mem_walk_seq");
      m_mem_walk_seq.model=m_psif_regs_rw;

      // Start the test!
      phase.raise_objection(null,"Starting test");

        // Reset DUT. The m_reset_agent_sqr sequencer and the m_top_reset_seq sequence 
        //   are defined in base_test
        m_top_reset_seq.start(m_reset_agent_sqr);
   
        // Delay for MMCM setup. MMCM currently not used, but included for later MMCM usage ....
        #30us; // Wait for MMCM locked!!!!!!!!!!!!!!!

        // Write/check all addresses in all PSIF RW memories/RAM
        m_mem_walk_seq.start(null);
                      
     // Test complete!          
     phase.drop_objection(null,"Test done, ending simulation");

   endtask // run_phase
   
endclass // psif_ram_test
