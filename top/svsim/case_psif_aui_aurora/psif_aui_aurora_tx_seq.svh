`include "uvm_macros.svh"

class psif_aui_aurora_tx_seq extends base_seq;
   `uvm_object_utils(psif_aui_aurora_tx_seq);

   int es;  // Task exit status (i.e. es)

   logic [31:0] txdata;
      
   function new( string name="psif_aui_aurora_tx_seq" );
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

      // Performing internal AUI loop test
      regw(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h1);
      regc(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h1);

      regc(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);
      
      // Write 2 data words to the FIFO
      txdata= 'h12345678;
      memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);
      txdata= 'h89ABCDEF;
      memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);

      // Disable reading of TX FIFO data
      regw(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h0);

      // Write 40 data words to the FIFO
      for (int i=0; i<40; i++) begin
        txdata[31:8]= 'h428496;
        txdata[7:0]= i;
        memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);
      end

      // Enable reading of TX FIFO data
      regw(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);

/* -----\/----- EXCLUDED -----\/-----
      #100us;                                 

      // Performing external data testbench loop
      regw(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h0);
      regc(es, "PSIF","AUI", "AUI_AURORA_ACCESS_LOOP_ENA", 'h0);

      regc(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);
      
      // Write 2 data words to the FIFO
      txdata= 'h23456000;
      memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);
      txdata= 'h9ABCD000;
      memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);

      // Disable reading of TX FIFO data
      regw(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h0);

      // Write 500 data words to the FIFO
      for (int i=0; i<500; i++) begin
        txdata[31:12]= 'h56789;
        txdata[11:0]= i;
        memw(es, "PSIF","AUIAURORATXFIFO", txdata, 'h0);
      end

      // Enable reading of TX FIFO data
      regw(es, "PSIF","AUI","AUI_AURORA_FIFO_TX_WRITE_ENABLE", 'h1);
 -----/\----- EXCLUDED -----/\----- */
      
   endtask : body
   
endclass //psif_aui_aurora_tx_seq
