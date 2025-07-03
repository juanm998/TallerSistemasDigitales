library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regRA_tb is
end entity;

architecture test of regRA_tb is
    constant N : integer := 4;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal set : std_logic := '0';
    signal d   : std_logic_vector(N-1 downto 0) := (others => '0');

    signal q_reset_async : std_logic_vector(N-1 downto 0);
    signal q_reset_sync  : std_logic_vector(N-1 downto 0);
    signal q_set_async   : std_logic_vector(N-1 downto 0);
    signal q_set_sync    : std_logic_vector(N-1 downto 0);

    constant clk_period : time := 10 ns;
begin

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        wait for 5 ns;
        d <= "1010";
        wait for clk_period;

        rst <= '1';  -- Reset async y sync activados
        wait for 5 ns;
        rst <= '0';
        d <= "1100";
        wait for clk_period;

        set <= '1';  -- Set async y sync activados
        wait for 5 ns;
        set <= '0';
        d <= "0011";
        wait for clk_period;

        d <= "1111";
        wait for clk_period;

        wait;
    end process;

    -- Instancias de los 4 registros

    regRA_inst: entity work.regRA
        generic map (N => N)
        port map (clk => clk, rst => rst, d => d, q => q_reset_async);

    regRS_inst: entity work.regRS
        generic map (N => N)
        port map (clk => clk, rst => rst, d => d, q => q_reset_sync);

    regSA_inst: entity work.regSA
        generic map (N => N)
        port map (clk => clk, set => set, d => d, q => q_set_async);

    regSS_inst: entity work.regSS
        generic map (N => N)
        port map (clk => clk, set => set, d => d, q => q_set_sync);

end architecture;