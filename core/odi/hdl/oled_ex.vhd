--
-- Written by Ryan Kim, Digilent Inc.
-- Modified by Michael Mattioli
--
-- Description: Demo for the OLED display. First displays the alphabet for ~4 seconds and then
-- clears the display, waits for a ~1 second and then displays "Hello world!".
--

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity oled_ex is
    generic (
      SIMULATION_MODE : string);
    port (  clk           : in  std_logic; -- System clock
            rst           : in  std_logic; -- Global synchronous reset
            en            : in  std_logic; -- Block enable pin
            line1_1       : in  string;
            line3_1       : in  string;
            line1_2       : in  string;
            oledbyte3_0   : in  std_logic_vector(31 downto 0);
            oledbyte7_4   : in  std_logic_vector(31 downto 0);
            oledbyte11_8  : in  std_logic_vector(31 downto 0);
            oledbyte15_12 : in  std_logic_vector(31 downto 0);       
            sdout         : out std_logic; -- SPI data out
            oled_sclk     : out std_logic; -- SPI clock
            oled_dc       : out std_logic; -- Data/Command controller
            fin           : out std_logic; -- Finish flag for block
            alphabet_done_str : out std_logic); -- ADDED alphabet_done strobe signal for simulation/testbench purposes

     end oled_ex;

architecture behavioral of oled_ex is

    -- SPI controller
    component spi_ctrl
        port (  clk         : in std_logic;
                rst         : in std_logic;
                en          : in std_logic;
                sdata       : in std_logic_vector (7 downto 0);
                sdout       : out std_logic;
                oled_sclk   : out std_logic;
                fin         : out std_logic);
    end component;

    -- delay controller
    component delay
        generic (
          SIMULATION_MODE : string);
        port (  clk         : in std_logic;
                rst         : in std_logic;
                delay_ms    : in std_logic_vector (11 downto 0);
                delay_en    : in std_logic;
                delay_fin   : out std_logic);
    end component;

    -- character library, latency = 1
    component ascii_rom
        port (  clk    : in std_logic; -- System clock
                addr   : in std_logic_vector (10 downto 0); -- First 8 bits is the ASCII value of the character, the last 3 bits are the parts of the char
                dout   : out std_logic_vector (7 downto 0)); -- Data byte out
    end component;

    -- States for state machine
    type states is (Idle,
                    ClearDC,
                    SetPage,
                    PageNum,
                    LeftColumn1,
                    LeftColumn2,
                    SetDC,
                    Alphabet,
                    Wait1,
                    ClearScreen,
                    Wait2,
                    HelloWorldScreen1,
                    Wait3,
                    ClearScreen2,
                    Wait4,
                    HelloWorldScreen2,
                    UpdateScreen,
                    SendChar1,
                    SendChar2,
                    SendChar3,
                    SendChar4,
                    SendChar5,
                    SendChar6,
                    SendChar7,
                    SendChar8,
                    ReadMem,
                    ReadMem2,
                    Done,
                    Transition1,
                    Transition2,
                    Transition3,
                    Transition4,
                    Transition5);

    type oled_mem is array (0 to 3, 0 to 15) of std_logic_vector (7 downto 0);
    type t_line3_2 is array (0 to 15) of std_logic_vector (7 downto 0);

    -- Variable that contains what the screen will be after the next UpdateScreen state
    signal current_screen : oled_mem;

    signal line3_2 : t_line3_2;

