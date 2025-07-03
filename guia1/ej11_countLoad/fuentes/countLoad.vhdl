library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity countLoad is
    generic(
        N : natural := 8
    );
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        load  : in std_logic;
        value : in std_logic_vector(N-1 downto 0);
        y     : out std_logic_vector(N-1 downto 0)
    );
end entity countLoad;

architecture countLoad_arq of countLoad is
    signal aux : unsigned(N-1 downto 0);
begin
    process(clk,rst)
    begin
        if rst = '1' then
            aux <= (others => '0');
        elsif rising_edge(clk)  then
            if load = '1' then
                aux <= unsigned(value);
            else
                aux <= aux + 1;
            end if;
        end if;
    end process;
    y <= std_logic_vector(aux);
end architecture countLoad_arq;