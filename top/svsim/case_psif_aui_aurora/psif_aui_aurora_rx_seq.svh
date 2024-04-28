`include "uvm_macros.svh"

class psif_aui_aurora_rx_seq extends base_seq;
   `uvm_object_utils(psif_aui_aurora_rx_seq);

   int es;  // Task exit status (i.e. es)

   int ps_rxfifo_cnt;
   logic [31:0] rxdata;
      
   function new( string name="psif_aui_aurora_rx_seq" );
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
      

      // Waiting for internal AUI loop data received
      do begin
	#10us;
        regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
      end while (ps_rxfifo_cnt < 2);
      
      memc(es, "PSIF","AUIAURORARXFIFO", 'h12345678, 'h0);
      memc(es, "PSIF","AUIAURORARXFIFO", 'h89ABCDEF, 'h0);

      // Waiting for 40 data words received
      do begin
	#10us;
        regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
      end while (ps_rxfifo_cnt < 40);
      
      for (int i=0; i<40; i++) begin
        rxdata[31:8]= 'h428496;
        rxdata[7:0]= i;
        memc(es, "PSIF","AUIAURORARXFIFO", rxdata, 'h0);
      end

/* -----\/----- EXCLUDED -----\/-----
      #100us; 

      // Waiting for external testbench loop data received
      do begin
	#10us;
        regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
      end while (ps_rxfifo_cnt < 2);
      
      memc(es, "PSIF","AUIAURORARXFIFO", 'h2345602a, 'h0);
      memc(es, "PSIF","AUIAURORARXFIFO", 'h9ABCD02a, 'h0);

      // Waiting for 500 data words received
      do begin
	#10us;
        regr(es, "PSIF","AUI","AUI_AURORA_PS_RXFIFO_COUNT", ps_rxfifo_cnt,"OFF");
      end while (ps_rxfifo_cnt < 500);
      
      for (int i=0; i<500; i++) begin
        rxdata[31:12]= 'h56789;
        rxdata[11:0]= i + 42; // 42 added by the aurora loop sequence
        memc(es, "PSIF","AUIAURORARXFIFO", rxdata, 'h0);
      end  
 -----/\----- EXCLUDED -----/\----- */
                               
   endtask : body
   
endclass //psif_aui_aurora_rx_seq
