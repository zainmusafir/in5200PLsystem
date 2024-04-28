 `include "uvm_macros.svh"
 
module tb_top ();

//`define SETUP_KBAXI4LITE 1  
   
   import uvm_pkg::*;
   import base_test_pkg::*;
   
   import psif_reg_pkg::*;
   import psif_ram_pkg::*;
//   import psif_irq_pkg::*;

   import psif_odi_spi_pkg::*;

   import psif_scu_pkg::*;
   import psif_dti_spi_loop_pkg::*;
//   import psif_dti_spi_pkg::*;
//   import psif_dti_spi_module_pkg::*;
   import psif_zu_pkg::*;
   import psif_zu_csim_pkg::*;
//   import psif_aui_aurora_pkg::*;

   wire [14:0] ddr_addr;  
   wire [2:0] ddr_ba;      
   wire ddr_cas_n;         
   wire ddr_ck_n;          
   wire ddr_ck_p;          
   wire ddr_cke;           
   wire ddr_cs_n;          
   wire [3:0] ddr_dm;      
   wire [31:0] ddr_dq;     
   wire [3:0] ddr_dqs_n;   
   wire [3:0] ddr_dqs_p;   
   wire ddr_odt;           
   wire ddr_ras_n;         
   wire ddr_reset_n;       
   wire ddr_we_n;          
   wire fixed_io_ddr_vrn;  
   wire fixed_io_ddr_vrp;  
   wire [53:0] fixed_io_mio; 
   wire fixed_io_ps_clk;   
   wire fixed_io_ps_porb;
   wire fixed_io_ps_srstb;
   wire [15:0] hdmi_data;
   wire hdmi_data_e;
   wire hdmi_hsync;
   wire hdmi_out_clk;
   wire hdmi_vsync;
   wire [1:0] iic_mux_scl;
   wire [1:0] iic_mux_sda;
   wire [0:0] otg_resetn;
   wire otg_vbusoc;

   // Aurora example design signals    
   logic       aurora_init_clk_p;
   logic       aurora_init_clk_n;
   logic       aurora_exdes_reset;
   logic       aurora_hard_err;
   logic       aurora_soft_err;
   logic       aurora_frame_err;
   logic [7:0] aurora_err_count; 
   logic       aurora_crc_pass_fail_n;
   logic       aurora_crc_valid;
   logic       aurora_lane_up;
   logic       aurora_channel_up;
   logic       aurora_gt_reset_in;
   logic       aurora_gsr_r;
   logic       aurora_gts_r;
   logic [0:0] gt_powergood_exdes;
   
   logic arst_n;          // Processor/AXI4 reset; PS generated reset
