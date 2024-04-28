class interrupt_handler_psif_seq extends interrupt_handler_base_isr_seq;

   `uvm_object_utils(interrupt_handler_psif_seq);

   parameter CHANNEL_OFFSET = 1;

   int es; // Task exit status value (i.e. es)

//   logic [31:0] irq2psif;
   bit irq2psif[];
   int irq_value;

// Unused due to all interrupt bits cleared in one write access
//   int bit_index;
//   logic [31:0] irq_local;
//   int local_bit_index;

   // Declare communication mailboxes between interrupt handler and use sequences .
   mailbox #(module_interrupt_item) mbox_irq_psif2redside_interrupt_seq;      

   function new(string name = "interrupt_handler_psif_seq",
      mailbox #(module_interrupt_item) mbox_irq_psif2redside_interrupt_seq = mbox_irq_psif2redside_interrupt_seq);
      super.new(name);
      this.mbox_irq_psif2redside_interrupt_seq = mbox_irq_psif2redside_interrupt_seq;
 
   endfunction : new

   task body;

      //##############################################################
      // Get registers for tasks regw, regr and regc    
      // Get memories for tasks memw, memr and memc    
      //##############################################################
      // Check m_psif_regs_all not equal null.
      if (m_psif_regs_all==null) begin
        `uvm_fatal(get_type_name(), "PSIF registers is NULL in PSIF interrupt handler; execution terminated");
      end;
      m_psif_regs_all.get_registers(psif_regs);  
      m_psif_regs_all.get_memories(psif_mems);  
      m_psif_regs_all.get_blocks(psif_blocks);
   
      forever begin

         m_req=interrupt_handler_item::type_id::create("m_req");

	 m_req.status = WAITING_FOR_IRQ;

	 // The start_item method blocks until the sequencer is ready to accept the m_req sequence item.
         start_item(m_req);
         // The finish_item method blocks until the driver (i.e. in file interrupt_handler_driver.svh)  
         //   completes, and in this case deliveres an m_req sequence item,
         //   i.e. identifying the interrupt(s). 
	 finish_item(m_req);
         // Get the m_req sequence item to identify the interrupt(s). IS IT POSSIBLE TO DELETE THIS STATEMENT; CHECK!!
	 get_response(m_req);
 
         irq2psif = m_req.sources;   
	 
	 // At this time we have got our irq
	 m_sequencer.grab(this);
	 assert(m_req.status==GOT_IRQ);
	 `uvm_info(get_type_name(),"Got interrupt, running Interrupt Service Routine",UVM_MEDIUM);

         // Check for interrupts in all modules in PSIF
         for (int i=0; i<irq2psif.size(); i++) begin

           // Check each module and clear all interrupts in the module
           if (irq2psif[i]== 1'b1) begin
    
             // Create interrupt item to be sent to stimuli and receiver modules
             m_module_interrupt_item=module_interrupt_item::type_id::create("m_module_interrupt_item");

             // Clear interrupts in all module in PSIF interface
             if (i==0) begin // This is the LTC module
               regr(es,"PSIF","LTC","LTC_IRQ", irq_value, "OFF");  
      	       `uvm_info(get_type_name(),"Clearing IRQ",UVM_DEBUG);    
               regw(es,"PSIF","LTC","LTC_IRQ_ICR", irq_value);
               m_module_interrupt_item.module_if= "PSIF";
               m_module_interrupt_item.module_name= "LTC";
               m_module_interrupt_item.module_irq= irq_value;

             end else if (i==1) begin // This is the ZBUF module
               regr(es,"PSIF","ZBUF","ZBUF_IRQ", irq_value, "OFF");  
      	       `uvm_info(get_type_name(),"Clearing IRQ",UVM_DEBUG);    
               regw(es,"PSIF","ZBUF","ZBUF_IRQ_ICR", irq_value);
               m_module_interrupt_item.module_if= "PSIF";
               m_module_interrupt_item.module_name= "ZBUF";
               m_module_interrupt_item.module_irq= irq_value;

             end else if (i==2) begin // This is the RNG module
               regr(es,"PSIF","RNG","RNG_IRQ", irq_value, "OFF");  
      	       `uvm_info(get_type_name(),"Clearing IRQ",UVM_DEBUG);    
               regw(es,"PSIF","RNG","RNG_IRQ_ICR", irq_value);
               m_module_interrupt_item.module_if= "PSIF";
               m_module_interrupt_item.module_name= "RNG";
               m_module_interrupt_item.module_irq= irq_value;

             end else if (i==3) begin // This is the REV module
               regr(es,"PSIF","REV","REV_IRQ", irq_value, "OFF");  
      	       `uvm_info(get_type_name(),"Clearing IRQ",UVM_DEBUG);    
               regw(es,"PSIF","REV","REV_IRQ_ICR", irq_value);
               m_module_interrupt_item.module_if= "PSIF";
               m_module_interrupt_item.module_name= "REV";
               m_module_interrupt_item.module_irq= irq_value;
                
             end else if (i==4) begin // This is the COMBUF module
               regr(es,"PSIF","COMBUF","COMBUF_IRQ", irq_value, "OFF");  
      	       `uvm_info(get_type_name(),"Clearing IRQ",UVM_DEBUG);    
               regw(es,"PSIF","COMBUF","COMBUF_IRQ_ICR", irq_value);
               m_module_interrupt_item.module_if= "PSIF";
               m_module_interrupt_item.module_name= "COMBUF";
               m_module_interrupt_item.module_irq= irq_value;

             end else begin
                // All modules cleared and giving simulation error if module not defined.
      	       `uvm_error(get_type_name(),"Interrupt from unknown module in PSIF interface");
             end    
                     
//             m_req.displayAll();       
             m_module_interrupt_item.displayAll();       
             mbox_irq_psif2redside_interrupt_seq.put(m_module_interrupt_item);         

           end;
         end;
            
    	 `uvm_info(get_type_name(),"Ending Interrupt Service Routine",UVM_DEBUG);
    
         m_req.status = IRQ_DONE;

//         m_req.got_irq();

	 m_sequencer.ungrab(this);

      end // forever begin

   endtask // body

endclass // interrupt_handler_psif_seq
