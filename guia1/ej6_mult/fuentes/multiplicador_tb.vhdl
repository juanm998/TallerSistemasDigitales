library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mult is
end tb_mult;

architecture behavioral of tb_mult is
    constant TB_N : natural := 4;

    signal tb_x0 : std_logic_vector(TB_N-1 downto 0);
    signal tb_x1 : std_logic_vector(TB_N-1 downto 0);
    signal tb_y  : std_logic_vector(2*TB_N-1 downto 0);
begin

    -- Estímulos temporales con enteros convertidos a std_logic_vector
    process
    begin
        tb_x0 <= std_logic_vector(to_unsigned(2, TB_N));
        tb_x1 <= std_logic_vector(to_unsigned(9, TB_N));
        wait for 10 ns;

        tb_x0 <= std_logic_vector(to_unsigned(5, TB_N));
        tb_x1 <= std_logic_vector(to_unsigned(14, TB_N));
        wait for 10 ns;

        tb_x0 <= std_logic_vector(to_unsigned(15, TB_N));
        tb_x1 <= std_logic_vector(to_unsigned(15, TB_N));
        wait for 10 ns;

        tb_x0 <= std_logic_vector(to_unsigned(0, TB_N));
        tb_x1 <= std_logic_vector(to_unsigned(0, TB_N));
        wait;

    end process;

    -- Instancia del multiplicador
    I1: entity work.multiplicador(multiplicador_arq)
        generic map (N => TB_N)
        port map (
            x1 => tb_x0,
            x2 => tb_x1,
            y  => tb_y
        );

end behavioral;
