library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture str of zu is

  component zu_reg is
    generic (
      DEBUG_READBACK : boolean);
    port (
      decryption_bypass    : out std_logic_vector(0 downto 0);
      start_decryption_str : out std_logic_vector(0 downto 0);
      done_decryption      : in  std_logic_vector(0 downto 0);
      fsm_rst              : out std_logic_vector(0 downto 0);
      pif_clk              : in  std_logic;
      pif_rst              : in  std_logic;
      pif_regcs            : in  std_logic;
      pif_addr             : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata            : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re               : in  std_logic_vector(0 downto 0);
      pif_we               : in  std_logic_vector(0 downto 0);
      pif_be               : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif           : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif             : out std_logic);
  end component zu_reg;

  component zu_fsm is
    port (
      mclk                 : in  std_logic;
      rst                  : in  std_logic;
      fsm_rst              : in  std_logic;
      start_str            : in  std_logic;
      done                 : out std_logic;
      zu_tdata_cnt_str     : out std_logic;
      zu_tdata_cnt         : out std_logic_vector(7 downto 0);
      inv_chiper_rst_n     : out std_logic;
      inv_chiper_start_str : out std_logic;
      inv_chiper_tvalid    : in  std_logic;
      inv_chiper_tready    : in  std_logic;
      inv_chiper_done_str  : in  std_logic;
      inv_chiper_idle      : in  std_logic); 
  end component zu_fsm;
  
  component bram_truedualport_512x32bit is
    port (
      clka  : in  STD_LOGIC;
      rsta  : in  STD_LOGIC;
      ena   : in  STD_LOGIC;
      wea   : in  STD_LOGIC_VECTOR (3 downto 0);
      addra : in  STD_LOGIC_VECTOR (8 downto 0);
      dina  : in  STD_LOGIC_VECTOR (31 downto 0);
      douta : out STD_LOGIC_VECTOR (31 downto 0);
      clkb  : in  STD_LOGIC;
      rstb  : in  STD_LOGIC;
      enb   : in  STD_LOGIC;
      web   : in  STD_LOGIC_VECTOR (0 to 0);
      addrb : in  STD_LOGIC_VECTOR (10 downto 0);
      dinb  : in  STD_LOGIC_VECTOR (7 downto 0);
      doutb : out STD_LOGIC_VECTOR (7 downto 0));
  end component bram_truedualport_512x32bit;

  --component ila_zu
  --port (
  --      clk : in std_logic;
  --      probe0 : in std_logic_vector(0 downto 0); 
  --      probe1 : in std_logic_vector(0 downto 0); 
  --      probe2 : in std_logic_vector(0 downto 0); 
  --      probe3 : in std_logic_vector(0 downto 0); 
  --      probe4 : in std_logic_vector(0 downto 0); 
  --      probe5 : in std_logic_vector(0 downto 0); 
  --      probe6 : in std_logic_vector(0 downto 0); 
  --      probe7 : in std_logic_vector(0 downto 0); 
  --      probe8 : in std_logic_vector(0 downto 0);
  --      probe9 : in std_logic_vector(7 downto 0)
  --    );
  --end component;

  component aes_inv_cipher is
  port (
    ap_clk        : in  std_logic;
    ap_rst_n      : in  std_logic;
    ap_start      : in  std_logic;
    ap_done       : out std_logic;
    ap_idle       : out std_logic;
    ap_ready      : out std_logic;
    bypass        : in  std_logic_vector (0 downto 0);
    in_r_address0 : out std_logic_vector (3 downto 0);
    in_r_ce0      : out std_logic;
    in_r_q0       : in  std_logic_vector (7 downto 0);
    out_r_tdata   : out std_logic_vector (7 downto 0);
    out_r_tvalid  : out std_logic;
    out_r_tready  : in  std_logic;
    w_address0    : out std_logic_vector (7 downto 0);
    w_ce0         : out std_logic;
    w_q0          : in  std_logic_vector (7 downto 0));
  end component aes_inv_cipher;
  
  signal decryption_bypass       : std_logic;
  signal start_decryption_str    : std_logic;
  signal done_decryption         : std_logic;
  signal zu_fsm_rst              : std_logic;

  signal in_r_address0 : std_logic_vector (3 downto 0);
  signal in_r_ce0      : std_logic;
  signal in_r_q0       : std_logic_vector (7 downto 0);

  signal w_address0  : std_logic_vector (7 downto 0);
  signal w_ce0       : std_logic;
  signal w_q0        : std_logic_vector (7 downto 0);

  signal inv_chiper_rst_n     : std_logic;
  signal inv_chiper_start_str : std_logic;
  signal inv_chiper_done_str  : std_logic;
  signal inv_chiper_idle      : std_logic;

  signal zu_tdata_i           : std_logic_vector(7 downto 0);
  signal zu_tvalid_i          : std_logic;
  
  
