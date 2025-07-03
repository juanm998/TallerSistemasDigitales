library IEEE;
use IEEE.std_logic_1164.all;

entity shift_register_en_tb is
end entity;

architecture sim of shift_register_en_tb is
    constant N : natural := 8;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal enable  : std_logic := '0';
    signal load    : std_logic := '0';
    signal data_in : std_logic_vector(N-1 downto 0) := (others => '0');
    signal q       : std_logic_vector(N-1 downto 0);

    -- Instancia del DUT (Device Under Test)
    component shift_register_en
        generic (
            N : natural := 8
        );
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            enable  : in  std_logic;
            load    : in  std_logic;
            data_in : in  std_logic_vector(N-1 downto 0);
            q       : out std_logic_vector(N-1 downto 0)
        );
    end component;

begin
    -- Instanciación
    dut: shift_register_en
        generic map (N => N)
        port map (
            clk     => clk,
            rst     => rst,
            enable  => enable,
            load    => load,
            data_in => data_in,
            q       => q
        );

    -- Reloj: 10 ns periodo
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';

        -- Carga inicial
        enable <= '1';
        load <= '1';
        data_in <= "10101010";
        wait for 10 ns;

        -- Desplazamiento (3 veces)
        load <= '0';
        wait for 30 ns;

        -- Enable = 0 (debe mantener el valor)
        enable <= '0';
        wait for 20 ns;

        -- Carga otro valor
        enable <= '1';
        load <= '1';
        data_in <= "11110000";
        wait for 10 ns;

        -- Desplazamiento nuevo
        load <= '0';
        wait for 20 ns;

        wait;
    end process;

end architecture;
