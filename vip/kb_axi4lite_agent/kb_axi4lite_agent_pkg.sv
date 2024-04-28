
//----------------------------------------------------------------------
// kb_axi4lite_agent_pkg
//----------------------------------------------------------------------
package kb_axi4lite_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import typedef_pkg::*;
     
  // Include the sequence_items (transactions)
  `include "kb_axi4lite_agent_item.svh"  

  // Include the agent config object
  `include "kb_axi4lite_agent_config.svh"

  // Include the components  
  `include "kb_axi4lite_agent_driver.svh"
  `include "kb_axi4lite_agent_monitor.svh"
  `include "kb_axi4lite_agent_coverage_monitor.svh"
  `include "reg2axi4lite_adapter.svh"
  `include "kb_axi4lite_agent.svh"

  
endpackage: kb_axi4lite_agent_pkg