//   logic fpga_rst;        // External PL core reset. NOTE: Removed due to reset from reset agent.
   logic psclk;           // Processor/AXI4 clock; PS generated clock
   logic refclk;          // External PL core clock
 
   logic [7:0] led_8bit;
   logic       alarm_ack_btn= '0;
   logic       toggle_on= '1;
   
   logic    rf_gt_refclk1_p;
   logic    rf_gt_refclk1_n;
   logic    rf_rxp;           
   logic    rf_rxn;           
   logic    rf_txp;           
   logic    rf_txn;

   logic       top_spi_4wire_if_dmy_ce;        // 4 wire SPI Agent Interface dummy signal
   logic       top_spi_4wire_if_dmy_sclk;      // 4 wire SPI Agent Interface dummy signal
   logic       top_spi_4wire_if_dmy_sdi;       // 4 wire SPI Agent Interface dummy signal
   logic       top_spi_4wire_if_dmy_sdo;       // 4 wire SPI Agent Interface dummy signal   
     
   // External Aurora INIT_CLK for Aurora Example Design
   initial begin
      aurora_init_clk_p = 0;
      aurora_init_clk_n = 1;
      #2ns;
      forever begin
	 #8ns;  // 62.5 MHz halfperiod; i.e. 62.5 MHz Aurora INIT_CLK
	 aurora_init_clk_p = ~aurora_init_clk_p;
	 aurora_init_clk_n = ~aurora_init_clk_n;
      end
   end // initial begin

   // External GT ref clock
   initial begin
      rf_gt_refclk1_p = 0;
      rf_gt_refclk1_n = 1;
      #2ns;
      forever begin
	 #4ns;  // 125 MHz halfperiod; i.e. 125 MHz gt_refclk
	 rf_gt_refclk1_p = ~rf_gt_refclk1_p;
	 rf_gt_refclk1_n = ~rf_gt_refclk1_n;
      end
   end // initial begin

   // AXI4-Lite agent reset; i.e. AXI4 interface to PL reset          
   initial begin
      arst_n <= 0;
      repeat(32) @(posedge psclk);
      arst_n <= 1;      
   end

   // PS clock
   initial begin
      psclk = 0;     
      forever begin
	 // Final clock period TBD!!!!!!!!!!!!!!!!!
	 #5ns;  // 100MHz halfperiod
	 psclk = ~psclk;
      end
   end

   // External ref clock
   initial begin
      refclk = 0;
      #2.5ns;
      forever begin
	 #5ns;  // 100 MHz halfperiod; i.e. ZEDBOARD ref. clock
	 refclk = ~refclk;
      end
   end // initial begin

   
   // Reset interface  
   reset_agent_if top_reset_if(refclk);

   // Oled_spi interface  
   oled_spi_agent_if top_oled_spi_if(refclk);

   // Spi_4wire interface  
   // spi_4wire_agent_if top_spi_4wire_if(refclk);
   
    
   `ifdef SETUP_KBAXI4LITE
      // Instantiating KONGSBERG AXI4-Lite interface     
      kb_axi4lite_agent_if psif_axi4lite_master_if(psclk, arst_n);
   `else
      // Instantiating Mentor Questa QVIP AXI4 interface
      mgc_axi4 #(32,
                32,
                32,
                4,
                4,
                16) psif_axi4lite_master_if(psclk, arst_n);  
   `endif // !`ifdef SETUP_KBAXI4LITE

   
   // Interrupt handler interfaces with the number of interrupts set to 32    
   // interrupt_if#(32) psif_interrupt_if(psclk, arst_n);

   // AXI4STREAM interface for   
   kb_axi4stream_agent_if kb_axi4stream_if(kb_axi4stream_if.CLK);
           
   // DUT: MLA PS (dummy architecture) and PL

   top #(.TARGET("ZEDBOARD"), 
         .PSMODULE("SIMPLE"),    //  Selects PS (.bd) module
         .HLSMODULE("AES128"),
         .SIMULATION_MODE("ON"))  mla_top (
     
     .ddr_addr                      (ddr_addr),         
     .ddr_ba                        (ddr_ba),           
     .ddr_cas_n                     (ddr_cas_n),        
     .ddr_ck_n                      (ddr_ck_n),         
     .ddr_ck_p                      (ddr_ck_p),         
     .ddr_cke                       (ddr_cke),          
     .ddr_cs_n                      (ddr_cs_n),         
     .ddr_dm                        (ddr_dm),           
     .ddr_dq                        (ddr_dq),           
     .ddr_dqs_n                     (ddr_dqs_n),        
     .ddr_dqs_p                     (ddr_dqs_p),        
     .ddr_odt                       (ddr_odt),          
     .ddr_ras_n                     (ddr_ras_n),    
     .ddr_reset_n                   (ddr_reset_n),      
     .ddr_we_n                      (ddr_we_n),
     .fixed_io_ddr_vrn              (fixed_io_ddr_vrn),
     .fixed_io_ddr_vrp              (fixed_io_ddr_vrp), 
     .fixed_io_mio                  (fixed_io_mio),     
     .fixed_io_ps_clk               (fixed_io_ps_clk),  
     .fixed_io_ps_porb              (fixed_io_ps_porb), 
     .fixed_io_ps_srstb             (fixed_io_ps_srstb),
     .hdmi_data                     (hdmi_data),
     .hdmi_data_e                   (hdmi_data_e),
     .hdmi_hsync                    (hdmi_hsync),
     .hdmi_out_clk                  (hdmi_out_clk), 
     .hdmi_vsync                    (hdmi_vsync),
     .iic_mux_scl                   (iic_mux_scl), 
     .iic_mux_sda                   (iic_mux_sda),
     .otg_resetn                    (otg_resetn),
     .otg_vbusoc                    (otg_vbusoc),

     .fpga_rst                      (top_reset_if.rst),  // Reset Agent Interface signal
                                    
     .refclk                        (refclk),
               
     .led_8bit                      (led_8bit),

//     .dti_ce                        (top_spi_4wire_if.ce),        // 4 wire SPI Agent Interface signal
//     .dti_sclk                      (top_spi_4wire_if.sclk),      // 4 wire SPI Agent Interface signal
//     .dti_sdi                       (top_spi_4wire_if.sdi),       // 4 wire SPI Agent Interface signal
//     .dti_sdo                       (top_spi_4wire_if.sdo),       // 4 wire SPI Agent Interface signal
     .dti_ce                        (top_spi_4wire_if_dmy_ce),        // 4 wire SPI Agent Interface signal
     .dti_sclk                      (top_spi_4wire_if_dmy_sclk),      // 4 wire SPI Agent Interface signal
     .dti_sdi                       (top_spi_4wire_if_dmy_sdi),       // 4 wire SPI Agent Interface signal
     .dti_sdo                       (top_spi_4wire_if_dmy_sdo),       // 4 wire SPI Agent Interface signal

     .rf_gt_refclk1_p               (rf_gt_refclk1_p),  // AUI (Aurora) signals used in simulation only        
     .rf_gt_refclk1_n  		    (rf_gt_refclk1_n),  
     .rf_rxp           		    (rf_rxp),
     .rf_rxn           		    (rf_rxn),           
     .rf_txp           		    (rf_txp),           			   
     .rf_txn			    (rf_txn),           
					   
     .oled_sdin                     (top_oled_spi_if.oled_sdin),  // OLED_SPI Agent Interface signal
     .oled_sclk                     (top_oled_spi_if.oled_sclk),  // OLED_SPI Agent Interface signal
     .oled_dc                       (top_oled_spi_if.oled_dc),    // OLED_SPI Agent Interface signal
     .oled_res                      (top_oled_spi_if.oled_res),   // OLED_SPI Agent Interface signal
     .oled_vbat                     (top_oled_spi_if.oled_vbat),  // OLED_SPI Agent Interface signal
     .oled_vdd                      (top_oled_spi_if.oled_vdd),   // OLED_SPI Agent Interface signal
     .alarm_ack_btn                 (alarm_ack_btn)
   );

   
