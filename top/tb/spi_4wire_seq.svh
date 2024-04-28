`include "uvm_macros.svh"

class spi_4wire_seq extends uvm_sequence#(spi_4wire_agent_item);
   `uvm_object_utils(spi_4wire_seq);

   spi_4wire_agent_item  m_req_address;
   spi_4wire_agent_item  m_req_data;

   logic [7:0] registers [0:6];

   function new( string name="spi_4wire_seq" );
      super.new( name );
   endfunction // new

   task body;

        `uvm_info("SPI_4WIRE_SEQ", $sformatf("SPI 4WIRE sequence is started"), UVM_MEDIUM)
        
        // Monitor transactions from the 4 wire SPI interface
        forever begin
           
          m_req_address = spi_4wire_agent_item::type_id::create("m_req_address");
          m_req_data    = spi_4wire_agent_item::type_id::create("m_req_data");
                        
   	  // The start_item method blocks until the sequencer is ready to accept the m_req_address sequence item.
          start_item(m_req_address);

          // The finish_item method blocks until the driver (i.e. in file xxx_driver.svh)  
          //   completes, and in this case deliveres an m_req_address sequence item
	  finish_item(m_req_address);

           
   	  // The start_item method blocks until the sequencer is ready to accept the m_req_data sequence item.
          start_item(m_req_data);

          if (m_req_address.rw_address[7]==0) begin
            m_req_data.read_data= registers[m_req_address.rw_address];
          end else begin
            m_req_data.read_data= 0;
          end            
           
          // The finish_item method blocks until the driver (i.e. in file xxx_driver.svh)  
          //   completes, and in this case deliveres an m_req_data sequence item
   	  finish_item(m_req_data);           
            
          // If write access write to registers    
          if (m_req_address.rw_address[7]==1) begin
            registers[m_req_address.rw_address[6:0]]= m_req_data.write_data;
          end 
 
        end
 
   endtask : body
   
endclass // spi_4wire_seq
