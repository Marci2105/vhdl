----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2025 20:33:53
-- Design Name: 
-- Module Name: HAUSARBEIT_Pong - Behavioral
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
use IEEE.NUMERIC_STD.ALL; -- Wird fuer unsigned/integer Konvertierungen benötigt

entity HAUSARBEIT_Pong is
    Port ( R : out STD_LOGIC_VECTOR (3 downto 0);
           B : out STD_LOGIC_VECTOR (3 downto 0);
           G : out STD_LOGIC_VECTOR (3 downto 0);
           HS : out STD_LOGIC;
           VS : out STD_LOGIC;
           -- Angenommener Systemtakt (z.B. 100 MHz auf dem FPGA Board)
           sys_clk : in STD_LOGIC
           );
end HAUSARBEIT_Pong;

architecture Behavioral of HAUSARBEIT_Pong is
    -- Signaldeklarationen (unveraendert)
    signal h_count : natural range 0 to 799 := 0;
    signal v_count : natural range 0 to 524 := 0;
    signal h_sync_s : std_logic;
    signal v_sync_s : std_logic;
    signal vga_active_s : std_logic;

    -- --- Clock Divider Signale ---
    -- Der VGA-Takt (ca. 25 MHz)
    signal vga_clk : std_logic := '0';
    -- Zaehler, um den Takt zu teilen (100 MHz / 4 = 25 MHz)
    constant CLK_DIV_MAX : integer := 2; -- Zaehlt 0, 1. Toggelt bei 1 -> Division durch 4
    signal clk_div_count : natural range 0 to CLK_DIV_MAX-1 := 0;
    
begin

-- ----------------------------
-- Clock Divider (100 MHz -> 25 MHz)
-- ----------------------------
process(sys_clk)
begin
    if rising_edge(sys_clk) then
        if clk_div_count = CLK_DIV_MAX-1 then
            vga_clk <= not vga_clk; -- Toggelt den 25 MHz Takt
            clk_div_count <= 0;
        else
            clk_div_count <= clk_div_count + 1;
        end if;
    end if;
end process;
-- 

-- ----------------------------
-- VGA-Signalerzeugung (Pixel Clock Domain)
-- ----------------------------
process(vga_clk)
begin
    -- Der gesamte VGA-Prozess laeuft jetzt auf dem geteilten Takt (vga_clk)
    if rising_edge(vga_clk) then
    
        -- --- 1. Horizontaler Zaehler (Pixel-Zaehler) ---
        if h_count < 799 then 
            h_count <= h_count + 1;
        else 
            h_count <= 0; -- Zaehler zuruecksetzen

            -- --- 2. Vertikaler Zaehler (Zeilen-Zaehler) ---
            if v_count < 524 then 
                v_count <= v_count + 1;
            else 
                v_count <= 0; -- Vertikal-Zaehler zuruecksetzen
            end if;
        end if;
        
        -- --- 3. Synchronisations-Signale und Active Area ---
        
        -- Horizontal Sync (HS) Timing
        -- HS ist aktiv (LOW) von Pixel 656 (Active Area + Front Porch) bis 751
        if h_count >= 656 and h_count < (656 + 96) then
            h_sync_s <= '0'; -- Aktiv LOW
        else
            h_sync_s <= '1';
        end if;
        
        -- Vertical Sync (VS) Timing
        -- VS ist aktiv (LOW) von Zeile 491 (Active Area + Front Porch) bis 492
        if v_count >= 491 and v_count < (491 + 2) then
            v_sync_s <= '0'; -- Aktiv LOW
        else
            v_sync_s <= '1';
        end if;
        
        -- Active Area (Wenn gezeichnet werden darf)
        if h_count < 640 and v_count < 480 then
            vga_active_s <= '1';
        else
            vga_active_s <= '0';
        end if;
        
    end if;
end process;

-- Port-Zuweisungen
HS <= h_sync_s;
VS <= v_sync_s;

-- Beispiel fuer die Farbausgabe (Schwarz im Blanking, Weiss in der Active Area)
-- Das muessten Sie spaeter fuer das Pong-Spiel anpassen!
-- Die Farbausgabe muss natuerlich ebenfalls im Taktsignal-Bereich der VGA-Logik liegen,
-- aber für dieses Beispiel reicht diese einfache Zuweisung.

R <= (others => vga_active_s);
G <= (others => vga_active_s);
B <= (others => vga_active_s);

end Behavioral;