----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 21:21:35
-- Design Name: 
-- Module Name: Graphics - Behavioral
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

entity Graphics is
    Port ( Ball_x : in integer;
           Ball_y : in integer;
           Plate_1 : in integer;
           Plate_2 : in integer;
           Current_State: in integer;
           CLK_25_175MHz : in STD_LOGIC;
           --clock_enable : in STD_LOGIC;
           Score : in STD_LOGIC_VECTOR (13 downto 0);
           MenuSlct : in STD_LOGIC_VECTOR (1 downto 0);
           HSYNC : out STD_LOGIC;
           VSYNC : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0));
end Graphics;

architecture Behavioral of Graphics is

    -- Konstanten für die Grafikberechnung
    constant BALL_SIZE : integer := 4;
    constant PLATE_HEIGHT : integer := 75;
    constant PLATE_WIDTH : integer := 10;
    
    constant SCREEN_WIDTH : integer := 639;
    constant SCREEN_HEIGHT : integer := 479;
    constant SYNC_WIDTH : integer := 96;
    constant SYNC_HEIGHT : integer := 2;
    constant FRONT_PORCH_HORIZONTAL : integer := 16;
    constant FRONT_PORCH_VERTICAL : integer := 10;
    constant BACK_PORCH_HORIZONTAL : integer := 48;
    constant BACK_PORCH_VERTICAL : integer := 33;
    
    -- Signale für die Grafikdarstellung
    signal hPos : integer := 0;
    signal vPos : integer := 0;
    signal videoOn: std_logic :='0';
    signal clk25: std_logic := '0';
    signal clk50: std_logic := '0';
    signal red_i   : std_logic_vector(3 downto 0) := (others => '0');
    signal green_i : std_logic_vector(3 downto 0) := (others => '0');
    signal blue_i  : std_logic_vector(3 downto 0) := (others => '0');

    
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
    
    -- Prozess zum Zählen der horizontalen Position
    Horizontal_Position_Counter : process(clk25)
    begin 
        if (rising_edge(CLK_25_175MHz)) then
            if (hPos = SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL + BACK_PORCH_HORIZONTAL + SYNC_WIDTH -1) then
                hPos <= 0;
            else
                hPos <= hPos + 1;
            end if;
        end if;
    end process;
    
    -- Prozess zum Zählen der vertikalen Position
    Vertical_Position_Counter : process(CLK_25_175MHz)
    begin
        if (rising_edge(CLK_25_175MHz)) then
            if (hPos = SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL + BACK_PORCH_HORIZONTAL + SYNC_WIDTH -1) then
                if (vPos = SCREEN_HEIGHT + FRONT_PORCH_VERTICAL + BACK_PORCH_VERTICAL + SYNC_HEIGHT -1) then
                    vPos <= 0;
                else
                    vPos <= vPos +1;
                end if;
            end if;
        end if;     
    end process;
    
    -- Prozess für die horizontale Synchronisation
    Horizontal_Synchronistation : process(CLK_25_175MHz, hPos)
    begin
        if (rising_edge(CLK_25_175MHz)) then
            if ((hPos <= SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL) OR (hPos > SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL + SYNC_WIDTH)) then
                HSYNC <= '1';
            else
                HSYNC <= '0';
            end if;
        end if;
    end process;
    
    -- Prozess für die vertikale Synchronisation
    Vertical_Synchronisation : process(CLK_25_175MHz, vPos)
    begin
        if (rising_edge(CLK_25_175MHz)) then
            if ((vPos <= SCREEN_HEIGHT + FRONT_PORCH_VERTICAL) OR (vPos > SCREEN_HEIGHT + FRONT_PORCH_VERTICAL + SYNC_HEIGHT)) then
                VSYNC <= '1';
            else
                VSYNC <= '0';
            end if;
        end if;
    end process;
 
 
    vidON:process(CLK_25_175MHz)
    begin
    
        if (rising_edge(CLK_25_175MHz)) then
            if((hPos <= SCREEN_WIDTH) AND (vPos <= SCREEN_HEIGHT)) then
                videoOn <= '1';
            else
                videoOn <= '0';
            end if;  
        end if;
    end Process;

    
   draw:process(CLK_25_175MHz, Current_State)
    begin    
             if (CLK_25_175MHz'event and CLK_25_175MHz = '1') then
               if videoOn = '1' then
               
                   if Current_State = 0 then
                            --W
                            if (hPos >= 10 and hPos <= 15) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 15 and hPos <= 40) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 40 and hPos <= 45) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 45 and hPos <= 70) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 70 and hPos <= 75) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --E
                            elsif (hPos >= 85 and hPos <= 90) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 90 and hPos <= 115) and 
                               (vPos >= 190 and vPos <= 195) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 90 and hPos <= 115) and 
                               (vPos >= 237 and vPos <= 243) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 90 and hPos <= 115) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --L
                            elsif (hPos >= 125 and hPos <= 130) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                           elsif (hPos >= 130 and hPos <= 155) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --C
                            elsif (hPos >= 165 and hPos <= 170) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 170 and hPos <= 195) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 170 and hPos <= 195) and 
                               (vPos >= 190 and vPos <= 195) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --O
                             elsif (hPos >= 205 and hPos <= 210) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 210 and hPos <= 235) and 
                               (vPos >= 190 and vPos <= 195) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 210 and hPos <= 235) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 235 and hPos <= 240) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --M
                            elsif (hPos >= 250 and hPos <= 255) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 255 and hPos <= 305) and 
                               (vPos >= 190 and vPos <= 195) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                             elsif (hPos >= 277 and hPos <= 282) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 300 and hPos <= 305) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --E
                            elsif (hPos >= 315 and hPos <= 320) and 
                               (vPos >= 190 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 320 and hPos <= 345) and 
                               (vPos >= 190 and vPos <= 195) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            elsif (hPos >= 320 and hPos <= 345) and 
                               (vPos >= 237 and vPos <= 242) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                           elsif (hPos >= 320 and hPos <= 345) and 
                               (vPos >= 285 and vPos <= 290) then
                                red_i <= "1111";
                                green_i <= "1111";
                                blue_i <= "1111";
                            --Rest Schwarz    
                            else
                                red_i <= "0000";
                                green_i <= "0000";
                                blue_i <= "0000";
                            end if;
                    
                    elsif Current_State = 1 then
                        -- Linkes Paddle
                        if (hPos >= 10 and hPos <= 20) and 
                           (vPos >= Plate_1 and vPos <= Plate_1 + 75) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";
                    
                        -- Rechtes Paddle
                        elsif (hPos >= SCREEN_WIDTH - 20 and hPos <= SCREEN_WIDTH - 10) and
                              (vPos >= Plate_2 and vPos <= Plate_2 + 75) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";
                        elsif (hPos >= Ball_x and hPos <= Ball_x+4) and
                              (vPos >= Ball_y and vPos <= Ball_y+4) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";    
                        else
                            red_i <= "0000";
                            green_i <= "0000";
                            blue_i <= "0000";
                        end if;
                    
                    else
                        red_i <= "0000";
                        green_i <= "0000";
                        blue_i <= "0000";
                    end if;
                end if;
             end if;  

    end Process;
   
RED <= red_i;
GREEN <= green_i;
BLUE <= blue_i;   
end Behavioral;

