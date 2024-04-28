`include "uvm_macros.svh"

class psif_aui_aurora_seq extends base_seq;
   `uvm_object_utils(psif_aui_aurora_seq);

   int es;  // Task exit status (i.e. es)

   int ps_rxfifo_cnt;
      
   function new( string name="psif_aui_aurora_seq" );
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
 
      regc(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h1);

      regc(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h1);
      #1us;
      regw(es, "PSIF","AUI", "AUI_AURORA_RESET", 'h0);

      #5us;
      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h0);
      #1us;
      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h1);
      #1us;
      regw(es, "PSIF","AUI", "AUI_AURORA_GT_RESET", 'h0);

      #20us; // wait for Aurora SERDES initialization
      
      regc(es, "PSIF","AUI", "AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h0);
      regw(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h1);
      regc(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h1);
      regc(es, "PSIF","AUI", "AUI_AURORA_PS_RXFIFO_COUNT", 'h0, "OFF");
      regc(es, "PSIF","AUI", "AUI_AURORA_PS_TXFIFO_COUNT", 'h0, "OFF");
      
      memw(es, "PSIF","AUIAURORATXFIFO", 'h12345678, 'h0);
      memw(es, "PSIF","AUIAURORATXFIFO", 'hABCDEF98, 'h4);
      memw(es, "PSIF","AUIAURORATXFIFO", 'h98765432, 'h8);      
      regc(es, "PSIF","AUI","AUI_AURORA_PS_TXFIFO_COUNT",'h3,"OFF");
      regw(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);
      regc(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);
      regp(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT",'h3,"OFF",1us);  // Polling for all data looped 
      memc(es, "PSIF","AUIAURORARXFIFO", 'h12345678, 'h0);
      memc(es, "PSIF","AUIAURORARXFIFO", 'hABCDEF98, 'h4);
      memc(es, "PSIF","AUIAURORARXFIFO", 'h98765432, 'h8);
      regc(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","AUI","AUI_AURORA_PS_TXFIFO_COUNT",'h0,"OFF");

      regw(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h0);
      regc(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h0);

      fork 
        begin      
          regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
          //while (ps_rxfifo_cnt < 12) begin
          while (ps_rxfifo_cnt < 2) begin
            regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
          end;
/* -----\/----- EXCLUDED -----\/-----
          memc(es, "PSIF","AUIAURORARXFIFO", 'h35124512, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h36124612, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h37124712, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h38124812, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h39124912, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3A124A12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3B124B12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3C124C12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3D124D12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3E124E12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h3F124F12, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h40125012, 'h0);
 -----/\----- EXCLUDED -----/\----- */
          memc(es, "PSIF","AUIAURORARXFIFO", 'h00000042, 'h0);
          memc(es, "PSIF","AUIAURORARXFIFO", 'h00000084, 'h0);
        end // fork
         begin
          memw(es, "PSIF","AUIAURORATXFIFO", 'h00000042, 'h0);
          memw(es, "PSIF","AUIAURORATXFIFO", 'h00000084, 'h0);
         end
      join
         
                              
   endtask : body
   
endclass //psif_aui_aurora_seq
