library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity postprocesado_cordic is
    port (
        x_i     : in  Q3_16_t;
        y_i     : in  Q3_16_t;
        x_proc  : out Q3_16_t;
        y_proc  : out Q3_16_t
    );
end entity;

architecture postprocesado_cordic_arq of postprocesado_cordic is
    -- Multiplicar dos Q3.16 da Q6.32 (38 bits)
    signal mult_x : signed(2*N+5 downto 0);
    signal mult_y : signed(2*N+5 downto 0);
begin
    -- Producto completo
    mult_x <= x_i * K_Q3_16;
    mult_y <= y_i * K_Q3_16;

    -- Tomo los bits centrales, para volver a Q3.16
    -- Q3.16 está en (N+2 downto 0), así que tomamos los bits más significativos después del producto:
    -- Resultado Q6.32: mult_x(37 downto 0)
    -- Para volver a Q3.16: tomamos los bits (N+2+16 downto 16) = (34 downto 16) para N=16
    x_proc <= mult_x(N+2+N downto N);
    y_proc <= mult_y(N+2+N downto N);

end architecture postprocesado_cordic_arq;
