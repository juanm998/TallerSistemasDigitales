library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_pkg.all;

entity contador_ch_st_tb is
end entity;

architecture tb of contador_ch_st_tb is

    -- Señales internas
    signal clk_i     : std_logic := '0';
    signal rst_i     : std_logic := '1';
    signal seg1_i    : std_logic := '0';
    signal estado_i  : t_estado := E_R1_V2;
    signal ch_st     : std_logic;

    -- Parámetro de clock
    constant clk_period : time := 20 ns;

begin

    -- Instancia del módulo
    DUT: entity work.contador_ch_st
        port map (
            clk_i    => clk_i,
            rst_i    => rst_i,
            seg1_i   => seg1_i,
            estado_i => estado_i,
            ch_st    => ch_st
        );

    -- Clock de 50 MHz
    clk_process: process
    begin
        while now < 100 sec loop
            clk_i <= '0';
            wait for clk_period / 2;
            clk_i <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Generador de pulso de 1 segundo
    seg1_proc: process
    begin
        wait for 100 ns;
        for i in 0 to 80 loop  -- 80 segundos aprox
            seg1_i <= '1';
            wait for clk_period;
            seg1_i <= '0';
            wait for 1 sec - clk_period;
        end loop;
        wait;
    end process;

    -- Estímulos de estados
    stim_proc: process
    begin
        wait for 100 ns;
        rst_i <= '0';

        -- Estado largo (30s): E_R1_V2
        estado_i <= E_R1_V2;
        wait for 31 sec;

        -- Estado corto (3s): E_A1_R2
        estado_i <= E_A1_R2;
        wait for 4 sec;

        -- Otro estado largo (30s): E_V1_R2
        estado_i <= E_V1_R2;
        wait for 31 sec;

        -- Otro estado corto (3s): E_R1_A2
        estado_i <= E_R1_A2;
        wait for 4 sec;

        wait;
    end process;

end architecture;