library IEEE;
use IEEE.std_logic_1164.all;

entity detector_tb is
end entity;

architecture behavior of detector_tb is
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal data_in : std_logic := '0';
    signal detect  : std_logic;

    constant T : time := 10 ns;
begin
    -- Instancia de la FSM
    uut: entity work.fsm
        port map (
            clk     => clk,
            rst     => rst,
            data_in => data_in,
            detect  => detect
        );

    -- Generador de reloj
    clk_process: process
    begin
        while now < 300 ns loop
            clk <= '0';
            wait for T / 2;
            clk <= '1';
            wait for T / 2;
        end loop;
        wait;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for T;
        rst <= '0';

        -- Secuencia: 0 0 1 0 1 1 0 -> detect = '1'
        data_in <= '0'; wait for T;
        data_in <= '0'; wait for T;
        data_in <= '1'; wait for T;
        data_in <= '0'; wait for T;
        data_in <= '1'; wait for T;
        data_in <= '1'; wait for T;
        data_in <= '0'; wait for T;

        -- Un poco de ruido después
        data_in <= '1'; wait for T;
        data_in <= '1'; wait for T;
        data_in <= '0'; wait for T;
        data_in <= '0'; wait for T;

        wait;
    end process;

end architecture;
