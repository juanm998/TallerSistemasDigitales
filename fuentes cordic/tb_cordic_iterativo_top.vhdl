library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity tb_cordic_iterativo_top is
end entity;

architecture tb of tb_cordic_iterativo_top is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal start    : std_logic := '0';
    signal modo     : std_logic := '0';
    signal x_i, y_i : Q3_16_t := (others => '0');
    signal angle_i  : Q3_16_t := (others => '0');
    signal x_o, y_o, z_o : Q3_16_t;
    signal done     : std_logic;

    function to_q316(val : real) return Q3_16_t is
        variable tmp : integer;
    begin
        tmp := integer(val * 65536.0);
        return to_signed(tmp, 19);
    end function;

    function to_real(val : Q3_16_t) return real is
    begin
        return real(to_integer(val)) / 65536.0;
    end function;

    procedure esperar_ciclos(signal clk : in std_logic; n : integer) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin
    dut: entity work.cordic_iterativo_top
        port map (
            clk      => clk,
            reset    => reset,
            start    => start,
            modo     => modo,
            x_i      => x_i,
            y_i      => y_i,
            angle_i  => angle_i,
            x_o      => x_o,
            y_o      => y_o,
            z_o      => z_o,
            done     => done
        );

    clk_proc: process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- Reset global
        reset <= '1';
        esperar_ciclos(clk, 2);
        reset <= '0';
        esperar_ciclos(clk, 2);

        -- =============================
        -- PRUEBA 1: ROTACIÓN (1,0) 45°
        -- =============================
        modo    <= '0';
        x_i     <= to_q316(1.0);
        y_i     <= to_q316(0.0);
        angle_i <= to_q316(3.1415926535/4.0);  -- PI/4
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 1: Rotacion (1,0) 45 -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 2: VECTORIZACIÓN (1,1)
        -- =============================
        modo    <= '1';
        x_i     <= to_q316(1.0);
        y_i     <= to_q316(1.0);
        angle_i <= to_q316(0.0);
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 2: Vectorizacion (1,1) -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 3: ROTACIÓN (0,1) -90°
        -- =============================
        modo    <= '0';
        x_i     <= to_q316(0.0);
        y_i     <= to_q316(1.0);
        angle_i <= to_q316(-3.1415926535/2.0); -- -PI/2
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 3: Rotacion (0,1) -90 -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 4: ROTACIÓN (1,0) 135°
        -- =============================
        modo    <= '0';
        x_i     <= to_q316(1.0);
        y_i     <= to_q316(0.0);
        angle_i <= to_q316(3.0*3.1415926535/4.0); -- 135°
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 4: Rotacion (1,0) 135 -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 5: ROTACIÓN (-1,0) 45°
        -- =============================
        modo    <= '0';
        x_i     <= to_q316(-1.0);
        y_i     <= to_q316(0.0);
        angle_i <= to_q316(3.1415926535/4.0); -- 45°
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 5: Rotacion (-1,0) 45 -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 6: VECTORIZACIÓN (-1,-1)
        -- =============================
        modo    <= '1';
        x_i     <= to_q316(-1.0);
        y_i     <= to_q316(-1.0);
        angle_i <= to_q316(0.0);
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 6: Vectorizacion (-1,-1) -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 7: VECTORIZACIÓN (-2, 0)
        -- =============================
        modo    <= '1';
        x_i     <= to_q316(-2.0);
        y_i     <= to_q316(0.0);
        angle_i <= to_q316(0.0);
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 7: Vectorizacion (-2,0) -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- =============================
        -- PRUEBA 8: VECTORIZACIÓN (0,0)
        -- =============================
        modo    <= '1';
        x_i     <= to_q316(0.0);
        y_i     <= to_q316(0.0);
        angle_i <= to_q316(0.0);
        esperar_ciclos(clk, 1);

        start <= '1';
        esperar_ciclos(clk, 1);
        start <= '0';

        wait until done = '1';

        report "PRUEBA 8: Vectorizacion (0,0) -> x_o=" & real'image(to_real(x_o)) &
                " y_o=" & real'image(to_real(y_o)) &
                " z_o=" & real'image(to_real(z_o));

        esperar_ciclos(clk, 3);

        -- FIN DE SIMULACION
        wait;
    end process;

end architecture;




