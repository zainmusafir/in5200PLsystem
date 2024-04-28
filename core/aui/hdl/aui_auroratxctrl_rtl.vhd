
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture rtl of aui_auroratxctrl is

  type t_aurora_tx_fsm_state is (IDLE,
                                 IDLE_WAIT,
                                 FIFO_AURORA_RD_WAIT,
                                 FIFO_AURORA_WR);
  signal aurora_tx_fsm_state : t_aurora_tx_fsm_state;  

  -- Internal signals
  -- TBD
   
begin

  P_AURORA_TX_CTRL_FSM:
  process (rst, mclk) is
  begin
    if ( rst = '1') then

      ps_txfifo_rd     <= '0';
      s_axi_tx_tdata   <= (others => '0');
      s_axi_tx_tkeep   <= (others => '0');
      s_axi_tx_tlast   <= '0';
      s_axi_tx_tvalid  <= '0';
        
    elsif rising_edge(mclk) then

      -- Default values
      ps_txfifo_rd     <= '0';
 
      case aurora_tx_fsm_state is

        when IDLE  =>        
          s_axi_tx_tdata  <= (others => '0');
          s_axi_tx_tkeep  <= (others => '0');
          s_axi_tx_tlast  <= '0';
          s_axi_tx_tvalid <= '0';
          if (access_loop_ena='0' and fifo_tx_write_enable='1' and
             unsigned(ps_txfifo_count) > 0 and s_axi_tx_tready = '1') then
            ps_txfifo_rd  <= '1';
            aurora_tx_fsm_state  <= FIFO_AURORA_RD_WAIT;            
          end if; 

        when FIFO_AURORA_RD_WAIT =>    
         aurora_tx_fsm_state <= FIFO_AURORA_WR;      
                            
        when FIFO_AURORA_WR =>
          -- Write AXI4Stream TX data to Aurora IP when tready is active high (i.e. '1').
          if (s_axi_tx_tready = '1') then

            -- ADD YOUR CODE FOR AXI4STREAM TX DATA
            
            aurora_tx_fsm_state <= IDLE_WAIT;            
          end if;

        when IDLE_WAIT =>
          -- Hold data and wait for s_axi_tx_tready to be ready (i.e. '1').
          if (s_axi_tx_tready = '1') then
            s_axi_tx_tvalid <= '0';
            s_axi_tx_tdata  <= (others => '0');
            s_axi_tx_tkeep  <= (others => '0');
            s_axi_tx_tlast  <= '0';
            aurora_tx_fsm_state <= IDLE;
          end if;          
            
      end case;
      
    end if;
    
  end process P_AURORA_TX_CTRL_FSM;
    
end rtl;
