library IEEE;
use IEEE.std_logic_1164.all;

entity d_ff_set_sync is
    port (
        clk   : in  std_logic;
        set   : in  std_logic;
        d     : in  std_logic;
        q     : out std_logic
    );
end entity;

architecture behavioral of d_ff_set_sync is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if set = '1' then
                q <= '1';
            else
                q <= d;
            end if;
        end if;
    end process;
end architecture;