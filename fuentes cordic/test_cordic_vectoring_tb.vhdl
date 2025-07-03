library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity test_cordic_vectoring_tb is
end entity;

architecture sim of test_cordic_vectoring_tb is

    -- Entradas originales
    signal x_in, y_in     : Q3_16_t;
    signal angle_in       : Q3_16_t;

    -- Salidas preprocesado vectoring
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

    -- Función para convertir Q3.16 a real
    function to_real(val : Q3_16_t) return real is
    begin
        return real(to_integer(val)) / 65536.0;
    end function;

    -- Constante para convertir rad a grados
    constant RAD_TO_DEG : real := 180.0 / 3.14159265358979323846;

begin

    -- Instancio preprocesado vectoring para ajustar vector y ángulo inicial
    preproc_vec_inst : entity work.preprocesado_vectoring
        port map (
            x_i => x_in,
            y_i => y_in,
            z_i => angle_in,
            x_o => x_pre,
            y_o => y_pre,
            z_o => angle_pre
        );

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
                modo => '1',  -- VECTORING
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

    -- Estímulo y reporte
    process
        variable modulo_real, angulo_rad, angulo_deg : real;
    begin
        -- Ejemplo: vector (-1,0) con angulo inicial 0
        x_in     <= to_Q3_16(-1.0);
        y_in     <= to_Q3_16(-1.0);
        angle_in <= to_Q3_16(0.0); --SIEMPRE

        wait for 100 ns;

        modulo_real := to_real(x_post);  -- módulo resultante (x_post)
        angulo_rad := to_real(z_stage(16)); -- ángulo final (z en salida CORDIC)
        angulo_deg := angulo_rad * RAD_TO_DEG;

        report "--------------------";
        report "CORDIC VECTORING (Q3.16, 16 etapas)";
        report "Entrada: (x, y) = (-1.0, -1.0)";
        report "Salida (postprocesado):";
        report "   Modulo (x) = " & real'image(modulo_real);
        report "   Residuo y  = " & real'image(to_real(y_post));
        report "   Angulo final = " & real'image(angulo_rad) & " rad";
        report "   Angulo final = " & real'image(angulo_deg) & " grados";

        wait;
    end process;

end architecture;




