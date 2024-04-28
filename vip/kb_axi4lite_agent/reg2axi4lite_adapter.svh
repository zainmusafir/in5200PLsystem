
class reg2axi4lite_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2axi4lite_adapter)

   function new(string name = "reg2axi4lite_adapter");
      super.new(name);
      supports_byte_enable = 1;
      provides_responses = 1;
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    kb_axi4lite_agent_item  axi4lite_item = kb_axi4lite_agent_item::type_id::create("axi4lite_item");
    axi4lite_item.m_read_or_write = (rw.kind == UVM_READ) ? AXI4LITE_READ : AXI4LITE_WRITE;
    axi4lite_item.m_addr    = rw.addr[31:0];

    axi4lite_item.m_strb    = '0;
    axi4lite_item.m_wr_data = '0;

    if (rw.n_bits > 16) begin
      axi4lite_item.m_transaction_size = SINGLE;
      axi4lite_item.m_strb = 4'b1111;
      axi4lite_item.m_wr_data = rw.data[31:0];
    end else begin
      if (rw.n_bits > 8) begin
        axi4lite_item.m_transaction_size = HALFWORD;
        if (rw.addr[1:0] == 2'b00) begin
          axi4lite_item.m_strb[1:0] = 2'b11;
          axi4lite_item.m_wr_data[15:0] = rw.data[15:0];
        end
        if (rw.addr[1:0] == 2'b10) begin
          axi4lite_item.m_strb[3:2] = 2'b11;
          axi4lite_item.m_wr_data[31:16] = rw.data[15:0];
        end
      end else begin
        axi4lite_item.m_transaction_size = BYTE;
        axi4lite_item.m_strb[rw.addr[1:0]] = 1'b1;
        case (rw.addr[1:0]) 
          0: axi4lite_item.m_wr_data[7:0] = rw.data[7:0];
          1: axi4lite_item.m_wr_data[15:8] = rw.data[7:0];
          2: axi4lite_item.m_wr_data[23:16] = rw.data[7:0];
          3: axi4lite_item.m_wr_data[31:24] = rw.data[7:0];
        endcase
      end
    end
    
    return axi4lite_item;
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    kb_axi4lite_agent_item axi4lite_item;
    if (!$cast(axi4lite_item, bus_item)) begin
      `uvm_fatal("NOT_AXI4LITE_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = (axi4lite_item.m_read_or_write == AXI4LITE_WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr[63:32] = '0;
    rw.addr[31:0]  = axi4lite_item.m_addr;
    rw.data = '0;
    case (axi4lite_item.m_transaction_size)
      SINGLE:   rw.n_bits = 32;
      HALFWORD: rw.n_bits = 16;
      BYTE:     rw.n_bits = 8;
    endcase

    if (axi4lite_item.m_read_or_write == AXI4LITE_READ) begin
      rw.status = UVM_IS_OK;
      rw.data[31:0] = axi4lite_item.m_rd_data;

/* // NOT compatible with Mentor AXI4 QVIP.
      case (axi4lite_item.m_transaction_size)
        SINGLE: rw.data[31:0] = axi4lite_item.m_rd_data;
        HALFWORD: case (rw.addr[1:0]) 
                    0: rw.data[15:0] = axi4lite_item.m_rd_data[15:0];
                    2: rw.data[15:0] = axi4lite_item.m_rd_data[31:16];
                  endcase
        BYTE: case (rw.addr[1:0]) 
                0: rw.data[7:0] = axi4lite_item.m_rd_data[7:0];
                1: rw.data[7:0] = axi4lite_item.m_rd_data[15:8]; 
                2: rw.data[7:0] = axi4lite_item.m_rd_data[23:16];
                3: rw.data[7:0] = axi4lite_item.m_rd_data[31:24];
              endcase
      endcase
*/

    end else begin
      case (axi4lite_item.m_transaction_size)
        SINGLE: rw.data[31:0] = axi4lite_item.m_wr_data;
        HALFWORD: case (rw.addr[1:0]) 
                    0: rw.data[15:0] = axi4lite_item.m_wr_data[15:0];
                    2: rw.data[15:0] = axi4lite_item.m_wr_data[31:16];
                  endcase
        BYTE: case (rw.addr[1:0]) 
                  0: rw.data[7:0] = axi4lite_item.m_wr_data[7:0];
                  1: rw.data[7:0] = axi4lite_item.m_wr_data[15:8]; 
                  2: rw.data[7:0] = axi4lite_item.m_wr_data[23:16];
                  3: rw.data[7:0] = axi4lite_item.m_wr_data[31:24];
                endcase
      endcase
    end
  endfunction: bus2reg

endclass: reg2axi4lite_adapter

