   import uvm_pkg::*;
   `include "uvm_macros.svh";

  class coverage_dti_spi extends coverage_dti_spi_base;
    `uvm_component_utils(coverage_dti_spi);     

    const time TIME_OUT= 50ms;

    // Get a reference to the global singleton object by 
    // calling a static method
    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
 
    // Either create a uvm_event or return a reference to it
    // (which depends on the order of execution of the two
    //  sequences (stim and result) - the first call creates the event,
    //  the second and subsequent calls return a reference to
    //  an existing event.)
    static uvm_event ev = ev_pool.get("ev");

    spi_4wire_agent_item  m_spi_4wire_agent_item;

    mailbox #(spi_4wire_agent_item) dti_spi_monitor_out;
    
    // DTI SPI input signals
    logic [7:0] dti_spi_wr_instr_val;
    logic [7:0] dti_spi_rd_instr_val;
    logic [7:0] dti_spi_wdata_val;
    logic       dti_spi_wr_str_val;
    logic       dti_spi_rd_str_val;
                
    // DTI SPI output data
    logic [7:0] dti_spi_rdata_val;  

    // DTI SPI coverage signals
    logic [7:0] dti_spi_instr;
    logic [7:0] dti_spi_wdata;
    logic       dti_spi_wr_str;
    logic       dti_spi_rd_str;
                
    // DTI SPI coverage signals
    logic [7:0] dti_spi_rdata;  
     
    
    // Covergroup for DTI SPI instr data functional coverage
    covergroup dti_spi_cg;
      dti_spi_wr_instr_cp: coverpoint dti_spi_wr_instr_val {
        bins instr80 = {8'h80};
        bins instr81 = {8'h81}; // NOTE: NOT WR on target MAX31722
        bins instr82 = {8'h82}; // NOTE: NOT WR on target MAX31722
        bins instr83 = {8'h83};
        bins instr84 = {8'h84};
        bins instr85 = {8'h85};
        bins instr86 = {8'h86};
        bins misc = default;
      }
      dti_spi_rd_instr_cp: coverpoint dti_spi_rd_instr_val {
        bins instr00 = {8'h00};
        bins instr01 = {8'h01};
        bins instr02 = {8'h02};
        bins instr03 = {8'h03};
        bins instr04 = {8'h04};
        bins instr05 = {8'h05};
        bins instr06 = {8'h06};
        bins misc = default;
      }
      dti_spi_wdata_cp: coverpoint dti_spi_wdata_val {
        option.auto_bin_max= 4;                                                
      }
      dti_spi_rdata_cp: coverpoint dti_spi_rdata_val {
        option.auto_bin_max= 4;                                                
      }
      dti_spi_rd_str_cp:    coverpoint dti_spi_rd_str_val {
         bins one = {1'b1};
         bins misc = default;
      }
      dti_spi_wr_str_cp:    coverpoint dti_spi_wr_str_val {
         bins one = {1'b1};
         bins misc = default;
      }       
    endgroup   

        
    function new(string name="", uvm_component parent=null);
      super.new(name, parent);
      dti_spi_monitor_out= new(); 
      dti_spi_cg= new();
    endfunction // new

    
    // Declare test probes for internal design signals in modules
    probe_abstract #(logic [0:0]) dti_spi_mclk_h;    // NOTE: MUST be [0:0] !!
    probe_abstract #(logic [7:0]) dti_spi_instr_h;   
    probe_abstract #(logic [7:0]) dti_spi_wdata_h; 
    probe_abstract #(logic [0:0]) dti_spi_wr_str_h;  // NOTE: MUST be [0:0] !!
    probe_abstract #(logic [0:0]) dti_spi_rd_str_h;  // NOTE: MUST be [0:0] !! 
    probe_abstract #(logic [0:0]) dti_spi_busy_h;    // NOTE: MUST be [0:0] !! 
    probe_abstract #(logic [7:0]) dti_spi_rdata_h; 
 
    function void build_phase(uvm_phase phase); 
       super.build_phase(phase);    
       $cast(dti_spi_mclk_h,   factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_mclk",,"dti_spi_probe_mclk_h"));  
       $cast(dti_spi_instr_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_instr",,"dti_spi_probe_instr_h"));  
       $cast(dti_spi_wdata_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_wdata",,"dti_spi_probe_wdata_h"));  
       $cast(dti_spi_wr_str_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_wr_str",,"dti_spi_probe_wr_str_h"));  
       $cast(dti_spi_rd_str_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_rd_str",,"dti_spi_probe_rd_str_h"));  
       $cast(dti_spi_busy_h,   factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_busy",,"dti_spi_probe_busy_h"));  
       $cast(dti_spi_rdata_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_rdata",,"dti_spi_probe_rdata_h"));  
    endfunction : build_phase


    // The coverage class is here declared as a uvm_subscriber class and that class comes with (i.e. built-in)
    //   an analysis_export port.
    // NOTE that we have to use the try_put() methods/task instead of the try() method due to that it is not allowed to have time
    //   consuming methods in functions (i.e. only in tasks!) like the blocking put() method, but we know due to unlimited size of the mailbox that
    //   try_put() will always succeed and this write() method does then not consume time. 
    // In other cases may try_get() also be used instead og get() because get is blocking.
    function void write(spi_4wire_agent_item t);

        dti_spi_monitor_out.try_put(t);

    endfunction : write

    
    // TBD
    task run_phase(uvm_phase phase);

      m_spi_4wire_agent_item = spi_4wire_agent_item::type_id::create("m_spi_4wire_agent_item");
       
      phase.raise_objection(this, "End coverage");

      // This process is just for monitor data observation in the coverage module; 
      //   nothing to do with functional coverage!
      fork : coverage_get_monitor_value
        process_1: forever begin
          dti_spi_monitor_out.get(m_spi_4wire_agent_item);
          m_spi_4wire_agent_item.displayAllData();
        end
      join_none;
      
             
      fork : coverage_sample_design_spi_input_data
        process_1: forever begin
          dti_spi_wr_str_h.edge_probe(1);
          dti_spi_mclk_h.edge_probe(0);
          dti_spi_wr_str_val= dti_spi_wr_str_h.get_probe();
          dti_spi_wr_instr_val = dti_spi_instr_h.get_probe();
          dti_spi_rd_str_val= 0;
          dti_spi_rd_instr_val= 99; // Invalid instruction value
          dti_spi_wdata_val = dti_spi_wdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI wr_str value: 0x%0h", dti_spi_wr_str_val), UVM_MEDIUM);
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI wr instruction value: 0x%0h", dti_spi_wr_instr_val), UVM_MEDIUM);
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI data write value: 0x%0h", dti_spi_wdata_val), UVM_MEDIUM);
          dti_spi_wr_str_h.edge_probe(0);
          // Write access terminated when busy toggles from '1' to '0'.
          dti_spi_busy_h.edge_probe(0);
          dti_spi_cg.sample();           
        end
        process_2: forever begin
          dti_spi_rd_str_h.edge_probe(1);
          dti_spi_mclk_h.edge_probe(0);
          dti_spi_rd_str_val= dti_spi_rd_str_h.get_probe();
          dti_spi_rd_instr_val = dti_spi_instr_h.get_probe();
          dti_spi_wr_str_val= 0;
          dti_spi_wr_instr_val = 99; // Invalid instruction value
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI rd_str value: 0x%0h", dti_spi_rd_str_val), UVM_MEDIUM);
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI rd instruction value: 0x%0h", dti_spi_rd_instr_val), UVM_MEDIUM);
          dti_spi_rd_str_h.edge_probe(0);
          // Read access terminated and read data ready when busy toggles from '1' to '0'.
          dti_spi_busy_h.edge_probe(0);
          dti_spi_mclk_h.edge_probe(0);
          dti_spi_rdata_val= dti_spi_rdata_h.get_probe();
          `uvm_info(get_type_name(),$psprintf("Coverage DTI SPI data read value: 0x%0h", dti_spi_rdata_val), UVM_MEDIUM);
          dti_spi_cg.sample();           
        end
        process_3: begin
          while (dti_spi_cg.get_coverage() != 100) #1us;
          `uvm_info(get_type_name(), "All coverage requirements complete.", UVM_MEDIUM);           // Trigger the event
          ev.trigger();
          `uvm_info(get_type_name(), $psprintf("%t: Event ev triggered due to coverage requirements complete", $time), UVM_MEDIUM);
        end
        process_4: begin
          #TIME_OUT;          
          `uvm_error(get_type_name(),"TIMEOUT: Coverage simulation terminated."); 
        end         
      join_any;
      disable coverage_sample_design_spi_input_data; // Terminate all fork'ed processes (i.e. process_1, process_2, process_3 and process_4).
      
      phase.drop_objection(this, "End coverage");

    endtask : run_phase
   
  endclass : coverage_dti_spi
