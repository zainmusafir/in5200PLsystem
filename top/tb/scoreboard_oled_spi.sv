   import uvm_pkg::*;
   `include "uvm_macros.svh";

class scoreboard_oled_spi extends scoreboard_oled_spi_base;
    `uvm_component_utils(scoreboard_oled_spi);

    const time TIME_OUT= 500ms;
   
    oled_spi_agent_item  m_oled_spi_item;

    // Moved to scoreboard_oled_spi_out_base class   
//    uvm_tlm_analysis_fifo #(oled_spi_agent_item) oled_spi_monitor_out;

    // SPI input signals
    logic       initialize_spi_comp_en_val;
    logic [7:0] initialize_spi_comp_sdata_val;
    logic       example_spi_comp_en_val;
    logic [7:0] example_spi_comp_sdata_val;

    int oled_sdata;

    mailbox #(int) mbx_oled_spi_data;

    int execution_termination= 0;

    function new(string name="",uvm_component parent=null);
      super.new(name,parent);
      mbx_oled_spi_data= new();      
    endfunction // new

    // Declare test probes for internal design signals in modules
    probe_abstract #(logic [0:0])  initialize_spi_comp_en_h;     // NOTE: MUST be [0:0] !!!!!!!!!!!!!!!!!!
    probe_abstract #(logic [7:0])  initialize_spi_comp_sdata_h;     
    probe_abstract #(logic [0:0])  example_spi_comp_en_h;        // NOTE: MUST be [0:0] !!!!!!!!!!!!!!!!!!
    probe_abstract #(logic [7:0])  example_spi_comp_sdata_h;    
    probe_abstract #(logic [0:0])  init_done_h;                  // NOTE: MUST be [0:0] !!!!!!!!!!!!!!!!!!
    probe_abstract #(logic [0:0])  alphabet_done_str_h;          // NOTE: MUST be [0:0] !!!!!!!!!!!!!!!!!!

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);

       $cast(initialize_spi_comp_en_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize.spi_comp.initilize_spi_comp_probe_en",,"initialize_spi_comp_en_h"));  
       $cast(initialize_spi_comp_sdata_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize.spi_comp.initilize_spi_comp_probe_sdata",,"initialize_spi_comp_sdata_h"));  
       $cast(example_spi_comp_en_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example.spi_comp.example_spi_comp_probe_en",,"example_spi_comp_probe_en_h"));  
       $cast(example_spi_comp_sdata_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example.spi_comp.example_spi_comp_probe_sdata",,"example_spi_comp_probe_sdata_h"));  
       $cast(init_done_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize.initialize_probe_init_done",,"init_done_h"));  
       $cast(alphabet_done_str_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example.example_probe_alphabet_done_str",,"alphabet_done_str_h"));  
       
    endfunction : build_phase

   
    task run_phase(uvm_phase phase);

      m_oled_spi_item = oled_spi_agent_item::type_id::create("m_oled_spi_item");
       
      phase.raise_objection(this, "End test");

      fork : scoreboard_compare_with_monitor_value
        process_0: forever begin
//          #10us; // THIS STATEMENT ONLY INSERTED TO GET ARTIFICIAL TIME BETWEEN SPI DATA INPUT AND 
                 // DATA FROM MONITOR TO DEMONSTRATE PHASE_READY_TO_END FUNCTIONALITY !!!!
          oled_spi_monitor_out.get(m_oled_spi_item);
          `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI monitor write value: 0x%0h", m_oled_spi_item.write_data), UVM_MEDIUM);

           mbx_oled_spi_data.get(oled_sdata);

           if ( !(m_oled_spi_item.write_data == oled_sdata)) begin
             `uvm_error(get_type_name(),$psprintf("Scoreboard OLED SPI monitor write value: 0x%0h, but OLED design probe value was:  0x%0h." , m_oled_spi_item.write_data, oled_sdata));
           end
           if ( (m_oled_spi_item.write_data == oled_sdata)) begin
             `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI monitor write value: 0x%0h and OLED SPI design probe value was:  0x%0h." , m_oled_spi_item.write_data, oled_sdata), UVM_MEDIUM);
           end      
        end
      join_none;
      
             
      fork : scoreboard_sample_design_spi_input_data
        process_0: begin
          init_done_h.edge_probe(1);
          `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI initialization done, execution termination signal: 0x%0h", execution_termination), UVM_MEDIUM);            
          alphabet_done_str_h.edge_probe(1);
          execution_termination= 1;
          `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI example alphabeth execution done, execution termination signal: 0x%0h", execution_termination), UVM_MEDIUM);            
        end
        process_1: forever begin
          initialize_spi_comp_en_h.edge_probe(1);
          initialize_spi_comp_sdata_val= initialize_spi_comp_sdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI Initialize data write value: 0x%0h", initialize_spi_comp_sdata_val), UVM_MEDIUM);
           mbx_oled_spi_data.put(initialize_spi_comp_sdata_val);           
        end
        process_2: forever begin
          example_spi_comp_en_h.edge_probe(1);
          example_spi_comp_sdata_val= example_spi_comp_sdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Scoreboard OLED SPI Example data write value: 0x%0h", example_spi_comp_sdata_val), UVM_MEDIUM);            

           mbx_oled_spi_data.put(example_spi_comp_sdata_val);           
        end
        process_3: begin
          #TIME_OUT;          
          `uvm_error(get_type_name(),"TIMEOUT: Scoreboard simulation terminated."); 
        end         
      join_any;
      disable scoreboard_sample_design_spi_input_data; // Terminate all fork'ed processes (i.e. process_1, process_2 and process_3).
      
      phase.drop_objection(this, "End test");

    endtask : run_phase


    // Just test the functionality of phase_ready_to_end method which is executed automatically by UVM once
    //   'all dropped' condition is achieved during run phase. 
    // Shall be used in Scoreboards to ensure that all tests have been completed !!!!!!!!!!!!!!!!!!!
    virtual function void phase_ready_to_end (uvm_phase phase);

       if (phase.get_name != "run")
         return;

       if (execution_termination == 1) begin
         phase.raise_objection(this, "NOT yet ready to end test");
         `uvm_info(get_type_name(),$psprintf("DUT execution complete with 0x%0h left in mailbox.", mbx_oled_spi_data.num()), UVM_MEDIUM);            
         fork begin
           `uvm_info("Scoreboard", "Testing ready_to_end phase: begin ..... ", UVM_LOW);
           wait_for_ok_to_finish();
           `uvm_info("Scoreboard", "Testing ready_to_end phase: end! ", UVM_LOW);
           phase.drop_objection(this, "NOT yet ready to end test");
         end;
         join_none;
       end
       
    endfunction: phase_ready_to_end;

    task wait_for_ok_to_finish();
       // Ensure that all tests have been completed!
       wait (mbx_oled_spi_data.num() == 0 );
       execution_termination= 0;
    endtask: wait_for_ok_to_finish;
    
     
endclass : scoreboard_oled_spi
