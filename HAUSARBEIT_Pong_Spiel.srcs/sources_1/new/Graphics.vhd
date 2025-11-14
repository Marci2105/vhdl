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
           CLK_25_125MHz : in STD_LOGIC;
           clock_enable : in STD_LOGIC;
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
    constant PLATE_HEIGHT : integer := 20;
    constant PLATE_WIDTH : integer := 4;
    
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
    
begin
    -- Prozess zum Zählen der horizontalen Position
    Horizontal_Position_Counter : process(CLK_25_125MHz)
    begin 
        if (rising_edge(CLK_25_125MHz)) then
            if (hPos = SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL + BACK_PORCH_HORIZONTAL + SYNC_WIDTH -1) then
                hPos <= 0;
            else
                hPos <= hPos + 1;
            end if;
        end if;
    end process;
    
    -- Prozess zum Zählen der vertikalen Position
    Vertical_Position_Counter : process(CLK_25_125MHz)
    begin
        if (rising_edge(CLK_25_125MHz)) then
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
    Horizontal_Synchronistation : process(CLK_25_125MHz, hPos)
    begin
        if (rising_edge(CLK_25_125MHz)) then
            if ((hPos <= SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL) OR (hPos > SCREEN_WIDTH + FRONT_PORCH_HORIZONTAL + SYNC_WIDTH)) then
                HSYNC <= '1';
            else
                HSYNC <= '0';
            end if;
        end if;
    end process;
    
    -- Prozess für die vertikale Synchronisation
    Vertical_Synchronisation : process(CLK_25_125MHz, vPos)
    begin
        if (rising_edge(CLK_25_125MHz)) then
            if ((vPos <= SCREEN_HEIGHT + FRONT_PORCH_VERTICAL) OR (vPos > SCREEN_HEIGHT + FRONT_PORCH_VERTICAL + SYNC_HEIGHT)) then
                VSYNC <= '1';
            else
                VSYNC <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
