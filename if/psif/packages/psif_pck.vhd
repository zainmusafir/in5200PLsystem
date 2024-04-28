
library ieee;
use ieee.std_logic_1164.all;

package psif_pck is

  -- ---------------------------------------------------------------------------
  --            GENERAL
  -- ---------------------------------------------------------------------------

  constant PSIF_ADDRESS_LENGTH                          : natural :=  32;
  constant PSIF_DATA_LENGTH                             : natural :=  32;
  constant PSIF_DEBUG_READBACK_V                        : boolean :=  TRUE;

  -- ---------------------------------------------------------------------------
  --            CONSTANTS
  -- ---------------------------------------------------------------------------

  constant PSIF_JUST_A_TEST                             : string(1 to 4) :=  "abcd";
  constant PSIF_JUST_A_TEST2                            : std_logic_vector(31 downto 0) :=  x"00000000";
  constant PSIF_JUST_A_TEST3                            : std_logic_vector(7 downto 0) :=  (0 => '1', others => '0');

  -- ---------------------------------------------------------------------------
  --            REGISTER AND INTERRUPT SELECT SIGNAL
  -- ---------------------------------------------------------------------------

  constant PSIF_REGSEL_ODI                              : natural :=  0;
  constant PSIF_REGSEL_DTI                              : natural :=  1;
  constant PSIF_REGSEL_ZU                               : natural :=  2;
  constant PSIF_REGSEL_SCU                              : natural :=  3;
  constant PSIF_REGSEL_AUI                              : natural :=  4;

  -- ---------------------------------------------------------------------------
  --            MEMORY SELECT SIGNAL
  -- ---------------------------------------------------------------------------

  constant PSIF_MEMSEL_DTISPITXFIFO                     : natural :=  0;
  constant PSIF_MEMSEL_DTISPIRXFIFO                     : natural :=  1;
  constant PSIF_MEMSEL_ZUPACKET                         : natural :=  2;
  constant PSIF_MEMSEL_ZUKEY                            : natural :=  3;
  constant PSIF_MEMSEL_AUIAURORATXFIFO                  : natural :=  4;
  constant PSIF_MEMSEL_AUIAURORARXFIFO                  : natural :=  5;

  -- ---------------------------------------------------------------------------
  --            RAM
  -- ---------------------------------------------------------------------------

  constant PSIF_DTISPITXFIFO                            : std_logic_vector(31 downto 0) :=  x"00200000"; -- 2048 * U32, 32
  constant PSIF_DTISPITXFIFO_RAMSIZE                    : natural :=  65536;
  constant PSIF_DTISPIRXFIFO                            : std_logic_vector(31 downto 0) :=  x"00400000"; -- 2048 * U32, 32
  constant PSIF_DTISPIRXFIFO_RAMSIZE                    : natural :=  65536;
  constant PSIF_ZUPACKET                                : std_logic_vector(31 downto 0) :=  x"00600000"; -- 512 * U32, 32
  constant PSIF_ZUPACKET_RAMSIZE                        : natural :=  16384;
  constant PSIF_ZUKEY                                   : std_logic_vector(31 downto 0) :=  x"00800000"; -- 512 * U32, 32
  constant PSIF_ZUKEY_RAMSIZE                           : natural :=  16384;
  constant PSIF_AUIAURORATXFIFO                         : std_logic_vector(31 downto 0) :=  x"00A00000"; -- 2048 * U32, 32
  constant PSIF_AUIAURORATXFIFO_RAMSIZE                 : natural :=  65536;
  constant PSIF_AUIAURORARXFIFO                         : std_logic_vector(31 downto 0) :=  x"00C00000"; -- 2048 * U32, 32
  constant PSIF_AUIAURORARXFIFO_RAMSIZE                 : natural :=  65536;

  -- ---------------------------------------------------------------------------
  --            REGISTER ADDRESSES
  -- ---------------------------------------------------------------------------

  constant PSIF_ODI_BASE_ADDRESS                        : std_logic_vector(31 downto 0) := x"00010000";  -- ADDRESS SPACE START
  constant PSIF_DTI_BASE_ADDRESS                        : std_logic_vector(31 downto 0) := x"00020000";  -- ADDRESS SPACE START
  constant PSIF_ZU_BASE_ADDRESS                         : std_logic_vector(31 downto 0) := x"00030000";  -- ADDRESS SPACE START
  constant PSIF_SCU_BASE_ADDRESS                        : std_logic_vector(31 downto 0) := x"00040000";  -- ADDRESS SPACE START
  constant PSIF_AUI_BASE_ADDRESS                        : std_logic_vector(31 downto 0) := x"00050000";  -- ADDRESS SPACE START


end psif_pck;
