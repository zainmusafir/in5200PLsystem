   import uvm_pkg::*;
   `include "uvm_macros.svh";

class scoreboard_dti_spi extends scoreboard_dti_spi_base;
    `uvm_component_utils(scoreboard_dti_spi);

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
   
    spi_4wire_agent_item  m_dti_spi_item;

    // Moved to scoreboard_dti_spi_out_base class   
//    uvm_tlm_analysis_fifo #(spi_4wire_agent_item) dti_spi_monitor_out;

    // DTI SPI input signals
    logic [7:0] dti_spi_instr_val;
    logic [7:0] dti_spi_wdata_val;
    logic       dti_spi_wr_str_val;
    logic       dti_spi_rd_str_val;
                
    // DTI SPI output data
    logic [7:0] dti_spi_rdata_val;

    logic [7:0] dti_spi_rdata_compare_val;

    logic [7:0] registers [0:6];

    mailbox #(int) mbx_dti_spi_data;

    int execution_termination= 0;

    function new(string name="",uvm_component parent=null);
      super.new(name,parent);
      mbx_dti_spi_data= new();      
    endfunction // new

    
    // Declare test probes for internal design signals in modules
    probe_abstract #(logic [0:0]) dti_spi_busy_h;    // NOTE: MUST be [0:0] !!!!!!!!!!!!!!!!!! 
    probe_abstract #(logic [7:0]) dti_spi_rdata_h; 


    function void build_phase(uvm_phase phase);
       super.build_phase(phase);

       $cast(dti_spi_busy_h,   factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_busy",,"dti_spi_probe_busy_h"));  
       $cast(dti_spi_rdata_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_spi_0.dti_spi_probe_rdata",,"dti_spi_probe_rdata_h"));  

    endfunction : build_phase

   
    task run_phase(uvm_phase phase);

      m_dti_spi_item = spi_4wire_agent_item::type_id::create("m_dti_spi_item");
       
      phase.raise_objection(this, "End test");

      fork : scoreboard_compare_with_monitor_value
        process_0: forever begin
//          #10us; // THIS STATEMENT ONLY INSERTED TO GET ARTIFICIAL TIME BETWEEN SPI DATA INPUT AND 
//                 // DATA READ TO DEMONSTRATE PHASE_READY_TO_END FUNCTIONALITY !!!!
          dti_spi_monitor_out.get(m_dti_spi_item);
          if (m_dti_spi_item.rw_address[7] == 1) begin
            // Write data SPI operation
            registers[m_dti_spi_item.rw_address[6:0]]= m_dti_spi_item.write_data;
            `uvm_info(get_type_name(),$psprintf("Scoreboard DTI SPI data write to address: 0x%0h with value: 0x%0h", m_dti_spi_item.rw_address[6:0], m_dti_spi_item.write_data), UVM_MEDIUM);
            mbx_dti_spi_data.get(dti_spi_rdata_compare_val); // Remove value due to write access!
          end else begin
            // Read data SPI operation
            mbx_dti_spi_data.get(dti_spi_rdata_compare_val); 
            if (registers[m_dti_spi_item.rw_address[6:0]] != dti_spi_rdata_compare_val) begin
              `uvm_error(get_type_name(),$psprintf("Scoreboard DTI SPI data read from address: 0x%0h with value: 0x%0h NOT equal expected value: 0x%0h", 
                                                   m_dti_spi_item.rw_address[6:0], registers[m_dti_spi_item.rw_address[6:0]], dti_spi_rdata_compare_val));          
            end else begin
              `uvm_info(get_type_name(),$psprintf("Scoreboard DTI SPI data read from address: 0x%0h with value: 0x%0h equal expected value: 0x%0h", 
                                                  m_dti_spi_item.rw_address[6:0], dti_spi_rdata_compare_val, registers[m_dti_spi_item.rw_address[6:0]]), UVM_MEDIUM);                
            end
          end
        end
      join_none;
      
             
      fork : scoreboard_sample_design_spi_read_data
        process_0: forever begin
          dti_spi_busy_h.edge_probe(1);
          dti_spi_busy_h.edge_probe(0);
          dti_spi_rdata_val= dti_spi_rdata_h.get_probe();
          mbx_dti_spi_data.put(dti_spi_rdata_val);         
        end
        process_1: begin
          // wait for the trigger due to coverage requirements complete
          ev.wait_trigger();
          `uvm_info(get_type_name(), $psprintf("%t: Event ev trigger received due to coverage requirements complete", $time), UVM_MEDIUM);
          execution_termination= 1;
        end 
        process_2: begin
          #TIME_OUT;          
          `uvm_error(get_type_name(),"TIMEOUT: Scoreboard simulation terminated."); 
        end         
      join_any;
      disable scoreboard_sample_design_spi_read_data; // Terminate all fork'ed processes (i.e. process_0, process_1 and process_2).
      
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
         `uvm_info(get_type_name(),$psprintf("DUT execution complete with 0x%0h left in mailbox.", mbx_dti_spi_data.num()), UVM_MEDIUM);            
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
       wait (mbx_dti_spi_data.num() == 0 );
       execution_termination= 0;
    endtask: wait_for_ok_to_finish;
    
     
endclass : scoreboard_dti_spi
