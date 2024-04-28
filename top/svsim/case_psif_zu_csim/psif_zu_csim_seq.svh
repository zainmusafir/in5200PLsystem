   `include "uvm_macros.svh"

   import "DPI-C" function void aes_cipher(input int bypass, byte in[16], byte out[16], byte w[240]);


class psif_zu_csim_seq extends base_seq;
   `uvm_object_utils(psif_zu_csim_seq);

   int es;            // Task exit status (i.e. es)

   logic[31:0] keyword;
   logic[31:0] dataword;
   logic[31:0] resultword;   

   // Expanded 256-bit key with key: 00 01 02 03 ... 1e 1f (i.e. 8 bit * 32)   
   byte keymem[240] = '{'h00, 'h01, 'h02, 'h03, 'h04, 'h05, 'h06, 'h07, 'h08, 'h09, 'h0a, 'h0b, 
                        'h0c, 'h0d, 'h0e, 'h0f, 'h10, 'h11, 'h12, 'h13, 'h14, 'h15, 'h16, 'h17, 
                        'h18, 'h19, 'h1a, 'h1b, 'h1c, 'h1d, 'h1e, 'h1f, 'ha5, 'h73, 'hc2, 'h9f, 
                        'ha1, 'h76, 'hc4, 'h98, 'ha9, 'h7f, 'hce, 'h93, 'ha5, 'h72, 'hc0, 'h9c, 
                        'h16, 'h51, 'ha8, 'hcd, 'h02, 'h44, 'hbe, 'hda, 'h1a, 'h5d, 'ha4, 'hc1, 
                        'h06, 'h40, 'hba, 'hde, 'hae, 'h87, 'hdf, 'hf0, 'h0f, 'hf1, 'h1b, 'h68, 
                        'ha6, 'h8e, 'hd5, 'hfb, 'h03, 'hfc, 'h15, 'h67, 'h6d, 'he1, 'hf1, 'h48, 
                        'h6f, 'ha5, 'h4f, 'h92, 'h75, 'hf8, 'heb, 'h53, 'h73, 'hb8, 'h51, 'h8d, 
                        'hc6, 'h56, 'h82, 'h7f, 'hc9, 'ha7, 'h99, 'h17, 'h6f, 'h29, 'h4c, 'hec, 
                        'h6c, 'hd5, 'h59, 'h8b, 'h3d, 'he2, 'h3a, 'h75, 'h52, 'h47, 'h75, 'he7,
                        'h27, 'hbf, 'h9e, 'hb4, 'h54, 'h07, 'hcf, 'h39, 'h0b, 'hdc, 'h90, 'h5f, 
                        'hc2, 'h7b, 'h09, 'h48, 'had, 'h52, 'h45, 'ha4, 'hc1, 'h87, 'h1c, 'h2f, 
                        'h45, 'hf5, 'ha6, 'h60, 'h17, 'hb2, 'hd3, 'h87, 'h30, 'h0d, 'h4d, 'h33, 
                        'h64, 'h0a, 'h82, 'h0a, 'h7c, 'hcf, 'hf7, 'h1c, 'hbe, 'hb4, 'hfe, 'h54, 
                        'h13, 'he6, 'hbb, 'hf0, 'hd2, 'h61, 'ha7, 'hdf, 'hf0, 'h1a, 'hfa, 'hfe, 
                        'he7, 'ha8, 'h29, 'h79, 'hd7, 'ha5, 'h64, 'h4a, 'hb3, 'haf, 'he6, 'h40, 
                        'h25, 'h41, 'hfe, 'h71, 'h9b, 'hf5, 'h00, 'h25, 'h88, 'h13, 'hbb, 'hd5, 
                        'h5a, 'h72, 'h1c, 'h0a, 'h4e, 'h5a, 'h66, 'h99, 'ha9, 'hf2, 'h4f, 'he0, 
                        'h7e, 'h57, 'h2b, 'haa, 'hcd, 'hf8, 'hcd, 'hea, 'h24, 'hfc, 'h79, 'hcc, 
                        'hbf, 'h09, 'h79, 'he9, 'h37, 'h1a, 'hc2, 'h3c, 'h6d, 'h68, 'hde, 'h36};

   // Used with aes_key_expansion C function
   byte keymem_dmy[240];
   byte key[32];

   byte indata[16];

   byte out_encrypted[16];

   int 	bypass;
   
   
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

      regw(es, "PSIF","SCU", "SCU_ZU_DATA_ENA", 'h1);
      regc(es, "PSIF","SCU", "SCU_ZU_DATA_ENA", 'h1);
      regw(es, "PSIF","SCU", "SCU_DTI_READ_ENA", 'h1);
      regc(es, "PSIF","SCU", "SCU_DTI_READ_ENA", 'h1);      
                  
      for (int no_keywords=0; no_keywords<60; no_keywords++) begin
        keyword[7:0]  = keymem[4*no_keywords+0];
        keyword[15:8] = keymem[4*no_keywords+1];
        keyword[23:16]= keymem[4*no_keywords+2];
        keyword[31:24]= keymem[4*no_keywords+3];         
        memw(es, "PSIF", "ZUKEY", keyword, no_keywords);
      end
      for (int no_keywords=0; no_keywords<60; no_keywords++) begin
        keyword[7:0]  = keymem[4*no_keywords+0];
        keyword[15:8] = keymem[4*no_keywords+1];
        keyword[23:16]= keymem[4*no_keywords+2];
        keyword[31:24]= keymem[4*no_keywords+3];         
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

      bypass= 1;
      
      regw(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h1);
      regc(es, "PSIF","ZU", "ZU_DECRYPTION_BYPASS", 'h1);

      regw(es, "PSIF","ZU", "ZU_START_DECRYPTION", 'h1);
 
      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h0, "OFF");     

      regp(es, "PSIF","ZU", "ZU_DONE_DECRYPTION", 'h1, "OFF");

      regc(es, "PSIF","SCU", "SCU_ZU_TDATA_CNT", 'd16, "OFF"); 
      regc(es, "PSIF","SCU", "SCU_ZU_BYTE_CNT_ERROR", 'h0, "OFF");       
      
      regp(es, "PSIF","SCU", "SCU_ALARM_ACK_BUTTON", 'h1, "OFF");

      // Simulate NO BYPASS with "FACE RECOGNIZED!" that is ASCII data: 
      // 'h46, 'h41, 'h43, 'h45, 'h20, 'h52, 'h45, 'h43, 'h4f, 'h47, 'h4e, 'h49, 'h5a, 'h45, 'h44, 'h21
      // gives ciphered data:
      // indata[16]= '{'hcc, 'h9a, 'hba, 'hc4, 'h21, 'h19, 'h50, 'hb3, 'hb1, 'h97, 'h69, 'h2b, 'hef, 'h0e, 'hcb, 'h59};
      // with expected decrypted result:
      // out_encrypted[16]= '{'h46, 'h41, 'h43, 'h45, 'h20, 'h52, 'h45, 'h43, 'h4f, 'h47, 'h4e, 'h49, 'h5a, 'h45, 'h44, 'h21};
      
      bypass= 0;

      // FACE RECOGNIZED! as 16 ASCII characters.
      indata= '{'h46, 'h41, 'h43, 'h45, 'h20, 'h52, 'h45, 'h43, 'h4f, 'h47, 'h4e, 'h49, 'h5a, 'h45, 'h44, 'h21};
      
      // FACE RECOGNIZED! encrypted with keymem[240] array value! 
      aes_cipher(bypass, indata, out_encrypted, keymem);
      
      
      for (int no_words=0; no_words<4; no_words++) begin
        dataword[7:0]  = out_encrypted[4*no_words+0];
        dataword[15:8] = out_encrypted[4*no_words+1];
        dataword[23:16]= out_encrypted[4*no_words+2];
        dataword[31:24]= out_encrypted[4*no_words+3];                 
        memw(es, "PSIF", "ZUPACKET", dataword, no_words);
      end
      for (int no_words=0; no_words<4; no_words++) begin
        dataword[7:0]  = out_encrypted[4*no_words+0];
        dataword[15:8] = out_encrypted[4*no_words+1];
        dataword[23:16]= out_encrypted[4*no_words+2];
        dataword[31:24]= out_encrypted[4*no_words+3];                 
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
   
endclass // psif_zu_csim_seq
