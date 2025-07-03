library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;


entity preprocesado_rotation is
    port (
        angle_i : in  Q3_16_t;
        x_i     : in  Q3_16_t;
        y_i     : in  Q3_16_t;
        angle_o : out Q3_16_t;
        x_o     : out Q3_16_t;
        y_o     : out Q3_16_t
    );
end entity preprocesado_rotation;

architecture preprocesado_rotation_arq of preprocesado_rotation is
begin
    -- Lógica concurrente: 
    -- Si el ángulo está fuera de [-π/2, π/2], ajusto ángulo y niego coordenadas

    x_o <= -x_i when (angle_i > PI_2_Q316) or (angle_i < -PI_2_Q316) else x_i;
    y_o <= -y_i when (angle_i > PI_2_Q316) or (angle_i < -PI_2_Q316) else y_i;
    angle_o <= (angle_i - PI_Q316) when angle_i > PI_2_Q316 else
                (angle_i + PI_Q316) when angle_i < -PI_2_Q316 else
                angle_i;
end architecture preprocesado_rotation_arq;
