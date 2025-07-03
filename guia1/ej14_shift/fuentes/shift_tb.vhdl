library ieee;
use ieee.std_logic_1164.all;

entity shift_tb is
end shift_tb;

architecture behavioral of shift_tb is
    constant SIM_TIME_NS : time := 200 ns;
    constant TB_N: natural := 4;
    signal tb_clk: std_logic := '0';
    signal tb_rst: std_logic;
    signal tb_data_in : std_logic;
    signal tb_data_out : std_logic;
begin
    tb_rst <= '0', '1' after 30 ns, '0' after 50 ns;
    tb_clk <= not tb_clk after 5 ns;
    tb_data_in <= '0', '1' after 72 ns, '0' after 82 ns, '1' after 92 ns,'0' after 102 ns;

stop_simulation : process
begin
    wait for SIM_TIME_NS;--run the simulation for this duration
    assert false
        report "Simulation finished."
        severity failure;
end process;

I1: entity work.shift_reg(behavioral)
    generic map(
        N => TB_N
    )
    port map(
    rst => tb_rst,
    clk => tb_clk,
    data_in => tb_data_in,
    data_out => tb_data_out
);

end behavioral;