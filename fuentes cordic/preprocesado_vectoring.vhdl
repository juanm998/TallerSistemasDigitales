library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity preprocesado_vectoring is
    port (
        x_i     : in  Q3_16_t;
        y_i     : in  Q3_16_t;
        z_i     : in  Q3_16_t;  -- ángulo inicial
        x_o     : out Q3_16_t;
        y_o     : out Q3_16_t;
        z_o     : out Q3_16_t
    );
end entity preprocesado_vectoring;

architecture preprocesado_vectoring_arq of preprocesado_vectoring is
begin
    
    -- Si x_i es negativo (bit signo en posición N+2)
    x_o <= -x_i when x_i(x_i'high) = '1' else x_i;
    y_o <= -y_i when x_i(x_i'high) = '1' else y_i;
    z_o <= z_i + PI_Q316 when x_i(x_i'high) = '1' else z_i;

end architecture preprocesado_vectoring_arq;