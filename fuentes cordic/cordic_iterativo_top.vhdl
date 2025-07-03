library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes_cordic.all;

entity cordic_iterativo_top is
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
        start   : in  std_logic;
        modo    : in  std_logic;            
        x_i     : in  Q3_16_t;             
        y_i     : in  Q3_16_t;             
        angle_i : in  Q3_16_t;            
        x_o     : out Q3_16_t;            
        y_o     : out Q3_16_t;            
        z_o     : out Q3_16_t;           
        done    : out std_logic          
    );
end entity cordic_iterativo_top;

architecture cordic_iterativo_top_arq of cordic_iterativo_top is

    -- Señales para interconectar preprocesamiento
    signal pre_rot_x    : Q3_16_t;
    signal pre_rot_y    : Q3_16_t;
    signal pre_rot_angle: Q3_16_t;
    signal pre_vec_x    : Q3_16_t;
    signal pre_vec_y    : Q3_16_t;
    signal pre_vec_z    : Q3_16_t;

    -- Señales multiplexadas (salidas efectivas del preprocesamiento según modo)
    signal pre_x : Q3_16_t;
    signal pre_y : Q3_16_t;
    signal pre_z : Q3_16_t;

    -- Registros internos para valores iterativos
    signal x_reg, y_reg, z_reg : Q3_16_t;
    signal iter_count : unsigned(NL-1 downto 0) := (others => '0');  -- Contador de iteración (4 bits para 0..15)
    signal running   : std_logic := '0'; 
    signal next_done : std_logic := '0'; 

    -- Señales de salida de la etapa CORDIC (combinacional)
    signal x_next, y_next, z_next : Q3_16_t;
    -- Señal de constante de ángulo actual (de la tabla) correspondiente a iter_count
    signal atan_const : Q3_16_t;

begin
    -- Instancias de bloques de preprocesamiento (rotación y vectorización)
    u_pre_rot: entity work.preprocesado_rotation 
        port map(
            angle_i => angle_i,      -- ángulo de entrada
            x_i     => x_i, 
            y_i     => y_i,
            angle_o => pre_rot_angle,
            x_o     => pre_rot_x,
            y_o     => pre_rot_y
        );

    u_pre_vec: entity work.preprocesado_vectoring
        port map(
            x_i  => x_i,
            y_i  => y_i,
            z_i  => angle_i,         -- ángulo inicial (ej. 0) para acumulador
            x_o  => pre_vec_x,
            y_o  => pre_vec_y,
            z_o  => pre_vec_z
        );

    -- Selección de salidas de preprocesamiento según el modo
    pre_x <= pre_rot_x    when modo = '0' else pre_vec_x;
    pre_y <= pre_rot_y    when modo = '0' else pre_vec_y;
    pre_z <= pre_rot_angle when modo = '0' else pre_vec_z;

    -- Instancia de la etapa combinacional CORDIC (una iteración)
    u_stage: entity work.etapa_cordic 
        port map(
            xi   => x_reg,
            yi   => y_reg,
            zi   => z_reg,
            bi   => atan_const,                   -- constante atan(2^-i) para la iteración actual
            i    => std_logic_vector(iter_count), -- número de iteración (como std_logic_vector de 4 bits)
            modo => modo,
            xn   => x_next,
            yn   => y_next,
            zn   => z_next
        );

    -- Obtener constante de ángulo desde la tabla según iteración actual
    atan_const <= atan_table(to_integer(iter_count));  -- Lookup en la ROM de ángulos

    -- Instancia de post-procesamiento (corrección de ganancia K)
    u_post: entity work.postprocesado_cordic 
        port map(
            x_i    => x_reg,    -- se multiplica el valor final almacenado en registros
            y_i    => y_reg,
            x_proc => x_o,      -- salida corregida en escala
            y_proc => y_o
        );

    -- Proceso secuencial principal: gestiona las iteraciones y registros
    process(clk, reset)
    begin 
        if reset = '1' then
            -- Inicialización asíncrona de registros
            x_reg     <= (others => '0');
            y_reg     <= (others => '0');
            z_reg     <= (others => '0');
            iter_count <= (others => '0');
            running   <= '0';
            done      <= '0';
        elsif rising_edge(clk) then
            if start = '1' and running = '0' then
                -- Cargar entradas preprocesadas al iniciar
                x_reg      <= pre_x;
                y_reg      <= pre_y;
                z_reg      <= pre_z;
                iter_count <= to_unsigned(0, NL);
                running    <= '1';
                done       <= '0';
            elsif running = '1' then
                if iter_count < to_unsigned(15, NL) then
                    -- Iteración en curso (no es la última): cargar siguiente valores y avanzar contador
                    x_reg      <= x_next;
                    y_reg      <= y_next;
                    z_reg      <= z_next;
                    iter_count <= iter_count + 1;
                else
                    -- Última iteración (i = 15) completada: cargar resultado final y señalizar done
                    x_reg   <= x_next;
                    y_reg   <= y_next;
                    z_reg   <= z_next;
                    running <= '0';
                    done    <= '1';
                    -- iter_count puede reiniciarse opcionalmente a 0 aquí
                end if;
            end if;
        end if;
    end process;

    -- Las salidas finales:
    z_o <= z_reg;   -- El acumulador angular final (Q3.16) se asigna directamente a la salida z_o
    -- x_o, y_o salen directamente de la instancia de postprocesado (asignados en port map)

end architecture cordic_iterativo_top_arq;



