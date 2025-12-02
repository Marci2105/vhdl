library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Externe Anschlüsse an das System
entity pong_top is
    Port ( btn : in STD_LOGIC_VECTOR (3 downto 0);
           CLK100MHZ : in STD_LOGIC;
           CLK12MHZ : in STD_LOGIC;
           RESET: in STD_LOGIC;
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
        CLK_25_175MHz : in std_logic;
        screen_refresh : in std_logic;
        Game_Reset: in STD_LOGIC;
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
        Score_Upt : in std_logic_vector (1 downto 0);    -- Update des Scores als Vektor
        CLK_25_175MHz : in STD_LOGIC;
        Game_Actv : in std_logic;                         -- Angabe, ob Spiel läuft
        Btn_Press : in std_logic;  
        screen_refreshed : in STD_LOGIC;                      -- Buttoneingabe zum Menü wechseln
        RESET_Game : in STD_LOGIC;
        Curr_Score_1 : out STD_LOGIC_VECTOR (6 downto 0);
        Curr_Score_2 : out STD_LOGIC_VECTOR (6 downto 0);    -- Darstellung der Ziffern erstmal im sieben Segment-Format
        Balls_left: out STD_LOGIC_VECTOR (1 downto 0);
        Winning_player: out std_logic;
        MenuSlct : out std_logic_vector (1 downto 0));  -- Auswahl der Darstellung
        
end component;

component Graphics
    port(
        CLK_25_175MHz : in std_logic;
        Curr_Score_Player_1 : STD_LOGIC_VECTOR (6 downto 0);
        Curr_Score_Player_2 : STD_LOGIC_VECTOR (6 downto 0);
        Balls_left_Gra: out STD_LOGIC_VECTOR (1 downto 0);
        MenuSlct : in std_logic_vector (1 downto 0);
        Ball_x : in integer;
        Ball_y : in integer;
        Plate_1 : in integer;
        Plate_2 : in integer;
        Which_player_won : in STD_LOGIC;
        refresh_rate : out std_logic;
        HSYNC : out std_logic;
        VSYNC : out std_logic;
        RED : out STD_LOGIC_VECTOR (3 downto 0);
        GREEN : out STD_LOGIC_VECTOR (3 downto 0);
        BLUE : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component clk_wiz_1
    port(
        CLK_IN1 : in std_logic;
        CLK_OUT1 : out std_logic);
end component;

-- Deklaration der innenliegenden Signale zum Verbinden der Module
signal internal_25_175MHz : std_logic;
signal internal_scoreUpt : std_logic_vector (1 downto 0);
signal internal_score_1 : STD_LOGIC_VECTOR (6 downto 0);
signal internal_score_2 : STD_LOGIC_VECTOR (6 downto 0);
signal internal_game_active : std_logic;
signal internal_button_pressed : std_logic;
signal internal_menu_select : std_logic_vector (1 downto 0);
signal internal_vsync : std_logic;  -- Bildwiederholungsrate
signal internal_winning_player : std_logic;
signal internal_ball_x : integer;
signal internal_ball_y : integer;
signal internal_plate1 : integer;
signal internal_plate2 : integer;
signal internal_Current_State: std_logic_vector (1 downto 0);
signal internal_Balls_left: std_logic_vector (1 downto 0);

begin
   -- Instanziierung und Verdrahtung der Physik
   U1_Physics : Physics
   port map(
       BTNs => btn,
       CLK_25_175MHz => internal_25_175MHz,
       screen_refresh => internal_vsync,
       ScoreUpt => internal_scoreUpt,
       Game_Reset =>RESET,
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
       Which_player_won => internal_winning_player,
       CLK_25_175MHz => internal_25_175MHz,
       Curr_Score_Player_1 => internal_score_1,
       Curr_Score_Player_2 => internal_score_2,
       Balls_left_Gra =>internal_Balls_left,
       MenuSlct => internal_Current_State,
       refresh_rate => internal_vsync,
       VSYNC => VSYNC,
       HSYNC => HSYNC,
       RED => RED,
       GREEN => GREEN,
       BLUE => BLUE);
   
   -- Instanziierung und Verdrahtung des Scoreboards
   U3_Scoreboard : Scoreboard
   port map(
       Score_Upt => internal_scoreUpt,
       CLK_25_175MHz => internal_25_175MHz,
       Curr_Score_1 => internal_score_1,
       Curr_Score_2 => internal_score_2,
       screen_refreshed =>internal_vsync,
       RESET_Game => RESET,
       Game_Actv => internal_game_active,
       Balls_left => internal_Balls_left,
       MenuSlct=> internal_Current_State,
       Winning_player => internal_winning_player,
       Btn_Press => internal_button_pressed);
       
   
   -- Instanziierung und Verdratung des clk_wiz
   U4_CLK_WIZ_0 : clk_wiz_1
   port map(
       CLK_IN1 => CLK100MHZ,
       CLK_OUT1 => internal_25_175MHz);
   
end Structural;
