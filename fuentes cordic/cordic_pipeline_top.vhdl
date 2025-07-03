library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;


entity cordic_pipeline_top is
    port (
        clk   : in std_logic;           
        rst   : in std_logic;           
        modo  : in std_logic;           
        x_in  : in Q3_16_t;             
        y_in  : in Q3_16_t;             
        z_in  : in Q3_16_t;            
        x_out : out Q3_16_t;            
        y_out : out Q3_16_t;            
        z_out : out Q3_16_t             
    );
end entity;

architecture cordic_pipeline_top_arq of cordic_pipeline_top is

    -- Defino tipos para arreglos pipeline
    type stage_array is array (0 to 16) of Q3_16_t;
    type stage_array_15 is array (0 to 15) of Q3_16_t;

    -- Registros pipeline para cada etapa
    signal x_pipe, y_pipe, z_pipe : stage_array;
    signal x_next, y_next, z_next : stage_array_15;

    -- Salidas de los preprocesados rotación y vectoring
    signal x_pre_rot, y_pre_rot, z_pre_rot : Q3_16_t;
    signal x_pre_vec, y_pre_vec, z_pre_vec : Q3_16_t;

    -- Selección final de preprocesado según modo
    signal x_pre, y_pre, z_pre : Q3_16_t;

begin

    -- Instancia preprocesado rotación (modo = '0')
    preproc_rotation_inst : entity work.preprocesado_rotation
        port map (
            angle_i => z_in,
            x_i     => x_in,
            y_i     => y_in,
            angle_o => z_pre_rot,
            x_o     => x_pre_rot,
            y_o     => y_pre_rot
        );

    -- Instancia preprocesado vectoring (modo = '1')
    preproc_vectoring_inst : entity work.preprocesado_vectoring
        port map (
            x_i => x_in,
            y_i => y_in,
            z_i => z_in,
            x_o => x_pre_vec,
            y_o => y_pre_vec,
            z_o => z_pre_vec
        );

    -- Selección concurrente del preprocesado según modo
    x_pre <= x_pre_rot when modo = '0' else x_pre_vec;
    y_pre <= y_pre_rot when modo = '0' else y_pre_vec;
    z_pre <= z_pre_rot when modo = '0' else z_pre_vec;

    -- Registro pipeline etapa 0 (captura entrada preprocesada)
    process(clk, rst)
    begin
        if rst = '1' then
            x_pipe(0) <= (others => '0');
            y_pipe(0) <= (others => '0');
            z_pipe(0) <= (others => '0');
        elsif rising_edge(clk) then
            x_pipe(0) <= x_pre;
            y_pipe(0) <= y_pre;
            z_pipe(0) <= z_pre;
        end if;
    end process;

    -- Pipeline de 16 etapas CORDIC con registros entre etapas
    gen_stages : for i in 0 to 15 generate

        -- Instancio la etapa combinacional CORDIC i
        etapa_inst : entity work.etapa_cordic
            port map (
                xi   => x_pipe(i),
                yi   => y_pipe(i),
                zi   => z_pipe(i),
                bi   => atan_table(i),
                i    => std_logic_vector(to_unsigned(i, NL)),
                modo => modo,
                xn   => x_next(i),
                yn   => y_next(i),
                zn   => z_next(i)
            );

        -- Registro pipeline para almacenar salida etapa i y pasar a la siguiente
        process(clk, rst)
        begin
            if rst = '1' then
                x_pipe(i+1) <= (others => '0');
                y_pipe(i+1) <= (others => '0');
                z_pipe(i+1) <= (others => '0');
            elsif rising_edge(clk) then
                x_pipe(i+1) <= x_next(i);
                y_pipe(i+1) <= y_next(i);
                z_pipe(i+1) <= z_next(i);
            end if;
        end process;

    end generate;

    -- Postprocesado para corregir ganancia K en las salidas X e Y
    postproc_inst : entity work.postprocesado_cordic
        port map (
            x_i    => x_pipe(16),
            y_i    => y_pipe(16),
            x_proc => x_out,
            y_proc => y_out
        );

    -- Registro de salida para el ángulo final Z (sin postprocesar)
    process(clk, rst)
    begin
        if rst = '1' then
            z_out <= (others => '0');
        elsif rising_edge(clk) then
            z_out <= z_pipe(16);
        end if;
    end process;

end cordic_pipeline_top_arq;


