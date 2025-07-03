library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity countEna is
    generic(
        N : natural := 8
    );
    port(
        clk   : in std_logic;
        ena   : in std_logic;
        rst   : in std_logic;
        y     : out std_logic_vector(N-1 downto 0)
    );
end entity countEna;

architecture countEna_arq of countEna is
    signal aux : unsigned(N-1 downto 0) := (others => '0');
begin
    process(clk,rst)
    begin
        if rst = '1' then
            aux <= (others => '0');
        elsif rising_edge(clk) then
            if ena = '0' then
                aux <= aux;
            else
                aux <= aux + 1;
            end if;
        end if;
    end process;
    y <= std_logic_vector(aux);
end architecture countLoad_arq;