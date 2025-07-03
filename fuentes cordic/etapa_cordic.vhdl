library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity etapa_cordic is
    port(
        xi   : in  Q3_16_t; --18 dto 0
        yi   : in  Q3_16_t;
        zi   : in  Q3_16_t;
        bi   : in  Q3_16_t; --cte de atan table
        i    : in  std_logic_vector(NL-1 downto 0);
        modo   : in  std_logic;           -- bit de decisión (externo)
        xn : out Q3_16_t;
        yn : out Q3_16_t;
        zn : out Q3_16_t
    );
end entity etapa_cordic;

architecture etapa_cordic_arq of etapa_cordic is
    
    signal xsr, ysr : signed(N+2 downto 0);
    signal di_int : std_logic;
    
begin
    
    -- Desplazamientos aritméticos
    xsr <= shift_right(xi, to_integer(unsigned(i)));
    ysr <= shift_right(yi, to_integer(unsigned(i)));

    -- Bit de decisión
    di_int <= zi(N+2) when modo = '0' else yi(N+2);

    -- Operaciones CORDIC concurrente:
    -- Dos ecuaciones distintas según modo y di_int

    xn <=   xi - ysr when (modo = '0' and di_int = '0') else
            xi + ysr when (modo = '0' and di_int = '1') else
            xi + ysr when (modo = '1' and di_int = '0') else
            xi - ysr; -- (modo = '1' and di_int = '1')

    yn <=   yi + xsr when (modo = '0' and di_int = '0') else
            yi - xsr when (modo = '0' and di_int = '1') else
            yi - xsr when (modo = '1' and di_int = '0') else
            yi + xsr; -- (modo = '1' and di_int = '1')

    zn <=   zi - bi  when (modo = '0' and di_int = '0') else
            zi + bi  when (modo = '0' and di_int = '1') else
            zi + bi  when (modo = '1' and di_int = '0') else
            zi - bi; -- (modo = '1' and di_int = '1')
end architecture etapa_cordic_arq;