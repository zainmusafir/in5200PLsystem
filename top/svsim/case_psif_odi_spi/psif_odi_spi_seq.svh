`include "uvm_macros.svh"

class psif_odi_spi_seq extends base_seq;
   `uvm_object_utils(psif_odi_spi_seq);

   int es;            // Task exit status (i.e. es)
   
   function new( string name="psif_odi_spi_seq" );
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

      // Perform test of ODI registers

      regc(es,"PSIF","ODI","ODI_PS_ACCESS_ENA",'h0);
      regw(es,"PSIF","ODI","ODI_PS_ACCESS_ENA",'h1);
      regc(es,"PSIF","ODI","ODI_PS_ACCESS_ENA",'h1);
      
      regc(es,"PSIF","ODI","ODI_OLEDBYTE3_0",'h21202020);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE3_0",'h12345678);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE3_0",'h12345678);

      regc(es,"PSIF","ODI","ODI_OLEDBYTE7_4",'h20212020);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE7_4",'h9ABCDEF0);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE7_4",'h9ABCDEF0);

      regc(es,"PSIF","ODI","ODI_OLEDBYTE11_8",'h20202120);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE11_8",'h56781234);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE11_8",'h56781234);

      regc(es,"PSIF","ODI","ODI_OLEDBYTE15_12",'h20202021);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE15_12",'hDEF0ABCD);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE15_12",'hDEF0ABCD);

      regw(es,"PSIF","ODI","ODI_OLEDBYTE3_0",'h21202020);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE7_4",'h20212020);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE11_8",'h20202120);
      regw(es,"PSIF","ODI","ODI_OLEDBYTE15_12",'h20202021);

      regc(es,"PSIF","ODI","ODI_OLEDBYTE3_0",'h21202020);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE7_4",'h20212020);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE11_8",'h20202120);
      regc(es,"PSIF","ODI","ODI_OLEDBYTE15_12",'h20202021);
      
      // Scoreboard terminates execution when all OLED SPI data have been generated.
      //   by the oled_ctrl module in the ODI module.
      //   This takes approx. 7.3 ms.
              
   endtask : body
   
endclass // psif_odi_spi_seq
