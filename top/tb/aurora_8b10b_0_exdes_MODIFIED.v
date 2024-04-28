///////////////////////////////////////////////////////////////////////////////
// (c) Copyright 2008 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
`timescale 1 ns / 1 ps
(* core_generation_info = "aurora_8b10b_0,aurora_8b10b_v11_1_10,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=31250,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
module aurora_8b10b_0_exdes #
(
     parameter   USE_CORE_TRAFFIC     = 1,
     parameter   USE_CHIPSCOPE        = 1
      //pragma translate_off
        & 0
      //pragma translate_on
)
(
    // User IO
    RESET,
    HARD_ERR,
    SOFT_ERR,
    FRAME_ERR,
    ERR_COUNT,

    // CRC Status
    CRC_PASS_FAIL_N,
    CRC_VALID,   
    // Added by Roarsk
    GT_POWERGOOD,

    LANE_UP,
    CHANNEL_UP,
    INIT_CLK_P,
    INIT_CLK_N,
    GT_RESET_IN,

    // Added by Roarsk
    AURORA_USER_CLK,
    TX_TDATA,
    TX_TVALID,
    TX_TREADY,
    TX_TKEEP,
    TX_TLAST,
    RX_TDATA,
    RX_TVALID,
    RX_TKEEP,
    RX_TLAST,
 
    GT_REFCLK_P,
    GT_REFCLK_N,
    // GT I/O
    RXP,
    RXN,
    TXP,
    TXN
);


//***********************************Port Declarations*******************************
    // User I/O
input              RESET;
input              INIT_CLK_P;
input              INIT_CLK_N;
input              GT_RESET_IN;
output             HARD_ERR;
output             SOFT_ERR;
output             FRAME_ERR;
output  [0:7]      ERR_COUNT;

    // CRC Status
output             CRC_PASS_FAIL_N;
output             CRC_VALID;

// Added by Roarsk
output  [0:0]      GT_POWERGOOD;
   
// Added AXI4STREAM TX and RX interfaces by Roarsk
output             AURORA_USER_CLK;
input   [31:0]     TX_TDATA;
input              TX_TVALID;
output             TX_TREADY;
input   [3:0]      TX_TKEEP;
input              TX_TLAST;
output  [31:0]     RX_TDATA;
output             RX_TVALID;
output  [3:0]      RX_TKEEP;
output             RX_TLAST;

output             LANE_UP;
output             CHANNEL_UP;
    // Clocks
input              GT_REFCLK_P;
input              GT_REFCLK_N;


    // GT Serial I/O
input              RXP;
input              RXN;
output             TXP;
output             TXN;

//**************************External Register Declarations****************************
reg                HARD_ERR;
reg                SOFT_ERR;
reg                FRAME_ERR;
reg     [0:7]      ERR_COUNT;    
reg                LANE_UP;
reg                CHANNEL_UP;
//********************************Wire Declarations**********************************
    // LocalLink TX Interface
(* mark_debug = "true" *) wire    [0:31]     tx_d_i;
wire    [0:1]      tx_rem_i;
wire               tx_src_rdy_n_i;
wire               tx_sof_n_i;
wire               tx_eof_n_i;
wire               tx_dst_rdy_n_i;
    // LocalLink RX Interface
wire    [0:31]     rx_d_i;
wire    [0:1]      rx_rem_i;
wire               rx_src_rdy_n_i;
wire               rx_sof_n_i;
wire               rx_eof_n_i;

    // Error Detection Interface
(* mark_debug = "true" *)wire               hard_err_i;
(* mark_debug = "true" *)wire               soft_err_i;
(* mark_debug = "true" *)wire               frame_err_i;
    // Status
(* mark_debug = "true" *)wire               channel_up_i;
(* mark_debug = "true" *)reg                channel_up_r;
(* mark_debug = "true" *)wire               channel_up_r_vio;
(* mark_debug = "true" *)wire               lane_up_i;
    // System Interface
(* mark_debug = "true" *)wire               pll_not_locked_i;
(* mark_debug = "true" *)wire               pll_not_locked_ila;
wire               user_clk_i;
wire               reset_i;
wire               power_down_i;
wire    [2:0]      loopback_i;
wire               tx_lock_i;
(* mark_debug = "true" *)wire               link_reset_i;
(* mark_debug = "true" *)wire               link_reset_ila;
(* mark_debug = "true" *)wire               tx_resetdone_i;
(* mark_debug = "true" *)wire               tx_resetdone_ila;
(* mark_debug = "true" *)wire               rx_resetdone_i;
(* KEEP = "TRUE" *) wire               init_clk_i;
wire    [9:0]     daddr_in_i;
wire              dclk_in_i;
wire              den_in_i;
wire    [15:0]    di_in_i;
wire              drdy_out_unused_i;
wire    [15:0]    drpdo_out_unused_i;
wire              dwe_in_i;


(* mark_debug = "true" *)wire               gt_reset_i; 
(* mark_debug = "true" *)wire               system_reset_i;
(* mark_debug = "true" *)wire               sysreset_vio_i;
(* mark_debug = "true" *)wire               sysreset_i;
(* mark_debug = "true" *)wire               gtreset_vio_i;
wire               gtreset_vio_o;
(* mark_debug = "true" *)wire    [2:0]      loopback_vio_i;
wire    [2:0]      loopback_vio_o;
    //Frame check signals
(* mark_debug = "true" *)  wire    [0:7]      err_count_i;


    wire [35:0] icon_to_vio_i;
wire [63:0] sync_in_i;
    wire [15:0] sync_out_i;

(* mark_debug = "true" *)    wire        lane_up_i_i;
(* mark_debug = "true" *)    reg         lane_up_i_i_r;
(* mark_debug = "true" *)    wire        lane_up_i_i_vio;
(* mark_debug = "true" *)    wire        tx_lock_i_i;
(* mark_debug = "true" *)    wire        tx_lock_i_ila;
(* mark_debug = "true" *)    wire        tx_lock_i_i_vio;
    wire        lane_up_reduce_i;
    wire        rst_cc_module_i;

wire               tied_to_ground_i;
wire    [0:31]     tied_to_gnd_vec_i;
    // TX AXI PDU I/F wires
wire    [31:0]     tx_data_i;
wire               tx_tvalid_i;
wire               tx_tready_i;
wire    [3:0]      tx_tkeep_i;
wire               tx_tlast_i;
      
// Roarsk: Added "loop" signals  
wire    [36:0]     rx_data_i_loop;
wire    [36:0]     tx_data_i_loop;
wire               tx_tready_i_loop;
wire               tx_tvalid_i_loop;
wire    [8:0]      rx2tx_loop_fifo_cnt;
wire               rx2tx_loop_fifo_rd;
reg                rx2tx_loop_fifo_rd_i;
reg                tx_tvalid_i_loop_i;
   
                   
    // RX AXI PDU I/F wires
wire    [31:0]     rx_data_i;
wire               rx_tvalid_i;
wire    [3:0]      rx_tkeep_i;
wire               rx_tlast_i;

/* -----\/----- EXCLUDED -----\/-----
// Roarsk: Added "loop" signals  
wire    [31:0]     rx_data_i_loop;
wire               rx_tvalid_i_loop;
wire    [3:0]      rx_tkeep_i_loop;
wire               rx_tlast_i_loop;
 -----/\----- EXCLUDED -----/\----- */
   
    wire               INIT_CLK_IN;
   wire  drpclk_i;
   //SLACK Registers
   reg               lane_up_r;
   reg               lane_up_r2;
//*********************************Main Body of Code**********************************

  IBUFDS init_clk_ibufg_i
  (
   .I(INIT_CLK_P),
   .IB(INIT_CLK_N),
   .O(INIT_CLK_IN)
  );

  BUFG init_clk_bufg
   (.O   (init_clk_i),
    .I   (INIT_CLK_IN));
 



  //SLACK registers
  always @ (posedge user_clk_i)
  begin
    lane_up_r    <=  lane_up_i;
    lane_up_r2   <=  lane_up_r;
  end

  assign lane_up_reduce_i  = &lane_up_r2;
  assign rst_cc_module_i   = !lane_up_reduce_i;


//____________________________Register User I/O___________________________________
// Register User Outputs from core.

    always @(posedge user_clk_i)
    begin
        HARD_ERR      <=  hard_err_i;
        SOFT_ERR      <=  soft_err_i;
        FRAME_ERR     <=  frame_err_i;
        ERR_COUNT       <=  err_count_i;
        LANE_UP         <=  lane_up_i;
        CHANNEL_UP      <=  channel_up_i;
    end

//____________________________Tie off unused signals_______________________________

    // System Interface
    assign          tied_to_ground_i        = 1'b0;
    assign  tied_to_gnd_vec_i   =   32'd0;
    assign  power_down_i        =   1'b0;

    always @(posedge user_clk_i)
        channel_up_r      <=  channel_up_i;

assign  daddr_in_i  =  10'h0;
assign  den_in_i    =  1'b0;
assign  di_in_i     =  16'h0;
assign  dwe_in_i    =  1'b0;
//___________________________Module Instantiations_________________________________

    aurora_8b10b_0
    aurora_module_i
    (
        // AXI TX Interface
/* -----\/----- EXCLUDED -----\/-----
        // Roarsk: Changed to "loop" signals
        .s_axi_tx_tdata(tx_data_i_loop[31:0]),
        .s_axi_tx_tkeep(tx_data_i_loop[35:32]),
        .s_axi_tx_tvalid(tx_tvalid_i_loop),
        .s_axi_tx_tlast(tx_data_i_loop[36]),
        .s_axi_tx_tready(tx_tready_i_loop),
 -----/\----- EXCLUDED -----/\----- */
        // Roarsk: Changed to module TX i/o signals
        .s_axi_tx_tdata(TX_TDATA),
        .s_axi_tx_tkeep(TX_TKEEP),
        .s_axi_tx_tvalid(TX_TVALID),
        .s_axi_tx_tlast(TX_TLAST),
        .s_axi_tx_tready(TX_TREADY),

/* -----\/----- EXCLUDED -----\/-----
        .s_axi_tx_tdata(tx_data_i),
        .s_axi_tx_tkeep(tx_tkeep_i),
        .s_axi_tx_tvalid(tx_tvalid_i),
        .s_axi_tx_tlast(tx_tlast_i),
        .s_axi_tx_tready(tx_tready_i),
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----
        // AXI RX Interface
        .m_axi_rx_tdata(rx_data_i),
        .m_axi_rx_tkeep(rx_tkeep_i),
        .m_axi_rx_tvalid(rx_tvalid_i),
        .m_axi_rx_tlast(rx_tlast_i),
 -----/\----- EXCLUDED -----/\----- */
        // Roarsk: Changed to module RX i/o signals
        .m_axi_rx_tdata(RX_TDATA),
        .m_axi_rx_tkeep(RX_TKEEP),
        .m_axi_rx_tvalid(RX_TVALID),
        .m_axi_rx_tlast(RX_TLAST),
     
        // V5 Serial I/O
        .rxp(RXP),
        .rxn(RXN),
        .txp(TXP),
        .txn(TXN),
        // GT Reference Clock Interface
 
        .gt_refclk1_p(GT_REFCLK_P),
        .gt_refclk1_n(GT_REFCLK_N),
        // Error Detection Interface
        .hard_err(hard_err_i),
        .soft_err(soft_err_i),
        .frame_err(frame_err_i),

	//CRC Status
	.crc_pass_fail_n(CRC_PASS_FAIL_N),
        .crc_valid(CRC_VALID),

        // Status
        .channel_up(channel_up_i),
        .lane_up(lane_up_i),
        // System Interface
        .user_clk_out(user_clk_i),
        .reset(reset_i),
        .sys_reset_out(system_reset_i),
        .power_down(power_down_i),
        .loopback(loopback_vio_o),
        .gt_reset(gtreset_vio_o),
        .tx_lock(tx_lock_i),
        .pll_not_locked_out(pll_not_locked_i),
	.tx_resetdone_out(tx_resetdone_i),
	.rx_resetdone_out(rx_resetdone_i),
        .init_clk_in(init_clk_i),
.gt0_drpaddr  (daddr_in_i),
.gt0_drpen    (den_in_i),
.gt0_drpdi     (di_in_i),
.gt0_drprdy  (drdy_out_unused_i),
.gt0_drpdo (drpdo_out_unused_i),
.gt0_drpwe    (dwe_in_i),
.gt_reset_out    ( ),
.sync_clk_out    ( ),
.gt_refclk1_out  ( ),

        // Added by Roarsk
        .gt_powergood(GT_POWERGOOD),

        .link_reset_out(link_reset_i)
    );

// Roarsk: Generated user_clk set to output signal
   assign AURORA_USER_CLK = user_clk_i;


// Roarsk: Looping data
//   assign rx_data_i_loop[36:0] = {rx_tlast_i, rx_tkeep_i,rx_data_i};
   assign rx_data_i_loop[36:32] = {rx_tlast_i, rx_tkeep_i};
   assign rx_data_i_loop[31:4] = rx_data_i[31:4];
   // Introducing burst write length error condition for packet length 10 changed to 9; i.e. one byte too short.
   assign rx_data_i_loop[3:0] = (rx_data_i[31:28]=='h3 && rx_data_i[3:0]=='hB) ? 'hA : rx_data_i[7:0];

   always 
   begin
     rx2tx_loop_fifo_rd_i = 1'b0;
     tx_tvalid_i_loop_i = 1'b0;     
     while (rx2tx_loop_fifo_cnt==0) @(posedge user_clk_i);
     rx2tx_loop_fifo_rd_i = 1'b1;
     @(posedge user_clk_i);
     rx2tx_loop_fifo_rd_i = 1'b0;
     tx_tvalid_i_loop_i = 1'b1;
     @(posedge user_clk_i);
     while (tx_tready_i_loop==0) @(posedge user_clk_i);
   end

   assign rx2tx_loop_fifo_rd = rx2tx_loop_fifo_rd_i;
   assign tx_tvalid_i_loop = tx_tvalid_i_loop_i;
   

/* -----\/----- EXCLUDED -----\/-----
fifo_512x37bit_fwft rx2tx_loop_fifo (
  .rst(system_reset_i),      // input wire rst
  .wr_clk(user_clk_i),       // input wire wr_clk
  .rd_clk(user_clk_i),       // input wire rd_clk
  .din(rx_data_i_loop),      // input wire [36 : 0] din
  .wr_en(rx_tvalid_i),       // input wire wr_en
  .rd_en(rx2tx_loop_fifo_rd),  // input wire rd_en
  .dout(tx_data_i_loop),     // output wire [36 : 0] dout
  .full(),                   // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(rx2tx_loop_fifo_cnt),  // output wire [8 : 0] rd_data_count
  .wr_rst_busy(),
  .rd_rst_busy()
);
 -----/\----- EXCLUDED -----/\----- */

   

generate
 if (USE_CORE_TRAFFIC==1)
 begin : traffic

    //_____________________________ TX AXI SHIM _______________________________

    aurora_8b10b_0_LL_TO_AXI_EXDES #
    (
       .DATA_WIDTH(32),
       .USE_4_NFC (0),
       .STRB_WIDTH(4),
       .REM_WIDTH (2)
    )

    frame_gen_ll_to_axi_pdu_i
    (
     // LocalLink input Interface
     .LL_IP_DATA(tx_d_i),
     .LL_IP_SOF_N(tx_sof_n_i),
     .LL_IP_EOF_N(tx_eof_n_i),
     .LL_IP_REM(tx_rem_i),
     .LL_IP_SRC_RDY_N(tx_src_rdy_n_i),
     .LL_OP_DST_RDY_N(tx_dst_rdy_n_i),

     // AXI4-S output signals
     .AXI4_S_OP_TVALID(tx_tvalid_i),
     .AXI4_S_OP_TDATA(tx_data_i),
     .AXI4_S_OP_TKEEP(tx_tkeep_i),
     .AXI4_S_OP_TLAST(tx_tlast_i),
     .AXI4_S_IP_TREADY(tx_tready_i)
    );

    // Roarsk: Setting input values to zero 
/* -----\/----- EXCLUDED -----\/-----
    assign tx_d_i= '0;
    assign tx_sof_n_i= '0;
    assign tx_eof_n_i= '0;
    assign tx_rem_i= '0;
    assign tx_src_rdy_n_i= '0;
 -----/\----- EXCLUDED -----/\----- */
    
    
    //Connect a frame generator to the TX User interface
    aurora_8b10b_0_FRAME_GEN frame_gen_i
    (
        // User Interface
        .TX_D(tx_d_i), 
        .TX_REM(tx_rem_i),    
        .TX_SOF_N(tx_sof_n_i),      
        .TX_EOF_N(tx_eof_n_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),


        // System Interface
        .USER_CLK(user_clk_i),      
        .RESET(system_reset_i),
        .CHANNEL_UP(channel_up_r)
    );
    //_____________________________ RX AXI SHIM _______________________________
    aurora_8b10b_0_AXI_TO_LL_EXDES #
    (
       .DATA_WIDTH(32),
       .STRB_WIDTH(4),
       .REM_WIDTH (2)
    )
    frame_chk_axi_to_ll_pdu_i
    (
     // AXI4-S input signals
     .AXI4_S_IP_TX_TVALID(rx_tvalid_i),
     .AXI4_S_IP_TX_TREADY(),
     .AXI4_S_IP_TX_TDATA(rx_data_i),
     .AXI4_S_IP_TX_TKEEP(rx_tkeep_i),
     .AXI4_S_IP_TX_TLAST(rx_tlast_i),

     // LocalLink output Interface
     .LL_OP_DATA(rx_d_i),
     .LL_OP_SOF_N(rx_sof_n_i),
     .LL_OP_EOF_N(rx_eof_n_i) ,
     .LL_OP_REM(rx_rem_i) ,
     .LL_OP_SRC_RDY_N(rx_src_rdy_n_i),
     .LL_IP_DST_RDY_N(1'b0),

     // System Interface
     .USER_CLK(user_clk_i),      
     .RESET(system_reset_i),
     .CHANNEL_UP(channel_up_r)
     );

    aurora_8b10b_0_FRAME_CHECK frame_check_i
    (
        // User Interface
        .RX_D(rx_d_i), 
        .RX_REM(rx_rem_i),    
        .RX_SOF_N(rx_sof_n_i),      
        .RX_EOF_N(rx_eof_n_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),

        // System Interface
        .USER_CLK(user_clk_i),      
        .RESET(system_reset_i),
        .CHANNEL_UP(channel_up_r),
        .ERR_COUNT(err_count_i)
    );   
 
 end //end USE_CORE_TRAFFIC=1 block
 else
 begin: no_traffic
     //define traffic generation modules here
 end //end USE_CORE_TRAFFIC=0 block

endgenerate //End generate for USE_CORE_TRAFFIC


generate
if (USE_CHIPSCOPE==1)
begin : chipscope1


assign lane_up_i_i = &lane_up_i;
assign tx_lock_i_i = tx_lock_i;

    // Shared VIO Inputs
        assign  sync_in_i[15:0]         =  tx_d_i;
        assign  sync_in_i[31:16]        =  rx_d_i;
        assign  sync_in_i[39:32]        =  err_count_i;
        assign  sync_in_i[53:40]        =  14'd0;
        assign  sync_in_i[54]           =  link_reset_i;
        assign  sync_in_i[55]           =  rx_resetdone_i;
        assign  sync_in_i[56]           =  tx_resetdone_i;
        assign  sync_in_i[57]           =  frame_err_i;
        assign  sync_in_i[58]           =  soft_err_i;
        assign  sync_in_i[59]           =  hard_err_i;
        assign  sync_in_i[60]           =  tx_lock_i_i;
        assign  sync_in_i[61]           =  pll_not_locked_i;
        assign  sync_in_i[62]           =  channel_up_r;
        assign  sync_in_i[63]           =  lane_up_i_i;

always @ (posedge user_clk_i)
begin
  lane_up_i_i_r <= lane_up_i_i;
end

  aurora_8b10b_0_cdc_sync_exdes
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (1             ),  
       .c_reset_state   (0             ),  
       .c_single_bit    (1             ),  
       .c_vector_width  (2             ),  
       .c_mtbf_stages   (3              )
     )channel_up_vio_cdc_sync_exdes 
     (
       .prmry_aclk      (user_clk_i        ),
       .prmry_rst_n     (1'b1              ),
       .prmry_in        (channel_up_r      ),
       .prmry_vect_in   (2'd0              ),
       .scndry_aclk     (init_clk_i        ),
       .scndry_rst_n    (1'b1              ),
       .prmry_ack       (                  ),
       .scndry_out      (channel_up_r_vio  ),
       .scndry_vect_out (                  ) 
      );
      
  aurora_8b10b_0_cdc_sync_exdes
     #(
        .c_cdc_type      (1             ),   
        .c_flop_input    (1             ),  
        .c_reset_state   (0             ),  
        .c_single_bit    (1             ),  
        .c_vector_width  (2             ),  
        .c_mtbf_stages   (3              )
      )lane_up_vio_cdc_sync_exdes 
      (
        .prmry_aclk      (user_clk_i        ),
        .prmry_rst_n     (1'b1              ),
        .prmry_in        (lane_up_i_i_r     ),
        .prmry_vect_in   (2'd0              ),
        .scndry_aclk     (init_clk_i        ),
        .scndry_rst_n    (1'b1              ),
        .prmry_ack       (                  ),
        .scndry_out      (lane_up_i_i_vio   ),
        .scndry_vect_out (                  ) 
       );
   
  aurora_8b10b_0_cdc_sync_exdes
       #(
          .c_cdc_type      (1             ),   
          .c_flop_input    (1             ),  
          .c_reset_state   (0             ),  
          .c_single_bit    (1             ),  
          .c_vector_width  (2             ),  
          .c_mtbf_stages   (3              )
        )tx_lock_vio_cdc_sync_exdes
        (
          .prmry_aclk      (user_clk_i        ),
          .prmry_rst_n     (1'b1              ),
          .prmry_in        (tx_lock_i_i       ),
          .prmry_vect_in   (2'd0              ),
          .scndry_aclk     (init_clk_i        ),
          .scndry_rst_n    (1'b1              ),
          .prmry_ack       (                  ),
          .scndry_out      (tx_lock_i_i_vio   ),
          .scndry_vect_out (                  ) 
         );
            
  aurora_8b10b_0_cdc_sync_exdes
       #(
          .c_cdc_type      (1             ),   
          .c_flop_input    (1             ),  
          .c_reset_state   (0             ),  
          .c_single_bit    (1             ),  
          .c_vector_width  (2             ),  
          .c_mtbf_stages   (3              )
        )system_reset_vio_cdc_sync_exdes
        (
          .prmry_aclk      (init_clk_i        ),
          .prmry_rst_n     (1'b1              ),
          .prmry_in        (sysreset_vio_i    ),
          .prmry_vect_in   (2'd0              ),
          .scndry_aclk     (user_clk_i        ),
          .scndry_rst_n    (1'b1              ),
          .prmry_ack       (                  ),
          .scndry_out      (sysreset_i        ),
          .scndry_vect_out (                  ) 
         );

  //-----------------------------------------------------------------
  //  VIO core instance
  //-----------------------------------------------------------------
vio_8series i_vio 
(
  .clk(init_clk_i), // input CLK
  .probe_in0(channel_up_r_vio), // input [0 : 0] PROBE_IN0
  .probe_in1(lane_up_i_i_vio), // input [0 : 0] PROBE_IN1
  .probe_in2(tx_lock_i_i_vio), // input [0 : 0] PROBE_IN2
  .probe_out0(sysreset_vio_i), // output [0 : 0] PROBE_OUT0
  .probe_out1(gtreset_vio_i), // output [0 : 0] PROBE_OUT1
  .probe_out2(loopback_vio_i) // output [2 : 0] PROBE_OUT2
);

  //-----------------------------------------------------------------
  //  ILA core instance
  //-----------------------------------------------------------------
  aurora_8b10b_0_cdc_sync_exdes
     #(
        .c_cdc_type      (1             ),   
        .c_flop_input    (1             ),  
        .c_reset_state   (0             ),  
        .c_single_bit    (1             ),  
        .c_vector_width  (2             ),  
        .c_mtbf_stages  (3              )
      )tx_resetdone_ila_cdc_sync_exdes 
      (
        .prmry_aclk      (init_clk_i        ),
        .prmry_rst_n     (1'b1              ),
        .prmry_in        (tx_resetdone_i    ),
        .prmry_vect_in   (2'd0              ),
        .scndry_aclk     (user_clk_i        ),
        .scndry_rst_n    (1'b1              ),
        .prmry_ack       (                  ),
        .scndry_out      (tx_resetdone_ila  ),
        .scndry_vect_out (                  ) 
      );
  aurora_8b10b_0_cdc_sync_exdes
     #(
        .c_cdc_type      (1             ),   
        .c_flop_input    (1             ),  
        .c_reset_state   (0             ),  
        .c_single_bit    (1             ),  
        .c_vector_width  (2             ),  
        .c_mtbf_stages   (3              )
      )link_reset_ila_cdc_sync_exdes 
      (
        .prmry_aclk      (init_clk_i        ),
        .prmry_rst_n     (1'b1              ),
        .prmry_in        (link_reset_i      ),
        .prmry_vect_in   (2'd0              ),
        .scndry_aclk     (user_clk_i        ),
        .scndry_rst_n    (1'b1              ),
        .prmry_ack       (                  ),
        .scndry_out      (link_reset_ila    ),
        .scndry_vect_out (                  ) 
      );
  aurora_8b10b_0_cdc_sync_exdes
     #(
        .c_cdc_type      (1             ),   
        .c_flop_input    (1             ),  
        .c_reset_state   (0             ),  
        .c_single_bit    (1             ),  
        .c_vector_width  (2             ),  
        .c_mtbf_stages   (3              )
      )pll_not_locked_ila_cdc_sync_exdes 
      (
        .prmry_aclk      (init_clk_i        ),
        .prmry_rst_n     (1'b1              ),
        .prmry_in        (pll_not_locked_i  ),
        .prmry_vect_in   (2'd0              ),
        .scndry_aclk     (user_clk_i        ),
        .scndry_rst_n    (1'b1              ),
        .prmry_ack       (                  ),
        .scndry_out      (pll_not_locked_ila),
        .scndry_vect_out (                  ) 
      );
 
  aurora_8b10b_0_cdc_sync_exdes
     #(
        .c_cdc_type      (1             ),   
        .c_flop_input    (1             ),  
        .c_reset_state   (0             ),  
        .c_single_bit    (1             ),  
        .c_vector_width  (2             ),  
        .c_mtbf_stages   (3              )
      )tx_lock_i_ila_cdc_sync_exdes 
      (
        .prmry_aclk      (init_clk_i        ),
        .prmry_rst_n     (1'b1              ),
        .prmry_in        (tx_lock_i_i       ),
        .prmry_vect_in   (2'd0              ),
        .scndry_aclk     (user_clk_i        ),
        .scndry_rst_n    (1'b1              ),
        .prmry_ack       (                  ),
        .scndry_out      (tx_lock_i_ila     ),
        .scndry_vect_out (                  ) 
      );
      
ila_8series i_ila (
  .clk(user_clk_i), // input CLK
  .probe0({lane_up_i_i_r,channel_up_r,pll_not_locked_ila,tx_lock_i_ila,hard_err_i,soft_err_i,frame_err_i,tx_resetdone_ila,rx_resetdone_i,link_reset_ila,14'd0,err_count_i,rx_d_i[0:15],tx_d_i[0:15]}) // input [63 : 0] PROBE0
);

end //end USE_CHIPSCOPE=1 generate section
else
begin : no_chipscope1
                                                                                                                                                                      
    // Shared VIO Inputs
        assign  sync_in_i         =  64'h0;

end

 if (USE_CHIPSCOPE==1)
 begin : chipscope2
     // Shared VIO Outputs
 assign  reset_i =   RESET | sysreset_i;
 assign  gtreset_vio_o =   GT_RESET_IN | gtreset_vio_i;
 assign  loopback_vio_o =   3'b000 | loopback_vio_i;
 end //end USE_CHIPSCOPE=1 block
 else
 begin: no_chipscope2
 assign  reset_i =   RESET;
 assign  gtreset_vio_o =   GT_RESET_IN;
 assign  loopback_vio_o =   3'b000;
 end //end USE_CHIPSCOPE=0 block

endgenerate //End generate for USE_CHIPSCOPE


endmodule
 
