----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 21:21:35
-- Design Name: 
-- Module Name: Physics - Behavioral
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

entity Physics is
    Port ( BTNs : in STD_LOGIC_VECTOR (3 downto 0);
           CLK_25_175MHz : in STD_LOGIC;
           screen_refresh : in STD_LOGIC;
           GameActv : in STD_LOGIC;
           Game_Reset: in STD_LOGIC;
           ScoreUpt : out STD_LOGIC_VECTOR (1 downto 0);
           BtnPress : out STD_LOGIC;
           Ball_x : out integer;
           Ball_y : out integer;
           Plate_1 : out integer;
           Plate_2 : out integer);
           -- ball_velocity : out integer);
end Physics;

architecture Behavioral of Physics is
    
    -- Konstanten für die weitere Berechnung
    constant SCREEN_HEIGHT : integer := 480;
    constant SCREEN_WIDTH : integer := 640;
    constant PLATE_HEIGHT : integer := 75;
    constant PLATE_WIDTH : integer := 10;
    constant BALL_RAD : integer := 2;
    constant VER_MAX_BAR : integer := SCREEN_HEIGHT - PLATE_HEIGHT;
    constant VER_MIN_BAR : integer := 0;
    constant MOVE_BAR : integer := 3;
    constant MIDDLE_HOR : integer := 320;
    constant MIDDLE_VER : integer := 240;
    constant ACC_CONTACTS : integer := 3; -- Ballkontakte, bis dieser schneller wird

    -- Signale für die weitere Verarbeitung
    signal ball_mvmt_vector : std_logic_vector (1 downto 0) := (others => '1');
    signal ball_velo : integer := 1; 
    signal bounce_cnt : integer := ACC_CONTACTS;  -- Ball startet mit 1px/Frame   
    signal ball_pos_x  : integer := 320;  -- Ballposition x
    signal ball_pos_y : integer := 240; -- Ballposition y
    signal x_offset_left : integer range 0 to 419 := 0;  -- horizontale Verschiebung (Bezugspunkt oben links)
    signal x_offset_right : integer range 0 to 419 := 0;  -- horizontale Verschiebung
    signal screen_refresh_d : std_logic := '0';
    signal screen_refresh_rise : std_logic := '0';
    signal goal_happend :  std_logic := '0';
    signal any_button_pressed :  std_logic := '0'; 
    signal goal_scored_by_player: STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
    signal collision_lock_left : std_logic := '0';
    signal collision_lock_right : std_logic := '0';

begin

detect_current_State:process(CLK_25_175MHz)
  begin
      if ((BTNs(0) = '1') or (BTNs(1) = '1')or(BTNs(2) = '1')or(BTNs(3) = '1')) then
        any_button_pressed <= '1';
        end if;
      BtnPress <= any_button_pressed;
  end Process;
  
process(CLK_25_175MHz)
    begin
        if rising_edge(CLK_25_175MHz) then
            screen_refresh_d <= screen_refresh;
            screen_refresh_rise <= screen_refresh AND NOT screen_refresh_d;
        end if;
    end process;


move_bar_left : process(CLK_25_175MHz)
    begin
        if rising_edge(CLK_25_175MHz) then
            if( BTNs(0) = '1' and (screen_refresh_rise = '1')) then
                    if x_offset_left < VER_MAX_BAR then
                        x_offset_left <= x_offset_left + MOVE_BAR;
                    else
                        x_offset_left <= VER_MAX_BAR;
                    end if;
            elsif( BTNs(1) = '1' and (screen_refresh_rise = '1')) then
                if x_offset_left > VER_MIN_BAR then
                    x_offset_left <= x_offset_left - MOVE_BAR;
                else
                    x_offset_left <= VER_MIN_BAR;
                end if;
            end if;
        end if;  
        Plate_1 <= x_offset_left;   
    end process;

move_bar_right : process(CLK_25_175MHz)
    begin
        if rising_edge(CLK_25_175MHz) then
            if( BTNs(2) = '1' and (screen_refresh_rise = '1')) then
                if x_offset_right < VER_MAX_BAR then
                    x_offset_right <= x_offset_right + MOVE_BAR;
                else
                    x_offset_right <= VER_MAX_BAR;
                end if;
            elsif( BTNs(3) = '1' and (screen_refresh_rise = '1')) then
                if x_offset_right > VER_MIN_BAR then
                    x_offset_right <= x_offset_right - MOVE_BAR;
                else
                    x_offset_right <= VER_MIN_BAR;
                end if;
            end if;
        end if;
        Plate_2 <= x_offset_right;       
    end process;
    