begin

  zu_reg_0: zu_reg
    generic map (
      DEBUG_READBACK => PSIF_DEBUG_READBACK_V)
    port map (
      decryption_bypass(0)    => decryption_bypass,
      start_decryption_str(0) => start_decryption_str,
      done_decryption(0)      => done_decryption,
      fsm_rst(0)              => zu_fsm_rst,
      pif_clk                 => mclk,
      pif_rst                 => rst,
      pif_regcs               => pif_regcs,
      pif_addr                => pif_addr,
      pif_wdata               => pif_wdata,
      pif_re                  => pif_re,
      pif_we                  => pif_we,
      pif_be                  => pif_be,
      rdata_2pif              => rdata_2pif,
      ack_2pif                => ack_2pif);

  zu_fsm_0: zu_fsm
    port map (
      mclk                 => mclk,
      rst                  => rst,
      fsm_rst              => zu_fsm_rst,
      start_str            => start_decryption_str,
      done                 => done_decryption,
      zu_tdata_cnt_str     => zu_tdata_cnt_str, 
      zu_tdata_cnt         => zu_tdata_cnt,
      inv_chiper_rst_n     => inv_chiper_rst_n,
      inv_chiper_start_str => inv_chiper_start_str,
      inv_chiper_tvalid    => zu_tvalid_i,
      inv_chiper_tready    => zu_tready,
      inv_chiper_done_str  => inv_chiper_done_str,
      inv_chiper_idle      => inv_chiper_idle);

  zupacket_ram: bram_truedualport_512x32bit
    port map (
      clka  => pif_clk,
      rsta  => pif_rst,
      ena   => pif_memcs(0),
      wea   => pif_be,
      addra => pif_addr(10 downto 2),
      dina  => pif_wdata,
      douta => mdata_zupacket2pif,
      clkb  => mclk,
      rstb  => rst,
      enb   => in_r_ce0,
      web   => (others => '0'),
      addrb => "0000000" & in_r_address0,
      dinb  => (others => '0'),
      doutb => in_r_q0);

  zukey_ram: bram_truedualport_512x32bit
    port map (
      clka  => pif_clk,
      rsta  => pif_rst,
      ena   => pif_memcs(1),
      wea   => pif_be,
      addra => pif_addr(10 downto 2),
      dina  => pif_wdata,
      douta => mdata_zukey2pif,
      clkb  => mclk,
      rstb  => rst,
      enb   => w_ce0,
      web   => (others => '0'),
      addrb => "000" & w_address0,
      dinb  => (others => '0'),
      doutb => w_q0);
      
    aes128_inv_cipher_0: aes_inv_cipher
    port map (
      ap_clk        => mclk,
      ap_rst_n      => inv_chiper_rst_n,
      ap_start      => inv_chiper_start_str,    
      ap_done       => inv_chiper_done_str,     
      ap_idle       => inv_chiper_idle,         
      ap_ready      => open,                
      bypass(0)     => decryption_bypass,
      in_r_address0 => in_r_address0,
      in_r_ce0      => in_r_ce0,
      in_r_q0       => in_r_q0,
      out_r_tdata   => zu_tdata_i,
      out_r_tvalid  => zu_tvalid_i,
      out_r_tready  => zu_tready,
      w_address0    => w_address0,
      w_ce0         => w_ce0,
      w_q0          => w_q0);
    
  --ila_zu_0: ila_zu
  --  port map (
  --    clk    => mclk,
  --    probe0(0) => inv_chiper_rst_n,  
  --    probe1(0) => inv_chiper_start_str, 
  --    probe2(0) => inv_chiper_done_str,  
  --    probe3(0) => inv_chiper_idle,      
  --    probe4(0) => zu_fsm_rst,  
  --    probe5(0) => start_decryption_str,  
  --    probe6(0) => done_decryption,  
  --    probe7(0) => zu_tready,
  --    probe8(0) => zu_tvalid_i,
  --    probe9    => zu_tdata_i
  --  );

   -- Concurrent statements
   zu_tdata  <= zu_tdata_i;   
   zu_tvalid <= zu_tvalid_i;   

end str;
