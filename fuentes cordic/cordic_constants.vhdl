library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cordic_constants is
    -- Parámetros globales
    constant N  : natural := 16;  -- número de etapas
    constant NL : natural := 4;   -- clog2(N)

    -- Tipo de ángulo en punto fijo signed (N+2 bits)
    subtype angle_t is signed(N+1 downto 0);
    type angle_table_t is array(0 to N-1) of angle_t;

    -- Constantes atan(2^-i) en radianes, escala Q2.14
    -- Es decir: valor = atan(2^-i) * 2^14
    constant b : angle_table_t := (
        to_signed(12867, N+2), -- atan(2^-0) ≈ 0.785398 rad
        to_signed(7596,  N+2), -- atan(2^-1) ≈ 0.463648
        to_signed(4014,  N+2), -- atan(2^-2) ≈ 0.244978
        to_signed(2037,  N+2), -- atan(2^-3) ≈ 0.124355
        to_signed(1021,  N+2), -- atan(2^-4)
        to_signed(511,   N+2),
        to_signed(256,   N+2),
        to_signed(128,   N+2),
        to_signed(64,    N+2),
        to_signed(32,    N+2),
        to_signed(16,    N+2),
        to_signed(8,     N+2),
        to_signed(4,     N+2),
        to_signed(2,     N+2),
        to_signed(1,     N+2),
        to_signed(1,     N+2)  -- Últimos valores son muy pequeños
    );

end package cordic_constants;