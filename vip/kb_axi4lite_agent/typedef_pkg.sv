//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : axi4lite_kb
// Unit            : kb_axi4lite_agent_agent_pkg
// File            : kb_axi4lite_agent_agent_pkg.svh
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 2015/06/23
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// kb_axi4lite_agent_pkg
//----------------------------------------------------------------------
package typedef_pkg;

   typedef enum {BYTE, HALFWORD, SINGLE, DOUBLE} axi4lite_transaction_size_t;
   typedef enum {AXI4LITE_OK,AXI4LITE_TIMEOUT} axi4lite_status_t;
   typedef enum {AXI4LITE_READ,AXI4LITE_WRITE} axi4lite_read_or_write_t;
    
endpackage: typedef_pkg

