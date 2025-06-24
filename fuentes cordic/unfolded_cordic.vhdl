library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cordic_constants.all;

entity unfolded_cordic is
    port(
        xo   : in  signed(N+1 downto 0);
        yo   : in  signed(N+1 downto 0);
        zo   : in  signed(N+1 downto 0);
        xn   : out signed(N+1 downto 0);
        yn   : out signed(N+1 downto 0);
        zn   : out signed(N+1 downto 0)
    );
end entity unfolded_cordic;

architecture unfolded_cordic_arq of unfolded_cordic is

    type signed_matrix is array(0 to N) of signed(N+1 downto 0);

    -- Señales funcionales entre etapas
    signal x : signed_matrix;
    signal y : signed_matrix;
    signal z : signed_matrix;

    -- Registros para observación y depuración
    signal reg_x : signed_matrix;
    signal reg_y : signed_matrix;
    signal reg_z : signed_matrix;

    component etapa_cordic is
        generic(
            N  : natural := 16;
            NL : natural := 4
        );
        port(
            xi   : in  signed(N+1 downto 0);
            yi   : in  signed(N+1 downto 0);
            zi   : in  signed(N+1 downto 0);
            bi   : in  signed(N+1 downto 0);
            i    : in  std_logic_vector(NL-1 downto 0);
            xip1 : out signed(N+1 downto 0);
            yip1 : out signed(N+1 downto 0);
            zip1 : out signed(N+1 downto 0)
        );
    end component;

begin

    -- Entrada a la etapa 0
    x(0) <= xo;
    y(0) <= yo;
    z(0) <= zo;

    -- Instanciación de todas las etapas CORDIC
    gen_cordic: for i in 0 to N-1 generate
        ETAPA_i: etapa_cordic
        generic map(
            N  => N,
            NL => NL
        )
        port map(
            xi    => x(i),
            yi    => y(i),
            zi    => z(i),
            bi    => b(i),
            i     => std_logic_vector(to_unsigned(i, NL)),
            xip1  => x(i+1),
            yip1  => y(i+1),
            zip1  => z(i+1)
        );
    end generate;

    -- Registro de resultados de cada etapa para trazado
    registrar: process(all)
    begin
        reg_x(0) <= xo;
        reg_y(0) <= yo;
        reg_z(0) <= zo;

        for i in 1 to N loop
            reg_x(i) <= x(i);
            reg_y(i) <= y(i);
            reg_z(i) <= z(i);
        end loop;
    end process;

    -- Asignación de salidas finales
    xn <= x(N);
    yn <= y(N);
    zn <= z(N);

end architecture;