/* -----\/----- EXCLUDED -----\/-----
   aurora_8b10b_0_exdes  aurora_8b10b_0_exdes_inst( 
     .RESET(aurora_exdes_reset),
     .HARD_ERR(aurora_hard_err),
     .SOFT_ERR(aurora_soft_err),
     .FRAME_ERR(aurora_frame_err),
     .ERR_COUNT(aurora_err_count),
    
     // CRC Status
     .CRC_PASS_FAIL_N(aurora_crc_pass_fail_n),
     .CRC_VALID(aurora_crc_valid),
     // Added by Roarsk
     .GT_POWERGOOD(gt_powergood_exdes),

    
     .LANE_UP(aurora_lane_up),
     .CHANNEL_UP(aurora_channel_up),
     .INIT_CLK_P(aurora_init_clk_p),
     .INIT_CLK_N(aurora_init_clk_n),
     .GT_RESET_IN(aurora_gt_reset_in),

     // Added by Roarsk
     .AURORA_USER_CLK(kb_axi4stream_if.CLK),
      .TX_TDATA(kb_axi4stream_if.TX_TDATA),
     .TX_TVALID(kb_axi4stream_if.TX_TVALID),
      .TX_TKEEP(kb_axi4stream_if.TX_TKEEP),
      .TX_TLAST(kb_axi4stream_if.TX_TLAST),
     .TX_TREADY(kb_axi4stream_if.TX_TREADY),
     .RX_TDATA(kb_axi4stream_if.RX_TDATA),
     .RX_TVALID(kb_axi4stream_if.RX_TVALID),
     .RX_TKEEP(kb_axi4stream_if.RX_TKEEP),
     .RX_TLAST(kb_axi4stream_if.RX_TLAST),
     
     .GT_REFCLK_P(rf_gt_refclk1_p),
     .GT_REFCLK_N(rf_gt_refclk1_n),
     // GT I/O
     .RXP(rf_txp), // Output from DUT is input to example design test unit
     .RXN(rf_txn),
     .TXP(rf_rxp), // Input to DUT is output from example design test unit
     .TXN(rf_rxn)
   );

 -----/\----- EXCLUDED -----/\----- */
    //____________________________Aurora Resets begin ____________________________
   
    initial
    begin
        aurora_exdes_reset = 1'b1;
        #31us aurora_exdes_reset = 1'b0;
    end
   
    //Simultate the global Aurora reset that occurs after configuration at the beginning
    //of the simulation. Note that both GT smart models use the same global signals.
