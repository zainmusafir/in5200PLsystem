
`include "uvm_macros.svh"

class aurora_seq_base extends uvm_sequence#(kb_axi4stream_agent_item);
   `uvm_object_utils(aurora_seq_base);

   // Get a reference to the global singleton object by 
   // calling a static method
   static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
 
   // Either create a uvm_event or return a reference to it
   // (which depends on the order of execution of the two
   //  sequences (stim and result) - the first call creates the event,
   //  the second and subsequent calls return a reference to
   //  an existing event.)
   static uvm_event ev = ev_pool.get("ev");   
   static uvm_event ev_aurora_sync = ev_pool.get("ev_aurora_sync");      

   function new( string name="aurora_seq_base" );
      super.new( name );
   endfunction // new

   kb_axi4stream_agent_item  m_req;
   
   task body;

     // Empty in base class
 
   endtask : body
   
endclass // aurora_seq_base
