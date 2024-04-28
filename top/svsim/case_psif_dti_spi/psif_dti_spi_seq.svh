`include "uvm_macros.svh"

class psif_dti_spi_seq extends base_seq;
   `uvm_object_utils(psif_dti_spi_seq);

   int es;            // Task exit status (i.e. es)
   
   
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

      regc(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h0);      
      regw(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h1);
      regc(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h1);      

      regc(es, "PSIF","DTI", "DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h1);
      regw(es, "PSIF","DTI", "DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h0);
      regc(es, "PSIF","DTI", "DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h0);
      regw(es, "PSIF","DTI", "DTI_SPI_LOOP_ENA", 'h1);
      regc(es, "PSIF","DTI", "DTI_SPI_LOOP_ENA", 'h1);
      regc(es, "PSIF","DTI", "DTI_SPI_RX_FIFO_COUNT", 'h0, "OFF");
      regc(es, "PSIF","DTI", "DTI_SPI_TX_FIFO_COUNT", 'h0, "OFF");
      
      memw(es, "PSIF","DTISPITXFIFO", 'h12345678, 'h0);
      memw(es, "PSIF","DTISPITXFIFO", 'hABCDEF98, 'h0);
      memw(es, "PSIF","DTISPITXFIFO", 'h98765432, 'h0);      
      regw(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h1);
      regc(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h1);
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h3,"OFF");
      memc(es, "PSIF","DTISPIRXFIFO", 'h00005678, 'h0);
      memc(es, "PSIF","DTISPIRXFIFO", 'h0000EF98, 'h0);
      memc(es, "PSIF","DTISPIRXFIFO", 'h00005432, 'h0);
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","DTI","DTI_SPI_TX_FIFO_COUNT",'h0,"OFF");

      // Writing and reading 3 SPI accesses before SPI access is started; 
      //   i.e. when DTI_SPI_FIFO_TX_WRITE_ENABLE is set to '1'.
      regw(es, "PSIF","DTI","DTI_SPI_LOOP_ENA", 'h0);
      regw(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h0);
      memw(es, "PSIF","DTISPITXFIFO", 'h00008012, 'h0); // Write instruction; bit 15='1'.
      memw(es, "PSIF","DTISPITXFIFO", 'h000081AB, 'h0); // Write instruction; bit 15='1'. NOTE: NOT WR on target MAX31722
      memw(es, "PSIF","DTISPITXFIFO", 'h000082CD, 'h0); // Write instruction; bit 15='1'. NOTE: NOT WR on target MAX31722
      memw(es, "PSIF","DTISPITXFIFO", 'h00008324, 'h0); // Write instruction; bit 15='1'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00008436, 'h0); // Write instruction; bit 15='1'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00008547, 'h0); // Write instruction; bit 15='1'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00008658, 'h0); // Write instruction; bit 15='1'.
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","DTI","DTI_SPI_TX_FIFO_COUNT",'h7,"OFF");
      regw(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h1);
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      regw(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h0);
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","DTI","DTI_SPI_TX_FIFO_COUNT",'h0,"OFF");
      memw(es, "PSIF","DTISPITXFIFO", 'h00000000, 'h0); // Read instruction; bit 15='0'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00000100, 'h0); // Read instruction; bit 15='0'. NOTE: ONLY RD on target MAX31722
      memw(es, "PSIF","DTISPITXFIFO", 'h00000200, 'h0); // Read instruction; bit 15='0'. NOTE: ONLY RD on target MAX31722
      memw(es, "PSIF","DTISPITXFIFO", 'h00000300, 'h0); // Read instruction; bit 15='0'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00000400, 'h0); // Read instruction; bit 15='0'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00000500, 'h0); // Read instruction; bit 15='0'.
      memw(es, "PSIF","DTISPITXFIFO", 'h00000600, 'h0); // Read instruction; bit 15='0'.
      regw(es, "PSIF","DTI","DTI_SPI_FIFO_TX_WRITE_ENABLE", 'h1);
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h7,"OFF");
      regc(es, "PSIF","DTI","DTI_SPI_TX_FIFO_COUNT",'h0,"OFF");
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000012, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h000001AB, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h000002CD, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000324, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000436, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000547, 'h0); 
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000658, 'h0); 
      regc(es, "PSIF","DTI","DTI_SPI_RX_FIFO_COUNT",'h0,"OFF");
      regc(es, "PSIF","DTI","DTI_SPI_TX_FIFO_COUNT",'h0,"OFF");

      // Single write and single read SPI access
      memw(es, "PSIF","DTISPITXFIFO", 'h00008348, 'h0); // Write instruction; bit 15='1'.
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      memw(es, "PSIF","DTISPITXFIFO", 'h00000300, 'h0); // Read instruction; bit 15='0'.
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000348, 'h0);

      // Single write and single read SPI access
      memw(es, "PSIF","DTISPITXFIFO", 'h00008658, 'h0); // Write instruction; bit 15='1'.
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      memw(es, "PSIF","DTISPITXFIFO", 'h00000600, 'h0); // Read instruction; bit 15='0'.
      regp(es, "PSIF","DTI","DTI_SPI_ACTIVE", 'h0, "OFF", 1us); // Polling for value= 0; i.e. SPI not active
      memc(es, "PSIF","DTISPIRXFIFO", 'h00000658, 'h0);
          
   endtask : body
   
endclass // psif_dti_spi_seq
