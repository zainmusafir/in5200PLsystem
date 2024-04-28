   import uvm_pkg::*;
   `include "uvm_macros.svh";

   import "DPI-C" function void aes_cipher(input int bypass, byte in[16], byte out[16], byte w[240]);
   import "DPI-C" function void aes_inv_cipher(input int bypass, byte in[16], byte out[16], byte w[240]);


class scoreboard_zu_aes128 extends scoreboard_zu_base;
   `uvm_component_utils(scoreboard_zu_aes128);

   function new(string name="",uvm_component parent=null);
     super.new(name,parent);
   endfunction // new


   // Declare test probes for internal design signals in kdf_0 and kdf_1 modules
   probe_abstract #(logic [0:0])  aes_inv_cipher_ap_clk_h;        // NOTE: MUST be [0:0] !!
   probe_abstract #(logic [0:0])  aes_inv_cipher_bypass_h;        // NOTE: MUST be [0:0] !!          
   probe_abstract #(logic [0:0])  aes_inv_cipher_ap_start_h;      // NOTE: MUST be [0:0] !! 
   probe_abstract #(logic [0:0])  aes_inv_cipher_ap_done_h;       // NOTE: MUST be [0:0] !!           
   probe_abstract #(logic [7:0])  aes_inv_cipher_out_r_tdata_h;   // 8-bit probe
   probe_abstract #(logic [0:0])  aes_inv_cipher_out_r_tvalid_h;  // NOTE: MUST be [0:0] !!             
   probe_abstract #(logic [0:0])  aes_inv_cipher_out_r_tready_h;  // NOTE: MUST be [0:0] !! 
 
   int tdata_compare;
   
   byte axi4stream_data;
   int axi4stream_tready;
   int axi4stream_tvalid;


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
   
   
    byte in[16];
    byte out_encrypted[16];  
    byte out[16];
    int bypass;
    byte tdata_answer[16];
   

    function void build_phase(uvm_phase phase);
      $cast(aes_inv_cipher_ap_clk_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_ap_clk",,"aes_inv_cipher_probe_ap_clk_h"));   
      $cast(aes_inv_cipher_bypass_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_bypass",,"aes_inv_cipher_probe_bypass_h"));   
      $cast(aes_inv_cipher_ap_start_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_ap_start",,"aes_inv_cipher_probe_ap_start_h"));   
      $cast(aes_inv_cipher_ap_done_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_ap_done",,"aes_inv_cipher_probe_ap_done(ap_done_h"));   
      $cast(aes_inv_cipher_out_r_tdata_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_out_r_tdata",,"aes_inv_cipher_probe_out_r_tdata_h"));   
      $cast(aes_inv_cipher_out_r_tvalid_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_out_r_tvalid",,"aes_inv_cipher_probe_out_r_tvalid_h"));   
      $cast(aes_inv_cipher_out_r_tready_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.zu_0.aes128_inv_cipher_0.aes_inv_cipher_probe_out_r_tready",,"aes_inv_cipher_probe_out_r_tready_h"));   
    endfunction : build_phase

   
    task run_phase(uvm_phase phase);

       `uvm_info(get_type_name(), "Scoreboard running ...", UVM_MEDIUM);

       fork
         begin
	     
           forever begin
	      
             aes_inv_cipher_ap_start_h.edge_probe(1);
	      
             `uvm_info(get_type_name(), "AES128 decryption start ...", UVM_MEDIUM);
	     for (int i=0; i<16; i++) begin		
               do begin
                 aes_inv_cipher_ap_clk_h.edge_probe(0);
                 $cast(axi4stream_tvalid, aes_inv_cipher_out_r_tvalid_h.get_probe());
                 $cast(axi4stream_tready, aes_inv_cipher_out_r_tready_h.get_probe());
                 aes_inv_cipher_ap_clk_h.edge_probe(1);
               end while (!(axi4stream_tvalid==1 && axi4stream_tready==1)); // Wait for valid data
		
               $cast(axi4stream_data, aes_inv_cipher_out_r_tdata_h.get_probe());
               `uvm_info(get_type_name(), $psprintf("AXI4Stream data= %0h", axi4stream_data), UVM_MEDIUM);
               tdata_answer[i]= axi4stream_data;  
             end  // for (int i=0; i<16; i++)       
	   end // forever begin
	    
	 end

           begin
	     
             // Check BYPASS with data:
	     bypass= 1; // Set to bypass
	     in= '{'h0,  'h1,  'h2,  'h3, 'h4, 'h5, 'h6, 'h7, 'h8, 'h9, 'ha, 'hb, 'hc, 'hd, 'he, 'hf};
	      
             aes_inv_cipher_ap_done_h.edge_probe(1);
             `uvm_info(get_type_name(), "AES128 decryption done", UVM_MEDIUM);
	     // for (int j=0; j<16; j++) begin		
             //   `uvm_info(get_type_name(), $psprintf("AXI4Stream answer data= %0h", tdata_answer[j]), UVM_MEDIUM);
             // end

             // Use C answer function in aes.c
	     // for (int m=0; m<16; m++) begin		
             //  `uvm_info(get_type_name(), $psprintf("AES input data= %0h", in[m]), UVM_MEDIUM);       	       
	     // end      
	     // for (int p=0; p<240; p++) begin		       	       
             //   `uvm_info(get_type_name(), $psprintf("AES key data= %0h", keymem[p]), UVM_MEDIUM);       	       
	     // end
	      
             aes_cipher(bypass, in, out_encrypted, keymem);
             aes_inv_cipher(bypass, out_encrypted, out, keymem);
	      
	     // for (int r=0; r<16; r++) begin		
             //   `uvm_info(get_type_name(), $psprintf("AES encrypted data= %0h", out_encrypted[r]), UVM_MEDIUM);       	       
	     // end      
	     for (int n=0; n<16; n++) begin		
               `uvm_info(get_type_name(), $psprintf("AES C generated answer data= %0h", out[n]), UVM_MEDIUM);       	       
	     end

	     tdata_compare= 1;
	     for (int q=0; q<16; q++) begin
		if (in[q]!=tdata_answer[q]) begin
                  tdata_compare= 0;
		end
	     end
             
	     if (tdata_compare==0) begin	
               `uvm_error(get_type_name(), "Error in decryption"); 
             end else begin
               `uvm_info(get_type_name(), "Decryption OK!", UVM_MEDIUM); 
             end
    	       
	      
             // Check NO BYPASS "FACE RECOGNIZED!" with 16 ASCII characters: 
	     //   'h46, 'h41, 'h43, 'h45, 'h20, 'h52, 'h45, 'h43, 'h4f, 'h47, 'h4e, 'h49, 'h5a, 'h45, 'h44, 'h21
             bypass= 0; // Set bypass to zero
	     in= '{'h46, 'h41, 'h43, 'h45, 'h20, 'h52, 'h45, 'h43, 'h4f, 'h47, 'h4e, 'h49, 'h5a, 'h45, 'h44, 'h21};
	      
             aes_inv_cipher_ap_done_h.edge_probe(1);
      
             `uvm_info(get_type_name(), "AES128 decryption done", UVM_MEDIUM);
	     // for (int j=0; j<16; j++) begin		
             //   `uvm_info(get_type_name(), $psprintf("AXI4Stream answer data= %0h", tdata_answer[j]), UVM_MEDIUM);
             // end

             // Use C answer function in aes.c
	     // for (int m=0; m<16; m++) begin		
             //   `uvm_info(get_type_name(), $psprintf("AES input data= %0h", in[m]), UVM_MEDIUM);       	       
	     // end      
	     // for (int p=0; p<240; p++) begin		       	       
             //   `uvm_info(get_type_name(), $psprintf("AES key data= %0h", keymem[p]), UVM_MEDIUM);       	       
	     // end
	      
             aes_cipher(bypass, in, out_encrypted, keymem);
             aes_inv_cipher(bypass, out_encrypted, out, keymem);
	      
	     // for (int r=0; r<16; r++) begin		
             //   `uvm_info(get_type_name(), $psprintf("AES encrypted data= %0h", out_encrypted[r]), UVM_MEDIUM);
	     // end      
	     for (int n=0; n<16; n++) begin		
               `uvm_info(get_type_name(), $psprintf("AES C generated answer data= %0h", out[n]), UVM_MEDIUM);
	     end

	     tdata_compare= 1;
	     for (int q=0; q<16; q++) begin
		if (in[q]!=tdata_answer[q]) begin
                  tdata_compare= 0;
		end
	     end
             
	     if (tdata_compare==0) begin	
               `uvm_error(get_type_name(), "Error in decryption"); 
             end else begin
               `uvm_info(get_type_name(), "Decryption OK!", UVM_MEDIUM); 
             end      	       
	      
           end
  
        join_any
           
    endtask : run_phase
   
   
endclass : scoreboard_zu_aes128
