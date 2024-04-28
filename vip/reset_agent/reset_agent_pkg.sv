
//----------------------------------------------------------------------
// reset_agent_pkg
//----------------------------------------------------------------------
package reset_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
     
  // Include the sequence_items (transactions)
  `include "reset_agent_item.svh"  

  // Include the agent config object
  `include "reset_agent_config.svh"

  // Include the components  
  `include "reset_agent_driver.svh"
  `include "reset_agent.svh"
  
endpackage: reset_agent_pkg

