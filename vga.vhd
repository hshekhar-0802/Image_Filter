library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga is
  Port( CLK25: in STD_LOGIC;
        pixel_data: in STD_LOGIC_VECTOR(7 downto 0);
        RST: in STD_LOGIC;
        HSYNC: out STD_LOGIC;
        VSYNC: out STD_LOGIC;
        red: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        hPo: out integer;
        vPo: out integer);
end vga;
architecture Behavioral of vga is
    constant HD: integer :=639;
    constant HFP: integer :=16;
    constant HSP: integer :=96;
    constant HBP: integer :=46;
    signal hPos: integer := 0;
    signal vPos: integer := 0;
    constant VD: integer :=479;
    constant VFP: integer :=10;
    constant VSP: integer :=2;
    constant VBP: integer :=33;
    signal videoOn: std_logic:= '0';

begin
Horizontal_position_counter: process(clk25,RST)
begin
    if(RST='1')then
        hPos<=0;
    elsif(clk25'event and clk25='1')then
        if(hPos =(HD + HFP + HSP + HBP))then
            hPos<=0;
        else
            hPos<=hPos+1;
        end if;
    end if;
    hpo <= hpos;
end process;

Vertical_position_counter: process(clk25,RST,hPos)
begin
    if(RST='1')then
        vPos<=0;
    elsif(clk25'event and clk25='1')then
        if(hPos =(HD + HFP + HSP + HBP)) then
            if(vPos =(VD + VFP + VSP + VBP))then
                vPos<=0;
            else
                vPos<=vPos+1;
            end if;
        end if;
    end if;
    vpo <= vpos;
end process;

Horizontal_Synchronisation:process(clk25,RST,hPos)
begin
    if(RST='1')then
       HSYNC<='0';
    elsif(clk25'event and clk25='1')then
        if(hPos <=(HD+HFP) OR (hPos > HD+ HFP+HSP))then
            HSYNC <='1';
        else
            HSYNC<='0';
        end if;
    end if;
end process;

Vertical_Synchronisation:process(clk25,RST,vPos)
begin
    if(RST='1')then
        VSYNC <='0';
    elsif(clk25'event and clk25='1')then
        if(vPos <=(VD+VFP) OR (vPos > VD+ VFP+VSP))then
            VSYNC <='1';
        else
            VSYNC<='0';
        end if;
    end if;
end process;


video_on:process(clk25,RST,hPos,vPos)
begin
    if(RST='1')then
        videoOn <='0';
    elsif(clk25'event and clk25='1')then
        if(hPos <=HD and vPos<=VD)then
            videoOn <='1';
        else
            videoOn <='0';
        end if;
    end if;
end process;

draw:process(clk25,hPos,vPos,videoOn,RST)
begin
    if(RST='1')then
        red<="0000";
        blue<="0000";
        green<="0000";
    elsif(clk25'event and clk25='1')then
        if(videoOn='1')then
            if((hPos>=9 and hPos <73) and (vPos>=10 and vPos<74))then
                red(0) <= pixel_data(4);
                red(1) <= pixel_data(5);
                red(2) <= pixel_data(6);
                red(3) <= pixel_data(7);
                blue(0) <= pixel_data(4);
                blue(1) <= pixel_data(5);
                blue(2) <= pixel_data(6);
                blue(3) <= pixel_data(7);
                green(0) <= pixel_data(4);
                green(1) <= pixel_data(5);
                green(2) <= pixel_data(6);
                green(3) <= pixel_data(7);
            else
                red<="0000";
                blue<="0000";
                green<="0000";
            end if;
        end if;
    end if;
end process;
end Behavioral;