//    assign glbl.GSR = aurora_gsr_r;
//    assign glbl.GTS = aurora_gts_r;

    initial
        begin
            aurora_gts_r    = 1'b0;       
            aurora_gsr_r    = 1'b1;
            aurora_gt_reset_in = 1'b1;
            #35us;
            aurora_gsr_r    = 1'b0;
            aurora_gt_reset_in = 1'b0;
            repeat(10) @(posedge aurora_init_clk_p);
            aurora_gt_reset_in = 1'b1;
            repeat(10) @(posedge aurora_init_clk_p);
            aurora_gt_reset_in = 1'b0;
        end

    //____________________________Aurora Resets end ____________________________
   
      
   // FPGA processor SW reset. This Signal is Active HIGH
//   assign mla_top.G_PS.mla_ps.pl_rst[0]       = fpga_rst;   

   // Assign clock and reset signals to internal dmy processor model   
   assign mla_top.G_PS.mla_ps.axi_aclk        = psclk;
   // AXI4-Lite Reset Signal. This Signal is Active LOW
   assign mla_top.G_PS.mla_ps.areset_n        = arst_n;

   // Assign PSIF interface to internal dmy processor model   
   // Write address (issued by master, acceped by Slave)
   assign mla_top.G_PS.mla_ps.psif_awaddr      = psif_axi4lite_master_if.AWADDR;
   // Write channel Protection type. This signal indicates the
   // privilege and security level of the transaction, and whether
   // the transaction is a data access or an instruction access.
   assign mla_top.G_PS.mla_ps.psif_awprot	 = psif_axi4lite_master_if.AWPROT;
   // Write address valid. This signal indicates that the master signaling
   // valid write address and control information.
   assign mla_top.G_PS.mla_ps.psif_awvalid     = psif_axi4lite_master_if.AWVALID;
   // Write address ready. This signal indicates that the slave is ready
   // to accept an address and associated control signals.
   assign psif_axi4lite_master_if.AWREADY = mla_top.G_PS.mla_ps.psif_awready;
   // Write data (issued by master, acceped by Slave) 
   assign mla_top.G_PS.mla_ps.psif_wdata	 = psif_axi4lite_master_if.WDATA;
   // Write strobes. This signal indicates which byte lanes hold
   // valid data. There is one write strobe bit for each eight
   // bits of the write data bus.    
   assign mla_top.G_PS.mla_ps.psif_wstrb	 = psif_axi4lite_master_if.WSTRB;
   // Write valid. This signal indicates that valid write
   // data and strobes are available.
   assign mla_top.G_PS.mla_ps.psif_wvalid	 = psif_axi4lite_master_if.WVALID;
   // Write ready. This signal indicates that the slave
   // can accept the write data.
   assign psif_axi4lite_master_if.WREADY  = mla_top.G_PS.mla_ps.psif_wready;
   // Write response. This signal indicates the status
   // of the write transaction.
   assign psif_axi4lite_master_if.BRESP   = mla_top.G_PS.mla_ps.psif_bresp;
   // Write response valid. This signal indicates that the channel
   // is signaling a valid write response.
   assign psif_axi4lite_master_if.BVALID  = mla_top.G_PS.mla_ps.psif_bvalid;
   // Response ready. This signal indicates that the master
   // can accept a write response.
   assign mla_top.G_PS.mla_ps.psif_bready	 = psif_axi4lite_master_if.BREADY;
   // Read address (issued by master, acceped by Slave)
   assign mla_top.G_PS.mla_ps.psif_araddr	 = psif_axi4lite_master_if.ARADDR;
   // Protection type. This signal indicates the privilege
   // and security level of the transaction, and whether the
   // transaction is a data access or an instruction access.
   assign mla_top.G_PS.mla_ps.psif_arprot      = psif_axi4lite_master_if.ARPROT;
   // Read address valid. This signal indicates that the channel
   // is signaling valid read address and control information.
   assign mla_top.G_PS.mla_ps.psif_arvalid     = psif_axi4lite_master_if.ARVALID;
   // Read address ready. This signal indicates that the slave is
   // ready to accept an address and associated control signals.
   assign psif_axi4lite_master_if.ARREADY = mla_top.G_PS.mla_ps.psif_arready;
   // Read data (issued by slave)
   assign psif_axi4lite_master_if.RDATA   = mla_top.G_PS.mla_ps.psif_rdata;
   // Read response. This signal indicates the status of the
   // read transfer.
   assign psif_axi4lite_master_if.RRESP   = mla_top.G_PS.mla_ps.psif_rresp;
   // Read valid. This signal indicates that the channel is
   // signaling the required read data.
   assign psif_axi4lite_master_if.RVALID = mla_top.G_PS.mla_ps.psif_rvalid;
   // Read ready. This signal indicates that the master can
   // accept the read data and response information.
   assign mla_top.G_PS.mla_ps.psif_rready	= psif_axi4lite_master_if.RREADY;

   
   // Assign interrupt signals to the interrupt_if signals. This assigns the interrupt signals into the testbench.
