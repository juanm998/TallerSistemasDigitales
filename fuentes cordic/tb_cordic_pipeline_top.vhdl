library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;  -- para sqrt y constantes reales
use work.constantes_cordic.all;

entity tb_cordic_pipeline_top is
end entity;

architecture sim of tb_cordic_pipeline_top is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal modo  : std_logic;
    signal x_in  : Q3_16_t;
    signal y_in  : Q3_16_t;
    signal z_in  : Q3_16_t;
    signal x_out : Q3_16_t;
    signal y_out : Q3_16_t;
    signal z_out : Q3_16_t;

    constant CLK_PERIOD : time := 10 ns;

    function to_Q3_16(val : real) return Q3_16_t is
    begin
        return to_signed(integer(val * 65536.0), N+3);
    end function;

    function to_real(val : Q3_16_t) return real is
    begin
        return real(to_integer(val)) / 65536.0;
    end function;

    constant RAD_TO_DEG : real := 180.0 / 3.14159265358979323846;

begin

    clk_proc : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    dut : entity work.cordic_pipeline_top
        port map (
            clk => clk,
            rst => rst,
            modo => modo,
            x_in => x_in,
            y_in => y_in,
            z_in => z_in,
            x_out => x_out,
            y_out => y_out,
            z_out => z_out
        );

    stimulus_proc : process
        variable modulo_real, residuo_real, angulo_rad, angulo_deg : real;
        variable x_in_r, y_in_r, z_in_r : real;
        variable mode_str : string(1 to 15);
    begin
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;  -- sincronizo al clk

        -- Prueba modo rotacion
        modo <= '0';
        x_in <= to_Q3_16(1.0);
        y_in <= to_Q3_16(0.0);
        z_in <= to_Q3_16(3.1415926535 / 4.0); -- pi/4

        wait for CLK_PERIOD * 16;  -- espero latencia pipeline
        wait for CLK_PERIOD;       -- un ciclo extra para salida registrada

        x_in_r := to_real(x_in);
        y_in_r := to_real(y_in);
        z_in_r := to_real(z_in);

        modulo_real := sqrt(to_real(x_out)**2 + to_real(y_out)**2);
        residuo_real := to_real(y_out);
        angulo_rad := to_real(z_out);
        angulo_deg := angulo_rad * RAD_TO_DEG;

        mode_str := "ROTACION       ";

        report "----------------------------------------------";
        report "Modo: " & mode_str;
        report "Entrada: x = " & real'image(x_in_r) & ", y = " & real'image(y_in_r) & ", angulo = " & real'image(z_in_r);
        report "Salida modulo (x_out) = " & real'image(modulo_real);
        report "Salida residuo (y_out) = " & real'image(residuo_real);
        report "Salida angulo (z_out) = " & real'image(angulo_rad) & " rad / " & real'image(angulo_deg) & " deg";

        wait for CLK_PERIOD * 10;  -- separación entre pruebas

        -- Prueba modo vectoring
        modo <= '1';
        x_in <= to_Q3_16(1.0);
        y_in <= to_Q3_16(1.0);
        z_in <= to_Q3_16(0.0);

        wait for CLK_PERIOD * 16;  -- espero latencia pipeline
        wait for CLK_PERIOD;       -- un ciclo extra para salida registrada

        x_in_r := to_real(x_in);
        y_in_r := to_real(y_in);
        z_in_r := to_real(z_in);

        modulo_real := sqrt(to_real(x_out)**2 + to_real(y_out)**2);
        residuo_real := to_real(y_out);
        angulo_rad := to_real(z_out);
        angulo_deg := angulo_rad * RAD_TO_DEG;

        mode_str := "VECTORING      ";

        report "----------------------------------------------";
        report "Modo: " & mode_str;
        report "Entrada: x = " & real'image(x_in_r) & ", y = " & real'image(y_in_r) & ", angulo = " & real'image(z_in_r);
        report "Salida modulo (x_out) = " & real'image(modulo_real);
        report "Salida residuo (y_out) = " & real'image(residuo_real);
        report "Salida angulo (z_out) = " & real'image(angulo_rad) & " rad / " & real'image(angulo_deg) & " deg";

        wait;  -- fin simulación
    end process;

end architecture;










