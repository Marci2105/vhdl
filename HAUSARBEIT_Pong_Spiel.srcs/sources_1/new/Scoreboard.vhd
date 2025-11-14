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
    Port ( ScoreUpt : in STD_LOGIC_VECTOR (1 downto 0);
           GameActv : in STD_LOGIC;
           BtnPress : in STD_LOGIC;
           Score : out STD_LOGIC_VECTOR (13 downto 0);
           MenuSlct : out STD_LOGIC_VECTOR (1 downto 0));
end Scoreboard;

architecture Behavioral of Scoreboard is

begin


end Behavioral;
