
library ieee;
use ieee.std_logic_1164.all;

package aui_pck is

  -- AUI MODULE --
  constant AUI_IRQ_WIDTH                                : natural := 5;
  constant AUI_SPI_TX_SENT_IRQ                          : natural := 0;
  constant AUI_SPI_RX_RECEIVED_IRQ                      : natural := 1;
  constant AUI_AURORA_TX_SENT_IRQ                       : natural := 2;
  constant AUI_AURORA_RX_RECEIVED_IRQ                   : natural := 3;
  constant AUI_AURORA_RX_RECEIVED_LENGTH_ERROR          : natural := 4;
  constant AUI_IRQ                                      : std_logic_vector(31 downto 0) := x"00000000";  -- RO U32,5
  constant AUI_IRQ_IER                                  : std_logic_vector(31 downto 0) := x"00000004";  -- RW U32,5
  constant AUI_IRQ_ITR                                  : std_logic_vector(31 downto 0) := x"00000008";  -- RW U32,5
  constant AUI_IRQ_ISR                                  : std_logic_vector(31 downto 0) := x"0000000C";  -- RO U32,5
  constant AUI_IRQ_ICR                                  : std_logic_vector(31 downto 0) := x"00000010";  -- RW U32,5


  -- Register addresses
  constant AUI_RESET                                    : std_logic_vector(31 downto 0) := x"00001020";  -- RW U8,1
  constant AUI_CHANNEL_SELECT                           : std_logic_vector(31 downto 0) := x"00001024";  -- RW U8,1
  constant AUI_SPI_FIFO_TX_WRITE_ENABLE                 : std_logic_vector(31 downto 0) := x"00001028";  -- RW U8,1
  constant AUI_SPI_ACCESS_ACTIVE                        : std_logic_vector(31 downto 0) := x"0000102C";  -- RO U8,1
  constant AUI_SPI_TXFIFO_COUNT                         : std_logic_vector(31 downto 0) := x"00001030";  -- RO U16,9
  constant AUI_SPI_RXFIFO_COUNT                         : std_logic_vector(31 downto 0) := x"00001034";  -- RO U16,9
  constant AUI_SPI_ACCESS_LOOP_ENA                      : std_logic_vector(31 downto 0) := x"00001038";  -- RW U8,1
  constant AUI_AURORA_CORE_STATUS                       : std_logic_vector(31 downto 0) := x"0000103C";  -- RO U16,13
  constant AUI_AURORA_LOOPBACK                          : std_logic_vector(31 downto 0) := x"00001040";  -- RW U8,3
  constant AUI_AURORA_RESET                             : std_logic_vector(31 downto 0) := x"00001044";  -- RW U8,1
  constant AUI_AURORA_GT_RESET                          : std_logic_vector(31 downto 0) := x"00001048";  -- RW U8,1
  constant AUI_AURORA_PS_TXFIFO_COUNT                   : std_logic_vector(31 downto 0) := x"0000104C";  -- RO U16,9
  constant AUI_AURORA_PS_RXFIFO_COUNT                   : std_logic_vector(31 downto 0) := x"00001050";  -- RO U16,9
  constant AUI_AURORA_FIFO_TX_WRITE_ENABLE              : std_logic_vector(31 downto 0) := x"00001054";  -- RW U8,1
  constant AUI_AURORA_ACCESS_LOOP_ENA                   : std_logic_vector(31 downto 0) := x"00001058";  -- RW U8,1

end aui_pck;
