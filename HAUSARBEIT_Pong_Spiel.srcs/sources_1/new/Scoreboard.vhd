----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 21:21:35
-- Design Name: 
-- Module Name: Scoreboard - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Scoreboard is
    Port ( Score_Upt : in STD_LOGIC_VECTOR (1 downto 0);
           CLK_25_175MHz : in STD_LOGIC;
           Btn_Press : in STD_LOGIC;
           screen_refreshed : in STD_LOGIC;
           RESET_Game : in STD_LOGIC;
           Curr_Score_1 : out STD_LOGIC_VECTOR (6 downto 0);
           Curr_Score_2 : out STD_LOGIC_VECTOR (6 downto 0);
           Game_Actv : out STD_LOGIC;
           Balls_left: out STD_LOGIC_VECTOR (1 downto 0);
           Winning_player: out std_logic;
           MenuSlct : out STD_LOGIC_VECTOR (1 downto 0));
end Scoreboard;




architecture Behavioral of Scoreboard is

    signal current_state: STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
    signal Game_atv: STD_LOGIC :='0';
    signal balls_left_int: integer := 3;
    signal Curr_score_p1: integer := 0;
    signal Curr_score_p2: integer := 0;
    signal Game_over: std_logic := '0';
    signal Reset: std_logic := '0';
    signal Winning_player_signal: std_logic := '0';
    signal screen_refresh_d : std_logic := '0';
    signal screen_refresh_rise : std_logic := '0';
    signal signal_Curr_Score_1 : STD_LOGIC_VECTOR (6 downto 0);
    signal signal_Curr_Score_2 : STD_LOGIC_VECTOR (6 downto 0);
    signal signal_balls_left: STD_LOGIC_VECTOR (1 downto 0) := (others => '1');
    
    constant GOALS_NEEDED_TO_WIN : integer := 2;
    constant AMOUNT_OF_BALLS_TO_START : integer := 3;
begin

process(CLK_25_175MHz)
    begin
        if rising_edge(CLK_25_175MHz) then
            screen_refresh_d <= screen_refreshed;
            screen_refresh_rise <= screen_refreshed AND NOT screen_refresh_d;
        end if;
    end process;

State_Machine : process(CLK_25_175MHz)
begin 
    if (rising_edge(CLK_25_175MHz)) then
            if RESET_Game = '1' then
                Game_atv <= '0';
                Game_over <= '0';
                current_state <= "00";
            else   
                if (((Btn_Press = '1') and (Game_atv = '0') and (Game_over = '0') and (current_state = "00")))then 
                    current_state <= "10"; -- State das Spiel läuft
                    Game_atv <= '1';          
                elsif (current_state= "10") and (balls_left_int = 0) and (Game_atv = '1') and (Game_over = '0')then
                    current_state <= "11"; -- State das Spiel beendet ist
                    if Curr_Score_p1 >= GOALS_NEEDED_TO_WIN then 
                        Winning_player_signal <= '1';
                    elsif  Curr_score_p2 >= GOALS_NEEDED_TO_WIN then 
                        Winning_player_signal <= '0';
                    end if;
                    Game_atv <= '0';
                    Game_over <= '1';      
               end if;
            end if;
    end if;
    MenuSlct <= current_state;
    Game_Actv <= Game_atv;
    Winning_player <= Winning_player_signal;
end process;

Current_Score_proc : process(CLK_25_175MHz)
begin
    if (rising_edge(CLK_25_175MHz)) then
        if screen_refresh_rise = '1' then
            if  RESET_Game = '1' then 
                Curr_Score_p1 <= 0;
                Curr_Score_p2 <= 0;
                balls_left_int <= AMOUNT_OF_BALLS_TO_START;
            else 
                if Score_Upt /= "00" then
                    balls_left_int <= balls_left_int -1;
                    if Score_Upt = "10" then
                        Curr_score_p2 <= Curr_score_p2 +1;
                    elsif Score_Upt = "01" then 
                        Curr_score_p1 <= Curr_score_p1 +1;
                    end if;
                   
                end if;
              end if;
        end if;
    end if;
end process;

Convert_Score_to_seven_seg : process(CLK_25_175MHz)
begin
    if (rising_edge(CLK_25_175MHz)) then
        if Curr_score_p1 = 0 then 
            signal_Curr_Score_1 <= "1111110";
        elsif Curr_score_p1 = 1 then 
            signal_Curr_Score_1 <= "0110000";
        elsif Curr_score_p1 = 2 then 
            signal_Curr_Score_1 <= "1101101";
        end if;
        
        if Curr_score_p2 = 0 then 
            signal_Curr_Score_2 <= "1111110";
        elsif Curr_score_p2 = 1 then 
            signal_Curr_Score_2 <= "0110000";
        elsif Curr_score_p2 = 2 then 
            signal_Curr_Score_2 <= "1101101";
        end if;
        
        if balls_left_int = 3 then 
            signal_balls_left <= "11";
        elsif  balls_left_int = 2 then 
            signal_balls_left <= "10";
        elsif  balls_left_int = 1 then 
            signal_balls_left <= "01";
        elsif  balls_left_int = 0 then 
            signal_balls_left <= "00";
        end if;
        
    Curr_Score_1<=signal_Curr_Score_1;
    Curr_Score_2<=signal_Curr_Score_2;
    balls_left<= signal_balls_left;
    end if;
    
    
end process;

end Behavioral;
