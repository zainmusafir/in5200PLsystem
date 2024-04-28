library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture str of odi is

  component odi_reg is
    generic (
      DEBUG_READBACK : boolean);
    port (
      oledbyte3_0   : out std_logic_vector(31 downto 0);
      oledbyte7_4   : out std_logic_vector(31 downto 0);
      oledbyte11_8  : out std_logic_vector(31 downto 0);
      oledbyte15_12 : out std_logic_vector(31 downto 0);
      ps_access_ena : out std_logic_vector(0 downto 0);
      pif_clk       : in  std_logic;
      pif_rst       : in  std_logic;
      pif_regcs     : in  std_logic;
      pif_addr      : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata     : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re        : in  std_logic_vector(0 downto 0);
      pif_we        : in  std_logic_vector(0 downto 0);
      pif_be        : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif    : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif      : out std_logic);
  end component odi_reg;

  component oled_ctrl is
    generic (
      SIMULATION_MODE : string);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      oledbyte3_0   : in  std_logic_vector(31 downto 0);
      oledbyte7_4   : in  std_logic_vector(31 downto 0);
      oledbyte11_8  : in  std_logic_vector(31 downto 0);
      oledbyte15_12 : in  std_logic_vector(31 downto 0);
      oled_sdin     : out std_logic;
      oled_sclk     : out std_logic;
      oled_dc       : out std_logic;
      oled_res      : out std_logic;
      oled_vbat     : out std_logic;
      oled_vdd      : out std_logic);
  end component oled_ctrl;  

  --type t_oled_value is array (0 to 15) of std_logic_vector(7 downto 0);
  --constant oled_value : t_oled_value;
                      
  signal ps_oledbyte3_0   : std_logic_vector(31 downto 0);
  signal ps_oledbyte7_4   : std_logic_vector(31 downto 0);
  signal ps_oledbyte11_8  : std_logic_vector(31 downto 0);
  signal ps_oledbyte15_12 : std_logic_vector(31 downto 0);

  signal oledbyte3_0   : std_logic_vector(31 downto 0);
  signal oledbyte7_4   : std_logic_vector(31 downto 0);
  signal oledbyte11_8  : std_logic_vector(31 downto 0);
  signal oledbyte15_12 : std_logic_vector(31 downto 0);
  
  signal ps_access_ena : std_logic;
  
begin
  
  odi_reg_0: odi_reg
    generic map (
      DEBUG_READBACK => PSIF_DEBUG_READBACK_V)
    port map (
      oledbyte3_0   => ps_oledbyte3_0,   
      oledbyte7_4   => ps_oledbyte7_4,   
      oledbyte11_8  => ps_oledbyte11_8,  
      oledbyte15_12 => ps_oledbyte15_12,
      ps_access_ena(0) => ps_access_ena,
      pif_clk       => mclk,
      pif_rst       => rst,
      pif_regcs     => pif_regcs,
      pif_addr      => pif_addr,
      pif_wdata     => pif_wdata,
      pif_re        => pif_re,
      pif_we        => pif_we,
      pif_be        => pif_be,
      rdata_2pif    => rdata_2pif,
      ack_2pif      => ack_2pif);

  oled_ctrl_0: oled_ctrl
    generic map (
      SIMULATION_MODE => SIMULATION_MODE)
    port map (
      clk           => mclk,
      rst           => rst,
      oledbyte3_0   => oledbyte3_0,  
      oledbyte7_4   => oledbyte7_4,  
      oledbyte11_8  => oledbyte11_8, 
      oledbyte15_12 => oledbyte15_12,
      oled_sdin     => oled_sdin,
      oled_sclk     => oled_sclk,
      oled_dc       => oled_dc,
      oled_res      => oled_res,
      oled_vbat     => oled_vbat,
      oled_vdd      => oled_vdd);

  -- Concurrent statements
  oledbyte3_0   <= ps_oledbyte3_0   when ps_access_ena='1' else odi_oledbyte3_0;
  oledbyte7_4   <= ps_oledbyte7_4   when ps_access_ena='1' else odi_oledbyte7_4;
  oledbyte11_8  <= ps_oledbyte11_8  when ps_access_ena='1' else odi_oledbyte11_8;
  oledbyte15_12 <= ps_oledbyte15_12 when ps_access_ena='1' else odi_oledbyte15_12;

end str;
