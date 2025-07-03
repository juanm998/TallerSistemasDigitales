library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumadorUnsigned_tb is
end entity;

architecture test of sumadorUnsigned_tb is

    -- Constante para definir el tamaño del sumador
    constant N : natural := 8;

    -- Señales de prueba
    signal x0_tb : std_logic_vector(N-1 downto 0);
    signal x1_tb : std_logic_vector(N-1 downto 0);
    signal y_tb  : std_logic_vector(N downto 0);

begin

    -- Instanciación del DUT (sumador)
    uut: entity work.sumadorUnsigned
        generic map(N => N)
        port map(
            x0 => x0_tb,
            x1 => x1_tb,
            y  => y_tb
        );

    -- Proceso de estímulos
    stim_proc: process
    begin
        -- Prueba 1:  5 + 3 = 8
        x0_tb <= std_logic_vector(to_unsigned(5, N));
        x1_tb <= std_logic_vector(to_unsigned(3, N));
        wait for 20 ns;

        -- Prueba 2:  15 + 20 = 35
        x0_tb <= std_logic_vector(to_unsigned(15, N));
        x1_tb <= std_logic_vector(to_unsigned(20, N));
        wait for 20 ns;

        -- Prueba 3: 255 + 1 = 256 (con acarreo)
        x0_tb <= std_logic_vector(to_unsigned(255, N));
        x1_tb <= std_logic_vector(to_unsigned(1, N));
        wait for 20 ns;

        -- Prueba 4: 128 + 128 = 256
        x0_tb <= std_logic_vector(to_unsigned(128, N));
        x1_tb <= std_logic_vector(to_unsigned(128, N));
        wait for 20 ns;

        -- Prueba 5: 0 + 0 = 0
        x0_tb <= (others => '0');
        x1_tb <= (others => '0');
        wait for 20 ns;

        wait; -- Termina la simulación
    end process;

end architecture test;
