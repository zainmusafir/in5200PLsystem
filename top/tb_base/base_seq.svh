
    `ifdef SETUP_KBAXI4LITE

    class base_seq extends uvm_sequence#(kb_axi4lite_agent_item);

    `else

    class base_seq #( int AXI4_ADDRESS_WIDTH   = 32, 
					  int AXI4_RDATA_WIDTH     = 32,
					  int AXI4_WDATA_WIDTH     = 32,
					  int AXI4_ID_WIDTH        = 4,
					  int AXI4_USER_WIDTH      = 4,
					  int AXI4_REGION_MAP_SIZE = 16
                                         ) extends mvc_sequence;

   `endif

   `uvm_object_utils(base_seq);


   `ifdef SETUP_KBAXI4LITE

   typedef kb_axi4lite_agent_item  read_item_t;
   typedef kb_axi4lite_agent_item  write_item_t;

   `else

   typedef axi4_master_read  #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE
                               ) read_item_t;

   typedef axi4_master_write #(AXI4_ADDRESS_WIDTH,
                               AXI4_RDATA_WIDTH,
                               AXI4_WDATA_WIDTH,
                               AXI4_ID_WIDTH,
                               AXI4_USER_WIDTH,
                               AXI4_REGION_MAP_SIZE
                               ) write_item_t;
   `endif

   // PSIF; Red Interface module registers
   top_PSIF     m_psif_regs_all;
   top_PSIF_rw  m_psif_regs_rw;

   // Declare AXI4--Lite sequencers
   `ifdef SETUP_KBAXI4LITE
     uvm_sequencer #(kb_axi4lite_agent_item) m_psif_axi4_sqr;     
   `else
     mvc_sequencer m_psif_axi4_sqr;
   `endif

   // Declare IRQ sequencers
   // uvm_sequencer #(interrupt_handler_item) m_irq_psif_sqr;
    
   // uvm_sequencer #(spi_4wire_agent_item) m_spi_4wire_sqr;    
       
   //##############################################################
   // Declarations used in regw, regr and regc and 
   //   memw, memr, and menc tasks
   //##############################################################

   // PSIF interface register, block and memory queue declarations
   uvm_reg psif_regs[$];
   uvm_reg_block psif_blocks[$];
   uvm_mem psif_mems[$];

   // Interface register, block and memory queue declarations
   //   used in regw, regr and regc and memw, memr, and menc tasks
   uvm_reg if_regs[$];
   uvm_reg_block if_blocks[$];
   uvm_mem if_mems[$];

   // KB_AXI4STREAM sequencer 
   uvm_sequencer #(kb_axi4stream_agent_item) m_kb_axi4stream_sqr; 
       
   // Variables used in tasks
   uvm_status_e status;
   uvm_reg_data_t data;
   typedef enum {FALSE, TRUE} boolean;
   int value;

       
   function new(string name = "base_seq");
      super.new(name);
   endfunction : new


   // Register address test for register modules defined in build function (i.e. m_*_regs_all).
   //   The addresscheck test task checks for errors in register address decoding. 
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Registers or UVM registers blocks in interface not found
   task reg_addresscheck(output int exitstatus, input string moduleif);
     /* -----\/----- EXCLUDED -----\/-----
       // Print "everything" in m_psif_regs_rw
       if (m_psif_regs_rw==null) begin
         `uvm_error(get_type_name(), "Task reg_addresscheck error: PSIF RW registers is NULL; task execution terminated");
         return;
       end;          
       //     end else begin
       //       m_psif_regs_rw.print();
       //     end;
     -----/\----- EXCLUDED -----/\----- */
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF") begin
       m_psif_regs_rw.get_registers(if_regs); // Get all PSIF registers  
       m_psif_regs_rw.get_blocks(if_blocks);  // Get all PSIF blocks    
       m_psif_regs_rw.reset(); // Reset the entire PSIF register model; see Meade & Rosenberg p. 242!
     end else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     if (if_regs.size == 0 || if_blocks.size() == 0) begin               
       `uvm_error(get_type_name(), "Task reg_addresscheck error: No registers found; task execution terminated");
        exitstatus= 2; // Register queue or blocks queue empty; i.e. registers not found
        return;
     end;
     //  m_psif_regs_rw.PSIFTEST.get_registers(regs);           // Just an example of getting all registers in a module ...   
     foreach (if_regs[i]) if_regs[i].write(status, 0);      // Initialize all registers to zero.
     foreach (if_regs[j]) begin                             // For all registers in sequence
       if_regs[j].write(status, 1);                         // Write 1 to the selected register; i.e. minimum 1 bit length in each register
       //  if_regs[j].write(status, j*2+1);                   // Write to the selected register; increasing value used during debug
       foreach (if_regs[k]) if_regs[k].read(status, data);  // Check all registers
       foreach (if_regs[k]) if_regs[k].write(status, 0);    // Initialize all registers to zero.
     end 
     foreach (if_regs[i]) if_regs[i].write(status, 0);      // Set all registers to zero after test complete
     if (moduleif=="PSIF")
        m_psif_regs_rw.reset(); // Reset the entire PSIF register model; see Meade & Rosenberg p. 242!

   endtask // reg_addresscheck


   // Write value to register defined in build function (i.e. m_*_regs_all).
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   task automatic regw(output int exitstatus, input string moduleif, regmodule, register, int value);
     int n_bytes;
     logic [31:0] value_final;
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF") begin
       if_regs   = psif_regs;
       if_blocks = psif_blocks;
     end else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_blocks[j]) begin                               // For all blocks in sequence
       if (if_blocks[j].get_name()==regmodule.toupper) begin    // Find selected module
         foreach (if_regs[i]) begin                             // For all registers in sequence
           if (if_regs[i].get_name() == register.toupper) begin // Find selected register
             n_bytes= if_blocks[j].get_reg_by_name(register.toupper).get_n_bytes();
             if (n_bytes==1) begin
               value_final[7:0]  = value[7:0];
               value_final[15:8] = value[7:0];
               value_final[23:16]= value[7:0];
               value_final[31:24]= value[7:0];
             end else if (n_bytes==2) begin
               value_final[15:0] = value[15:0];
               value_final[31:16]= value[15:0];
             end else begin 
               value_final= value;
             end
             `uvm_info(get_type_name(), $psprintf("Write to module %s with register %s with value: 0x%0h", regmodule.toupper,  register.toupper, value), UVM_MEDIUM);
             if_blocks[j].get_reg_by_name(register.toupper).write(status, value_final);  // Write value to the selected register
             return;
           end
         end 
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Write register %s not found", register.toupper));        
         return;
       end
     end
     exitstatus= 2; // Module in interface not found
     `uvm_error(get_type_name(), $psprintf("Module %s not found", regmodule.toupper));       
   endtask // regw


   // Read value from register defined in build function (i.e. m_*_regs_all) 
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   task automatic regr(output int exitstatus, input string moduleif, string regmodule, register, output int value, input string mirrorcheck = "ON");
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF") begin
       if_regs   = psif_regs;
       if_blocks = psif_blocks;
       if (mirrorcheck != "ON")  
         m_psif_regs_all.top_if_map.set_check_on_read(.on(FALSE));
       else
         m_psif_regs_all.top_if_map.set_check_on_read(.on(TRUE));
     end else begin
       exitstatus= 1; // Interface not found
       return;
     end;   
     foreach (if_blocks[j]) begin                             // For all blocks in sequence
       if (if_blocks[j].get_name()==regmodule.toupper) begin  // Find selected module
         foreach (if_regs[i]) begin                           // For all registers in sequence
           if (if_regs[i].get_name()==register.toupper) begin // Find selected register
             if_blocks[j].get_reg_by_name(register.toupper).read(status, data);  // Read value from the selected register
             `uvm_info(get_type_name(), $psprintf("Read module %s with register %s with value: 0x%0h", regmodule.toupper,  register.toupper, data), UVM_MEDIUM);
             value = data;
             return;
           end
         end  
         value = 0;
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Read register %s not found", register.toupper));
         return;
       end
     end
     value = 0;
     exitstatus= 2; // Module in interface not found
     `uvm_error(get_type_name(), $psprintf("Module %s not found", regmodule.toupper));       
   endtask // regr


   // Check value in register defined in build function (i.e. m_*_regs_all) 
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   //   4: Register data read error
   //   5: Register data read error, but with UVM mirror error suppressed
   task automatic regc(output int exitstatus, input string moduleif, string regmodule, register, logic [31:0] value, input string mirrorcheck = "ON", string suppress_error = "OFF");
     int n_bytes;
     logic [31:0] value_final;
     logic [31:0] data_final;
     logic [1:0] addr_lsb;
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF") begin
       if_regs   = psif_regs;
       if_blocks = psif_blocks;
       if (mirrorcheck != "ON")  
         m_psif_regs_all.top_if_map.set_check_on_read(.on(FALSE));
       else
         m_psif_regs_all.top_if_map.set_check_on_read(.on(TRUE));
     end else begin
       exitstatus= 1; // Interface not found
       return;
     end; // else: !if(moduleif=="PSIF") 
     foreach (if_blocks[j]) begin                             // For all blocks in sequence
       if (if_blocks[j].get_name()==regmodule.toupper) begin  // Find selected module
         foreach (if_regs[i]) begin                           // For all registers in sequence
           if (if_regs[i].get_name()==register.toupper) begin // Find selected register
             if_blocks[j].get_reg_by_name(register.toupper).read(status, data);  // Read value from the selected register
             n_bytes= if_blocks[j].get_reg_by_name(register.toupper).get_n_bytes();
             addr_lsb= if_blocks[j].get_reg_by_name(register.toupper).get_address()[1:0];
             value_final= 0;
             data_final= 0;
             if (n_bytes==1) begin
               if (addr_lsb==0) begin
                 value_final[7:0]= value[7:0];
                 data_final[7:0] = data[7:0];                 
               end else if (addr_lsb==1) begin
                 value_final[15:8]= value[7:0];
                 data_final[15:8] = data[15:8];
               end else if (addr_lsb==2) begin
                 value_final[23:16]= value[7:0];
                 data_final[23:16] = data[23:16];
               end else begin
                 value_final[31:24]= value[7:0];
                 data_final[31:24] = data[31:24];
               end
             end else if (n_bytes==2) begin
               if (addr_lsb==0) begin
                 value_final[15:0]= value[15:0];
                 data_final[15:0] = data[15:0];
               end else if (addr_lsb==2) begin
                 value_final[31:16]= value[15:0];
                 data_final[31:16] = data[31:16];
               end
             end else begin 
               value_final= value;
               data_final= data;
             end
             if (value_final != data_final) begin
               if (suppress_error == "ON") begin
                 exitstatus= 5; // Register data read error with UVM mirror error suppressed. 
                 `uvm_warning(get_type_name(), $psprintf("Warning (NOTE: ERROR SUPPRESSED): Read register %s with value: 0x%0h, but expected:  0x%0h", register.toupper, data_final, value_final));
               end else begin
                 exitstatus= 4; // Register data read error
                 `uvm_error(get_type_name(), $psprintf("Error: Read register %s with value: 0x%0h, but expected:  0x%0h", register.toupper, data_final, value_final));
               end
             end else begin
               `uvm_info(get_type_name(), $psprintf("Check register %s with value: 0x%0h", register.toupper, data_final), UVM_MEDIUM);
             end
             return;
           end
         end
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Check register %s not found", register.toupper));
         return;        
       end
     end 
     value_final = 0;
     data_final = 0;
     exitstatus= 2; // Module in interface not found
     `uvm_error(get_type_name(), $psprintf("Module %s not found", regmodule.toupper));       
   endtask // regc
       

   // Read poll value in register defined in build function (i.e. m_*_regs_all) 
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   //   4: Register data poll read error
   //   5: Register data poll read error, but with UVM mirror error suppressed
   task automatic regp(output int exitstatus, input string moduleif, string regmodule, register, int value, input string mirrorcheck = "ON", time POLLTIME= 1us, time POLLTIMEOUT= 1000ms, string suppress_error = "OFF");
     time pollstart;    
     int pollcnt;
     int n_bytes;
     logic [31:0] value_final;
     logic [31:0] data_final;
     logic [1:0] addr_lsb;
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF") begin
       if_regs   = psif_regs;
       if_blocks = psif_blocks;
     end else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     pollstart= $time;
     foreach (if_blocks[j]) begin                             // For all blocks in sequence
       if (if_blocks[j].get_name()==regmodule.toupper) begin  // Find selected module
         foreach (if_regs[i]) begin                           // For all registers in sequence
           if (if_regs[i].get_name()==register.toupper) begin // Find selected register
             pollcnt= 0;
             do begin
               if (moduleif=="PSIF") begin
                 if (mirrorcheck != "ON")  
                   m_psif_regs_all.top_if_map.set_check_on_read(.on(FALSE));
                 else
                   m_psif_regs_all.top_if_map.set_check_on_read(.on(TRUE));
               end
               if_blocks[j].get_reg_by_name(register.toupper).read(status, data);  // Read value from the selected register  
               n_bytes= if_blocks[j].get_reg_by_name(register.toupper).get_n_bytes();
               addr_lsb= if_blocks[j].get_reg_by_name(register.toupper).get_address()[1:0];
               value_final= 0;
               data_final= 0;
               if (n_bytes==1) begin
                 if (addr_lsb==0) begin
                   value_final[7:0]= value[7:0];
                   data_final[7:0] = data[7:0];                 
                 end else if (addr_lsb==1) begin
                   value_final[15:8]= value[7:0];
                   data_final[15:8] = data[15:8];
                 end else if (addr_lsb==2) begin
                   value_final[23:16]= value[7:0];
                   data_final[23:16] = data[23:16];
                 end else begin
                   value_final[31:24]= value[7:0];
                   data_final[31:24] = data[31:24];
                 end
               end else if (n_bytes==2) begin
                 if (addr_lsb==0) begin
                   value_final[15:0]= value[15:0];
                   data_final[15:0] = data[15:0];
                 end else if (addr_lsb==2) begin
                   value_final[31:16]= value[15:0];
                   data_final[31:16] = data[31:16];
                 end
               end else begin 
                 value_final= value;
                 data_final= data;
               end
               if (value_final != data_final) begin
                 `uvm_info(get_type_name(), $psprintf("Warning: Polling register %s with value: 0x%0h, but polling:  0x%0h NOT found; still polling ...", register.toupper, data_final, value_final), UVM_MEDIUM);
               end else begin
                 `uvm_info(get_type_name(), $psprintf("Polling register %s with value: 0x%0h", register.toupper, data_final), UVM_MEDIUM);
                 return;
               end
               pollcnt= pollcnt+1;
               #POLLTIME; // Wait for POLLTIME between each register read!
             end while ((value_final != data_final) && ($time-pollstart < POLLTIMEOUT)); // UNMATCHED !!
             if (suppress_error == "ON") begin
               exitstatus= 5; // Register data poll read error with UVM mirror error suppressed. 
               `uvm_warning(get_type_name(), $psprintf("Warning (NOTE: ERROR SUPPRESSED): Polling register %s with value: 0x%0h, but polling value: 0x%0h NOT found within %0d read accesses in %0t ps(/timeunit) time", register.toupper, data_final, value_final, pollcnt, POLLTIMEOUT));
             end else begin
               exitstatus= 4; // Register data poll read error
               `uvm_error(get_type_name(), $psprintf("Error: Polling register %s with value: 0x%0h, but polling value: 0x%0h NOT found within %0d read accesses in %0t ps(/timeunit) time", register.toupper, data_final, value_final, pollcnt, POLLTIMEOUT));
             end
             return;
           end
         end
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Polling register %s not found", register.toupper));
         return;        
       end
     end 
     value_final = 0;
     data_final = 0;
     exitstatus= 2; // Module in interface not found
     `uvm_error(get_type_name(), $psprintf("Module %s not found", regmodule.toupper));       
   endtask // regp


   // Write value to memory defined in m_*_regs_all in build function
   // Value of task exitstatus:
   //   0: Memory write done without error
   //   1: Interface not found
   //   2: Memory in interface not found
   task automatic memw(output int exitstatus, input string moduleif, string memory, int value, int offset);
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF")
       if_mems = psif_mems;
     else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_mems[i]) begin                                    // For all memories in sequence
        if (if_mems[i].get_name() == memory.toupper) begin // Find selected memory
          `uvm_info(get_type_name(), $psprintf("Write memory %s with value: 0x%0h", memory.toupper, value), UVM_MEDIUM);
          if_mems[i].write(status, offset, value);                 // Write value to the selected memory
          return;
        end
     end 
     exitstatus= 2; // Memory in interface not found
     `uvm_error(get_type_name(), $psprintf("Write memory %s not found", memory.toupper));        
   endtask // memw
       

   // Read value from memory defined in m_*_regs_all in build function
   // Value of task exitstatus:
   //   0: Memory read done without error
   //   1: Interface not found
   //   2: Memory in interface not found
   task automatic memr(output int exitstatus, input string moduleif, string memory, output int value, input int offset);    
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF")
       if_mems = psif_mems;
     else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_mems[i]) begin                             // For all memories in sequence
        if (if_mems[i].get_name()==memory.toupper) begin // Find selected memory
          if_mems[i].read(status, offset, data);                    // Write value to the selected memory
          `uvm_info(get_type_name(), $psprintf("Read memory %s with value: 0x%0h", memory.toupper, data), UVM_MEDIUM);
          value = data;
          return;
        end
     end  
     value = 0;
     exitstatus= 2; // Memory in interface not found
     `uvm_error(get_type_name(), $psprintf("Read memory %s not found", memory.toupper));        
   endtask // memr


   // Check value to memory defined in m_psif_regs_all in build function
   // Value of task exitstatus:
   //   0: Memory check done without error
   //   1: Interface not found
   //   2: Memory in interface not found
   //   3: Memory data read error
   //   4: Memory data read error, but with UVM mirror error suppressed
   task automatic memc(output int exitstatus, input string moduleif, string memory, int value, int offset, string suppress_error = "OFF");
     exitstatus= 0; // Default task exit value set to zero; i.e. error not found.
     if (moduleif=="PSIF")
       if_mems = psif_mems;
     else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_mems[i]) begin                             // For all memories in sequence
        if (if_mems[i].get_name()==memory.toupper) begin    // Find selected memory
          if_mems[i].read(status, offset, data);            // read from the selected memory          
          if (value != data) begin
            if (suppress_error == "ON") begin
              exitstatus= 4; // Memory data read error with UVM mirror error suppressed. 
              `uvm_warning(get_type_name(), $psprintf("Warning (NOTE: ERROR SUPPRESSED): Read memory %s with value: 0x%0h, but expected:  0x%0h", memory.toupper, data, value));
            end else begin
              exitstatus= 3; // Memory data read error.
              `uvm_error(get_type_name(), $psprintf("Error: Read memory %s with value: 0x%0h, but expected:  0x%0h", memory.toupper, data, value));
            end
          end else begin
            `uvm_info(get_type_name(), $psprintf("Check memory %s with value: 0x%0h", memory.toupper, data), UVM_MEDIUM);
          end
          return;     
        end
     end  
     exitstatus= 2; // Memory in interface not found.
     `uvm_error(get_type_name(), $psprintf("Check memory %s not found", memory.toupper));
     return;        
   endtask // memc

   
endclass // base_seq
