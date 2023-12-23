library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

entity filter_unit is
Port( clock: in std_logic; 
      output: out integer;
      start: out std_logic:='0';
      done: out std_logic:='0';
      index: out integer:=0
      );
end filter_unit;

architecture Behavioral of filter_unit is
component mac_unit is 
PORT(
        clk : IN std_logic;
        rst : IN std_logic;
        pxl : in integer;
        krnl : in integer;
        outval :out integer
    );
end component;
component dist_mem_gen_0 is 
Port( a: in std_logic_vector(11 downto 0);
      clk: in std_logic;
      spo: out std_logic_vector(7 downto 0)
      );
end component;
component dist_mem_gen_1 is 
Port( a: in std_logic_vector(3 downto 0);
      clk: in std_logic;
      spo: out std_logic_vector(7 downto 0)
      );
end component;
--signal clock: std_logic:='0';
signal reset: std_logic:='0';
signal romout: std_logic_vector(7 downto 0);
signal kernelout: std_logic_vector( 7 downto 0);
signal romadd: std_logic_vector(11 downto 0);
signal kerneladd: std_logic_vector(3 downto 0);
signal gradient: integer;
signal cycle: integer:=0;
signal read_coe_done: std_logic:='0'; 
signal read_kernel_done: std_logic:='0';
signal calculate_done: std_logic:='0';
signal sent: std_logic:='0';
type memory is array(0 to 4095) of integer;
signal rawdata: memory;
type arr is array(0 to 4095) of integer;
signal coe: arr;
type ar is array(0 to 8) of integer;
signal krnl: ar;
signal romindex: integer:=0;
signal kernelindex: integer:=0;
signal x: integer:=0;
signal y: integer:=0;
signal macpxl: integer;
signal mackrnl: integer;
signal turn1: integer:=0;
signal turn2: integer:=0;
signal turn3: integer:=0;
signal x_pos: integer:=0;
signal y_pos: integer:=0;
signal idx: integer:=-1;

begin
multiplier: mac_unit
Port map(
clk=>clock,
rst=>reset,
pxl=>macpxl,
krnl=>mackrnl,
outval=>gradient
);
coefile: dist_mem_gen_0
Port map(
a=>romadd,
clk=>clock,
spo=>romout
);
kernel: dist_mem_gen_1
Port map(
a=>kerneladd,
clk=>clock,
spo=>kernelout
);

read_coe: process(clock)
begin
if(rising_edge(clock)) then
    if(read_coe_done='0') then
        if(turn1=0) then
            romadd<=std_logic_vector(to_unsigned(romindex,12));
            turn1<=1;
        elsif(turn1=3) then
            coe(romindex)<=to_integer(unsigned(romout));
            turn1<=0;
            if(romindex=4095) then
                read_coe_done<='1';
            end if;
            romindex<=romindex+1;
        else
            turn1<=turn1+1;
        end if;
    end if;
end if;
end process;

read_kernel: process(clock)
begin
if(rising_edge(clock)) then
    if(read_kernel_done='0') then
        if(turn2=0) then
            kerneladd<=std_logic_vector(to_unsigned(kernelindex,4));
            turn2<=1;
        elsif(turn2=3) then
            krnl(kernelindex)<=to_integer(signed(kernelout));
            turn2<=0;
            if(kernelindex=8) then
                read_kernel_done<='1';
            end if;
            kernelindex<=kernelindex+1;
        else
            turn2<=turn2+1;
        end if;
    end if;
end if;
end process;

calculate_gradient: process(clock)
begin
if(rising_edge(clock)) then
    if(read_kernel_done='1' and read_coe_done='1' and calculate_done='0') then
        if(turn3=0) then
            x<=x_pos-1;
            y<=y_pos-1;
            turn3<=1;
        elsif(turn3=1) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(0);
            else
                macpxl<=0;
                mackrnl<=krnl(0);
            end if;
            x<=x_pos;
            y<=y_pos-1;
            turn3<=2;
        elsif(turn3=2) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(1);
            else
                macpxl<=0;
                mackrnl<=krnl(1);
            end if;
            x<=x_pos+1;
            y<=y_pos-1;
            turn3<=3;
        elsif(turn3=3) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(2);
            else
                macpxl<=0;
                mackrnl<=krnl(2);
            end if;
            x<=x_pos-1;
            y<=y_pos;
            turn3<=4;
        elsif(turn3=4) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(3);
            else
                macpxl<=0;
                mackrnl<=krnl(3);
            end if;
            x<=x_pos;
            y<=y_pos;
            turn3<=5;
        elsif(turn3=5) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(4);
            else
                macpxl<=0;
                mackrnl<=krnl(4);
            end if;
            x<=x_pos+1;
            y<=y_pos;
            turn3<=6;
        elsif(turn3=6) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(5);
            else
                macpxl<=0;
                mackrnl<=krnl(5);
            end if;
            x<=x_pos-1;
            y<=y_pos+1;
            turn3<=7;
        elsif(turn3=7) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(6);
            else
                macpxl<=0;
                mackrnl<=krnl(6);
            end if;
            x<=x_pos;
            y<=y_pos+1;
            turn3<=8;
        elsif(turn3=8) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(7);
            else
                macpxl<=0;
                mackrnl<=krnl(7);
            end if;
            x<=x_pos+1;
            y<=y_pos+1;
            turn3<=9;
        elsif(turn3=9) then
            if(x>=0 and x<=63 and y>=0 and y<=63) then
                macpxl<=coe(64*y+x);
                mackrnl<=krnl(8);
            else
                macpxl<=0;
                mackrnl<=krnl(8);
            end if;
            x<=0;
            y<=0;
            turn3<=10;
        elsif(turn3=12) then
            reset<='1';
            turn3<=13;
        elsif(turn3=13) then
            rawdata(64*y_pos+x_pos)<=gradient;
            turn3<=0;
            reset<='0';
            if(x_pos<63 and y_pos<=63) then
                x_pos<=x_pos+1;
            elsif(x_pos=63 and y_pos<63) then
                x_pos<=0;
                y_pos<=y_pos+1;
            elsif(x_pos=63 and y_pos=63) then
                calculate_done<='1';
            end if;
        else
            turn3<=turn3+1;
        end if;
    end if;
end if;
end process;

send_process:process(clock)
begin
if(rising_edge(clock)) then
    if(calculate_done='1' and sent='0') then
        start<='1';
        if(idx>=0) then 
            output<=rawdata(idx);
            index<=idx;
            if(idx=4095) then
                sent<='1';
                done<='1';
            end if;
        end if;
        idx<=idx+1;
    end if;
end if;
end process;


--clk_pro: process
--begin
--clock<='0';
--wait for 10 ns;
--clock<='1';
--wait for 10 ns;
--end process;

end Behavioral;