library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

entity mac_unit is
    PORT(
        clk : IN std_logic;
        rst : IN std_logic;
        pxl : IN integer;
        krnl : IN integer;
        outval : OUT integer
--        cntrl : IN std_logic
    );
end mac_unit;

architecture Behavioral of mac_unit is

signal storedval: integer;
signal temp: integer;
begin
    
main: process(clk,pxl,krnl)
begin
    if(rising_edge(clk)) then
        if(rst='1') then
            storedval<=0;
--        elsif(cntrl='1') then
--            outval<=storedval;
        else
            temp<=pxl*krnl;
            storedval<=storedval+temp;
            outval<=storedval;
        end if;
    end if;
end process;

end Behavioral;
