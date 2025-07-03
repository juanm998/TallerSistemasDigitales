library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constantes_cordic is

    -- Q3.16: 1 bit signo, 2 bits enteros, 16 fraccionales (19 bits en total)
    constant N  : integer := 16; -- bits fraccionales
    constant NL : integer := 4;  -- log2(16) = 4 bits para iteraciones (i de 0 a 15)

    subtype Q3_16_t is signed(N+2 downto 0);

    -- Constante PI en Q3.16
    constant PI_Q316    : Q3_16_t := to_signed(205887, N+3);   -- PI = 3.1415926535 × 65536
    constant PI_2_Q316  : Q3_16_t := to_signed(102943, N+3);   -- PI/2 = 1.5707963268 × 65536
    -- Constante inversa de la ganancia en Q3.16

    constant K_Q3_16 : Q3_16_t := to_signed(39797, N+3);       -- K = 0.6072529 × 65536

    -- Tabla atan(2^-i) en radianes, Q3.16 (valor_decimal × 65536, redondeado)
    type atan_table_array is array (0 to 15) of Q3_16_t;
    constant atan_table : atan_table_array := (
        to_signed( 51472, N+3), -- atan(2^-0)  = 0.7853981634
        to_signed( 30385, N+3), -- atan(2^-1)  = 0.4636476090
        to_signed( 16056, N+3), -- atan(2^-2)  = 0.2449786631
        to_signed( 8149,  N+3), -- atan(2^-3)  = 0.1243549956
        to_signed( 4090,  N+3), -- atan(2^-4)  = 0.0624188090
        to_signed( 2045,  N+3), -- atan(2^-5)  = 0.0312398334
        to_signed( 1023,  N+3), -- atan(2^-6)  = 0.0156237286
        to_signed( 512,   N+3), -- atan(2^-7)  = 0.0078123411
        to_signed( 256,   N+3), -- atan(2^-8)  = 0.0039062301
        to_signed( 128,   N+3), -- atan(2^-9)  = 0.0019531225
        to_signed( 64,    N+3), -- atan(2^-10) = 0.0009765622
        to_signed( 32,    N+3), -- atan(2^-11) = 0.0004882812
        to_signed( 16,    N+3), -- atan(2^-12) = 0.0002441406
        to_signed( 8,     N+3), -- atan(2^-13) = 0.0001220703
        to_signed( 4,     N+3), -- atan(2^-14) = 0.0000610352
        to_signed( 2,     N+3)  -- atan(2^-15) = 0.0000305176
    );
end package constantes_cordic;

