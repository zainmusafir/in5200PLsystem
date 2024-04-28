library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture str of dti is

  component dti_reg is
    generic (
      DEBUG_READBACK : boolean);
    port (
      spi_fifo_tx_write_enable : out std_logic_vector(0 downto 0);
      spi_active               : in  std_logic_vector(0 downto 0);
      spi_tx_fifo_count        : in  std_logic_vector(8 downto 0);
      spi_rx_fifo_count        : in  std_logic_vector(8 downto 0);
      spi_loop_ena             : out std_logic_vector(0 downto 0);
      spi_ps_access_ena        : out std_logic_vector(0 downto 0);
      pif_clk                  : in  std_logic;
      pif_rst                  : in  std_logic;
      pif_regcs                : in  std_logic;
      pif_addr                 : in  std_logic_vector(PSIF_ADDRESS_LENGTH-1 downto 0);
      pif_wdata                : in  std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      pif_re                   : in  std_logic_vector(0 downto 0);
      pif_we                   : in  std_logic_vector(0 downto 0);
      pif_be                   : in  std_logic_vector((PSIF_DATA_LENGTH/8)-1 downto 0);
      rdata_2pif               : out std_logic_vector(PSIF_DATA_LENGTH-1 downto 0);
      ack_2pif                 : out std_logic);
  end component dti_reg;
  
 component spictrl
    port (
      rst                      : in  std_logic;
      mclk                     : in  std_logic;
      spi_loop_ena             : in  std_logic;
      spi_fifo_tx_write_enable : in  std_logic;
      spi_tx_fifo_count        : in  std_logic_vector(8 downto 0);
      spi_tx_data              : in  std_logic_vector(15 downto 0);
      spi_rd_data              : in  std_logic_vector(7 downto 0);
      spi_busy                 : in  std_logic; 
      spi_active               : out std_logic;
      spitxfifo_rd             : out std_logic;
      spirxfifo_wr             : out std_logic;
      spi_rx_data              : out std_logic_vector(15 downto 0);
      spi_wr_data              : out std_logic_vector(15 downto 0);
      spi_wr_str               : out std_logic;
      spi_rd_str               : out std_logic);  
  end component;
  
  component fifo_512x16bit
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector (15 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector (15 downto 0);
      full          : out std_logic;
      empty         : out std_logic;
      rd_data_count : out std_logic_vector (8 downto 0));
  end component;

  component dti_spi is
    port (
      rst    : in  std_logic;                     -- Master Reset
      mclk   : in  std_logic;                     -- Master clock
      instr  : in  std_logic_vector(7 downto 0);  -- SPI instruction
      wdata  : in  std_logic_vector(7 downto 0);  -- SPI write data
      wr_str : in  std_logic;                     -- SPI write strobe
      rd_str : in  std_logic;                     -- SPI write strobe
      sdo    : in  std_logic;                     -- SPI data input
      rdata  : out std_logic_vector(7 downto 0);  -- SPI read data
      busy   : out std_logic;                     -- SPI operation done
      sdi    : out std_logic;                     -- SPI data output
      sclk   : out std_logic;                     -- SPI clk
      ce     : out std_logic);                    -- SPI chip enable
  end component dti_spi;
    
  signal mdata_dtispirxfifo2pif_i  : std_logic_vector(15 downto 0);

  signal spi_fifo_tx_write_enable  : std_logic;
  signal spi_active                : std_logic;
  signal spi_tx_fifo_count         : std_logic_vector(8 downto 0);
  signal spi_rx_fifo_count         : std_logic_vector(8 downto 0);
  signal spi_loop_ena              : std_logic;
  signal spi_ps_access_ena         : std_logic;

  signal spitxfifo_rd              : std_logic;
  signal spirxfifo_wr              : std_logic;
  signal spi_tx_data               : std_logic_vector(15 downto 0);
  signal spi_rx_data               : std_logic_vector(15 downto 0);
  signal spi_rd_data               : std_logic_vector(7 downto 0);
  signal spi_busy                  : std_logic; 
  signal spictrl_wr_data           : std_logic_vector(15 downto 0);
  signal spictrl_rd_str            : std_logic;  
  signal spi_wr_str                : std_logic;
  signal spi_rd_str                : std_logic;  
  signal spi_wr_data               : std_logic_vector(15 downto 0);

