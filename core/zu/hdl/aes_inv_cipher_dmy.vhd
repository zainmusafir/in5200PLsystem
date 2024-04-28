
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity aes_inv_cipher is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    bypass : IN STD_LOGIC_VECTOR (0 downto 0);
    in_r_address0 : OUT STD_LOGIC_VECTOR (3 downto 0);
    in_r_ce0 : OUT STD_LOGIC;
    in_r_q0 : IN STD_LOGIC_VECTOR (7 downto 0);
    out_r_TDATA : OUT STD_LOGIC_VECTOR (7 downto 0);
    out_r_TVALID : OUT STD_LOGIC;
    out_r_TREADY : IN STD_LOGIC;
    w_address0 : OUT STD_LOGIC_VECTOR (7 downto 0);
    w_ce0 : OUT STD_LOGIC;
    w_q0 : IN STD_LOGIC_VECTOR (7 downto 0) );
end;


architecture dmy of aes_inv_cipher is
begin

  ap_done       <= '0';
  ap_idle       <= '0';
  ap_ready      <= '0';
  in_r_address0 <= (others => '0');
  in_r_ce0      <= '0';
  out_r_TDATA   <= (others => '0');
  out_r_TVALID  <= '0';
  w_address0    <= (others => '0');
  w_ce0         <= '0';
  
end dmy;
