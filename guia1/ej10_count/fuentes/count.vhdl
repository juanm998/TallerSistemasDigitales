library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic (
        N : natural := 8
    );
    port (
        clk : in std_logic;
        res : in std_logic;
        y   : out std_logic_vector(N-1 downto 0)
    );
end entity counter;

architecture counter_arq of counter is
    signal count_reg : unsigned(N-1 downto 0) := (others => '0');
begin
    process(clk, res)
    begin
        if res = '1' then
            count_reg <= (others => '0');
        elsif rising_edge(clk) then
            count_reg <= count_reg + 1;
        end if;
    end process;

    y <= std_logic_vector(count_reg);
end architecture counter_arq;