
//----------------------------------------------------------------------
// kb_axi4lite_agent_driver
//----------------------------------------------------------------------
class kb_axi4lite_agent_driver extends uvm_driver #(kb_axi4lite_agent_item);

   // factory registration macro
   `uvm_component_utils(kb_axi4lite_agent_driver);
   
   // no of transact
   int trcount= 0;
   

   // Configuration object
   kb_axi4lite_agent_config   m_cfg; 
   kb_axi4lite_agent_item     m_req;

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "kb_axi4lite_agent_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new


   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     m_cfg= kb_axi4lite_agent_config::type_id::create("m_cfg");
   endfunction : build_phase


   //--------------------------------------------------------------------
   // report_phase
   //--------------------------------------------------------------------  
   virtual function void report_phase(uvm_phase phase);
     string  s;  
     $sformat(s, "%0d AXI4Lite_Agent sequence items", trcount);
     `uvm_info({get_type_name(),":report"}, s, UVM_MEDIUM );
   endfunction: report_phase
     

   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);
      m_req=kb_axi4lite_agent_item::type_id::create("m_req"); // To get tr recording from time 0
      
      m_req.enable_recording("driver_items");

      // Calls init_signals task
      init_signals();
      forever begin

//   	    seq_item_port.get_next_item(m_req);
 	     seq_item_port.get(m_req);

	     this.begin_tr(m_req,"driver_items");

	     trcount++;
	     case (m_req.m_read_or_write)
	       AXI4LITE_READ:  read_access(m_req);   // Use read_access task for read accesses
	       AXI4LITE_WRITE: write_access(m_req);  // Use write_access task for write accesses
	     endcase // case (m_req.m_read_or_write)

	     this.end_tr(m_req);

//	       seq_item_port.item_done(m_req);
	     seq_item_port.put(m_req);
      end
   endtask: run_phase


   
   task init_signals();
      // Read Address Channel
      m_cfg.vif.ARADDR    <='0;
      m_cfg.vif.ARPROT    <='0;
      m_cfg.vif.ARVALID   <='0;
      m_cfg.vif.RREADY    <='0;
      // Write Address Channel
      m_cfg.vif.AWADDR    <='0;
      m_cfg.vif.AWPROT    <='0;
      m_cfg.vif.AWVALID   <='0;
      m_cfg.vif.WDATA     <='0;
      m_cfg.vif.WSTRB     <='0;
      m_cfg.vif.WVALID    <='0;
      m_cfg.vif.BREADY    <='0;
   endtask // init_signals
   
   
   task automatic write_access(ref kb_axi4lite_agent_item m_tr);
      `uvm_info(get_type_name(),"Initiating a write operation",UVM_DEBUG);
      m_tr.m_status=AXI4LITE_OK;
      @(posedge m_cfg.vif.ACLK);

      m_cfg.vif.WSTRB   <= m_tr.m_strb;
      m_cfg.vif.AWADDR  <= m_tr.m_addr;
      m_cfg.vif.AWPROT  <= 3'b000;
      m_cfg.vif.AWVALID <= 1'b1; 
      m_cfg.vif.WDATA   <= m_tr.m_wr_data;
      m_cfg.vif.WVALID  <= 1'b1;
      m_cfg.vif.BREADY  <= 1'b1;
      m_cfg.vif.m_transaction_size <= m_tr.m_transaction_size;

      `uvm_info(get_type_name(),"Waiting for axi_awready",UVM_HIGH);
      fork
	     @(posedge m_cfg.vif.AWREADY);
	     #(m_cfg.m_timeout);
      join_any
      if (m_cfg.vif.AWREADY) begin
	     `uvm_info(get_type_name(),"axi_awready went high",UVM_DEBUG);
	     @(posedge m_cfg.vif.ACLK);
	     m_cfg.vif.AWADDR  <= '0;
	     m_cfg.vif.AWPROT  <= '0;
	     m_cfg.vif.AWVALID <= '0; 
	     m_cfg.vif.WDATA   <=  m_tr.m_wr_data;
	     m_cfg.vif.WVALID  <= '0;
      end else begin
	     `uvm_warning(get_type_name(),"No axi_awready after 2 us");
	     fork
	       @(posedge m_cfg.vif.AWREADY);
	       #(m_cfg.m_timeout);
	     join_any
	     m_cfg.vif.AWADDR  <= '0;
	     m_cfg.vif.AWPROT  <= '0;
	     m_cfg.vif.AWVALID <= 1'b0; 
	     @(posedge m_cfg.vif.ACLK);
	     m_cfg.vif.WDATA   <= '0;
	     m_cfg.vif.WVALID  <= '0;      
      end
      
      if (~m_cfg.vif.BVALID) begin
	     fork
	       #(m_cfg.m_timeout);
	       @(posedge m_cfg.vif.BVALID);
	     join_any
      end

      @(negedge m_cfg.vif.ACLK);
      
      if (~m_cfg.vif.BVALID | (m_cfg.vif.BRESP !=2'b00)) begin
	     `uvm_error(get_type_name(),"AXI4Lite write access aborted: Write access timeout.");
	     m_tr.m_status=AXI4LITE_TIMEOUT;
      end

      @(posedge m_cfg.vif.ACLK);
      m_cfg.vif.BREADY <= '0;
      @(posedge m_cfg.vif.ACLK);

   endtask



   task automatic read_access(ref kb_axi4lite_agent_item m_tr);
      `uvm_info(get_type_name(),"Initiating a read operation",UVM_DEBUG);

      @(posedge m_cfg.vif.ACLK);
      m_cfg.vif.ARVALID  <= '1;
      m_cfg.vif.ARADDR   <= m_tr.m_addr;
      m_cfg.vif.ARPROT   <= '0;
      m_cfg.vif.RREADY   <= 1'b1;
      m_cfg.vif.m_transaction_size <= m_tr.m_transaction_size;
      fork 
	     @(posedge m_cfg.vif.ARREADY);
	     #(m_cfg.m_timeout);  
      join_any
      
      if (m_cfg.vif.ARREADY) begin
	     `uvm_info(get_type_name(),"axi_arready went high",UVM_DEBUG);
      end else
	     `uvm_warning(get_type_name(),"No axi_arready after 2 us");

      @(posedge m_cfg.vif.ACLK);
      m_cfg.vif.ARVALID  <= '0;
      m_cfg.vif.ARADDR   <= m_tr.m_addr;

      if (m_cfg.vif.RVALID == 0) begin
	     fork
	       #(m_cfg.m_timeout);
	       @(posedge m_cfg.vif.RVALID);
	    join_any
      end

      // might be removed
      @(negedge m_cfg.vif.ACLK);

      if ((m_cfg.vif.RVALID!=1'b1) |(m_cfg.vif.RRESP!=2'b00)) begin
	     m_tr.m_status = AXI4LITE_TIMEOUT;
	     `uvm_error(get_type_name(),"AXI4Lite read access aborted: Read access timeout.");
      end else begin
	     m_tr.m_rd_data = m_cfg.vif.RDATA;
	     m_tr.m_status = AXI4LITE_OK;
      end // UNMATCHED !!

      @(posedge m_cfg.vif.ACLK);
      m_cfg.vif.RREADY <= '0;
      m_cfg.vif.ARADDR <= '0;
      @(posedge m_cfg.vif.ACLK);

   endtask

endclass: kb_axi4lite_agent_driver

