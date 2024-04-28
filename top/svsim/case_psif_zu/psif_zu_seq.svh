`include "uvm_macros.svh"

class psif_zu_seq extends base_seq;
   `uvm_object_utils(psif_zu_seq);

   int es;            // Task exit status (i.e. es)

   int keyfile;
   int cipheredfile;

   logic[31:0] keyword;
   logic[31:0] dataword;
   logic[31:0] resultword;
   byte        keymem [0:239];
   byte        cipheredmem [0:15];
   int         code; 
   
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

      keyfile= $fopen("$MLA_DESIGN/top/svsim/case_psif_zu/expanded_key.txt", "r");
      for (int no_keybytes=0; no_keybytes<240; no_keybytes++) begin
         code= $fscanf(keyfile, "%h", keymem[no_keybytes]);
      end

      cipheredfile= $fopen("$MLA_DESIGN/top/svsim/case_psif_zu/ciphered_message.txt", "r");
      for (int no_bytes=0; no_bytes<240; no_bytes++) begin
         code= $fscanf(cipheredfile, "%h", cipheredmem[no_bytes]);
      end
            
      for (int no_keywords=0; no_keywords<60; no_keywords++) begin
        keyword[7:0]  = keymem[4*no_keywords+0];
        keyword[15:8] = keymem[4*no_keywords+1];
        keyword[23:16]= keymem[4*no_keywords+2];
        keyword[31:24]= keymem[4*no_keywords+3];         
        memw(es, "PSIF", "ZUKEY", keyword, no_keywords);
        memc(es, "PSIF", "ZUKEY", keyword, no_keywords);
      end

      // Simulate BYPASS with data:
      // 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
      // with decrypted result equal input data:
      // 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
 
      for (int no_words=0; no_words<4; no_words++) begin
        dataword[7:0]  = 4*no_words+0;
        dataword[15:8] = 4*no_words+1;
        dataword[23:16]= 4*no_words+2;
        dataword[31:24]= 4*no_words+3;                 
        memw(es, "PSIF", "ZUPACKET", dataword, no_words);
        memc(es, "PSIF", "ZUPACKET", dataword, no_words);
      end

      regw(es, "PSIF","SCU", "SCU_ZU_DATA_ENA", 'h1);
      regc(es, "PSIF","SCU", "SCU_ZU_DATA_ENA", 'h1);
      regw(es, "PSIF","SCU", "SCU_DTI_READ_ENA", 'h0);
      regc(es, "PSIF","SCU", "SCU_DTI_READ_ENA", 'h0);      

      regw(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h1);
      regc(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h1);

      regw(es, "PSIF","ZU", "ZU_START_DECRYPTION", 'h1);
 
      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h0, "OFF");     

      regp(es, "PSIF","ZU", "ZU_DONE_DECRYPTION", 'h1, "OFF");

      regc(es, "PSIF","SCU", "SCU_ZU_TDATA_CNT", 'd16, "OFF"); 
      regc(es, "PSIF","SCU", "SCU_ZU_BYTE_CNT_ERROR", 'h0, "OFF"); 

      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h1, "OFF");

      // Simulate ciphered data from file $MLA_DESIGN/top/svsim/case_psif_zu/ciphered_message.txt:
      // 0x34 0xce 0xcd 0xe1 0x89 0x65 0x9a 0xfd 0x29 0x4 0x6d 0x68 0x9e 0x4d 0xf8 0x5e
      // with expected decrypted result:
      // 0x0 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88 0x99 0xaa 0xbb 0xcc 0xdd 0xee 0xff
      
      for (int no_words=0; no_words<4; no_words++) begin
        dataword[7:0]  = cipheredmem[4*no_words+0];
        dataword[15:8] = cipheredmem[4*no_words+1];
        dataword[23:16]= cipheredmem[4*no_words+2];
        dataword[31:24]= cipheredmem[4*no_words+3];                 
        memw(es, "PSIF", "ZUPACKET", dataword, no_words);
        memc(es, "PSIF", "ZUPACKET", dataword, no_words);
      end

      regw(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h0);
      regc(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h0);

      regw(es, "PSIF","ZU", "ZU_START_DECRYPTION", 'h1);

      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h0, "OFF");      

      regp(es, "PSIF","ZU", "ZU_DONE_DECRYPTION", 'h1, "OFF");
      
      regc(es, "PSIF","SCU", "SCU_ZU_TDATA_CNT", 'd16, "OFF"); 
      regc(es, "PSIF","SCU", "SCU_ZU_BYTE_CNT_ERROR", 'h0, "OFF"); 

      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h1, "OFF");
   
                
   endtask : body
   
endclass // psif_zu_seq
