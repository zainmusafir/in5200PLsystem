`include "uvm_macros.svh"

class psif_aui_aurora_init_seq extends base_seq;
   `uvm_object_utils(psif_aui_aurora_init_seq);

   int es;  // Task exit status (i.e. es)

   logic [31:0] aurora_core_status;
      
   function new( string name="psif_aui_aurora_init_seq" );
      super.new( name );
   endfunction

   task body;

      //##############################################################
      // Get registers for tasks regw, regr and regc    
      // Get memories for tasks memw, memr and memc    
      //##############################################################      
      m_psif_regs_all.get_registers(psif_regs);  
      m_psif_regs_all.get_blocks(psif_blocks);      
      m_psif_regs_all.get_memories(psif_mems);
      

      // Print all blocks (i.e. modules) in PSIF
      foreach (psif_blocks[i]) begin  // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Module names: %s", psif_blocks[i].get_name().toupper), UVM_MEDIUM);
      end
      // Print all registers in PSIF
      foreach (psif_regs[i]) begin   // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Register names: %s", psif_regs[i].get_name().toupper), UVM_MEDIUM);
      end

      // Print "everything" in m_psif_regs_all
      m_psif_regs_all.print();
      m_psif_regs_rw.print();
 
      // Power on sequence start
 
      regc(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h1);

      regc(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h1);

      #1us;

      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h0);
      #5us;

      regw(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h0);
      #5us;

      // Power on sequence end
      
      // Normal operation reset start        
      
      regw(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h1);
      #5us; // Shall be at least 128 user_clk; i.e. ~2us but set to 5us.

      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h1);
      #30us; // Shall be one second on target; see PG046 page 56.
      
      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h0);     
      #1us;

      regw(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h0);

      // Normal operation reset end

      // Wait for  Aurora link up and channel up.
      do begin
        #10us;	 
        regr(es, "PSIF","AUI","AUI_AURORA_CORE_STATUS", aurora_core_status,"OFF");
      end while (aurora_core_status[0] != 1 && aurora_core_status[5] != 1);

      // Set to normal operation, but see UG476 and PG046 for loopback setting
      regw(es,"PSIF","AUI","AUI_AURORA_LOOPBACK", 'h0);
      regc(es,"PSIF","AUI","AUI_AURORA_LOOPBACK", 'h0);      
                              
   endtask : body
   
endclass //psif_aui_aurora_init_seq
