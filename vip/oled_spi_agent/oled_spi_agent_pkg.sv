
//----------------------------------------------------------------------
// oled_spi_agent_pkg
//----------------------------------------------------------------------
package oled_spi_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
     
  // Include the sequence_items (transactions)
  `include "oled_spi_agent_item.svh"  

  // Include the agent config object
  `include "oled_spi_agent_config.svh"

  // Include the components  
  `include "oled_spi_agent_monitor.svh"
  `include "oled_spi_agent_driver.svh"
  `include "oled_spi_agent.svh"
  
endpackage: oled_spi_agent_pkg

