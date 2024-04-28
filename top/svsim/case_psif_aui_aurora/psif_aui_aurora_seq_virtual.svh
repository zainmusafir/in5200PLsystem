
class psif_aui_aurora_seq_virtual extends base_seq;
   `uvm_object_utils(psif_aui_aurora_seq_virtual);

   // Set timeout; default set to 10 ms, but may have to be set to a higher value!!
   const time TIME_OUT= 50ms;
   event simulation_timeout;

   // Declare the UVM sequencers
   uvm_reg_hw_reset_seq  m_psif_reg_hw_reset_seq;
   
   // Declare the test case sequencers    
   psif_aui_aurora_init_seq   m_psif_aui_aurora_init_seq;
   psif_aui_aurora_loop_seq   m_psif_aui_aurora_loop_seq;
   psif_aui_aurora_tx_seq     m_psif_aui_aurora_tx_seq;
   psif_aui_aurora_rx_seq     m_psif_aui_aurora_rx_seq;
   aurora_seq                m_aurora_seq;
   
   function new( string name="psif_aui_aurora_seq_virtual" );
      super.new( name );
      // Create "built-in" uvm_reg_hw_reset sequences.
      m_psif_reg_hw_reset_seq= uvm_reg_hw_reset_seq::type_id::create("m_psif_reg_hw_reset_seq");      
      // Create test sequences.
      m_psif_aui_aurora_init_seq= psif_aui_aurora_init_seq::type_id::create("m_psif_aui_aurora_init_seq");
      m_psif_aui_aurora_loop_seq= psif_aui_aurora_loop_seq::type_id::create("m_psif_aui_aurora_loop_seq");
      m_psif_aui_aurora_tx_seq= psif_aui_aurora_tx_seq::type_id::create("m_psif_aui_aurora_tx_seq");
      m_psif_aui_aurora_rx_seq= psif_aui_aurora_rx_seq::type_id::create("m_psif_aui_aurora_rx_seq");
      m_aurora_seq= aurora_seq::type_id::create("m_aurora_seq");
   endfunction

   task body;

      // Set instances of uvm_reg_hw_reset_seq register model to m_psif_regs_all and 
      //   m_psif_regs_rw defined in base_seq.
      m_psif_reg_hw_reset_seq.model= m_psif_regs_all;
      m_psif_reg_hw_reset_seq.model= m_psif_regs_rw;

      // Set instances of sequence register models m_psif_regs_all, m_psif_regs_rw defined in base_seq.
      m_psif_aui_aurora_init_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_aui_aurora_init_seq.m_psif_regs_rw= m_psif_regs_rw;
      m_psif_aui_aurora_loop_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_aui_aurora_loop_seq.m_psif_regs_rw= m_psif_regs_rw;
      m_psif_aui_aurora_tx_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_aui_aurora_tx_seq.m_psif_regs_rw= m_psif_regs_rw;
      m_psif_aui_aurora_rx_seq.m_psif_regs_all= m_psif_regs_all; 
      m_psif_aui_aurora_rx_seq.m_psif_regs_rw= m_psif_regs_rw;

      // Check all initial values before the simulation case start 
      // The m_psif_axi4_sqr sequencers are defined in base_test
//      m_psif_reg_hw_reset_seq.start(m_psif_axi4_sqr);
            
      // Set timeout length
      fork
        begin
          #TIME_OUT;
          -> simulation_timeout;
        end
      join_none; 


      // Run the Aurora sequence
      fork : aurora_block
        m_aurora_seq.start(m_kb_axi4stream_sqr);
      join_none;         
            
          
      // Run the external Aurora TX to RX loop tests until TIME_OUT
      fork: simulation_threads 
         begin
           m_psif_aui_aurora_init_seq.start(null);
           m_psif_aui_aurora_loop_seq.start(null);
           fork  
             m_psif_aui_aurora_tx_seq.start(null);
             m_psif_aui_aurora_rx_seq.start(null);
           join
         end
         wait_for_sim_timeout;  
      join_any;
      
      
   endtask : body
   

   // Wait for timeout; the task writes error report to error log file!
   task wait_for_sim_timeout();
     @simulation_timeout;
     `uvm_error(get_type_name(),"Timeout; simulation terminated.");          
   endtask : wait_for_sim_timeout;
  
endclass // psif_aui_aurora_seq_virtual
