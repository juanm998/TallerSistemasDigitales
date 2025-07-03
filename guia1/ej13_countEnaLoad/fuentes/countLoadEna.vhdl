library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity countLoadEna is
    generic(
        N : natural := 8
    );
    port(
        clk   : in std_logic;
        ena   : in std_logic;
        rst   : in std_logic;
        load  : in std_logic;
        value : in std_logic_vector(N-1 downto 0);
        y     : out std_logic_vector(N-1 downto 0)
    );
end entity countLoadEna;

architecture countLoadEna_arq of countLoadEna is
    signal aux : unsigned(N-1 downto 0) := (others => '0');
begin
    process(clk,rst)
    begin
        if rst = '1' then
            aux <= (others => '0');
        elsif clk = '1' and clk'event then
            if enable = '1' then
                if load = '1' then
                    aux_count <= unsigned(value);
                else
                    aux_count <= aux_count + 1;
                end if;
            end if;
        end if;
    end process;
    y <= std_logic_vector(aux);
end architecture countLoadEna_arq;