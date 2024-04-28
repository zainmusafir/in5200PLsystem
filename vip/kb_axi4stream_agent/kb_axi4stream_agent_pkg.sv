
package kb_axi4stream_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import kb_axi4stream_typedef_pkg::*;
     
  // Include the sequence_items (transactions)
  `include "kb_axi4stream_agent_item.svh"  

  // Include the agent config object
  `include "kb_axi4stream_agent_config.svh"

  // Include the components  
  `include "kb_axi4stream_agent_driver.svh"
  `include "kb_axi4stream_agent_monitor.svh"
  `include "kb_axi4stream_agent.svh"

endpackage: kb_axi4stream_agent_pkg

