
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spictrl is
  port (
    -- Master clock Signal
    mclk                     : in std_logic;
    -- Master reset Signal. This signal is active HIGH
    rst                      : in std_logic;
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
    spi_rd_str               : out std_logic
  );  
end spictrl;

