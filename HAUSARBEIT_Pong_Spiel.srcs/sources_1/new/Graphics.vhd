library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Graphics is
    Port ( Ball_x : in integer;
           Ball_y : in integer;
           Plate_1 : in integer;
           Plate_2 : in integer;
           CLK_25_175MHz : in STD_LOGIC;
           Which_player_won : in STD_LOGIC;
           Curr_Score_Player_1 : in STD_LOGIC_VECTOR (6 downto 0);
           Curr_Score_Player_2 : in STD_LOGIC_VECTOR (6 downto 0);
           Balls_left_Gra: in STD_LOGIC_VECTOR (1 downto 0);
           MenuSlct : in STD_LOGIC_VECTOR (1 downto 0);
           refresh_rate : out STD_LOGIC;
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
    constant RADIUS : integer := 2; 
    constant VERSCHIEBUNG_SEVEN_SEG : integer := 320; 

   -- welcome image
    constant IMG_WIDTH : integer := 160;
    constant IMG_HEIGHT : integer := 120;
    constant IMG_STRETCH : integer := 4;

    -- Signale für die Grafikdarstellung
    signal hPos : integer := 0;
    signal vPos : integer := 0;
    signal videoOn: std_logic :='0';
    signal clk25: std_logic := '0';
    signal clk50: std_logic := '0';
    signal red_i   : std_logic_vector(3 downto 0) := (others => '0');
    signal green_i : std_logic_vector(3 downto 0) := (others => '0');
    signal blue_i  : std_logic_vector(3 downto 0) := (others => '0');
    signal signal_vsync : std_logic := '0';

    -- image signals
    signal rom_addr : std_logic_vector(14 downto 0) := (others => '0');
    signal rom_data : std_logic_vector(11 downto 0) := (others => '0'); 
    
    signal rom_addr_player_1 : std_logic_vector(14 downto 0) := (others => '0');
    signal rom_data_player_1 : std_logic_vector(11 downto 0) := (others => '0'); 
    
    signal rom_addr_player_2 : std_logic_vector(14 downto 0) := (others => '0');
    signal rom_data_player_2 : std_logic_vector(11 downto 0) := (others => '0'); 

    COMPONENT blk_mem_gen_0 
        PORT(
        clka : IN std_logic;
        addra : IN std_logic_vector(14 downto 0);
        douta : OUT std_logic_vector(11 downto 0)
        );
    end COMPONENT;
    
    COMPONENT player_1_won_img
        PORT(
        clka : IN std_logic;
        addra : IN std_logic_vector(14 downto 0);
        douta : OUT std_logic_vector(11 downto 0)
        );
    end COMPONENT;
    
    COMPONENT player_2_won_img
        PORT(
        clka : IN std_logic;
        addra : IN std_logic_vector(14 downto 0);
        douta : OUT std_logic_vector(11 downto 0)
        );
    end COMPONENT;

    
begin

    image_rom : blk_mem_gen_0
    PORT MAP (
        clka => CLK_25_175MHz,
        addra => rom_addr,
        douta => rom_data
    );
    
    image_player_1 : player_1_won_img
    PORT MAP (
        clka => CLK_25_175MHz,
        addra => rom_addr_player_1,
        douta => rom_data_player_1
    );
    
    image_player_2 : player_2_won_img
    PORT MAP (
        clka => CLK_25_175MHz,
        addra => rom_addr_player_2,
        douta => rom_data_player_2
    );

-- Alternativer Anslatz statt Clock Wizard
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
    Horizontal_Position_Counter : process(CLK_25_175MHz)
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
                signal_vsync <= '1';
            else
                signal_vsync <= '0';
            end if;
        end if;
        refresh_rate <= signal_vsync;
        VSYNC <= signal_vsync;
    end process;

    Address_Gen : process(hPos, vPos)
    begin
        if (hPos < SCREEN_WIDTH) and (vPos < SCREEN_HEIGHT) then
            rom_addr <= std_logic_vector(to_unsigned(
                (vPos / 4) * 160 + (hPos / 4), 
                15)); 
        else
            rom_addr <= (others => '0');
        end if;
    end process;
    
    Address_Gen_Player_1 : process(hPos, vPos)
    begin
        if (hPos < SCREEN_WIDTH) and (vPos < SCREEN_HEIGHT) then
            rom_addr_player_1 <= std_logic_vector(to_unsigned(
                (vPos / 4) * 160 + (hPos / 4), 
                15)); 
        else
            rom_addr_player_1 <= (others => '0');
        end if;
    end process;
    
    Address_Gen_Player_2 : process(hPos, vPos)
    begin
        if (hPos < SCREEN_WIDTH) and (vPos < SCREEN_HEIGHT) then
            rom_addr_player_2 <= std_logic_vector(to_unsigned(
                (vPos / 4) * 160 + (hPos / 4), 
                15)); 
        else
            rom_addr_player_2 <= (others => '0');
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

    
   draw:process(CLK_25_175MHz, MenuSlct)
    begin    
             if (CLK_25_175MHz'event and CLK_25_175MHz = '1') then
               if videoOn = '1' then

                   -- Darstellung des Welcom
                   if MenuSlct = "00" then
                        red_i   <= rom_data(11 downto 8);
                        green_i <= rom_data(7 downto 4);
                        blue_i  <= rom_data(3 downto 0);

                    -- Darstellung des Spiels
                    elsif MenuSlct = "10" then
                        -- Linkes Paddle
                        if (hPos >= 10 and hPos <= 20) and 
                           (vPos >= Plate_1 and vPos <= Plate_1 + PLATE_HEIGHT) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";
                    
                        -- Rechtes Paddle
                        elsif (hPos >= SCREEN_WIDTH - 20 and hPos <= SCREEN_WIDTH - 10) and
                              (vPos >= Plate_2 and vPos <= Plate_2 + PLATE_HEIGHT) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";
                            
                        -- Ball
                        elsif ((hPos >= (Ball_x - RADIUS)) and (hPos <= (Ball_x + RADIUS)) and
                              (vPos >= (Ball_y - RADIUS) and vPos <= (Ball_y + RADIUS))) then
                            red_i <= "1111";
                            green_i <= "1111";
                            blue_i <= "1111";    
                        else
                            red_i <= "0000";
                            green_i <= "0000";
                            blue_i <= "0000";
                        end if;
                        
                        --linke Sieben Segment Anzeige
                        if Curr_Score_Player_1(6) = '1' then 
                            if (hPos >= 140 and hPos <= 180) and 
                                   (vPos >= 10 and vPos <= 15) then
                                    red_i <= "1111";
                                    green_i <= "1111";
                                    blue_i <= "1111";
                            end if;
                           end if;
                           if Curr_Score_Player_1(5) = '1' then 
                                 if (hPos >= 175 and hPos <= 180) and 
                                           (vPos >= 15 and vPos <= 55) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_1(4) = '1' then 
                                if (hPos >= 175 and hPos <= 180) and 
                                           (vPos >= 55 and vPos <= 95) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_1(3) = '1' then 
                                if (hPos >= 140 and hPos <= 180) and 
                                               (vPos >= 95 and vPos <= 100) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            if Curr_Score_Player_1(2) = '1' then 
                                if (hPos >= 140 and hPos <= 145) and 
                                           (vPos >= 55 and vPos <= 95) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_1(1) = '1' then 
                                if (hPos >= 140 and hPos <= 145) and 
                                   (vPos >= 15 and vPos <= 55) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            if Curr_Score_Player_1(0) = '1' then 
                                if (hPos >= 140 and hPos <= 180) and 
                                   (vPos >= 55 and vPos <= 60) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            
                            --rechte Sieben Segment Anzeige
                            if Curr_Score_Player_2(6) = '1' then 
                                if (hPos >= 140 + VERSCHIEBUNG_SEVEN_SEG and hPos <= 180+ VERSCHIEBUNG_SEVEN_SEG) and 
                                       (vPos >= 10 and vPos <= 15) then
                                        red_i <= "1111";
                                        green_i <= "1111";
                                        blue_i <= "1111";
                                end if;
                           end if;
                           if Curr_Score_Player_2(5) = '1' then 
                                 if (hPos >= 175+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 180+ VERSCHIEBUNG_SEVEN_SEG) and 
                                           (vPos >= 15 and vPos <= 55) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_2(4) = '1' then 
                                if (hPos >= 175+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 180+ VERSCHIEBUNG_SEVEN_SEG) and 
                                           (vPos >= 55 and vPos <= 95) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_2(3) = '1' then 
                                if (hPos >= 140+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 180+ VERSCHIEBUNG_SEVEN_SEG) and 
                                               (vPos >= 95 and vPos <= 100) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            if Curr_Score_Player_2(2) = '1' then 
                                if (hPos >= 140+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 145+ VERSCHIEBUNG_SEVEN_SEG) and 
                                           (vPos >= 55 and vPos <= 95) then
                                            red_i <= "1111";
                                            green_i <= "1111";
                                            blue_i <= "1111";
                                    end if;
                            end if;
                            if Curr_Score_Player_2(1) = '1' then 
                                if (hPos >= 140+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 145+ VERSCHIEBUNG_SEVEN_SEG) and 
                                   (vPos >= 15 and vPos <= 55) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            if Curr_Score_Player_2(0) = '1' then 
                                if (hPos >= 140+ VERSCHIEBUNG_SEVEN_SEG and hPos <= 180+ VERSCHIEBUNG_SEVEN_SEG) and 
                                   (vPos >= 55 and vPos <= 60) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                        end if;
                            end if;
                            
                            -- Strichliste für übrige Bälle
                            if Balls_left_Gra(1)= '1' then 
                                if (hPos >= 317 and hPos <= 322) and 
                                   (vPos >= 10 and vPos <= 50) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                elsif (hPos >= 307 and hPos <= 312) and 
                                   (vPos >= 10 and vPos <= 50) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                end if;
                            end if;
                            if Balls_left_Gra(0)= '1' then  
                                if (hPos >= 327 and hPos <= 332) and 
                                   (vPos >= 10 and vPos <= 50) then
                                                red_i <= "1111";
                                                green_i <= "1111";
                                                blue_i <= "1111";
                                end if;
                            end if;

                    -- Darstellung des siegenden Spielers
                    elsif MenuSlct = "11" then
                        if Which_player_won = '1' then
                            red_i   <= rom_data_player_1(11 downto 8);
                            green_i <= rom_data_player_1(7 downto 4);
                            blue_i  <= rom_data_player_1(3 downto 0);
                        
                        elsif Which_player_won ='0' then
                            red_i   <= rom_data_player_2(11 downto 8);
                            green_i <= rom_data_player_2(7 downto 4);
                            blue_i  <= rom_data_player_2(3 downto 0);

                        end if;
                    end if;
                end if;
             end if;  
    end Process;
   
RED <= red_i;
GREEN <= green_i;
BLUE <= blue_i;   
end Behavioral;