begin

  dti_reg_0: dti_reg
    generic map (
      DEBUG_READBACK => PSIF_DEBUG_READBACK_V)
    port map (
      spi_fifo_tx_write_enable(0) => spi_fifo_tx_write_enable,
      spi_active(0)               => spi_active,
      spi_tx_fifo_count           => spi_tx_fifo_count,
      spi_rx_fifo_count           => spi_rx_fifo_count,
      spi_loop_ena(0)             => spi_loop_ena,
      spi_ps_access_ena(0)        => spi_ps_access_ena,
      pif_clk                     => mclk,
      pif_rst                     => rst,
      pif_regcs                   => pif_regcs,
      pif_addr                    => pif_addr,
      pif_wdata                   => pif_wdata,
      pif_re                      => pif_re,
      pif_we                      => pif_we,
      pif_be                      => pif_be,
      rdata_2pif                  => rdata_2pif,
      ack_2pif                    => ack_2pif);

  dti_spi_tx_fifo_512x16bit: fifo_512x16bit
    port map (
      rst           => pif_rst,
      wr_clk        => pif_clk,
      rd_clk        => mclk,
      din           => pif_wdata(15 downto 0),
      wr_en         => pif_we(0) and pif_memcs(PSIF_MEMSEL_DTISPITXFIFO),
      rd_en         => spitxfifo_rd,
      dout          => spi_tx_data(15 downto 0),
      full          => open,
      empty         => open,
      rd_data_count => spi_tx_fifo_count);

  dti_spi_rx_fifo_512x16bit: fifo_512x16bit
    port map (
      rst           => pif_rst,
      wr_clk        => mclk,
      rd_clk        => pif_clk,
      din           => spi_rx_data(15 downto 0),
      wr_en         => spirxfifo_wr,
      rd_en         => pif_re(0) and pif_memcs(PSIF_MEMSEL_DTISPIRXFIFO),
      dout          => mdata_dtispirxfifo2pif_i,
      full          => open,
      empty         => open,
      rd_data_count => spi_rx_fifo_count);

  spictrl_dti: spictrl
    port map (
      rst                      => rst,
      mclk                     => mclk,
      spi_loop_ena             => spi_loop_ena,
      spi_fifo_tx_write_enable => spi_fifo_tx_write_enable,
      spi_tx_fifo_count        => spi_tx_fifo_count,
      spi_tx_data              => spi_tx_data,
      spi_rd_data              => spi_rd_data,     
      spi_busy                 => spi_busy,        
      spi_active               => spi_active,
      spitxfifo_rd             => spitxfifo_rd,
      spirxfifo_wr             => spirxfifo_wr,
      spi_rx_data              => spi_rx_data,
      spi_wr_data              => spictrl_wr_data,
      spi_wr_str               => spi_wr_str,
      spi_rd_str               => spictrl_rd_str); 

  dti_spi_0: dti_spi
    port map (
      rst    => rst,                       -- Master Reset
      mclk   => mclk,                      -- Master clock
      instr  => spi_wr_data(15 downto 8),  -- SPI instruction
      wdata  => spi_wr_data(7 downto 0),   -- SPI write data
      wr_str => spi_wr_str,                -- SPI write strobe
      rd_str => spi_rd_str,                -- SPI write strobe
      sdo    => dti_sdo,                   -- SPI data input
      rdata  => spi_rd_data,               -- SPI read data
      busy   => spi_busy,                  -- SPI operation done
      sdi    => dti_sdi,                   -- SPI data output
      sclk   => dti_sclk,                  -- SPI clk
      ce     => dti_ce);                   -- SPI chip enable

  -- Concurrent statements
  mdata_dtispirxfifo2pif <= x"0000" & mdata_dtispirxfifo2pif_i;

  -- SPI read access controlled by SCU module 
  spi_rd_str    <= spictrl_rd_str  when spi_ps_access_ena='1' else dti_spi_rd_str; 
  spi_wr_data   <= spictrl_wr_data when spi_ps_access_ena='1' else dti_spi_instruction;
  dti_spi_busy  <= spi_busy;
  dti_spi_rdata <= spi_rd_data;

  
end str;
