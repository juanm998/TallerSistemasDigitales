library IEEE;
use IEEE.std_logic_1164.all;

entity edge_detector is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        signal_in : in  std_logic;
        rising  : out std_logic;
        falling : out std_logic
    );
end entity;

architecture behavioral of edge_detector is
    signal signal_prev : std_logic := '0';
begin
    process(clk, rst)
    begin
        if rst = '1' then
            signal_prev <= '0';
            rising      <= '0';
            falling     <= '0';
        elsif rising_edge(clk) then
            -- Detectar flanco de subida
            if signal_prev = '0' and signal_in = '1' then
                rising <= '1';
            else
                rising <= '0';
            end if;

            -- Detectar flanco de bajada
            if signal_prev = '1' and signal_in = '0' then
                falling <= '1';
            else
                falling <= '0';
            end if;

            -- Actualizar señal anterior
            signal_prev <= signal_in;
        end if;
    end process;
end architecture;