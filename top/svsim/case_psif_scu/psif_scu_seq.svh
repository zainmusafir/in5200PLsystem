`include "uvm_macros.svh"

class psif_scu_seq extends base_seq;
   `uvm_object_utils(psif_scu_seq);

   int es;            // Task exit status (i.e. es)
   
   function new( string name="psif_scu_seq" );
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

      // Perform test of SCUregisters

      regc(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_ENA",'h0);   //checks enable

      regw(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_ENA",'h1);
      regc(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_ENA",'h1);
                         //   SCU_TEMPERATURE_TEST_DIGIT0

      regw(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_DIGIT0",'h8);   //writes 9 
      regc(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_DIGIT0",'h8);


      regw(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_DIGIT1",'h9);
      regc(es,"PSIF","SCU","SCU_TEMPERATURE_TEST_DIGIT1",'h9);

      //regc(es,"PSIF","SCU","SCU_PS_ACCESS_ENA",'h1);
      
     
      // Scoreboard terminates execution when all OLED SPI data have been generated.
      //   by the oled_ctrl module in the SCUmodule.



      //   This takes approx. how much ?  3.3 ms
              
   endtask : body
   
endclass // psif_scu_seq
