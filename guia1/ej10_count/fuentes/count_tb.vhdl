library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity count_tb is
end entity;

architecture test of count_tb is
    constant N : integer := 8;

    signal clk : std_logic := '0';
    signal res : std_logic := '0';
    signal y   : std_logic_vector(N-1 downto 0);

    constant clk_period : time := 10 ns;
begin

    -- Instancia del contador
    uut: entity work.count
        generic map (N => N)
        port map (
            clk => clk,
            res => res,
            y   => y
        );

    -- Generación del reloj
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        -- Reset inicial
        res <= '1';
        wait for 15 ns;
        res <= '0';

        -- Contar unos ciclos
        wait for 100 ns;

        -- Activar reset nuevamente
        res <= '1';
        wait for 10 ns;
        res <= '0';

        -- Seguir contando
        wait for 50 ns;

        wait;
    end process;

end architecture;