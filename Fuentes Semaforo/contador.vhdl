library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador is
    port(
        rst_i   : in std_logic;
        clk_i   : in std_logic;
        seg1_o  : out std_logic
    );
end entity contador;

architecture contador_arq of contador is 
    constant velocidad : unsigned(25 downto 0) := to_unsigned(50000000 - 1, 26); -- para 50MHz
    signal aux : unsigned(25 downto 0) := (others => '0');
begin

    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            aux <= (others => '0');
        elsif rising_edge(clk_i) then
            if aux = velocidad then
                aux <= (others => '0');
            else
                aux <= aux + 1;
            end if;
        end if;
    end process;

    seg1_o <= '1' when aux = velocidad else '0';

end architecture contador_arq;