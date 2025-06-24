library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cordic_constants.all;

entity cordic_rotador is
    port(
        clk  : in  std_logic;
        xo   : in  signed(N+1 downto 0);
        yo   : in  signed(N+1 downto 0);
        zo   : in  signed(N+1 downto 0);  -- Ángulo en Q2.14
        xn   : out signed(N+1 downto 0);
        yn   : out signed(N+1 downto 0)
    );
end entity;

architecture rtl of cordic_rotador is

    signal xo_adj, yo_adj : signed(N+1 downto 0);
    signal zo_adj         : signed(N+1 downto 0);
    signal xn_cordic, yn_cordic, zn_cordic : signed(N+1 downto 0);

    signal negar_salida : std_logic;

    -- Constantes en Q2.14
    constant PI     : signed(N+1 downto 0) := to_signed(51472, N+2);  -- π ≈ 3.14159 * 2^14
    constant PI_DIV2: signed(N+1 downto 0) := to_signed(25736, N+2);  -- π/2 ≈ 1.5708 * 2^14

    component unfolded_cordic is
        port(
            xo : in  signed(N+1 downto 0);
            yo : in  signed(N+1 downto 0);
            zo : in  signed(N+1 downto 0);
            xn : out signed(N+1 downto 0);
            yn : out signed(N+1 downto 0);
            zn : out signed(N+1 downto 0)
        );
    end component;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Caso 1: dentro del rango convergente [-π/2, π/2]
            if (zo <= PI_DIV2 and zo >= -PI_DIV2) then
                xo_adj <= xo;
                yo_adj <= yo;
                zo_adj <= zo;
                negar_salida <= '0';

            -- Caso 2: zo > π/2 → rotar por (zo - π) y negar la salida
            elsif (zo > PI_DIV2) then
                xo_adj <= -xo;
                yo_adj <= -yo;
                zo_adj <= zo - PI;
                negar_salida <= '1';

            -- Caso 3: zo < -π/2 → rotar por (zo + π) y negar la salida
            else
                xo_adj <= -xo;
                yo_adj <= -yo;
                zo_adj <= zo + PI;
                negar_salida <= '1';
            end if;
        end if;
    end process;

    -- Invocación al CORDIC real
    instancia_cordic: unfolded_cordic
        port map(
            xo => xo_adj,
            yo => yo_adj,
            zo => zo_adj,
            xn => xn_cordic,
            yn => yn_cordic,
            zn => zn_cordic
        );

    -- Corrección de signo de salida
    xn <= xn_cordic when negar_salida = '0' else -xn_cordic;
    yn <= yn_cordic when negar_salida = '0' else -yn_cordic;

end architecture;