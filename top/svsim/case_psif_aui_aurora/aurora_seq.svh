
`include "uvm_macros.svh"

class aurora_seq extends aurora_seq_base;
   `uvm_object_utils(aurora_seq);

   int rx_data[$], rx_data_valid[$], rx_data_last[$], rx_data_keep[$];
   int tx_data_val, tx_data_valid_val, tx_data_last_val, tx_data_keep_val;

   function new( string name="aurora_seq" );
      super.new( name );
   endfunction // new
   
   task body;

        `uvm_info("AURORA_SEQ", $sformatf("Aurora sequence is started"), UVM_MEDIUM)
       
        // Monitor transactions from the Aurora high-speed interface
        forever begin
           
          m_req = kb_axi4stream_agent_item::type_id::create("m_req");
                                  
   	  // The start_item method blocks until the sequencer is ready to accept the m_req_data sequence item.
          start_item(m_req);

          m_req.tx_data       = tx_data_val;      
          m_req.tx_data_valid = tx_data_valid_val;  
          m_req.tx_data_last  = tx_data_last_val;  
          m_req.tx_data_keep  = tx_data_keep_val;

          // The finish_item method blocks until the driver (i.e. in file xxx_driver.svh)  
          //   completes, and in this case deliveres an m_req_data sequence item
   	  finish_item(m_req);           

          if (m_req.rx_data_valid == 1'b1) begin
            rx_data.push_back(m_req.rx_data);      
            rx_data_valid.push_back(m_req.rx_data_valid);  
            rx_data_last.push_back(m_req.rx_data_last);  
            rx_data_keep.push_back(m_req.rx_data_keep);
          end

          if (m_req.tx_data_ready == 1'b1) begin
            if (rx_data_valid.size() > 0) begin
              tx_data_val       = rx_data.pop_front() + 42; // Adds 42 just for loop demo  
              tx_data_valid_val = rx_data_valid.pop_front();  
              tx_data_last_val  = rx_data_last.pop_front();  
              tx_data_keep_val  = rx_data_keep.pop_front();
            end else begin
              tx_data_val       = '0;      
              tx_data_valid_val = '0;  
              tx_data_last_val  = '0;  
              tx_data_keep_val  = '0;
            end
          end  
        end
 
   endtask : body
   
endclass // aurora_seq
