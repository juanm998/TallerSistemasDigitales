library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_pkg.all;

entity semaforo_top is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        luces_1 : out std_logic_vector(2 downto 0); -- {verde_1, amarillo_1, rojo_1}
        luces_2 : out std_logic_vector(2 downto 0)  -- {verde_2, amarillo_2, rojo_2}
    );
end entity;

architecture rtl of semaforo_top is

    signal seg1     : std_logic;
    signal ch_st    : std_logic;
    signal estado_s : t_estado;

    component contador is
        port (
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            seg1_o  : out std_logic
        );
    end component;

    component contador_ch_st is
        port (
            clk_i     : in  std_logic;
            rst_i     : in  std_logic;
            seg1_i    : in  std_logic;
            estado_i  : in  t_estado;
            ch_st     : out std_logic
        );
    end component;

    component fsm_semaforo is
        port (
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            ch_st   : in  std_logic;
            estado  : out t_estado
        );
    end component;

begin

    -- Instancia contador de 1 segundo
    u1: contador
        port map (
            clk_i  => clk,
            rst_i  => rst,
            seg1_o => seg1
        );

    -- Instancia contador de cambio de estado
    u2: contador_ch_st
        port map (
            clk_i    => clk,
            rst_i    => rst,
            seg1_i   => seg1,
            estado_i => estado_s,
            ch_st    => ch_st
        );

    -- Instancia FSM
    u3: fsm_semaforo
        port map (
            clk_i  => clk,
            rst_i  => rst,
            ch_st  => ch_st,
            estado => estado_s
        );

    -- Luces semáforo 1 (verde, amarillo, rojo)
    luces_1 <=
        "100" when estado_s = E_V1_R2                         else -- Verde
        "010" when estado_s = E_A1_R2 or estado_s = E_R2_A1   else -- Amarillo
        "001" when estado_s = E_R1_V2 or estado_s = E_R1_A2 or estado_s = E_A2_R1 else -- Rojo
        "000";

    -- Luces semáforo 2 (verde, amarillo, rojo)
    luces_2 <=
        "100" when estado_s = E_R1_V2                         else -- Verde
        "010" when estado_s = E_A2_R1 or estado_s = E_R1_A2   else -- Amarillo
        "001" when estado_s = E_V1_R2 or estado_s = E_A1_R2 or estado_s = E_R2_A1 else -- Rojo
        "000";

end architecture;
