
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library psif_lib;
use psif_lib.psif_pck.all;

architecture rtl of psif_axi4pifb is

  type t_fsm_state is (IDLE,
                          WR_ACCESS, WR_WAIT, WR_ACCESS_DONE, WR_COMPLETE,
                          RD_ACCESS, RD_DATA_WAIT, RD_ACCESS_DONE, RD_COMPLETE);  
  signal fsm_state : t_fsm_state;

  -- Number of memory chip select
  constant NO_MEMCS : natural := 32;

  -- AXI4LITE signals
  signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_wdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal axi_wstrb   : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  signal axi_bresp   : std_logic_vector(1 downto 0);
  signal axi_bvalid  : std_logic;
  signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal axi_rresp   : std_logic_vector(1 downto 0);
  signal axi_rvalid  : std_logic;

  -- Register read and write access acknowledge synch signal
  signal rdata_odi2pif_i : std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
  signal ack_odi2pif_s1  : std_logic;
  signal ack_odi2pif_s2  : std_logic;
  signal ack_odi2pif_s3  : std_logic; 
  signal rdata_dti2pif_i : std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
  signal ack_dti2pif_s1  : std_logic;
  signal ack_dti2pif_s2  : std_logic;
  signal ack_dti2pif_s3  : std_logic; 
  signal rdata_zu2pif_i  : std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
  signal ack_zu2pif_s1   : std_logic;
  signal ack_zu2pif_s2   : std_logic;
  signal ack_zu2pif_s3   : std_logic; 
  signal rdata_scu2pif_i : std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
  signal ack_scu2pif_s1  : std_logic;
  signal ack_scu2pif_s2  : std_logic;
  signal ack_scu2pif_s3  : std_logic; 
  signal rdata_aui2pif_i : std_logic_vector(PIF_DATA_WIDTH-1 downto 0);
  signal ack_aui2pif_s1  : std_logic;
  signal ack_aui2pif_s2  : std_logic;
  signal ack_aui2pif_s3  : std_logic; 
  
  -- The Vivado direct_enable attributes ensures that the enable pin is used 
  -- in the clock domain crossing 
  attribute direct_enable                   : string;
  attribute direct_enable of ack_odi2pif_s3 : signal is "yes";
  attribute direct_enable of ack_dti2pif_s3 : signal is "yes";
  attribute direct_enable of ack_zu2pif_s3  : signal is "yes";
  attribute direct_enable of ack_scu2pif_s3 : signal is "yes";
  attribute direct_enable of ack_aui2pif_s3 : signal is "yes";

  -- Internal signals
  signal pif_regcs_i    : std_logic_vector(31 downto 0);
  signal pif_memcs_str  : std_logic_vector(31 downto 0);
  signal pif_addr_i     : std_logic_vector(PIF_ADDR_WIDTH-1 downto 0);
  signal pif_re_i       : std_logic_vector(0 downto 0);
  signal pif_we_i       : std_logic_vector(0 downto 0);
  signal ack_2pif       : std_logic;
  signal ack_2pif_str   : std_logic;                                           
  signal mem_ack_rd     : std_logic;
  signal mem_ack_wr     : std_logic;
  signal mem_ack_d1     : std_logic;
  signal mem_ack_str    : std_logic;
  signal mem_ack_str_d1 : std_logic;

  
