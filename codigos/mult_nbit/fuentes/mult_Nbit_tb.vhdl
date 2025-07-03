library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplicador_tb is
end entity;

architecture test of multiplicador_tb is
    constant N : integer := 4;

    -- Señales internas
    signal A_tb    : std_logic_vector(N-1 downto 0) := (others => '0');
    signal B_tb    : std_logic_vector(N-1 downto 0) := (others => '0');
    signal load_tb : std_logic := '0';
    signal clk_tb  : std_logic := '0';
    signal Sal_tb  : std_logic_vector(2*N-1 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instancia del multiplicador
    DUT: entity work.multiplicador
        generic map(N => N)
        port map (
            A    => A_tb,
            B    => B_tb,
            load => load_tb,
            clk  => clk_tb,
            Sal  => Sal_tb
        );

    -- Reloj
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Estímulos básicos
    stim_proc : process
    begin
        wait for 20 ns;

        -- Multiplicación 3 * 5
        A_tb    <= "0011";
        B_tb    <= "0101";
        load_tb <= '1';
        wait for clk_period;
        load_tb <= '0';

        wait for 50 ns;

        -- Multiplicación 7 * 2
        A_tb    <= "0111";
        B_tb    <= "0010";
        load_tb <= '1';
        wait for clk_period;
        load_tb <= '0';

        wait for 50 ns;

        -- Fin de simulación
        wait;
    end process;

end architecture test;
