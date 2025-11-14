library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_counter is
end tb_counter;

architecture Behavioral of tb_counter is

    -- Deklaration der zu testenden Komponente (UUT)
    component HAUSARBEIT_Pong
        Port ( R       : out STD_LOGIC_VECTOR (3 downto 0);
               B       : out STD_LOGIC_VECTOR (3 downto 0);
               G       : out STD_LOGIC_VECTOR (3 downto 0);
               HS      : out STD_LOGIC;
               VS      : out STD_LOGIC;
               sys_clk : in STD_LOGIC
             );
    end component;

    -- Signale fuer die UUT-Ports
    signal sys_clk_s : std_logic := '0'; -- Hier verwende ich _s, um Verwechslung zu vermeiden
    signal R_s       : std_logic_vector(3 downto 0);
    signal B_s       : std_logic_vector(3 downto 0);
    signal G_s       : std_logic_vector(3 downto 0);
    signal HS_s      : std_logic;
    signal VS_s      : std_logic;

    -- Takt-Konstante (100 MHz -> 10 ns Periode)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanziierung des Moduls (UUT)
    uut: HAUSARBEIT_Pong 
        port map (
            R       => R_s,
            B       => B_s,
            G       => G_s,
            HS      => HS_s,
            VS      => VS_s,
            sys_clk => sys_clk_s -- Verbindung zum generierten Takt
        );

    -- ----------------------------------------------------
    -- Taktgenerierungs-Prozess (100 MHz)
    -- ----------------------------------------------------
    clk_process : process
    begin
        loop
            sys_clk_s <= '0';
            wait for CLK_PERIOD / 2; -- 5 ns
            sys_clk_s <= '1';
            wait for CLK_PERIOD / 2; -- 5 ns
        end loop;
    end process;

    -- ----------------------------------------------------
    -- Stimulus-Prozess
    -- ----------------------------------------------------
    stim_proc: process
    begin        
        -- Warten Sie 50 ms, um mehrere Frames zu beobachten
        wait for 50 ms; 
        
        wait; -- Simulation beenden
    end process;

end Behavioral;