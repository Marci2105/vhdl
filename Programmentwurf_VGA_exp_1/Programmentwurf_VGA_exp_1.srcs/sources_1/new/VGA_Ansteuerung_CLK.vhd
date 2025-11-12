-- Engineer: 
-- 
-- Create Date: 12.11.2025 10:11:35
-- Design Name: 
-- Module Name: VGA_Ansteuerung_CLK - Behavioral
-- Project Name: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;


entity VGA_Ansteuerung_CLK is
    Port ( CLK_100MHz : in STD_LOGIC;
           RST : in STD_LOGIC;
           Button_l_up: in STD_LOGIC;
           Button_l_down: in STD_LOGIC;
           HSYNC : out STD_LOGIC;
           VSYNC : out STD_LOGIC;
           RED : out STD_LOGIC_VECTOR (3 downto 0);
           GREEN : out STD_LOGIC_VECTOR (3 downto 0);
           BLUE : out STD_LOGIC_VECTOR (3 downto 0));
end VGA_Ansteuerung_CLK;



architecture Behavioral of VGA_Ansteuerung_CLK is
    signal clk25: std_logic := '0';
    signal clk50: std_logic := '0';
    signal hPos: integer := 0;
    signal vPos: integer := 0;
    signal videoON: std_logic := '0';
    signal x_offset : integer range 0 to 419 := 0;  -- horizontale Verschiebung
    signal slow_cnt : integer range 0 to 499_999 := 0;  -- Teiler für langsame Bewegung

    
    constant Active_Pixels_Horizontal :integer:=    639;
    constant Front_Porch_Horizontal:integer:=       16;
    constant Sync_Width_Horizontal:integer:=        96;
    constant Back_Porch_Horizontal :integer:=       48;
    
    constant Active_Lines_Vertical :integer:=       479;
    constant Front_Porch_Vertical :integer:=        10;
    constant Sync_Width_Vertical :integer:=         2;
    constant Back_Porch_Vertical :integer:=         33;
   
begin


clk_divider_50:process(CLK_100MHz)
begin
    if (CLK_100MHz'event and CLK_100MHz = '1') then
        clk50 <= not clk50;
    end if;
end process;

clk_divider_25:process(clk50)
begin
    if (clk50'event and clk50 = '1') then
        clk25 <= not clk25;
    end if;
end process;

Hoizontal_Position_Counter: process(clk25, RST)
begin
    if(RST= '1') then
        hPos <= 0;
    elsif (clk25'event and clk25 = '1') then
        if(hPos = (Active_Pixels_Horizontal + Front_Porch_Horizontal + Sync_Width_Horizontal + Back_Porch_Horizontal)) then
            hPos <= 0;
        else
            hPos <= hPos +1;
        end if;    
    end if;    
end Process;

Vertical_Position_Counter: process(clk25, RST)
begin
    if(RST= '1') then
        vPos <= 0;
    elsif (clk25'event and clk25 = '1') then
        if(hPos = (Active_Pixels_Horizontal + Front_Porch_Horizontal + Sync_Width_Horizontal + Back_Porch_Horizontal)) then
            if(vPos = (Active_Lines_Vertical + Front_Porch_Vertical + Sync_Width_Vertical + Back_Porch_Vertical)) then
                vPos <= 0;
            else
                vPos <= vPos +1;
            end if;  
        end if;  
    end if;    
end Process;

Horizontal_Synchronisatio:process(clk25, RST, hPos)
begin
  if(RST= '1') then
    HSYNC <= '0';
  elsif (clk25'event and clk25 = '1') then
      if ((hPos <= (Active_Pixels_Horizontal + Front_Porch_Horizontal)) OR hPos > (Active_Pixels_Horizontal + Front_Porch_Horizontal + Sync_Width_Horizontal)) then
        HSYNC <= '1';
      else
        HSYNC <= '0';
      end if;    
  end if;
end Process;

Vertical_Synchronisatio:process(clk25, RST, vPos)
begin
  if(RST= '1') then
    VSYNC <= '0';
  elsif (clk25'event and clk25 = '1') then
      if ((vPos <= (Active_Lines_Vertical + Front_Porch_Vertical)) OR vPos > (Active_Lines_Vertical + Front_Porch_Vertical + Sync_Width_Vertical)) then
        VSYNC <= '1';
      else
        VSYNC <= '0';
      end if;    
  end if;
end Process;

vidON:process(clk25, RST, hPos, vPos)
begin
    if(RST= '1') then
        videoON <= '0';
    elsif (clk25'event and clk25 = '1') then
        if((hPos <= Active_Pixels_Horizontal) AND (vPos <= Active_Lines_Vertical)) then
            videoOn <= '1';
        else
            videoOn <= '0';
        end if;  
    end if;
end Process;

move_bar : process(clk25, RST)
begin
    if RST = '1' then
            slow_cnt <= 0;
            x_offset <= 0;
    elsif rising_edge(clk25) then
                if( Button_l_up = '1') then
                    if slow_cnt = 50_000 then  
                        slow_cnt <= 0;
                        if x_offset < 419 then
                            x_offset <= x_offset + 1;
                        else
                            x_offset <= 419;
                        end if;
                    else
                        slow_cnt <= slow_cnt + 1;
                    end if;
                elsif( Button_l_down = '1') then
                    if slow_cnt = 50_000 then  
                        slow_cnt <= 0;
                        if x_offset > 0 then
                            x_offset <= x_offset - 1;
                        else
                            x_offset <= 0;
                        end if;
                    else
                        slow_cnt <= slow_cnt + 1;
                    end if;
                end if;
     end if;       
end process;



draw:process(clk25, RST,  hPos, vPos, videoOn, x_offset)
begin    
        if(RST= '1') then
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
         elsif (clk25'event and clk25 = '1') then
            if(videoOn= '1') then
                if(((hPos>=(10))and (hPos <=(20))) and ((vPos>=x_offset)and (vPos <=75 + x_offset)))then
                    RED <= "1111";
                    GREEN <= "1111";
                    BLUE <= "1111";
                else
                    RED <= "0000";
                    GREEN <= "0000";
                    BLUE <= "0000";
                end if;
                
            else
                RED <= "0000";
                GREEN <= "0000";
                BLUE <= "0000";
            end if;
         end if;  

end Process;
end Behavioral;
