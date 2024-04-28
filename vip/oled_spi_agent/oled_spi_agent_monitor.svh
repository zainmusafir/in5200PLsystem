
//----------------------------------------------------------------------
// oled_spi_agent_monitor
//----------------------------------------------------------------------
class oled_spi_agent_monitor extends uvm_monitor;

   // factory registration macro
   `uvm_component_utils(oled_spi_agent_monitor);
      
   // Configuration object
   oled_spi_agent_config   m_cfg; 
   oled_spi_agent_item     m_oled_spi_item;
   oled_spi_agent_item     t;  // Note: MUST be declared as object named "t" !!

   // external interfaces
   uvm_analysis_port  #(oled_spi_agent_item) ap;
   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "oled_spi_agent_monitor",
                 uvm_component parent = null);
      super.new(name,parent);
      ap= new("ap", this);
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

      m_oled_spi_item = oled_spi_agent_item::type_id::create("m_oled_spi_item");
      monitor_dut();
      
   endtask: run_phase
   

  task monitor_dut();
     
    // Monitor transactions from the OLED SPI interface
    forever begin
       
      @(negedge m_cfg.oled_spi_if.oled_sclk);

       // Samples 8 bits and then waits for next negative edge on oled_slk
       for (int i=7; i>=0; i--) begin         
         @(posedge m_cfg.oled_spi_if.oled_sclk);
         m_oled_spi_item.write_data[i]= m_cfg.oled_spi_if.oled_sdin;         
       end

       $cast(t, m_oled_spi_item.clone());           
       `uvm_info(get_type_name(),$psprintf("OLED SPI monitor write value: 0x%0h", t.write_data), UVM_MEDIUM);

       ap.write(t);
           
    end
  endtask: monitor_dut

   
   
endclass: oled_spi_agent_monitor

