
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.scu_pck.all;

architecture rtl of scu_fsm is

  signal timer     : std_logic;
  signal timer_d1  : std_logic;
  signal timer_str : std_logic;

begin

  P_SCU_FSM: process (rst, mclk) is
                                                    
    type scu_fsm_state_type is (IDLE,
                                WAIT_DTI_READ_BUSY,
                                WAIT_DTI_READ_DONE,
                                READ_ZU_DATA,
                                WAIT_FOR_TDATA_CNT_STROBE,
                                WAIT_FOR_ALARM_ACKNOWLEDGE);
    variable scu_fsm_state : scu_fsm_state_type;

    variable dti_spi_rdata_i : unsigned(7 downto 0);
    variable digit0          : unsigned(3 downto 0);
    variable digit1          : unsigned(3 downto 0);
    variable bytes_received  : unsigned(5 downto 0);
                                                  
  begin
    if (rst = '1') then

      dti_spi_instruction <= (others => '0');
      dti_spi_rd_str      <= '0';
      zu_tready           <= '0';
      oledbyte3_0         <= (others => '0');
      oledbyte7_4         <= (others => '0');
      oledbyte11_8        <= (others => '0'); 
      oledbyte15_12       <= (others => '0');
      led_alarm           <= '0';
      alarm_acknowledge   <= '0';
      zu_byte_cnt_error   <= '0';
      
      digit0         := (others => '0');
      digit1         := (others => '0');
      bytes_received := (others => '0');
      
      scu_fsm_state  := IDLE;
      
    elsif rising_edge(mclk) then

      -- Default values
      dti_spi_rd_str <= '0';
      digit0:= (others => '0');
      digit1:= (others => '0');
      
      case scu_fsm_state is

        when IDLE =>          
          if fsm_rst='1' then
            dti_spi_instruction <= (others => '0');
            zu_tready           <= '0';
            oledbyte3_0         <= (others => '0');
            oledbyte7_4         <= (others => '0');
            oledbyte11_8        <= (others => '0'); 
            oledbyte15_12       <= (others => '0');
            led_alarm           <= '0';
            alarm_acknowledge   <= '0';
            zu_byte_cnt_error   <= '0';
            bytes_received      := (others => '0');
            scu_fsm_state       := IDLE;
          else
            led_alarm      <= '0';
            zu_tready      <= '0';
            bytes_received := (others => '0');
            if (zu_tvalid='1' and zu_data_ena='1') then
              led_alarm          <= '1';
              alarm_acknowledge  <= '0';
              zu_tready          <= '1';
              zu_byte_cnt_error  <= '0';
              scu_fsm_state  := READ_ZU_DATA;
            elsif (dti_read_ena='1' and timer_str='1' and dti_spi_busy='0') then
                dti_spi_instruction <= x"0200";
                dti_spi_rd_str <= '1';
                scu_fsm_state := WAIT_DTI_READ_BUSY;
            elsif (temperature_test_ena='1') then
              oledbyte3_0  <= ps_oledbyte3_0;  
              oledbyte7_4  <= ps_oledbyte7_4;  
              oledbyte11_8 <= ps_oledbyte11_8;                  
              oledbyte15_12(7 downto 0)   <= x"20";
              oledbyte15_12(15 downto 8)  <= std_logic_vector(x"30" + unsigned(temperature_test_digit0));
              oledbyte15_12(23 downto 16) <= std_logic_vector(x"30" + unsigned(temperature_test_digit1));                  
              oledbyte15_12(31 downto 24) <= x"20";
            end if;
          end if;

        when WAIT_DTI_READ_BUSY =>
          if fsm_rst='1' then
            scu_fsm_state := IDLE;
          elsif (dti_spi_busy='1') then  
            scu_fsm_state := WAIT_DTI_READ_DONE;
         end if;

        when WAIT_DTI_READ_DONE =>
          if fsm_rst='1' then
            scu_fsm_state  := IDLE;
          else
            if (dti_spi_busy='0') then
              oledbyte15_12(7 downto 0) <= x"43";         
              digit0:= (others=>'0');
              digit1:= (others=>'0');
              
              dti_spi_rdata_i:= unsigned(dti_spi_rdata);
              oledbyte15_12(31 downto 24) <= x"2B";
              if (dti_spi_rdata_i >= 128) then
                dti_spi_rdata_i:= (not dti_spi_rdata_i) + 1;
                oledbyte15_12(31 downto 24) <= x"2D";
              end if;                    

              digit0:= dti_spi_rdata_i(3 downto 0); -- digit0: gt 0 and le 15.
              
              if (digit0 >= 10) then
                digit1:= digit1 + 1;
                digit0:= digit0 - 10;
              end if;
              if (dti_spi_rdata_i(4)='1') then -- I.e. 2**4=16 = 1*10 + 6
                digit1:= digit1 + 1;
                digit0:= digit0 + 6;
                if (digit0 >= 10) then
                  digit1:= digit1 + 1;
                  digit0:= digit0 - 10;
                end if;
              end if;
              if (dti_spi_rdata_i(5)='1') then -- I.e. 2**5=32 = 3*10 + 2
                digit1:= digit1 + 3;
                digit0:= digit0 + 2;
                if (digit0 >= 10) then
                  digit1:= digit1 + 1;
                  digit0:= digit0 - 10;
                end if;
              end if;
              if (dti_spi_rdata_i(6)='1') then -- I.e. 2**6=64 = 6*10 + 4
                digit1:= digit1 + 6;
                digit0:= digit0 + 4;
                if (digit0 >= 10) then
                  digit1:= digit1 + 1;
                  digit0:= digit0 - 10;
                end if;
              end if;
                
              if (digit1 >= 10) then  -- I.e. greater than +99 degrees
                oledbyte15_12(31 downto 24) <= x"62"; -- ">",
                digit1:= x"9";
                digit0:= x"9";
              end if;
                          
              oledbyte3_0  <= ps_oledbyte3_0;  
              oledbyte7_4  <= ps_oledbyte7_4;  
              oledbyte11_8 <= ps_oledbyte11_8;                  
              oledbyte15_12(15 downto 8)  <= std_logic_vector(x"30" + digit0);
              oledbyte15_12(23 downto 16) <= std_logic_vector(x"30" + digit1);
              
              scu_fsm_state := IDLE;
             
            end if;
          end if;

        when READ_ZU_DATA =>
          if fsm_rst='1' then
            scu_fsm_state := IDLE;
          elsif (zu_tvalid='1') then
            bytes_received:= bytes_received + 1;
            if (bytes_received=1) then
              oledbyte15_12(31 downto 24) <= zu_tdata;
            end if;
            if (bytes_received=2) then
              oledbyte15_12(23 downto 16) <= zu_tdata;
            end if;
            if (bytes_received=3) then
              oledbyte15_12(15 downto 8) <= zu_tdata;
            end if;
            if (bytes_received=4) then
              oledbyte15_12(7 downto 0) <= zu_tdata;
            end if;
            if (bytes_received=5) then
              oledbyte11_8(31 downto 24) <= zu_tdata;
            end if;
            if (bytes_received=6) then
              oledbyte11_8(23 downto 16) <= zu_tdata;
            end if;
            if (bytes_received=7) then
              oledbyte11_8(15 downto 8) <= zu_tdata;
            end if;
            if (bytes_received=8) then
              oledbyte11_8(7 downto 0) <= zu_tdata;
            end if;
            if (bytes_received=9) then
              oledbyte7_4(31 downto 24) <= zu_tdata;
            end if;
            if (bytes_received=10) then
              oledbyte7_4(23 downto 16) <= zu_tdata;
            end if;
            if (bytes_received=11) then
              oledbyte7_4(15 downto 8) <= zu_tdata;
            end if;
            if (bytes_received=12) then
              oledbyte7_4(7 downto 0)  <= zu_tdata;
            end if;
            if (bytes_received=13) then
              oledbyte3_0(31 downto 24) <= zu_tdata;
            end if;
            if (bytes_received=14) then
              oledbyte3_0(23 downto 16) <= zu_tdata;
            end if;
            if (bytes_received=15) then
              oledbyte3_0(15 downto 8) <= zu_tdata;
            end if;
            if (bytes_received=16) then
              oledbyte3_0(7 downto 0)  <= zu_tdata;
            end if;
            
            if (bytes_received<16) then 
              scu_fsm_state := READ_ZU_DATA;
            else
              scu_fsm_state := WAIT_FOR_TDATA_CNT_STROBE;
            end if;
          end if;

        when WAIT_FOR_TDATA_CNT_STROBE =>
          if fsm_rst='1' then
            scu_fsm_state := IDLE;
          else
            zu_tready <= '0';
            if (zu_tdata_cnt_str='1') then
              if (unsigned(zu_tdata_cnt) /= unsigned(bytes_received)) then
                zu_byte_cnt_error <= '1';
              end if;
              scu_fsm_state := WAIT_FOR_ALARM_ACKNOWLEDGE;
            end if;
          end if;                    
          
        when WAIT_FOR_ALARM_ACKNOWLEDGE =>
          if fsm_rst='1' then
            scu_fsm_state := IDLE;
          else
            zu_tready <= '0';
            if (alarm_ack_btn='1') then
              alarm_acknowledge <= '1';
              scu_fsm_state := IDLE;
            end if;
          end if;          
          --scu_fsm_state := IDLE;
          
        when others => 
          scu_fsm_state := IDLE;
                 
      end case;
      
    end if;
    
  end process P_SCU_FSM;

  
  G_SIMULATION_MODE: if SIMULATION_MODE="ON" generate
    constant TIMER_LENGTH : natural:= 8;
  begin
    
    P_TIMER : process (rst, mclk)
      variable cnt : unsigned(TIMER_LENGTH-1 downto 0);
    begin
      if (rst = '1') then
        cnt := (others => '0');
        timer     <= '0';
        timer_d1  <= '0';
        timer_str <= '0';      
      elsif rising_edge(mclk) then
        cnt       := cnt + 1;
        timer     <= std_logic(cnt(TIMER_LENGTH-1));
        timer_d1  <= timer;
        timer_str <= timer xor timer_d1;
      end if;                                                         
    end process P_TIMER;
    
  else generate
         
    constant TIMER_LENGTH : natural:= 10;
  begin
    
    P_TIMER : process (rst, mclk)
      variable cnt : unsigned(TIMER_LENGTH-1 downto 0);
    begin
      if (rst = '1') then
        cnt := (others => '0');
        timer     <= '0';
        timer_d1  <= '0';
        timer_str <= '0';      
      elsif rising_edge(mclk) then
        cnt       := cnt + 1;
        timer     <= std_logic(cnt(TIMER_LENGTH-1));
        timer_d1  <= timer;
        timer_str <= timer xor timer_d1;
      end if;                                                         
    end process P_TIMER;
    
  end generate G_SIMULATION_MODE;
  
 
end rtl;
