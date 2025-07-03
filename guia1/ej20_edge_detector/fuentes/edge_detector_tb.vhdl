library IEEE;
use IEEE.std_logic_1164.all;

entity edge_detector_tb is
end entity;

architecture behavior of edge_detector_tb is
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal signal_in  : std_logic := '0';
    signal rising     : std_logic;
    signal falling    : std_logic;

    constant T : time := 10 ns;
begin
    -- Instancia del DUT (Device Under Test)
    uut: entity work.edge_detector
        port map (
            clk        => clk,
            rst        => rst,
            signal_in  => signal_in,
            rising     => rising,
            falling    => falling
        );

    -- Generador de reloj
    clk_process : process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end loop;
        wait;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset
        rst <= '1';
        wait for T;
        rst <= '0';

        -- Generamos algunos flancos
        signal_in <= '0'; wait for T;
        signal_in <= '1'; wait for T; -- Flanco de subida
        signal_in <= '1'; wait for T;
        signal_in <= '0'; wait for T; -- Flanco de bajada
        signal_in <= '1'; wait for T; -- Flanco de subida
        signal_in <= '0'; wait for T; -- Flanco de bajada
        signal_in <= '0'; wait for T;
        signal_in <= '1'; wait for T; -- Flanco de subida

        wait;
    end process;

end architecture;