--    constant ch_roarsk     : character:= '#';
--    constant vec_roarsk    : unsigned(7 downto 0):= to_unsigned(character'pos(ch_roarsk),8);
--    constant ch_slv_roarsk : std_logic_vector(7 downto 0):= std_logic_vector(vec_roarsk);
    
    
    --constant line1 : string(0 to 15):= "Display:        ";
    --constant line3 : string(0 to 15):= "   Hello Roar:-)";
    signal screen_slv : oled_mem := (others => (others => x"20"));
    

    -- Constant that contains the screen filled with the Alphabet and numbers
    constant alphabet_screen : oled_mem := ((x"41", x"42", x"43", x"44", x"45", x"46", x"47", x"48", x"49", x"4A", x"4B", x"4C", x"4D", x"4E", x"4F", x"50"),
                                            (x"51", x"52", x"53", x"54", x"55", x"56", x"57", x"58", x"59", x"5A", x"61", x"62", x"63", x"64", x"65", x"66"),
                                            (x"67", x"68", x"69", x"6A", x"6B", x"6C", x"6D", x"6E", x"6F", x"70", x"71", x"72", x"73", x"74", x"75", x"76"),
                                            (x"77", x"78", x"79", x"7A", x"30", x"31", x"32", x"33", x"34", x"35", x"36", x"37", x"38", x"39", x"7F", x"7F"));

    -- Constant that fills the screen with blank (spaces) entries
    constant clear_screen : oled_mem := (   (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                            (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                            (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                            (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));

    -- Constant that holds "Hello world!"
    constant hello_world_screen_line1 : oled_mem := ( (x"48", x"65", x"6c", x"6c", x"6f", x"20", x"77", x"6f", x"72", x"6c", x"64", x"21", x"20", x"20", x"20", x"20"),
                                                      (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                                      (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                                      (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));

    -- Constant that holds "Hello world!!!"
--    constant all_screen_lines : oled_mem := ( (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
--                                              (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
--                                              (screen_slv(2,0), screen_slv(2,1),screen_slv(2,2),screen_slv(2,3),screen_slv(2,4),screen_slv(2,5),screen_slv(2,6),screen_slv(2,7),
--                                                 screen_slv(2,8),screen_slv(2,9),screen_slv(2,10),screen_slv(2,11),screen_slv(2,12),screen_slv(2,13),screen_slv(2,14),screen_slv(2,15)),
--                                              (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                                              
    signal all_screen_lines : oled_mem := screen_slv; 
      

    -- Current overall state of the state machine
    signal current_state : states := Idle;

    -- State to go to after the SPI transmission is finished
    signal after_state : states;

    -- State to go to after the set page sequence
    signal after_page_state : states;

    -- State to go to after sending the character sequence
    signal after_char_state : states;

    -- State to go to after the UpdateScreen is finished
    signal after_update_state : states;

    -- Contains the value to be outputted to oled_dc
    signal temp_dc : std_logic := '0';

    -- Used in the Delay controller block
    signal temp_delay_ms : std_logic_vector (11 downto 0); -- Amount of ms to delay
    signal temp_delay_en : std_logic := '0'; -- Enable signal for the Delay block
    signal temp_delay_fin : std_logic; -- Finish signal for the Delay block

    -- Used in the SPI controller block
    signal temp_spi_en : std_logic := '0'; -- Enable signal for the SPI block
    signal temp_sdata : std_logic_vector (7 downto 0) := (others => '0'); -- Data to be sent out on SPI
    signal temp_spi_fin : std_logic; -- Finish signal for the SPI block

    signal temp_char : std_logic_vector (7 downto 0) := (others => '0'); -- Contains ASCII value for character
    signal temp_addr : std_logic_vector (10 downto 0) := (others => '0'); -- Contains address to byte needed in memory
    signal temp_dout : std_logic_vector (7 downto 0); -- Contains byte outputted from memory
    signal temp_page : std_logic_vector (1 downto 0) := (others => '0'); -- Current page
    signal temp_index : integer range 0 to 15 := 0; -- Current character on page

    signal temp_delay_4000_ms : std_logic_vector (11 downto 0); -- Amount of ms to delay; set to 4000 ms with simulation OFF and 2ms when ON
    signal temp_delay_1000_ms : std_logic_vector (11 downto 0); -- Amount of ms to delay; set to 1000 ms with similation OFF and 1ms when ON

begin

    oled_dc <= temp_dc;

    -- "Example" finish flag only high when in done state
    fin <= '1' when current_state = Done else '0';

    -- Instantiate SPI controller
    spi_comp: spi_ctrl port map (   clk => clk,
                                    rst => rst,
                                    en => temp_spi_en,
                                    sdata => temp_sdata,
                                    sdout => sdout,
                                    oled_sclk => oled_sclk,
                                    fin => temp_spi_fin);

    -- Instantiate delay
    delay_comp: delay
      generic map (
        SIMULATION_MODE => SIMULATION_MODE)
      port map (clk => clk,
                rst => rst,
                delay_ms => temp_delay_ms,
                delay_en => temp_delay_en,
                delay_fin => temp_delay_fin);

    -- Instantiate ASCII character library
    char_lib_comp : ascii_rom port map (clk => clk,
                                        addr => temp_addr,
                                        dout => temp_dout);

    
    line3_2(0)  <= oledbyte15_12(31 downto 24);
    line3_2(1)  <= oledbyte15_12(23 downto 16);
    line3_2(2)  <= oledbyte15_12(15 downto 8);
    line3_2(3)  <= oledbyte15_12(7 downto 0);
    line3_2(4)  <= oledbyte11_8(31 downto 24);
    line3_2(5)  <= oledbyte11_8(23 downto 16);
    line3_2(6)  <= oledbyte11_8(15 downto 8);
    line3_2(7)  <= oledbyte11_8(7 downto 0);
    line3_2(8)  <= oledbyte7_4(31 downto 24);
    line3_2(9)  <= oledbyte7_4(23 downto 16);
    line3_2(10) <= oledbyte7_4(15 downto 8);
    line3_2(11) <= oledbyte7_4(7 downto 0);
    line3_2(12) <= oledbyte3_0(31 downto 24);
    line3_2(13) <= oledbyte3_0(23 downto 16);
    line3_2(14) <= oledbyte3_0(15 downto 8);
    line3_2(15) <= oledbyte3_0(7 downto 0);

    G_TIMER_SIMULATION_ON: if SIMULATION_MODE="ON" generate
    begin
      temp_delay_4000_ms <= "000000000010";
      temp_delay_1000_ms <= "000000000001";
    end generate G_TIMER_SIMULATION_ON;

    G_TIMER_SIMULATION_OFF: if SIMULATION_MODE="OFF" generate
    begin
      temp_delay_4000_ms <= "111110100000"; -- 4000
      temp_delay_1000_ms <= "001111101000"; -- 1000
    end generate G_TIMER_SIMULATION_OFF;

    
    process (clk)
    begin
        if rising_edge(clk) then
            -- Default value
            alphabet_done_str <= '0';
            
            case current_state is
                -- Idle until en pulled high than intialize Page to 0 and go to state alphabet afterwards
                when Idle =>
                    if en = '1' then
                        current_state <= ClearDC;
                        after_page_state <= Alphabet;
                        temp_page <= "00";
                    end if;
                -- Set current_screen to constant alphabet_screen and update the screen; go to state Wait1 afterwards
                when Alphabet =>
                    current_screen <= alphabet_screen;
                    current_state <= UpdateScreen;
                    after_update_state <= Wait1;
                -- Wait 4ms and go to ClearScreen
                when Wait1 =>
                    alphabet_done_str <= '1';
                    temp_delay_ms <= temp_delay_4000_ms;
                    after_state <= ClearScreen;
                    current_state <= Transition3; -- Transition3 = delay transition states
                -- Set current_screen to constant clear_screen and update the screen; go to state Wait2 afterwards
                when ClearScreen =>
                    current_screen <= clear_screen;
                    after_update_state <= Wait2;
                    current_state <= UpdateScreen;
                -- Wait 1ms and go to HelloWorldScreen3
                when Wait2 =>
                    for j in 1 to 16 loop
                      all_screen_lines(1,j-1)<= std_logic_vector(to_unsigned(character'pos(line1_1(j)),8));
                    end loop;
                    for j in 1 to 16 loop
                      all_screen_lines(3,j-1)<= std_logic_vector(to_unsigned(character'pos(line3_1(j)),8));
                    end loop;
                    temp_delay_ms <= temp_delay_1000_ms;
                    after_state <= HelloWorldScreen1;
                    current_state <= Transition3; -- Transition3 = delay transition states
                -- Set currentScreen to constant hello_world_screen and update the screen; go to state Done afterwards
                when HelloWorldScreen1 =>
                    current_screen <= all_screen_lines;
--                    current_screen <= hello_world_screen_line1;
  --                  after_update_state <= Wait3;
                    after_update_state <= Wait4;
                    current_state <= UpdateScreen;
                 -- Wait 4ms and go to ClearScreen
--                when Wait3 =>
--                    temp_delay_ms <= "111110100000"; -- 4000
--                    after_state <= ClearScreen2;
--                    current_state <= Transition3; -- Transition3 = delay transition states
--                -- Set current_screen to constant clear_screen and update the screen; go to state Wait2 afterwards
--                when ClearScreen2 =>
--                    current_screen <= clear_screen;
--                    after_update_state <= Wait4;
--                    current_state <= UpdateScreen;
               when Wait4 =>
                    for j in 1 to 16 loop
                      all_screen_lines(1,j-1)<= std_logic_vector(to_unsigned(character'pos(line1_2(j)),8));
                    end loop;                    
                    for j in 0 to 15 loop
--                      all_screen_lines(3,j)<= std_logic_vector(to_unsigned(character'pos(line3_2(j)),8));
                      all_screen_lines(3,j)<= line3_2(j);
                    end loop;                   
                    temp_delay_ms <= temp_delay_1000_ms;
                    after_state <= HelloWorldScreen2;
                    current_state <= Transition3; -- Transition3 = delay transition states
                -- Set currentScreen to constant hello_world_screen and update the screen; go to state Done afterwards
                when HelloWorldScreen2 =>
                    current_screen <= all_screen_lines;
 --                   after_update_state <= Done;
                    if en = '0' then
                      current_state <= Idle;
                    else
                      -- Loop back to display hello_world_screen_line1.
                      after_update_state <= Wait2;
                      current_state <= UpdateScreen;
                    end if;
               -- Do nothing until en is deassertted and then current_state is Idle
--                when Done            =>
--                    if en = '0' then
--                        current_state <= Idle;
--                    end if;

                -- UpdateScreen State
                -- 1. Gets ASCII value from current_screen at the current page and the current spot
                --    of the page
                -- 2. If on the last character of the page transition update the page number, if on
                --    the last page(3) then the updateScreen go to "after_update_state" after
                when UpdateScreen =>
--                    temp_char <= current_screen(conv_integer(temp_page), temp_index);
                    temp_char <= current_screen(to_integer(unsigned(temp_page)), temp_index);
                    if temp_index = 15 then
                        temp_index <= 0;
--                        temp_page <= temp_page + 1;
                        temp_page <= std_logic_vector(unsigned(temp_page) + 1);
                         after_char_state <= ClearDC;
                        if temp_page = "11" then
                            after_page_state <= after_update_state;
                        else
                            after_page_state <= UpdateScreen;
                        end if;
                    else
                        temp_index <= temp_index + 1;
                        after_char_state <= UpdateScreen;
                    end if;
                    current_state <= SendChar1;

                -- Update Page states
                -- 1. Sets oled_dc to command mode
                -- 2. Sends the SetPage Command
                -- 3. Sends the Page to be set to
                -- 4. Sets the start pixel to the left column
                -- 5. Sets oled_dc to data mode
                when ClearDC =>
                    temp_dc <= '0';
                    current_state <= SetPage;
                when SetPage =>
                    temp_sdata <= "00100010";
                    after_state <= PageNum;
                    current_state <= Transition1;
                when PageNum =>
                    temp_sdata <= "000000" & temp_page;
                    after_state <= LeftColumn1;
                    current_state <= Transition1;
                when LeftColumn1 =>
                    temp_sdata <= "00000000";
                    after_state <= LeftColumn2;
                    current_state <= Transition1;
                when LeftColumn2 =>
                    temp_sdata <= "00010000";
                    after_state <= SetDC;
                    current_state <= Transition1;
                when SetDC =>
                    temp_dc <= '1';
                    current_state <= after_page_state;
                -- End update Page states

                -- Send character states
                -- 1. Sets the address to ASCII value of character with the counter appended to the
                --    end
                -- 2. Waits a clock cycle for the data to get ready by going to ReadMem and ReadMem2
                --    states
                -- 3. Send the byte of data given by the ROM
                -- 4. Repeat 7 more times for the rest of the character bytes
                when SendChar1 =>
                    temp_addr <= temp_char & "000";
                    after_state <= SendChar2;
                    current_state <= ReadMem;
                when SendChar2 =>
                    temp_addr <= temp_char & "001";
                    after_state <= SendChar3;
                    current_state <= ReadMem;
                when SendChar3 =>
                    temp_addr <= temp_char & "010";
                    after_state <= SendChar4;
                    current_state <= ReadMem;
                when SendChar4 =>
                    temp_addr <= temp_char & "011";
                    after_state <= SendChar5;
                    current_state <= ReadMem;
                when SendChar5 =>
                    temp_addr <= temp_char & "100";
                    after_state <= SendChar6;
                    current_state <= ReadMem;
                when SendChar6 =>
                    temp_addr <= temp_char & "101";
                    after_state <= SendChar7;
                    current_state <= ReadMem;
                when SendChar7 =>
                    temp_addr <= temp_char & "110";
                    after_state <= SendChar8;
                    current_state <= ReadMem;
                when SendChar8 =>
                    temp_addr <= temp_char & "111";
                    after_state <= after_char_state;
                    current_state <= ReadMem;
                when ReadMem =>
                    current_state <= ReadMem2;
                when ReadMem2 =>
                    temp_sdata <= temp_dout;
                    current_state <= Transition1;
                -- End send character states

                -- SPI transitions
                -- 1. Set en to 1
                -- 2. Waits for spi_ctrl to finish
                -- 3. Goes to clear state (Transition5)
                when Transition1 =>
                    temp_spi_en <= '1';
                    current_state <= Transition2;
                when Transition2 =>
                    if temp_spi_fin = '1' then
                        current_state <= Transition5;
                    end if;
                -- End SPI transitions

                -- Delay transitions
                -- 1. Set delay_en to 1
                -- 2. Waits for delay to finish
                -- 3. Goes to Clear state (Transition5)
                when Transition3 =>
                    temp_delay_en <= '1';
                    current_state <= Transition4;
                when Transition4 =>
                    if temp_delay_fin = '1' then
                        current_state <= Transition5;
                    end if;
                -- End Delay transitions

                -- Clear transition
                -- 1. Sets both delay_en and en to 0
                -- 2. Go to after state
                when Transition5 =>
                    temp_spi_en <= '0';
                    temp_delay_en <= '0';
                    current_state <= after_state;
                -- End Clear transition

                when others =>
                    current_state <= Idle;
            end case;
        end if;
    end process;

end behavioral;
