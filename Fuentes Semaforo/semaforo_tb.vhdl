library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_pkg.all;

entity semaforo_tb is
end entity;

architecture semaforo_tb_arq of semaforo_tb is

    -- Señales internas
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal seg1     : std_logic;
    signal ch_st    : std_logic;
    signal estado_s : t_estado;

    -- Señales para simular el reloj
    constant periodo_clk : time := 20 ns;

    -- Componente: contador 1 segundo
    component contador is
        port (
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            seg1_o  : out std_logic
        );
    end component;

    -- Componente: contador cambio de estado
    component contador_ch_st is
        port (
            clk_i     : in  std_logic;
            rst_i     : in  std_logic;
            seg1_i    : in  std_logic;
            estado_i  : in  t_estado;
            ch_st     : out std_logic
        );
    end component;

    -- Componente: FSM semáforo
    component fsm_semaforo is
        port (
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            ch_st   : in  std_logic;
            estado  : out t_estado
        );
    end component;

begin

    -- Instancia del contador de 1 segundo
    u1: contador
        port map (
            clk_i  => clk,
            rst_i  => rst,
            seg1_o => seg1
        );

    -- Instancia del contador de cambio de estado
    u2: contador_ch_st
        port map (
            clk_i    => clk,
            rst_i    => rst,
            seg1_i   => seg1,
            estado_i => estado_s,
            ch_st    => ch_st
        );

    -- Instancia de la FSM
    u3: fsm_semaforo
        port map (
            clk_i  => clk,
            rst_i  => rst,
            ch_st  => ch_st,
            estado => estado_s
        );

    -- Generación del reloj
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for periodo_clk / 2;
            clk <= '1';
            wait for periodo_clk / 2;
        end loop;
    end process;

    -- Reset inicial
    rst_process : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;

end architecture semaforo_tb_arq;
