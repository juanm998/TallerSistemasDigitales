library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity test_cordic_rotation_tb is
end entity;

architecture sim of test_cordic_rotation_tb is

    -- Entradas
    signal x_in, y_in     : Q3_16_t;
    signal angle_in       : Q3_16_t;

    -- Señales preprocesado
    signal x_pre, y_pre   : Q3_16_t;
    signal angle_pre      : Q3_16_t;

    -- Señales para pipeline
    type stage_array is array (0 to 16) of Q3_16_t;
    signal x_stage, y_stage, z_stage : stage_array;

    -- Postprocesado
    signal x_post, y_post : Q3_16_t;

    -- Helper para asignar punto fijo (sin round)
    function to_Q3_16(val : real) return Q3_16_t is
    begin
        return to_signed(integer(val * 65536.0), N+3);
    end function;

begin

    -- Instancio preprocesado para normalizar ángulo y coordenadas
    preproc_inst : entity work.preprocesado_rotation
        port map (
            angle_i => angle_in,
            x_i     => x_in,
            y_i     => y_in,
            angle_o => angle_pre,
            x_o     => x_pre,
            y_o     => y_pre
        );

    -- Reporte del preprocesado para debug
    process(angle_pre)
    begin
        if angle_pre > PI_2_Q316 then
            report "DEBUG: angle_pre > PI/2";
        elsif angle_pre < -PI_2_Q316 then
            report "DEBUG: angle_pre < -PI/2";
        else
            report "DEBUG: angle_pre en rango [-PI/2, PI/2]";
        end if;
    end process;

    -- Inicializo pipeline con salida del preprocesado
    x_stage(0) <= x_pre;
    y_stage(0) <= y_pre;
    z_stage(0) <= angle_pre;

    -- Pipeline de 16 etapas
    stages: for i in 0 to 15 generate
        etapa: entity work.etapa_cordic
        port map (
            xi   => x_stage(i),
            yi   => y_stage(i),
            zi   => z_stage(i),
            bi   => atan_table(i),
            i    => std_logic_vector(to_unsigned(i, NL)),
            modo => '0',  -- ROTACION
            xn   => x_stage(i+1),
            yn   => y_stage(i+1),
            zn   => z_stage(i+1)
        );
    end generate;

    -- Postprocesado: escalar por K
    postproc: entity work.postprocesado_cordic
        port map (
            x_i    => x_stage(16),
            y_i    => y_stage(16),
            x_proc => x_post,
            y_proc => y_post
        );

    -- Estímulo y reporte final
    process
        variable x_real, y_real : real;
    begin
        x_in     <= to_Q3_16(1.0);
        y_in     <= to_Q3_16(1.0);
        --angle_in <= to_Q3_16(3.1415926535); -- pi
        --angle_in <= to_Q3_16(-3*3.1415926535/4.0); -- -3pi/4
        --angle_in <= to_Q3_16(3.1415926535/2.0); -- pi/2
        angle_in <= to_Q3_16(0.0); -- 0

        wait for 100 ns;

        x_real := real(to_integer(x_post)) / 65536.0;
        y_real := real(to_integer(y_post)) / 65536.0;

        report "--------------------";
        report "CORDIC ROTACION (Q3.16, 16 etapas)";
        report "Entrada: (x, y) = (1.0, 0.0), angulo = pi/4";
        report "Salida (postprocesado):";
        report "   x = " & real'image(x_real) & " (esperado aprox 0.707)";
        report "   y = " & real'image(y_real) & " (esperado aprox 0.707)";

        wait;
    end process;

end architecture;

