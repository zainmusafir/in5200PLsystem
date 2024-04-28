`include "uvm_macros.svh"

class psif_dti_spi_module_seq extends base_seq;
   `uvm_object_utils(psif_dti_spi_module_seq);

   int es;  // Task exit status (i.e. es)

   class data_pattern;
     randc bit [7:0] address; // Fast test of all registers
//     rand  bit [7:0] address; // Random test of all registers
     rand  bit [7:0] data;
     constraint write_address_c {address >= 'h80; 
                                 address <= 'h86;}
//                                 address <= 'h88;}  // Testing error function
   endclass; // data_pattern

   // Creates data_pattern instance
   data_pattern datap = new();   
    
   // DTI SPI input signals
   logic [15:0] dti_wr_data_val;
   logic        dti_wr_str_val;
   logic        dti_rd_str_val;
               
   // DTI SPI output data
   logic [7:0] dti_rd_data_val;  
 
   // Declare test probes for internal design signals in modules
   probe_abstract #(logic [0:0])  dti_mclk_h;    // NOTE: MUST be [0:0] !
   probe_abstract #(logic [15:0]) dti_wr_data_h; 
   probe_abstract #(logic [0:0])  dti_wr_str_h;  // NOTE: MUST be [0:0] !
   probe_abstract #(logic [0:0])  dti_rd_str_h;  // NOTE: MUST be [0:0] !
   probe_abstract #(logic [0:0])  dti_busy_h;    // NOTE: MUST be [0:0] !
   probe_abstract #(logic [7:0])  dti_rd_data_h;

   function new( string name="psif_dti_spi_module_seq" );
      super.new( name );
      $cast(dti_mclk_h,    factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_mclk",,"dti_mclk_h"));  
      $cast(dti_wr_data_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_wr_data",,"dti_wr_data_h"));  
      $cast(dti_wr_str_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_wr_str",,"dti_wr_str_h"));  
      $cast(dti_rd_str_h,  factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_rd_str",,"dti_rd_str_h"));  
      $cast(dti_busy_h,    factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_busy",,"dti_busy_h"));  
      $cast(dti_rd_data_h, factory.create_object_by_name("probe_tb_top.mla_top.mla_pl.dti_0.dti_probe_rd_data",,"dti_rd_data_h"));  
   endfunction // new

   
   task body;

      //##############################################################
      // Get registers for tasks regw, regr and regc    
      // Get memories for tasks memw, memr and memc    
      //##############################################################      
      m_psif_regs_all.get_registers(psif_regs);  
      m_psif_regs_all.get_blocks(psif_blocks);      
      m_psif_regs_all.get_memories(psif_mems);
      

      // Print all blocks (i.e. modules) in PSIF
      foreach (psif_blocks[i]) begin  // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Module names: %s", psif_blocks[i].get_name().toupper), UVM_MEDIUM);
      end
      // Print all registers in PSIF
      foreach (psif_regs[i]) begin   // For all PSIF blocks in sequence
        `uvm_info(get_type_name(), $psprintf("Register names: %s", psif_regs[i].get_name().toupper), UVM_MEDIUM);
      end

      // Print "everything" in m_psif_regs_all
      m_psif_regs_all.print();
      m_psif_regs_rw.print();

      regc(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h0);      
      regw(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h1);
      regc(es, "PSIF","DTI", "DTI_SPI_PS_ACCESS_ENA", 'h1);
      
      spi_rw_init();

      // Simulation length determined by the requirements in class coverage_dti_spi used in the class psif_dti_spi_module_test
      forever begin
        datap.randomize(); // Always write access due to address constraint in class data_pattern; i.e. address(MSB) equal '1'.
        spi_write(datap.address, datap.data);
        datap.address[7]= '0; // Changing to read access 
        spi_read(datap.address, dti_rd_data_val);
        if (datap.data != dti_rd_data_val) begin
          `uvm_error(get_type_name(),$psprintf("DTI SPI address: 0x%0h with read data value: 0x%0h, but expected: 0x%0h", datap.address[6:0], dti_rd_data_val, datap.data));
        end
      end
              
   endtask : body

   // Access functions
   
   task spi_rw_init();
      dti_mclk_h.edge_probe(0);
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_rd_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_rd_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_wr_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_data", '0)) `uvm_error("TEST", "Force on DTI signal spi_wr_data failed");
      `uvm_info(get_type_name(), "DTI SPI module test initialization done!", UVM_MEDIUM);
   endtask; // spi_rw_init

   task spi_write(input bit [7:0] address, input bit [7:0] data);
      dti_wr_data_val[15:8]= address;
      dti_wr_data_val[7:0]= data;      
      dti_mclk_h.edge_probe(0);     
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_rd_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_rd_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_str", 1'b1)) `uvm_error("TEST", "Force on DTI signal spi_wr_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_data", dti_wr_data_val)) `uvm_error("TEST", "Force on DTI signal spi_wr_data failed");

      `uvm_info(get_type_name(),$psprintf("DTI SPI write address: 0x%0h and data: 0x%0h", dti_wr_data_val[15:8], dti_wr_data_val[7:0]), UVM_MEDIUM);

      dti_mclk_h.edge_probe(0);
      dti_wr_str_val= 'b0;
      dti_wr_data_val = 'h0;
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_rd_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_rd_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_wr_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_data", '0)) `uvm_error("TEST", "Force on DTI signal spi_wr_data failed");

      dti_busy_h.edge_probe(0);
   endtask; // spi_write

   task spi_read(input bit [7:0] address, output bit [7:0] data);      
      dti_wr_data_val[15:8]= address;  
      dti_wr_data_val[7:0]= '0;      
      dti_mclk_h.edge_probe(0);
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_rd_str", 1'b1)) `uvm_error("TEST", "Force on DTI signal spi_rd_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_wr_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_data", dti_wr_data_val)) `uvm_error("TEST", "Force on DTI signal spi_wr_data failed");

      dti_mclk_h.edge_probe(0);
      dti_rd_str_val= 'b0;
      dti_wr_data_val = 'h0;
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_rd_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_rd_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_str", 1'b0)) `uvm_error("TEST", "Force on DTI signal spi_wr_str failed");
      if (!uvm_hdl_force("$root.tb_top.mla_top.mla_pl.dti_0.spictrl_dti.spi_wr_data", '0)) `uvm_error("TEST", "Force on DTI signal spi_wr_data failed");
      dti_mclk_h.edge_probe(0);

      dti_busy_h.edge_probe(0);
      data= dti_rd_data_h.get_probe();
      `uvm_info(get_type_name(),$psprintf("DTI SPI read address: 0x%0h with value: 0x%0h", dti_wr_data_val[15:8], data), UVM_MEDIUM);
   
   endtask; // spi_read
      
   
endclass // psif_dti_spi_module_seq
