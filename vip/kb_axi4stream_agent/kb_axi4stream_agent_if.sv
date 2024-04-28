
interface kb_axi4stream_agent_if(input CLK);

  // TX Channel
  logic [31:0] TX_TDATA;
  logic        TX_TVALID;
  logic        TX_TLAST;
  logic [3:0]  TX_TKEEP;
  logic        TX_TREADY;
  
  // RX Channel 
  logic [31:0] RX_TDATA;
  logic        RX_TVALID;
  logic        RX_TLAST;
  logic [3:0]  RX_TKEEP;
  logic        RX_TREADY;
   
endinterface // kb_axi4stream_agent_if 

