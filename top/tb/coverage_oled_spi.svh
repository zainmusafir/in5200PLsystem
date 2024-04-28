   import uvm_pkg::*;
   `include "uvm_macros.svh";

// class coverage_oled_spi extends uvm_subscriber #(oled_spi_agent_item);
  class coverage_oled_spi extends coverage_oled_spi_base;
    `uvm_component_utils(coverage_oled_spi);

    const time TIME_OUT= 50ms;

    oled_spi_agent_item  m_oled_spi_item;

    mailbox #(oled_spi_agent_item) oled_spi_monitor_out;

    mailbox #(int) mbx_oled_spi_data;

    int execution_termination= 0;

    
    // SPI input signals
    logic       initialize_spi_comp_en_val;
    logic [7:0] initialize_spi_comp_sdata_val;
    logic       example_spi_comp_en_val;
    logic [7:0] example_spi_comp_sdata_val;

    // OLED SPI output data
    logic [7:0] oled_sdata;

    
    // Covergroup for OLED SPI output data functional coverage
    covergroup oled_sdata_cg;
      oled_sdata_cp: coverpoint oled_sdata {
         bins bit0 = {2**0};
         bins bit1 = {2**1};
         bins bit2 = {2**2};
         bins bit3 = {2**3};
         bins bit4 = {2**4};
         bins bit5 = {2**5};
         bins bit6 = {2**6};
//         bins bit7 = {2**7};
         bins misc = default;
      }
    endgroup // oled_sdata_cg
     
  
    // Covergroup for Initialize SPI input data functional coverage
    covergroup initialize_oled_spi_cg;
      initialize_spi_comp_en_cp:    coverpoint initialize_spi_comp_en_val {
         bins one = {1'b1};
         bins misc = default;
      }
    endgroup // initialize_oled_spi_cg
    
    // Covergroup for Example SPI input data functional coverage
    covergroup example_oled_spi_cg;
      example_spi_comp_en_cp:    coverpoint example_spi_comp_en_val {
         bins one = {1'b1};
         bins misc = default;
      }
    endgroup // example_oled_spi_cg
    
    
    function new(string name="", uvm_component parent=null);
      super.new(name, parent);
      oled_spi_monitor_out= new(); 
      mbx_oled_spi_data= new();      
      oled_sdata_cg= new();       
      initialize_oled_spi_cg= new();
      example_oled_spi_cg= new();
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


    // The coverage class is here declared as a uvm_subscriber class and that class comes with (i.e. built-in)
    //   an analysis_export port.
    // The scoreboard class is a uvm_scoreboard class that the scoreboard_base use, and this class
    //   does NOT come with a analysis_export port. Therefore we us a uvm_tlm_analysis_fifo that comes with
    //   "all" we need including analysis_export port and write() function. 
    // This MAY be a better/simpler solution, but it is not used here to show how to use the internal analysis_export and 
    //   write our own write() function. We use a mailbox instead of the uvm_tlm_analysis_fifo as the oled_spi_monitor_out 
    //   "FIFO" compared to the scoreboard class.
    // NOTE that we have to use the try_put() methods/task instead of the try() method due to that it is not allowed to have time
    //   consuming methods in functions like the blocking put() method, but we know due to unlimited size of the mailbox that
    //   try_put() will always succeed and this method does then not consume time. 
    // In other cases may try_get() also be used instead og get() because get is blocking.
    function void write(oled_spi_agent_item t);

        oled_spi_monitor_out.try_put(t);

    endfunction : write

    
    // TBD
    task run_phase(uvm_phase phase);

      m_oled_spi_item = oled_spi_agent_item::type_id::create("m_oled_spi_item");
       
      phase.raise_objection(this, "End coverage");

      fork : coverage_get_monitor_value
        process_0: forever begin
          #10us; // THIS STATEMENT ONLY INSERTED TO GET ARTIFICIAL TIME BETWEEN SPI DATA INPUT AND 
                 // DATA FROM MONITOR TO DEMONSTRATE PHASE_READY_TO_END FUNCTIONALITY !!!!
          oled_spi_monitor_out.get(m_oled_spi_item);
          `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI monitor write value: 0x%0h", m_oled_spi_item.write_data), UVM_MEDIUM);

          mbx_oled_spi_data.get(oled_sdata);

          if ( !(m_oled_spi_item.write_data == oled_sdata)) begin
            `uvm_error(get_type_name(),$psprintf("Coverage OLED SPI monitor write value: 0x%0h, but OLED design probe value was:  0x%0h." , m_oled_spi_item.write_data, oled_sdata));
          end
          if ( (m_oled_spi_item.write_data == oled_sdata)) begin
            `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI monitor write value: 0x%0h and OLED SPI design probe value was:  0x%0h." , m_oled_spi_item.write_data, oled_sdata), UVM_MEDIUM);
          end  
          oled_sdata_cg.sample();   
        end
      join_none;
      
             
      fork : coverage_sample_design_spi_input_data
        process_0: begin
          init_done_h.edge_probe(1);
          `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI initialization done, execution termination signal: 0x%0h", execution_termination), UVM_MEDIUM);            
          alphabet_done_str_h.edge_probe(1);
          execution_termination= 1;
          `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI example alphabeth execution done, execution termination signal: 0x%0h", execution_termination), UVM_MEDIUM);            
        end
        process_1: forever begin
          initialize_spi_comp_en_h.edge_probe(1);
          initialize_spi_comp_en_val= initialize_spi_comp_en_h.get_probe();
          initialize_spi_comp_sdata_val= initialize_spi_comp_sdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI Initialize data write value: 0x%0h", initialize_spi_comp_sdata_val), UVM_MEDIUM);
          mbx_oled_spi_data.put(initialize_spi_comp_sdata_val);
          initialize_oled_spi_cg.sample();           
        end
        process_2: forever begin
          example_spi_comp_en_h.edge_probe(1);
          example_spi_comp_en_val= example_spi_comp_en_h.get_probe();
          example_spi_comp_sdata_val= example_spi_comp_sdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Coverage OLED SPI Example data write value: 0x%0h", example_spi_comp_sdata_val), UVM_MEDIUM);
          mbx_oled_spi_data.put(example_spi_comp_sdata_val);
          example_oled_spi_cg.sample();           
        end
        process_3: begin
          while (oled_sdata_cg.get_coverage() != 100) #1us;
          `uvm_info(get_type_name(), "All coverage requirements complete.", UVM_MEDIUM);           // Trigger the event
//          ev.trigger();
//          `uvm_info(get_type_name(), $psprintf("%t: Event ev triggered due to coverage requirements complete", $time), UVM_MEDIUM);
        end
        process_4: begin
          #TIME_OUT;          
          `uvm_error(get_type_name(),"TIMEOUT: Coverage simulation terminated."); 
        end         
      join_any;
      disable coverage_sample_design_spi_input_data; // Terminate all fork'ed processes (i.e. process_1, process_2 and process_3).
      
      phase.drop_objection(this, "End coverage");

    endtask : run_phase


    // Just test the functionality of phase_ready_to_end method which is executed automatically by UVM once
    //   'all dropped' condition is achieved during run phase. 
    // Shall be used in Coverages to ensure that all tests have been completed !!!!!!!!!!!!!!!!!!!
    virtual function void phase_ready_to_end (uvm_phase phase);

       if (phase.get_name != "run")
         return;

       if (execution_termination == 1) begin
         phase.raise_objection(this, "NOT yet ready to end test");
         `uvm_info(get_type_name(),$psprintf("DUT execution complete with 0x%0h left in mailbox.", mbx_oled_spi_data.num()), UVM_MEDIUM);            
         fork begin
           `uvm_info("Coverage", "Testing ready_to_end phase: begin ..... ", UVM_LOW);
           wait_for_ok_to_finish();
           `uvm_info("Coverage", "Testing ready_to_end phase: end! ", UVM_LOW);
           phase.drop_objection(this, "NOT yet ready to end test");
         end;
         join_none;
       end
       
    endfunction: phase_ready_to_end;
     

    task wait_for_ok_to_finish();
       // SHALL be logic here to ensure that all coverage data have been completed!
       wait (mbx_oled_spi_data.num() == 0 );
       execution_termination= 0;
    endtask: wait_for_ok_to_finish;
   
  endclass : coverage_oled_spi
