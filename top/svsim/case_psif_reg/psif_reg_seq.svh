class psif_reg_seq extends base_seq;
   `uvm_object_utils(psif_reg_seq);
   
   int es; // Task exit status
   
   function new( string name="psif_reg_seq" );
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
      foreach (psif_blocks[i]) begin                             // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Module names: %s", psif_blocks[i].get_name().toupper), UVM_MEDIUM);
      end
      // Print all registers in PSIF
      foreach (psif_regs[i]) begin                             // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Register names: %s", psif_regs[i].get_name().toupper), UVM_MEDIUM);
      end

      // Perform access test in all modules in PSIF interface to check addressing errors for RW registers
      reg_addresscheck(es, "PSIF"); 
        
   endtask : body
   
endclass // psif_reg_seq
