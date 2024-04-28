`include "uvm_macros.svh"

class psif_aui_aurora_loop_seq extends base_seq;
   `uvm_object_utils(psif_aui_aurora_loop_seq);

   int es;  // Task exit status (i.e. es)
      
   function new( string name="psif_aui_aurora_loop_seq" );
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
      
      regp(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT",'h3,"OFF",1us);  // Polling for all data looped 
      memc(es, "PSIF","AUIAURORARXFIFO", 'h12345678, 'h0);
      memc(es, "PSIF","AUIAURORARXFIFO", 'hABCDEF98, 'h4);
      memc(es, "PSIF","AUIAURORARXFIFO", 'h98765432, 'h8);
      
      regc(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","AUI","AUI_AURORA_PS_TXFIFO_COUNT",'h0,"OFF");
                              
   endtask : body
   
endclass //psif_aui_aurora_loop_seq
