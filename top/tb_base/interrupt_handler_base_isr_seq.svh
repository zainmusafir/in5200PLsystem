class interrupt_handler_base_isr_seq extends uvm_sequence#(interrupt_handler_item);
   `uvm_object_utils(interrupt_handler_base_isr_seq);

   interrupt_handler_item  m_req;
   module_interrupt_item   m_module_interrupt_item;

   // PSIF interface module registers
   top_PSIF                 m_psif_regs_all;

   //##############################################################
   // Declarations used in tasks regw, regr and regc and 
   //   memw, memr, and menc.
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

   // Variables used in tasks
   uvm_status_e status;
   uvm_reg_data_t data;
   typedef enum {FALSE, TRUE} boolean;
   int value;


   function new(string name = "interrupt_handler_base_isr_seq");
      super.new(name);
   endfunction : new

   
   // Write value to register defined in build function (i.e. m_*_regs_all).
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   task automatic regw(output int exitstatus, input string moduleif, regmodule, register, int value);
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
             `uvm_info(get_type_name(), $psprintf("Write to module %s with register %s with value: 0x%0h", regmodule.toupper,  register.toupper, value), UVM_MEDIUM);
             if_blocks[j].get_reg_by_name(register.toupper).write(status, value);  // Write value to the selected register
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
   task automatic regc(output int exitstatus, input string moduleif, string regmodule, register, int value, input string mirrorcheck = "ON", string suppress_error = "OFF");    
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
             if (value != data) begin
               if (suppress_error == "ON") begin
                 exitstatus= 5; // Register data read error with UVM mirror error suppressed. 
                 `uvm_warning(get_type_name(), $psprintf("Warning (NOTE: ERROR SUPPRESSED): Read register %s with value: 0x%0h, but expected:  0x%0h", register.toupper, data, value));
               end else begin               
                 exitstatus= 4; // Register data read error
                 `uvm_error(get_type_name(), $psprintf("Error: Read register %s with value: 0x%0h, but expected:  0x%0h", register.toupper, data, value));
               end
             end else begin
               `uvm_info(get_type_name(), $psprintf("Check register %s with value: 0x%0h", register.toupper, data), UVM_MEDIUM);
             end
             return;
           end
         end
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Check register %s not found", register.toupper));
         return;        
       end
     end 
     value = 0;
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
               if (value != data) begin
                 `uvm_info(get_type_name(), $psprintf("Warning: Polling register %s with value: 0x%0h, but polling:  0x%0h NOT found; still polling ...", register.toupper, data, value), UVM_MEDIUM);
               end else begin
                 `uvm_info(get_type_name(), $psprintf("Polling register %s with value: 0x%0h", register.toupper, data), UVM_MEDIUM);
                 return;
               end
               pollcnt= pollcnt+1;
               #POLLTIME; // Wait for POLLTIME between each register read!
             end while ((value != data) && ($time-pollstart < POLLTIMEOUT)); // UNMATCHED !!
             if (suppress_error == "ON") begin
               exitstatus= 5; // Register data poll read error with UVM mirror error suppressed. 
               `uvm_warning(get_type_name(), $psprintf("Warning (NOTE: ERROR SUPPRESSED): Polling register %s with value: 0x%0h, but polling value: 0x%0h NOT found within %0d read accesses in %0t ps(/timeunit) time", register.toupper, data, value, pollcnt, POLLTIMEOUT));
             end else begin
               exitstatus= 4; // Register data poll read error
               `uvm_error(get_type_name(), $psprintf("Error: Polling register %s with value: 0x%0h, but polling value: 0x%0h NOT found within %0d read accesses in %0t ps(/timeunit) time", register.toupper, data, value, pollcnt, POLLTIMEOUT));
             end
             return;
           end
         end
         exitstatus= 3; // Register in module not found
         `uvm_error(get_type_name(), $psprintf("Polling register %s not found", register.toupper));
         return;        
       end
     end 
     value = 0;
     exitstatus= 2; // Module in interface not found
     `uvm_error(get_type_name(), $psprintf("Module %s not found", regmodule.toupper));       
   endtask // regp


   // Read poll value in register defined in build function (i.e. m_*_regs_all) 
   // Value of task exitstatus:
   //   0: Register write done without error
   //   1: Interface not found
   //   2: Module in interface not found
   //   3: Register in module not found
   //   4: Register data poll read error
   //   5: Register data poll read error, but with UVM mirror error suppressed
   task automatic memw(output int exitstatus, input string moduleif, string memory, int value, int offset);
     if (moduleif=="PSIF")
       if_mems   = psif_mems;
     else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_mems[i]) begin                                    // For all memorys in sequence
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
     if (moduleif=="PSIF")
       if_mems   = psif_mems;
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
     if (moduleif=="PSIF")
       if_mems   = psif_mems;
     else begin
       exitstatus= 1; // Interface not found
       return;
     end;
     foreach (if_mems[i]) begin                             // For all memorys in sequence
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
   endtask // memc
   
endclass // interrupt_handler_base_isr_seq
