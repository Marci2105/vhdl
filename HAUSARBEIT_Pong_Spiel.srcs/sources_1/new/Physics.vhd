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
           --clock_enable : in STD_LOGIC;
           ScoreUpt : out STD_LOGIC_VECTOR (1 downto 0);
           BtnPress : out STD_LOGIC;
           GameActv : out STD_LOGIC;
           Ball_x : out integer;
           Ball_y : out integer;
           Plate_1 : out integer;
           Plate_2 : out integer;
           Curr_State: out integer);
end Physics;

architecture Behavioral of Physics is

    -- Signale für die weitere Verarbeitung
    signal ball_mvmt_vector : std_logic_vector (1 downto 0) := (others => '0');
    --signal ball_velo_vector : unsigned (3 downto 0);
    
    -- Konstanten für die weitere Berechnung
    constant SCREEN_HEIGHT : integer := 480;
    constant SCREEN_WIDTH : integer := 640;
    constant PLATE_HEIGHT : integer := 75;
    constant PLATE_WIDTH : integer := 10;
    constant BALL_RAD : integer := 2;
    constant VER_MAX_BAR: integer := SCREEN_HEIGHT - PLATE_HEIGHT;
    constant VER_MIN_BAR: integer := 0;
    
    signal ball_pos_x  : integer := 320;  -- Ballposition x
    signal ball_pos_y : integer := 240; -- Ballposition y
    signal x_offset_left : integer range 0 to 419 := 0;  -- horizontale Verschiebung (Bezugspunkt oben links)
    signal x_offset_right : integer range 0 to 419 := 0;  -- horizontale Verschiebung
    signal slow_cnt_left : integer range 0 to 499_999 := 0;  -- Teiler für langsame Bewegung
    signal slow_cnt_right : integer range 0 to 499_999 := 0;  -- Teiler für langsame Bewegung
    
    signal intern_curr_State : integer range 0 to 2 := 0; 
    
begin

--    clk_divider_50:process(CLK_25_125MHz)
--    begin
--        if (CLK_25_125MHz'event and CLK_25_125MHz = '1') then
--            clk50 <= not clk50;
--        end if;
--    end process;
    
--    clk_divider_25:process(clk50)
--    begin
--        if (clk50'event and clk50 = '1') then
--            clk25 <= not clk25;
--        end if;
--    end process;

detect_current_State:process(CLK_25_175MHz)
  begin
      if ((BTNs(0) = '1') or (BTNs(1) = '1')or(BTNs(2) = '1')or(BTNs(3) = '1')) then
        intern_curr_State <= 1;
        end if;
      Curr_State <= intern_curr_State;
  end Process;


move_bar_left : process(CLK_25_175MHz)
    begin

        if rising_edge(CLK_25_175MHz) then
                    if( BTNs(0) = '1') then
                        if slow_cnt_left = 50_000 then  
                            slow_cnt_left <= 0;
                            if x_offset_left < VER_MAX_BAR then
                                x_offset_left <= x_offset_left + 1;
                            else
                                x_offset_left <= VER_MAX_BAR;
                            end if;
                        else
                            slow_cnt_left <= slow_cnt_left + 1;
                        end if;
                    elsif( BTNs(1) = '1') then
                        if slow_cnt_left = 50_000 then  
                            slow_cnt_left <= 0;
                            if x_offset_left > VER_MIN_BAR then
                                x_offset_left <= x_offset_left - 1;
                            else
                                x_offset_left <= VER_MIN_BAR;
                            end if;
                        else
                            slow_cnt_left <= slow_cnt_left + 1;
                        end if;
                    end if;
         end if;    
         Plate_1 <= x_offset_left;   
    end process;

move_bar_right : process(CLK_25_175MHz)
    begin
        if rising_edge(CLK_25_175MHz) then
                    if( BTNs(2) = '1') then
                        if slow_cnt_right = 50_000 then  
                            slow_cnt_right <= 0;
                            if x_offset_right < VER_MAX_BAR then
                                x_offset_right <= x_offset_right + 1;
                            else
                                x_offset_right <= VER_MAX_BAR;
                            end if;
                        else
                            slow_cnt_right <= slow_cnt_right + 1;
                        end if;
                    elsif( BTNs(3) = '1') then
                        if slow_cnt_right= 50_000 then  
                            slow_cnt_right <= 0;
                            if x_offset_right > VER_MIN_BAR then
                                x_offset_right <= x_offset_right - 1;
                            else
                                x_offset_right <= VER_MIN_BAR;
                            end if;
                        else
                            slow_cnt_right <= slow_cnt_right + 1;
                        end if;
                    end if;
         end if;
         Plate_2 <= x_offset_right;       
    end process;
    
ball_movement : process(CLK_25_175MHz)
    begin
       if (rising_edge(CLK_25_175MHz) and slow_cnt_left = 50_000) then
        if (ball_mvmt_vector = "00") then  -- oben links
            ball_pos_x <= ball_pos_x - 1;
            ball_pos_y <= ball_pos_y - 1;
        elsif (ball_mvmt_vector = "10") then  -- oben rechts
            ball_pos_x <= ball_pos_x + 1;
            ball_pos_y <= ball_pos_y - 1;
        elsif (ball_mvmt_vector = "01") then  -- unten links
            ball_pos_x <= ball_pos_x - 1;
            ball_pos_y <= ball_pos_y + 1;
        else
            ball_pos_x <= ball_pos_x + 1;
            ball_pos_y <= ball_pos_y + 1;                                 -- unten rechts
        end if;
        
        if (ball_pos_y = (0 + BALL_RAD) OR ball_pos_y = (SCREEN_HEIGHT - BALL_RAD)) then
            ball_mvmt_vector(1) <= not ball_mvmt_vector(1);
        end if;
        if (ball_pos_x = (0 + BALL_RAD) OR ball_pos_x = (SCREEN_WIDTH - BALL_RAD)) then
            ball_mvmt_vector(0) <= not ball_mvmt_vector(0);
        end if;
        
       end if;
       Ball_x <= ball_pos_x;
       Ball_y <= ball_pos_y;
    end process;
end Behavioral;

