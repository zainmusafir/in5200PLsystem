`include "uvm_macros.svh"

class top_reset_seq extends uvm_sequence#(reset_agent_item);
   `uvm_object_utils(top_reset_seq);

   reset_agent_item  m_req;
   
   function new( string name="top_reset_seq" );
      super.new( name );
   endfunction

   task body;

        m_req=reset_agent_item::type_id::create("m_req");

        // Set reset to active high
        m_req.rst<= 1'b1; 
               
 	// The start_item method blocks until the sequencer is ready to accept the m_req sequence item.
        start_item(m_req);

        // The finish_item method blocks until the driver (i.e. in file reset_agent_driver.svh)  
        //   completes, and in this case deliveres an m_req sequence item.
	finish_item(m_req);

        #1us; // Reset actice in 1 us.
      
        // Set reset to inactive low
        m_req.rst<= 1'b0;
               
 	// The start_item method blocks until the sequencer is ready to accept the m_req sequence item.
        start_item(m_req);

        // The finish_item method blocks until the driver (i.e. in file reset_agent_driver.svh)  
        //   completes, and in this case deliveres an m_req sequence item.
	finish_item(m_req);
     
   endtask : body
   
endclass // top_reset_seq
