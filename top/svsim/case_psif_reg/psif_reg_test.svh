class psif_reg_test extends base_test;
   
   `uvm_component_utils(psif_reg_test);

   // Declare the sequencers
   uvm_reg_bit_bash_seq m_reg_bit_bash_seq;
   uvm_reg_hw_reset_seq m_reg_hw_reset_seq;
   psif_reg_seq          m_psif_reg_seq;
   
   function new( string name="psif_reg_test" , uvm_component parent=null );
      super.new( name , parent );
   endfunction

   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     // Create testbench environment      
     m_env = tb_env_t::type_id::create("m_env",this);   
   endfunction // build_phase


   virtual function void end_of_elaboration_phase(uvm_phase phase);

      // Define log files
      file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_reg/psif_reg_test.sim/psif_reg_test.log", "w");
      error_file_h = $fopen("$MLA_DESIGN/top/svsim/case_psif_reg/psif_reg_test.sim/psif_reg_test_error.log", "w");

   endfunction // end_of_elaboration_phase

   
   task run_phase(uvm_phase phase);

      uvm_status_e status;
      uvm_reg_data_t data_rstvalue;
      uvm_reg_data_t data;

      // Create "built-in" uvm_reg_hw_reset sequence.
      m_reg_hw_reset_seq=uvm_reg_hw_reset_seq::type_id::create("m_reg_hw_reset_seq");
      // Set instance of uvm_reg_hw_reset_seq model to m_psif_regs_all defined in base_test.
      m_reg_hw_reset_seq.model=m_psif_regs_all;

      // Create "built-in" uvm_reg_bit_bash sequence.
      m_reg_bit_bash_seq=uvm_reg_bit_bash_seq::type_id::create("m_reg_bit_bash_seq");
      // Set instance of uvm_reg_bit_bash_seq model to m_psif_regs_rw defined in base_test (i.e. only RW registers; not RO and WO).
      m_reg_bit_bash_seq.model=m_psif_regs_rw;

      // Create psif_reg_seq instance m_psif_reg_seq.
      // Connect PSIF register and memory definitions to m_psif_reg_seq sequencer instance (i.e. psif_reg_seq)
      m_psif_reg_seq= psif_reg_seq::type_id::create("m_psif_reg_seq");
      m_psif_reg_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_reg_seq.m_psif_regs_rw= m_psif_regs_rw; 
      
      // Start the test!
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
                        
       // Run the initial/reset value check           
       m_reg_hw_reset_seq.start(null); // Check all initial values

       // Run the write/check walking '1' test to all bits in all RW registers
       // NOT USED IN DESIGN WITH INTERRUPT: ERROR due to PSIFTEST_IRQ_CLR is RW but should be WO ....      
       m_reg_bit_bash_seq.start(null); // Write/check walking '1' to all bits in all RW registers

       // Run the register reg test
       m_psif_reg_seq.start(null);   // Register reg test
//       m_psif_reg_seq.start(m_env.m_psif_axi4lite_master_agent.sequencer);
                         
     // Test complete!          
     phase.drop_objection(null,"Test done, ending simulation");

   endtask // run_phase   
   
endclass // psif_reg_test
