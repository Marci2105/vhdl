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
           CLK_25_125MHz : in STD_LOGIC;
           clock_enable : in STD_LOGIC;
           ScoreUpt : out STD_LOGIC_VECTOR (1 downto 0);
           BtnPress : out STD_LOGIC;
           GameActv : out STD_LOGIC;
           Ball_x : out integer;
           Ball_y : out integer;
           Plate_1 : out integer;
           Plate_2 : out integer);
end Physics;

architecture Behavioral of Physics is

    -- Signale für die weitere Verarbeitung
    signal ball_mvmt_vector : unsigned (1 downto 0) := (others => '0');
    --signal ball_velo_vector : unsigned (3 downto 0);
    
    -- Konstanten für die weitere Berechnung
    constant SCREEN_HEIGHT : integer := 480;
    constant SCREEN_WIDTH : integer := 640;
    constant PLATE_HEIGHT : integer := 20;
    constant PLATE_WIDTH : integer := 4;

begin
    -- Kollisionskontrolle
    
end Behavioral;
