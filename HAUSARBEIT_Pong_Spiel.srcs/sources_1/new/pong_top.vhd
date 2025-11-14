----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 20:04:19
-- Design Name: 
-- Module Name: pong_top - Structural
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

-- Externe Anschlüsse an das System
entity pong_top is
    Port ( btn : in STD_LOGIC_VECTOR (3 downto 0);
           CLK100MHZ : in STD_LOGIC;
           CLK12MHZ : in STD_LOGIC;
           HSYNC : out STD_LOGIC;
           VSYNC : out STD_LOGIC;
           RED : out STD_LOGIC_VECTOR (3 downto 0);
           GREEN : out STD_LOGIC_VECTOR (3 downto 0);
           BLUE : out STD_LOGIC_VECTOR (3 downto 0));
end pong_top;

architecture Structural of pong_top is

-- Deklaration der Komponenten
component Physics
    port(
        BTNs : in std_logic_vector (3 downto 0);
        CLK_25_125MHz : in std_logic;
        ScoreUpt : out std_logic_vector (1 downto 0);
        GameActv : out std_logic;
        BtnPress : out std_logic;
        Ball_x : out integer;
        Ball_y : out integer;
        Plate_1: out integer;
        Plate_2: out integer);
end component;

component Scoreboard
    port(
        ScoreUpt : in std_logic_vector (1 downto 0);    -- Update des Scores als Vektor
        GameActv : in std_logic;                         -- Angabe, ob Spiel läuft
        BtnPress : in std_logic;                        -- Buttoneingabe zum Menü wechseln
        Score : out std_logic_vector (13 downto 0);    -- Darstellung der Ziffern erstmal im sieben Segment-Format
        MenuSlct : out std_logic_vector (1 downto 0));  -- Auswahl der Darstellung
end component;

component Graphics
    port(
        CLK_25_125MHz : in std_logic;
        Score : in std_logic_vector (13 downto 0);
        MenuSlct : in std_logic_vector (1 downto 0);
        Ball_x : in integer;
        Ball_y : in integer;
        Plate_1 : in integer;
        Plate_2 : in integer;
        HSYNC : out std_logic;
        VSYNC : out std_logic;
        RED : out STD_LOGIC_VECTOR (3 downto 0);
        GREEN : out STD_LOGIC_VECTOR (3 downto 0);
        BLUE : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component clk_wiz_0
    port(
    CLK_IN1 : in std_logic;
    CLK_IN2 : in std_logic;
    CLK_OUT1 : out std_logic);
end component;

-- Deklaration der innenliegenden Signale zum Verbinden der Module
signal internal_25_125MHz : std_logic;
signal internal_scoreUpt : std_logic_vector (1 downto 0);
signal internal_score : std_logic_vector (13 downto 0);
signal internal_game_active : std_logic;
signal internal_button_pressed : std_logic;
signal internal_menu_select : std_logic_vector (1 downto 0);
signal internal_ball_x : integer;
signal internal_ball_y : integer;
signal internal_plate1 : integer;
signal internal_plate2 : integer;

begin
   -- Instanziierung und Verdrahtung der Physik
   U1_Physics : Physics
   port map(
       BTNs => btn,
       CLK_25_125MHz => internal_25_125MHz,
       ScoreUpt => internal_scoreUpt,
       GameActv => internal_game_active,
       BtnPress => internal_button_pressed,
       Ball_x => internal_ball_x,
       Ball_y => internal_ball_y,
       Plate_1 => internal_plate1,
       Plate_2 => internal_plate2);
   
   -- Instanziierung und Verdrahtung der Grafik
   U2_Graphics : Graphics
   port map(
       Ball_x => internal_ball_x,
       Ball_y => internal_ball_y,
       Plate_1 => internal_plate1,
       Plate_2 => internal_plate2,
       CLK_25_125MHz => internal_25_125MHz,
       Score => internal_score,
       MenuSlct => internal_menu_select,
       VSYNC => VSYNC,
       HSYNC => HSYNC,
       RED => RED,
       GREEN => GREEN,
       BLUE => BLUE);
   
   -- Instanziierung und Verdrahtung des Scoreboards
   U3_Scoreboard : Scoreboard
   port map(
       ScoreUpt => internal_scoreUpt,
       Score => internal_score,
       GameActv => internal_game_active,
       BtnPress => internal_button_pressed);
   
   -- Instanziierung und Verdratung der clk_wiz
   U4_CLK_WIZ_0 : clk_wiz_0
   port map(
   CLK_IN1 => CLK100MHZ,
   CLK_IN2 => CLK12MHZ,
   CLK_OUT1 => internal_25_125MHz);
   
end Structural;
