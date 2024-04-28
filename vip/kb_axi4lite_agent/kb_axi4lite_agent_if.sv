
import typedef_pkg::*;

interface kb_axi4lite_agent_if(input ACLK, ARESETn);

   // Write Address Channel
   logic [31:0]  AWADDR    ;
   logic [2:0]   AWPROT    ;
   logic   AWVALID   ;
   logic   AWREADY   ;
   
   // Write Data Channel
   logic [31:0]  WDATA     ;
   logic [3:0]   WSTRB     ;
   logic   WVALID    ;
   logic   WREADY    ;
   
   // Write Respons Channel
   logic [1:0]   BRESP     ;
   logic   BVALID    ;
   logic   BREADY    ;
   
   // Read Address Channel
   logic [31:0] ARADDR    ;
   logic [2:0]  ARPROT    ;
   logic  ARVALID   ;
   logic  ARREADY   ;
   
   // Read Data Channel
   logic [31:0] RDATA     ;
   logic [1:0]  RRESP     ;
   logic  RVALID    ;
   logic  RREADY    ;

   // Transaction size (NOT for DUT; for Monitor only!)
   axi4lite_transaction_size_t m_transaction_size;  
   
endinterface // axi4lite_if

