library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture rtl of spictrl is

  type t_fsm_state is (IDLE, FIFO_LOOP_RD_WAIT, FIFO_LOOP_WR,
                       FIFO_RD_WAIT, SPI_INSTR_DECODE,
                       WAIT_FOR_WR_BUSY, WAIT_FOR_RD_BUSY,
                       WAIT_FOR_WR_COMPLETION, WAIT_FOR_RD_COMPLETION);
  signal fsm_state : t_fsm_state;  
  
  -- Internal signals
  signal spi_wr_data_i  : std_logic_vector(15 downto 0);
  signal spi_wr_str_i   : std_logic;
  signal spi_rd_str_i   : std_logic;
        
begin

  P_SPI_CTRL_FSM:
  process (rst, mclk) is
  begin
    if ( rst = '1') then

      spi_active   <= '1';
      spitxfifo_rd <= '0';
      spirxfifo_wr <= '0';
      spi_rx_data  <= (others => '0');
      spi_wr_str_i   <= '0';
      spi_rd_str_i   <= '0';
      spi_wr_data_i  <= (others => '0');
      fsm_state    <= IDLE;

    elsif rising_edge( mclk ) then

      -- Default values
      spi_active   <= '1';
      spitxfifo_rd <= '0';
      spirxfifo_wr <= '0';
      spi_rx_data  <= (others => '0');
      spi_wr_str_i   <= '0';
      spi_rd_str_i   <= '0';
     
      case fsm_state is

        when IDLE  =>        
          if spi_loop_ena='1' and spi_fifo_tx_write_enable='1' and
             unsigned(spi_tx_fifo_count) > 0 then
            spitxfifo_rd <= '1';
            fsm_state       <= FIFO_LOOP_RD_WAIT;
          elsif spi_loop_ena='0' and spi_fifo_tx_write_enable='1' and
             unsigned(spi_tx_fifo_count) > 0 then
            spitxfifo_rd <= '1';
            fsm_state    <= FIFO_RD_WAIT;
          else
            spi_active   <= '0';      
          end if; 

        when FIFO_LOOP_RD_WAIT =>    
          spi_active   <= '1';
          fsm_state    <= FIFO_LOOP_WR;      
                            
        when FIFO_LOOP_WR =>
          spirxfifo_wr <= '1';
          spi_rx_data  <= spi_tx_data;  
          fsm_state    <= IDLE;      

        when FIFO_RD_WAIT =>    
          fsm_state    <= SPI_INSTR_DECODE;      

        when SPI_INSTR_DECODE =>
          spi_wr_data_i   <= spi_tx_data;
          if spi_tx_data(15)='0' then 
            spi_rd_str_i  <= '1';
            fsm_state   <= WAIT_FOR_RD_BUSY;                  
          else
            spi_wr_str_i  <= '1';
            fsm_state   <= WAIT_FOR_WR_BUSY;      
          end if;
          
        when WAIT_FOR_WR_BUSY =>
          spi_active <= '1';
          if spi_busy='1' then
            fsm_state   <= WAIT_FOR_WR_COMPLETION;      
          end if;
          
        when WAIT_FOR_WR_COMPLETION =>
          if spi_busy='0' then
            fsm_state   <= IDLE;      
          end if;

        when WAIT_FOR_RD_BUSY =>
          if spi_busy='1' then
            fsm_state   <= WAIT_FOR_RD_COMPLETION;      
          end if;

        when WAIT_FOR_RD_COMPLETION =>
          if spi_busy='0' then
            spi_rx_data  <= spi_tx_data(15 downto 8) & spi_rd_data;  
            spirxfifo_wr <= '1';
            fsm_state    <= IDLE;      
          end if;
            
      end case;            
    end if;
    
  end process P_SPI_CTRL_FSM;

  
  -- Concurrent I/O connections assignments
         
  spi_wr_data <= spi_wr_data_i; 
  spi_wr_str  <= spi_wr_str_i;  
  spi_rd_str  <= spi_rd_str_i;
      
  -- Concurrent statements
  -- TBD.
  
end rtl;