ball_movement : process(CLK_25_175MHz)
    begin
       if (rising_edge(CLK_25_175MHz)) then
           if Game_Reset = '1' then
                ball_pos_x <= 320;
                ball_pos_y <= 240;
                ball_velo <= 1;
                bounce_cnt <= 3;
           else
                if (screen_refresh_rise = '1') then
                    -- top and bottom
                    if (ball_pos_y <= BALL_RAD + 1) then
                        ball_mvmt_vector(0) <= '1';  -- nach unten
                    elsif (ball_pos_y >= SCREEN_HEIGHT - BALL_RAD - 1) then
                        ball_mvmt_vector(0) <= '0';  -- nach oben
                    end if;
                    
                    
                    -- right and left
                    if (ball_pos_x <= BALL_RAD and goal_happend = '0') then
                        ball_mvmt_vector(1) <= '1';  -- nach rechts
                        goal_happend <= '1';
                        goal_scored_by_player <= "10"; -- Spieler 2 hat getroffen
                    elsif (ball_pos_x >= SCREEN_WIDTH - BALL_RAD and goal_happend = '0') then
                        ball_mvmt_vector(1) <= '0';  -- nach links
                        goal_happend <= '1';
                        goal_scored_by_player <= "01"; -- Spieler 1 hat getroffen
                    else 
                        goal_scored_by_player <= "00";
                    end if;
                    
                    -- linkes Padle
                    if ((ball_pos_x - BALL_RAD <= PLATE_WIDTH + 10) and ((ball_pos_y - BALL_RAD < x_offset_left + PLATE_HEIGHT) and (ball_pos_y + BALL_RAD > x_offset_left))) then
                        if (collision_lock_left = '0') then
                            ball_mvmt_vector(1) <= '1';
                            bounce_cnt <= bounce_cnt + 1;
                            collision_lock_left <= '1';     -- Lock setzen, dass nur ein Bounce gezählt wird
                        end if;
                    end if;
                    if (((ball_pos_x - BALL_RAD <= 20) and (ball_pos_x + BALL_RAD >= 10)) and (((ball_pos_y + BALL_RAD <= x_offset_left + 1) and (ball_pos_y + BALL_RAD >= x_offset_left - 1)) or ((ball_pos_y - BALL_RAD <= x_offset_left + PLATE_HEIGHT +1) and (ball_pos_y - BALL_RAD >= x_offset_left + PLATE_HEIGHT -1)))) then
                        if (ball_pos_y < x_offset_left + 35) then
                            ball_mvmt_vector(0) <= '0';
                        else
                            ball_mvmt_vector(0) <= '1';
                        end if;
                    end if;
        
                    -- rechtes Padle
                    if ((ball_pos_x + BALL_RAD >= SCREEN_WIDTH - PLATE_WIDTH - 10) and ((ball_pos_y - BALL_RAD < x_offset_right + PLATE_HEIGHT) and (ball_pos_y + BALL_RAD > x_offset_right))) then
                        if (collision_lock_right = '0') then
                            ball_mvmt_vector(1) <= '0';
                            bounce_cnt <= bounce_cnt + 1;
                            collision_lock_right <= '1';
                        end if;
                    end if;
                    
                    if (((ball_pos_x + BALL_RAD >= SCREEN_WIDTH - 20) and (ball_pos_x - BALL_RAD <= SCREEN_WIDTH - 10)) and (((ball_pos_y + BALL_RAD <= x_offset_right + 1) and (ball_pos_y + BALL_RAD >= x_offset_right - 1)) or ((ball_pos_y - BALL_RAD <= x_offset_right + PLATE_HEIGHT + 1) and (ball_pos_y - BALL_RAD >= x_offset_right + PLATE_HEIGHT - 1)))) then
                        if (ball_pos_y < x_offset_right + 35) then
                            ball_mvmt_vector(0) <= '0';
                        else
                            ball_mvmt_vector(0) <= '1';
                        end if;
                    end if;
                    
                    -- Reset links: Ball fliegt nach rechts und ist > 20 Pixel entfernt
                    if (ball_mvmt_vector(1) = '1' and ball_pos_x - BALL_RAD > PLATE_WIDTH + 10 + 10) then
                        collision_lock_left <= '0';
                    end if;
                    
                    -- Reset rechts: Ball fliegt nach links und ist < 610 Pixel entfernt
                    if (ball_mvmt_vector(1) = '0' and ball_pos_x + BALL_RAD < SCREEN_WIDTH - PLATE_WIDTH - 10 - 10) then
                        collision_lock_right <= '0';
                    end if;
                        
                  -- bewegen des Balls
                  if(GameActv = '1') then
                        if (ball_mvmt_vector = "00") then  -- oben links
                            ball_pos_x <= ball_pos_x - ball_velo;
                            ball_pos_y <= ball_pos_y - ball_velo;
                        elsif (ball_mvmt_vector = "10") then  -- oben rechts
                            ball_pos_x <= ball_pos_x + ball_velo;
                            ball_pos_y <= ball_pos_y - ball_velo;
                        elsif (ball_mvmt_vector = "01") then  -- unten links
                            ball_pos_x <= ball_pos_x - ball_velo;
                            ball_pos_y <= ball_pos_y + ball_velo;
                        elsif (ball_mvmt_vector = "11") then -- unten rechts
                            ball_pos_x <= ball_pos_x + ball_velo;
                            ball_pos_y <= ball_pos_y + ball_velo;  
                        end if;
                        
                    end if;
                    if (goal_happend = '1')then
                        ball_pos_x <= MIDDLE_HOR;
                        ball_pos_y <= MIDDLE_VER;
                        goal_happend <= '0';
                   end if;  
                end if;
               end if;
               ball_velo <= bounce_cnt / ACC_CONTACTS;
           end if;
           ScoreUpt <= goal_scored_by_player;
           Ball_x <= ball_pos_x;
           Ball_y <= ball_pos_y;
    end process;

end Behavioral;
