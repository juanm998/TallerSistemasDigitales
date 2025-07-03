library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity restadorSigned_tb is
end entity;

architecture tb of restadorSigned_tb is

    constant N : natural := 8;

    signal tb_a : std_logic_vector(N-1 downto 0);
    signal tb_b : std_logic_vector(N-1 downto 0);
    signal tb_y : std_logic_vector(N-1 downto 0);

begin

    -- Instancia del DUT (Device Under Test)
    DUT: entity work.restadorSigned
        generic map (N => N)
        port map (
            a => tb_a,
            b => tb_b,
            y => tb_y
        );

    -- Estímulos
    stim_proc: process
    begin
        -- Caso 1: 5 - 3 = 2
        tb_a <= std_logic_vector(to_signed(5, N));
        tb_b <= std_logic_vector(to_signed(3, N));
        wait for 20 ns;

        -- Caso 2: 3 - 5 = -2
        tb_a <= std_logic_vector(to_signed(3, N));
        tb_b <= std_logic_vector(to_signed(5, N));
        wait for 20 ns;

        -- Caso 3: -10 - (-5) = -5
        tb_a <= std_logic_vector(to_signed(-10, N));
        tb_b <= std_logic_vector(to_signed(-5, N));
        wait for 20 ns;

        -- Caso 4: -4 - 4 = -8
        tb_a <= std_logic_vector(to_signed(-4, N));
        tb_b <= std_logic_vector(to_signed(4, N));
        wait for 20 ns;

        -- Caso 5: 0 - 0 = 0
        tb_a <= std_logic_vector(to_signed(0, N));
        tb_b <= std_logic_vector(to_signed(0, N));
        wait for 20 ns;

        wait;
    end process;

end architecture;
