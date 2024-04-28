
//----------------------------------------------------------------------
// oled_spi_agent_driver
//----------------------------------------------------------------------
class oled_spi_agent_driver extends uvm_driver #(oled_spi_agent_item);

   // factory registration macro
   `uvm_component_utils(oled_spi_agent_driver);
      
   // Configuration object
   oled_spi_agent_config   m_cfg; 
   oled_spi_agent_item     m_req;

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "oled_spi_agent_driver",
                 uvm_component parent = null);
      super.new(name,parent);
   endfunction: new


   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     m_cfg= oled_spi_agent_config::type_id::create("m_cfg");
   endfunction : build_phase
     

   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);

      // Calls init_signals task
      init_signals();
      
      forever begin

   	seq_item_port.get_next_item(m_req);

         // Driver not used in OLED SPI interface

	seq_item_port.item_done(m_req);
      end
      
   endtask: run_phase
   

   task init_signals();
      // m_cfg.oled_spi_if.XXXX <= ????; // TBD
   endtask // init_signals

   
endclass: oled_spi_agent_driver

