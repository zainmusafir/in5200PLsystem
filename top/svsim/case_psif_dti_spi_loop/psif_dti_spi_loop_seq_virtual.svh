
class psif_dti_spi_loop_seq_virtual extends base_seq;
   `uvm_object_utils(psif_dti_spi_loop_seq_virtual);

   // Set timeout; default set to 10 ms, but may have to be set to a higher value!!
   const time TIME_OUT= 500ms;
   event simulation_timeout;

   // Declare the UVM sequencers
   uvm_reg_hw_reset_seq  m_psif_reg_hw_reset_seq;
   
   // Declare the test case sequences
   psif_dti_spi_loop_seq  m_psif_dti_spi_loop_seq; 
   
   function new( string name="psif_dti_spi_loop_seq" );
      super.new( name );
      // Create "built-in" uvm_reg_hw_reset sequences.
      m_psif_reg_hw_reset_seq= uvm_reg_hw_reset_seq::type_id::create("m_psif_reg_hw_reset_seq");
      // Create test sequences.
      m_psif_dti_spi_loop_seq= psif_dti_spi_loop_seq::type_id::create("m_psif_dti_spi_loop_seq");
   endfunction

   task body;

      // Set instances of uvm_reg_hw_reset_seq register model to m_psif_regs_all, m_psif_regs_rw ,
      //   m_bif_regs_all, m_bif_regs_rw defined in base_seq.
      m_psif_reg_hw_reset_seq.model= m_psif_regs_all;
      m_psif_reg_hw_reset_seq.model= m_psif_regs_rw;

      // Set instances of sequence register models to m_psif_regs_all, m_psif_regs_rw ,
      //   m_bif_regs_all, m_bif_regs_rw defined in base_seq.
      m_psif_dti_spi_loop_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_dti_spi_loop_seq.m_psif_regs_rw= m_psif_regs_rw;
            
      // Check all initial values before the simulation case start 
      // The m_psif_axi4_sqr sequencer are defined in base_test
//      m_psif_reg_hw_reset_seq.start(m_psif_axi4_sqr);
            
      // Set timeout length
      fork
        begin
          #TIME_OUT;
          -> simulation_timeout;
        end
      join_none;     
         
      // Run the PSIF and BIF REV modules register tests until TIME_OUT
      // The m_psif_axi4_sqr sequencer are defined in base_test
      fork: simulation_threads
         fork
           m_psif_dti_spi_loop_seq.start(null);
         join
         wait_for_sim_timeout;  
      join_any;
      
      
   endtask : body
   

   // Wait for timeout; the task writes error report to error log file!
   task wait_for_sim_timeout();
     @simulation_timeout;
     `uvm_error(get_type_name(),"Timeout; simulation terminated.");          
   endtask : wait_for_sim_timeout;
  
endclass // psif_dti_spi_loop_seq_virtual