begin  

  -- Enable based synchronization of register read data and access acknowledge
  P_SYNCH_REGDATA: process(s_axi_aclk, s_axi_areset)
  begin 
    if s_axi_areset = '1' then 
      ack_odi2pif_s1  <= '0';
      ack_odi2pif_s2  <= '0';
      ack_odi2pif_s3  <= '0';
      rdata_odi2pif_i <= (others => '0');
      ack_dti2pif_s1  <= '0';
      ack_dti2pif_s2  <= '0';
      ack_dti2pif_s3  <= '0';
      rdata_dti2pif_i <= (others => '0');
      ack_zu2pif_s1   <= '0';
      ack_zu2pif_s2   <= '0';
      ack_zu2pif_s3   <= '0';
      rdata_zu2pif_i  <= (others => '0');
      ack_scu2pif_s1  <= '0';
      ack_scu2pif_s2  <= '0';
      ack_scu2pif_s3  <= '0';
      rdata_scu2pif_i <= (others => '0');
      ack_aui2pif_s1  <= '0';
      ack_aui2pif_s2  <= '0';
      ack_aui2pif_s3  <= '0';
      rdata_aui2pif_i <= (others => '0');
    elsif rising_edge(s_axi_aclk) then 
      ack_odi2pif_s1  <= ack_odi2pif;
      ack_odi2pif_s2  <= ack_odi2pif_s1;
      ack_odi2pif_s3  <= ack_odi2pif_s2;
      if ack_odi2pif_s3='1' then 
        rdata_odi2pif_i   <= rdata_odi2pif;
      end if;
      ack_dti2pif_s1  <= ack_dti2pif;
      ack_dti2pif_s2  <= ack_dti2pif_s1;
      ack_dti2pif_s3  <= ack_dti2pif_s2;
      if ack_dti2pif_s3='1' then 
        rdata_dti2pif_i   <= rdata_dti2pif;
      end if;
      ack_zu2pif_s1   <= ack_zu2pif;
      ack_zu2pif_s2   <= ack_zu2pif_s1;
      ack_zu2pif_s3   <= ack_zu2pif_s2;
      if ack_zu2pif_s3='1' then 
        rdata_zu2pif_i    <= rdata_zu2pif;
      end if;
      ack_scu2pif_s1  <= ack_scu2pif;
      ack_scu2pif_s2  <= ack_scu2pif_s1;
      ack_scu2pif_s3  <= ack_scu2pif_s2;
      if ack_scu2pif_s3='1' then 
        rdata_scu2pif_i   <= rdata_scu2pif;
      end if;
      ack_aui2pif_s1  <= ack_aui2pif;
      ack_aui2pif_s2  <= ack_aui2pif_s1;
      ack_aui2pif_s3  <= ack_aui2pif_s2;
      if ack_aui2pif_s3='1' then 
        rdata_aui2pif_i   <= rdata_aui2pif;
      end if;
    end if; 
  end process P_SYNCH_REGDATA;

  -- Generate memory acknowledge signal
  P_MEM_ACK_STR: process(s_axi_aclk, s_axi_areset)
  begin 
    if s_axi_areset = '1' then                                
      mem_ack_d1     <= '0';
      mem_ack_str    <= '0';
      mem_ack_str_d1 <= '0';
    elsif rising_edge(s_axi_aclk) then
      mem_ack_d1     <= mem_ack_rd or mem_ack_wr;
      mem_ack_str    <= (mem_ack_rd or mem_ack_wr) and not mem_ack_d1;
      mem_ack_str_d1 <= mem_ack_str;
    end if;
  end process P_MEM_ACK_STR;

  -- Register access acknowledge signal 
  P_SYNCH_REGCS: process(s_axi_aclk, s_axi_areset)
    variable ack_2pif_i : std_logic;
  begin 
    if s_axi_areset='1' then 
      ack_2pif_i    := '0';
      ack_2pif      <= '0';
      ack_2pif_str  <= '0'; 
    elsif rising_edge(s_axi_aclk) then 
      ack_2pif_i    := ack_odi2pif_s3 or ack_dti2pif_s3 or ack_zu2pif_s3 or ack_scu2pif_s3 or ack_aui2pif_s3;
      ack_2pif      <= ack_2pif_i;
      ack_2pif_str  <= (ack_2pif_i and (not ack_2pif)) or mem_ack_str_d1;
    end if; 
  end process P_SYNCH_REGCS;

  -- Brigde FSM
  P_AXI4LITE_BRIDGE_FSM: process (s_axi_aclk, s_axi_areset) is
    variable pif_memcs_i  : std_logic_vector(31 downto 0);
    variable pif_addr_sel : std_logic_vector(4 downto 0);
  begin
    if (s_axi_areset = '1') then
      axi_awready <= '0';
      axi_awaddr  <= (others => '0');
      axi_wready  <= '0';
      axi_wdata   <= (others => '0');
      axi_wstrb   <= (others => '0');
      axi_arready <= '0';
      axi_araddr  <= (others => '1');
      axi_bvalid  <= '0';
      axi_bresp   <= "00";
      axi_rvalid  <= '0';
      axi_rresp   <= "00";
      axi_rdata   <= (others => '0');

      pif_regcs_i   <= (others => '0');
      pif_memcs_i   := (others => '0');
      pif_memcs_str <= (others => '0');
      pif_addr_i    <= (others => '0');
      pif_wdata     <= (others => '0');
      -- Single bit, but vector type due to Xilinx generated RAM has vector type we signal.
      pif_we_i      <= (others => '0');
      -- Write strobes. This signal indicates which byte lanes hold
      --   valid data. There is one write strobe bit for each eight
      --   bits of the write data bus.    
      pif_be        <= (others => '0');
      mem_ack_wr    <= '0';
      pif_re_i      <= (others => '0');
      mem_ack_rd    <= '0';

      fsm_state <= IDLE;

    elsif rising_edge(s_axi_aclk) then

      --DefaultValues
      axi_awready <= '0';
      axi_wready  <= '0';
      axi_arready <= '0';

      BRIDGE_FSM_STATES: case fsm_state is

        when IDLE =>
          if (s_axi_awvalid = '1' and s_axi_wvalid = '1' and ack_2pif = '0') then
            axi_awready <= '1';
            axi_awaddr  <= s_axi_awaddr;
            axi_wready  <= '1';
            axi_wdata   <= s_axi_wdata;
            axi_wstrb   <= s_axi_wstrb;
            fsm_state   <= WR_ACCESS;
          elsif (s_axi_arvalid = '1' and ack_2pif = '0') then
            axi_arready <= '1';
            axi_araddr  <= s_axi_araddr;
            fsm_state   <= RD_ACCESS;
          end if;
          
        when WR_ACCESS=>
          pif_addr_i  <= axi_awaddr(PIF_ADDR_WIDTH-1 downto 0);
          pif_wdata   <= axi_wdata(PIF_DATA_WIDTH-1 downto 0);
          pif_we_i    <= (others => '1');
          pif_be      <= axi_wstrb;
          pif_regcs_i <= (others => '0');
          pif_memcs_i := (others => '0');
          mem_ack_wr  <= '0';
          if axi_awaddr(25 downto 21) = "00000" then
            -- Register module
            pif_addr_sel := axi_awaddr(20 downto 16);
            WR_REGCS_SELECT: case pif_addr_sel is
              when PSIF_ODI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(0) <= '1'; 
              when PSIF_DTI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(1) <= '1'; 
              when PSIF_ZU_BASE_ADDRESS(20 downto 16)   => pif_regcs_i(2) <= '1'; 
              when PSIF_SCU_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(3) <= '1'; 
              when PSIF_AUI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(4) <= '1'; 
              when others => 
                -- defaults to mem_ack_wr active to avoid a bus access hangup for unknown register module addresses. 
                mem_ack_wr  <= '1';
                pif_regcs_i <= (others => '0');
            end case WR_REGCS_SELECT;
          else
            -- RAM module
            mem_ack_wr   <= '1';
            pif_addr_sel := axi_awaddr(25 downto 21);
            WR_MEMCS_SELECT: case pif_addr_sel is
              when PSIF_DTISPITXFIFO(25 downto 21)  => pif_memcs_i(0) := '1';
              when PSIF_DTISPIRXFIFO(25 downto 21)  => pif_memcs_i(1) := '0';
              when PSIF_ZUPACKET(25 downto 21)      => pif_memcs_i(2) := '1';
              when PSIF_ZUKEY(25 downto 21)         => pif_memcs_i(3) := '1';
              when PSIF_AUIAURORATXFIFO(25 downto 21) => pif_memcs_i(4) := '1';
              when PSIF_AUIAURORARXFIFO(25 downto 21) => pif_memcs_i(5) := '0';
              when others                           => pif_memcs_i    := (others => '0');
            end case WR_MEMCS_SELECT;
          end if;
          fsm_state <= WR_WAIT;

        when WR_WAIT =>
          if (ack_2pif_str = '1') then
            pif_regcs_i <= (others => '0');
            pif_memcs_i := (others => '0');
            pif_addr_i  <= (others => '0');
            pif_we_i    <= (others => '0');
            pif_be      <= (others => '0');
            mem_ack_wr  <= '0';
            axi_bvalid  <= '1';
            axi_bresp   <= "00";
            fsm_state   <= WR_ACCESS_DONE;
          end if;
          

        when WR_ACCESS_DONE =>
          if (s_axi_bready = '1') then
            axi_bvalid <= '0';
            fsm_state  <= WR_COMPLETE;
          end if;


        when WR_COMPLETE =>
          if (s_axi_arvalid = '1' and ack_2pif = '0') then
            axi_arready <= '1';
            axi_araddr  <= s_axi_araddr;
            fsm_state   <= RD_ACCESS;
          else
            fsm_state <= IDLE;
          end if;

        when RD_ACCESS =>
          --pif_addr_i  <= axi_araddr(PIF_ADDR_WIDTH-1 downto 2) & "00";
          pif_addr_i  <= axi_araddr(PIF_ADDR_WIDTH-1 downto 0);
          pif_re_i    <= (others => '1');
          pif_regcs_i <= (others => '0');
          pif_memcs_i := (others => '0');
          mem_ack_rd  <= '0';
          if axi_araddr(25 downto 21) = "00000" then 
            -- registers
            pif_addr_sel := axi_araddr(20 downto 16);
            RD_REGCS_SELECT: case pif_addr_sel is
              when PSIF_ODI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(0) <= '1'; 
              when PSIF_DTI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(1) <= '1'; 
              when PSIF_ZU_BASE_ADDRESS(20 downto 16)   => pif_regcs_i(2) <= '1'; 
              when PSIF_SCU_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(3) <= '1'; 
              when PSIF_AUI_BASE_ADDRESS(20 downto 16)  => pif_regcs_i(4) <= '1'; 
              when others =>
                -- defaults to mem_ack_rd active to avoid a bus access hangup for unknown register module addresses
                mem_ack_rd  <= '1';
                pif_regcs_i <= (others => '0');
            end case RD_REGCS_SELECT;
          else                                       
            -- RAMs
            mem_ack_rd   <= '1';
            pif_addr_sel := axi_araddr(25 downto 21);
            RD_MEMCS_SELECT: case pif_addr_sel is
              when PSIF_DTISPITXFIFO(25 downto 21)  => pif_memcs_i(0) := '0'; 
              when PSIF_DTISPIRXFIFO(25 downto 21)  => pif_memcs_i(1) := '1'; 
              when PSIF_ZUPACKET(25 downto 21)      => pif_memcs_i(2) := '1'; 
              when PSIF_ZUKEY(25 downto 21)         => pif_memcs_i(3) := '1'; 
              when PSIF_AUIAURORATXFIFO(25 downto 21) => pif_memcs_i(4) := '0'; 
              when PSIF_AUIAURORARXFIFO(25 downto 21) => pif_memcs_i(5) := '1';
              when others                           => pif_memcs_i    := (others => '0');
            end case RD_MEMCS_SELECT;
          end if;
          fsm_state <= RD_DATA_WAIT;

        when RD_DATA_WAIT =>
          if (ack_2pif_str = '1') then
            pif_regcs_i <= (others => '0');
            pif_memcs_i := (others => '0');
            pif_addr_i  <= (others => '0');
            pif_re_i    <= (others => '0');
            mem_ack_rd  <= '0';
            if axi_araddr(25 downto 21) = "00000" then
              pif_addr_sel := axi_araddr(20 downto 16);
              REG_DATA_SELECT: case pif_addr_sel is
                when PSIF_ODI_BASE_ADDRESS(20 downto 16)  => axi_rdata <= rdata_odi2pif_i;
                when PSIF_DTI_BASE_ADDRESS(20 downto 16)  => axi_rdata <= rdata_dti2pif_i;
                when PSIF_ZU_BASE_ADDRESS(20 downto 16)   => axi_rdata <= rdata_zu2pif_i;
                when PSIF_SCU_BASE_ADDRESS(20 downto 16)  => axi_rdata <= rdata_scu2pif_i;
                when PSIF_AUI_BASE_ADDRESS(20 downto 16)  => axi_rdata <= rdata_aui2pif_i;
                when others                               => axi_rdata <= (others => '0');
              end case REG_DATA_SELECT;
            else
              pif_addr_sel := axi_araddr(25 downto 21);
              MEM_DATA_SELECT: case pif_addr_sel is
                when PSIF_DTISPIRXFIFO(25 downto 21) => axi_rdata <= mdata_dtispirxfifo2pif;
                when PSIF_ZUPACKET(25 downto 21)     => axi_rdata <= mdata_zupacket2pif;
                when PSIF_ZUKEY(25 downto 21)        => axi_rdata <= mdata_zukey2pif;
                when PSIF_AUIAURORARXFIFO(25 downto 21) => axi_rdata <= mdata_auiaurorarxfifo2pif;
                when others                          => axi_rdata <= (others => '0');
              end case MEM_DATA_SELECT;
            end if;
            axi_rvalid <= '1';
            axi_rresp  <= "00";         -- 'OK' response
            fsm_state  <= RD_ACCESS_DONE;
          end if;
          
        when RD_ACCESS_DONE =>
          if (s_axi_rready = '1') then
            -- Read data is accepted by the master
            axi_rvalid <= '0';
            axi_rdata  <= (others => '0');
            fsm_state  <= RD_COMPLETE;
          end if;

        when RD_COMPLETE =>
          if (s_axi_awvalid = '1' and s_axi_wvalid = '1' and ack_2pif = '0') then
            axi_awready <= '1';
            axi_awaddr  <= s_axi_awaddr;
            axi_wready  <= '1';
            axi_wdata   <= s_axi_wdata;
            axi_wstrb   <= s_axi_wstrb;
            fsm_state   <= WR_ACCESS;
          else
            fsm_state <= IDLE;
          end if;
        when OTHERS => fsm_state <= IDLE; 

      end case BRIDGE_FSM_STATES;

      -- Memory chip select is a strobe due FIFO read/write access
      for i in 0 to NO_MEMCS-1 loop
        pif_memcs_str(i) <= pif_memcs_i(i) and mem_ack_str;     
      end loop;    
      
    end if;
    
  end process P_AXI4LITE_BRIDGE_FSM;
  -- Concurrent I/O connections assignments
  s_axi_awready	<= axi_awready;
  s_axi_wready	<= axi_wready;
  s_axi_bresp   <= axi_bresp;
  s_axi_bvalid  <= axi_bvalid;
  s_axi_arready	<= axi_arready;
  s_axi_rdata   <= axi_rdata;
  s_axi_rresp   <= axi_rresp;
  s_axi_rvalid  <= axi_rvalid;
  
  pif_regcs <= pif_regcs_i; 
  pif_memcs <= pif_memcs_str; 
  pif_addr  <= pif_addr_i;
  pif_re    <= pif_re_i;
  pif_we    <= pif_we_i;
  
end rtl;