//   assign psif_interrupt_if.irq = mla_top.psif_irq;
//   assign psif_interrupt_if.irq = 0; // Interrupt set to zero due to currently not used


   initial
   begin
     alarm_ack_btn= '0;
     #10us;
     while (1) begin
       #10ns;
       if (led_8bit[7]==1) begin
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
         #10ns;
         alarm_ack_btn= '1;
         #10ns;
         alarm_ack_btn= '0;
        end
        #10us;
     end
   end // initial begin
   
      
   initial 
   begin

      // NOTE: "uvm_test_top" is the top-level instance name given to the test specified by run_test().
      //   See: https://verificationacademy.com/forums/uvm/what-uvmtop.-and-which-file-it-defined
        
      uvm_config_db #( virtual reset_agent_if )::set( null , "uvm_test_top", "TOP_RESET_IF", top_reset_if);

      uvm_config_db #( virtual oled_spi_agent_if )::set( null , "uvm_test_top", "TOP_OLED_SPI_IF", top_oled_spi_if);

      // uvm_config_db #( virtual spi_4wire_agent_if )::set( null , "uvm_test_top", "TOP_SPI_4WIRE_IF", top_spi_4wire_if);

      uvm_config_db #( virtual kb_axi4stream_agent_if )::set( null , "uvm_test_top", "TOP_KB_AXI4STREAM_IF", kb_axi4stream_if);        
      
      // Define the AXI4-Lite interfaces; For Mentor QVIP is license required
      //   NOTE: set method has null as a parameter due that we don't have a class here and just specify the UVM top level test instance uvm_test_top. 
      `ifdef SETUP_KBAXI4LITE
         uvm_config_db #( virtual kb_axi4lite_agent_if )::set( null , "uvm_test_top", "PSIF_AXI4LITE_MASTER_IF", psif_axi4lite_master_if);      
      `else
         uvm_config_db #( bfm_type )::set( null , "uvm_test_top", "PSIF_AXI4LITE_MASTER_IF", psif_axi4lite_master_if);       
      `endif

      // Number of interrupt set to 32
      //uvm_config_db #( virtual interrupt_if#(32)  )::set( null , "uvm_test_top", "IRQ_HANDLER_PSIF", psif_interrupt_if);
        
      // Run the selected test specified by +UVM_TESTNAME
      run_test();     
    end
  
endmodule // tb_top
