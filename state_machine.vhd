library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

entity state_machine is 
Port(clk100: in std_logic;
     r: out std_logic_vector(3 downto 0):=(others=>'0');
     g: out std_logic_vector(3 downto 0):=(others=>'0');
     b: out std_logic_vector(3 downto 0):=(others=>'0');
     h_sync: out std_logic; 
     v_sync: out std_logic
     );
end state_machine;

architecture Behavioral of state_machine is
component vga is
Port( CLK25: in STD_LOGIC;
        pixel_data: in STD_LOGIC_VECTOR(7 downto 0);
        RST: in STD_LOGIC;
        HSYNC: out STD_LOGIC;
        VSYNC: out STD_LOGIC;
        red: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        hPo: out integer;
        vPo: out integer
        );
end component;
component filter_unit is
Port( clock: in std_logic; 
      output: out integer;
      done: out std_logic:='0';
      index: out integer:=0;
      start: out std_logic:='0'
      );
end component;
signal cycle: integer:=0;
signal plain: integer:=0;
signal clk50: std_logic:='0';
signal clok25: std_logic:='0';
signal calculated: std_logic:='0';
signal gradient_done: std_logic:='0';
signal gradient_idx: integer:=0;
signal data_print: std_logic_vector(7 downto 0):=(others=>'0');
signal reset: std_logic:='0';
signal h_pos: integer:=0;
signal v_pos: integer:=0;
type state_type is (nothing,calculating, normalizing, displaying);
signal state: state_type;
signal normalize_done: std_logic:='0';
type arr is array(0 to 4095) of integer;
signal finaldata: arr;
signal unnormalized_data: arr; 
signal min: integer:=70000;
signal max: integer:=-1;
signal diff: integer:=0;
signal idx: integer:=0;
signal temp: integer:=0;
signal dispidx: integer:=0;
signal flag: std_logic:='0';
--signal clk100: std_logic:='0';
begin
gradient_calculator: filter_unit
port map(
clock=>clok25,
output=>plain,
done=>gradient_done,
index=>gradient_idx,
start=>calculated
);
display: vga
port map(
clk25=>clok25,
pixel_data=>data_print,
rst=>reset,
hsync=>h_sync,
vsync=>v_sync,
red=>r,
blue=>b,
green=>g,
hpo=>h_pos,
vpo=>v_pos
);

clockdiv1: process(clk100)
begin
if(clk100'event and clk100='1') then
    clk50<= not clk50;
end if;
end process;

clockdiv2: process(clk50)
begin
if(clk50'event and clk50='1') then
    clok25<= not clok25;
end if;
end process;

state_change: process(clok25)
begin
if(rising_edge(clok25)) then
    if(gradient_done='0' and calculated='0') then
        state<=nothing;
    elsif(gradient_done='0' and calculated='1') then
        state<=calculating;
    elsif(gradient_done='1' and state=calculating) then
        state<=normalizing;
    elsif(normalize_done='1') then
        state<=displaying;
    end if;
end if;
end process;

main: process(clok25)
begin
if(rising_edge(clok25)) then
    case state is 
        when nothing=>
            data_print<=(others=>'0');
        when calculating=>
            data_print<=(others=>'0');
            unnormalized_data(gradient_idx)<=plain;
            if(min>plain) then
                min<=plain;
            end if;
            if(max<plain) then
                max<=plain;
            end if;
            diff<=max-min;
        when normalizing=>
            data_print<=(others=>'0');
            if(cycle=0) then
                temp<=unnormalized_data(idx)-min;
                cycle<=1;
            elsif(cycle=1) then
                temp<=temp*255;
                cycle<=2;
            elsif(cycle=2) then
                temp<=temp/diff;
                cycle<=3;
            elsif(cycle=6) then
                finaldata(idx)<=temp;
                if(idx=4095) then
                    normalize_done<='1';
                end if;
                idx<=idx+1;
                cycle<=7;
            elsif(cycle=7) then
                cycle<=0;
            else
                cycle<=cycle+1;
            end if;
         when displaying=>
            if(flag='0') then
                reset<='1';
                flag<='1';
            else
                reset<='0';
                data_print<=std_logic_vector(to_unsigned(finaldata(dispidx),8));
                if(h_pos >=9 and h_pos<73 and v_pos >=10 and v_pos<74) then
                    dispidx<=(dispidx+1) mod 4096;
                end if;
            end if;
    end case;
end if;
end process;

--test: process
--begin
--clk100<='0';
--wait for 10 ns;
--clk100<='1';
--wait for 10 ns;
--end process;
end Behavioral;