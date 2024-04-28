
//----------------------------------------------------------------------
// kb_axi4lite_agent_coverage_monitor
//----------------------------------------------------------------------
class kb_axi4lite_agent_coverage_monitor extends uvm_subscriber #(kb_axi4lite_agent_item);
  
  // factory registration macro
  `uvm_component_utils(kb_axi4lite_agent_coverage_monitor)   
    
  // variables
  kb_axi4lite_agent_item    pkt;

  covergroup my_fcov_monitor;

    addr: coverpoint pkt.m_addr {
      bins  REG_WORDTEST1      = { 32'h44A00014 }; // RW U32,32  
      bins  REG_WORDTEST2      = { 32'h44A00018 }; // RW U32,31  
      bins  REG_WORDTEST3      = { 32'h44A0001C }; // RW U32,18  
      bins  REG_WORDTEST4      = { 32'h44A00020 }; // RW U32,17  
//      bins  REG_HALFWORDTEST1  = { 32'h44A00030 }; // RW U16,16  
//      bins  REG_HALFWORDTEST2  = { 32'h44A00032 }; // RW U16,15  
//      bins  REG_HALFWORDTEST3  = { 32'h44A00034 }; // RW U16,10  
//      bins  REG_HALFWORDTEST4  = { 32'h44A00036 }; // RW U16,9  
//      bins  REG_BYTETEST1      = { 32'h44A00040 }; // RW U8,8  
//      bins  REG_BYTETEST2      = { 32'h44A00041 }; // RW U8,7  
//      bins  REG_BYTETEST3      = { 32'h44A00042 }; // RW U8,2  
//      bins  REG_BYTETEST4      = { 32'h44A00043 }; // RW U8,1
//      bins  REG_IRQ_TEST       = { 32'h44A00044 }; // RW U8,1
      bins  misc               = default ;          // Does not count!
    }

//    wstrobe: coverpoint pkt.m_strb {
//      bins BYTE0 = { 4'h1};
//      bins BYTE1 = { 4'h2};
//      bins BYTE2 = { 4'h4};
//      bins BYTE3 = { 4'h8};
//      bins misc  = default ;          // Does not count!     
//    }

    rw: coverpoint pkt.m_read_or_write {
      bins RD = { AXI4LITE_READ };
      bins WR = { AXI4LITE_WRITE };
    }
    
//    cross addr, wstrobe;
   
//    cross addr, wstrobe, rw {
//      ignore_bins write_only = binsof(rw.RD);
//    } 

    rd_cross: cross addr, rw {
      ignore_bins write_only = binsof(rw.WR);
    }

    wr_cross: cross addr, rw {
      ignore_bins write_only = binsof(rw.RD);
    } 

  endgroup : my_fcov_monitor

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------     
  function new (string name = "kb_axi4lite_agent_coverage_monitor",
                uvm_component parent = null);
    super.new(name,parent);
    my_fcov_monitor = new();
  endfunction: new


  //--------------------------------------------------------------------
  // write
  //--------------------------------------------------------------------    

  function void write(kb_axi4lite_agent_item t);
    real current_coverage;
    pkt = t;
// Removed to reduce printout
//    `uvm_info(get_type_name(),$psprintf("Coverage_Monitor read value: 0x%0h",pkt.m_addr), UVM_MEDIUM);
    my_fcov_monitor.sample();
    current_coverage = $get_coverage();
// Removed to reduce printout
//    uvm_report_info("Coverage", $psprintf("Coverage = %f%% ", current_coverage));
  endfunction: write


endclass: kb_axi4lite_agent_coverage_monitor

