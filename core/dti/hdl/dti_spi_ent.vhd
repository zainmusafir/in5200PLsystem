------------ -------------------------------------------------
--
-- File	   : dti_spi_ent.vhd
-- Project : MLA
-- Designer: roarsk
--
-- Description: SPI for MAX31723
--
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dti_spi is  
  port (
    -- System Clock and Reset
    rst          : in  std_logic;                     -- Master Reset
    mclk         : in  std_logic;                     -- Master clock

   -- From FIFO                            
    instr        : in  std_logic_vector(7 downto 0);  -- SPI instruction
    wdata        : in  std_logic_vector(7 downto 0);  -- SPI write data
    wr_str       : in  std_logic;                     -- SPI write strobe
    rd_str       : in  std_logic;                     -- SPI write strobe

    -- From core/primary (from MAX31723 PMOD card)             
    sdo          : in  std_logic;                     -- SPI data input
    
    -- To FIFO                            
    rdata        : out std_logic_vector(7 downto 0);  -- SPI read data
    busy         : out std_logic;                     -- SPI operation done

    -- To core/primary (to MAX31723 PMOD card)             
    sdi          : out std_logic;                     -- SPI data output
    sclk         : out std_logic;                     -- SPI clk
    ce           : out std_logic                      -- SPI chip enable
  );  
end dti_spi;
