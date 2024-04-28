
library ieee;
use ieee.std_logic_1164.all;

package scu_pck is

  -- SCU MODULE --


  -- Register addresses
  constant SCU_ZU_DATA_ENA                              : std_logic_vector(31 downto 0) := x"00000000";  -- RW U8,1
  constant SCU_DTI_READ_ENA                             : std_logic_vector(31 downto 0) := x"00000004";  -- RW U8,1
  constant SCU_FSM_RST                                  : std_logic_vector(31 downto 0) := x"00000008";  -- RW U8,1
  constant SCU_ALARM_ACK_BUTTON                         : std_logic_vector(31 downto 0) := x"0000000C";  -- RO U8,1
  constant SCU_OLEDBYTE3_0                              : std_logic_vector(31 downto 0) := x"00000010";  -- RW U32,32
  constant SCU_OLEDBYTE7_4                              : std_logic_vector(31 downto 0) := x"00000014";  -- RW U32,32
  constant SCU_OLEDBYTE11_8                             : std_logic_vector(31 downto 0) := x"00000018";  -- RW U32,32
  constant SCU_OLEDBYTE15_12                            : std_logic_vector(31 downto 0) := x"0000001C";  -- RW U32,32
  constant SCU_ZU_TDATA_CNT                             : std_logic_vector(31 downto 0) := x"00000020";  -- RO U8,8
  constant SCU_ZU_BYTE_CNT_ERROR                        : std_logic_vector(31 downto 0) := x"00000024";  -- RO U8,1
  constant SCU_TEMPERATURE_TEST_ENA                     : std_logic_vector(31 downto 0) := x"00000028";  -- RW U8,1
  constant SCU_TEMPERATURE_TEST_DIGIT0                  : std_logic_vector(31 downto 0) := x"0000002C";  -- RW U8,4
  constant SCU_TEMPERATURE_TEST_DIGIT1                  : std_logic_vector(31 downto 0) := x"00000030";  -- RW U8,4

end scu_pck;
