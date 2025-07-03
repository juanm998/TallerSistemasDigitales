library IEEE;
use IEEE.std_logic_1164.all;

entity contador_tb is
end entity;

architecture tb of contador_tb is

    -- Señales para conectar con el DUT (Device Under Test)
    signal rst_i    : std_logic := '1';
    signal clk_i    : std_logic := '0';
    signal seg1_o   : std_logic;

    -- Clock period constant (20 ns para 50 MHz)
    constant clk_period : time := 20 ns;

begin

    -- Instancia del contador
    DUT: entity work.contador
        port map (
            rst_i   => rst_i,
            clk_i   => clk_i,
            seg1_o  => seg1_o
        );

    -- Generador de clock (50 MHz)
    clk_process: process
    begin
        while now < 2 sec loop
            clk_i <= '0';
            wait for clk_period / 2;
            clk_i <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Proceso de estímulo
    stim_proc: process
    begin
        -- Reset activo por 50 ns
        wait for 50 ns;
        rst_i <= '0';

        -- Simulamos por 2 segundos
        wait for 2 sec;

        -- Fin de la simulación
        wait;
    end process;

end architecture;