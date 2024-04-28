
class psif_zu_csim_seq_virtual extends base_seq;
   `uvm_object_utils(psif_zu_csim_seq_virtual);

   // Set timeout; default set to 10 ms, but may have to be set to a higher value!!
   const time TIME_OUT= 500ms;
   event simulation_timeout;

   // Declare the UVM sequencers
   uvm_reg_hw_reset_seq  m_psif_reg_hw_reset_seq;
   
   // Declare the test case sequences
   psif_zu_csim_seq  m_psif_zu_csim_seq; 
//   spi_4wire_seq     m_spi_4wire_seq;
   
   function new( string name="psif_zu_csim_seq" );
      super.new( name );
      // Create "built-in" uvm_reg_hw_reset sequences.
      m_psif_reg_hw_reset_seq= uvm_reg_hw_reset_seq::type_id::create("m_psif_reg_hw_reset_seq");
      // Create test sequences.
      m_psif_zu_csim_seq= psif_zu_csim_seq::type_id::create("m_psif_zu_csim_seq");
//      m_spi_4wire_seq= spi_4wire_seq::type_id::create("m_spi_4wire_seq");
   endfunction

   task body;

      // Set instances of uvm_reg_hw_reset_seq register model to m_psif_regs_all, m_psif_regs_rw ,
      //   m_bif_regs_all, m_bif_regs_rw defined in base_seq.
      m_psif_reg_hw_reset_seq.model= m_psif_regs_all;
      m_psif_reg_hw_reset_seq.model= m_psif_regs_rw;

      // Set instances of sequence register models to m_psif_regs_all, m_psif_regs_rw ,
      //   m_bif_regs_all, m_bif_regs_rw defined in base_seq.
      m_psif_zu_csim_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_zu_csim_seq.m_psif_regs_rw= m_psif_regs_rw;
            
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

      // Run the SPI 4WIRE DTI sequence
//      fork
//        m_spi_4wire_seq.start(m_spi_4wire_sqr);   
//      join_none;            
          
      // Run the PSIF and BIF REV modules register tests until TIME_OUT
      // The m_psif_axi4_sqr sequencer are defined in base_test
      fork: simulation_threads
         fork
//           m_psif_zu_csim_seq.start(m_spi_4wire_sqr);
           m_psif_zu_csim_seq.start(null);
         join
         wait_for_sim_timeout;  
      join_any;
      
      
   endtask : body
   

   // Wait for timeout; the task writes error report to error log file!
   task wait_for_sim_timeout();
     @simulation_timeout;
     `uvm_error(get_type_name(),"Timeout; simulation terminated.");          
   endtask : wait_for_sim_timeout;
  
endclass // psif_zu_csim_seq_virtual
