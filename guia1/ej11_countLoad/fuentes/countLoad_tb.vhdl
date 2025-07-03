library ieee;
use ieee.std_logic_1164.all;

entity countLoad_tb is
end contLoad_tb;

architecture behavioral of countLoad_tb is
    constant SIM_TIME_NS : time := 200 ns;
    constant TB_N: natural := 4;
    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic;
    signal tb_load : std_logic;
    signal tb_value : std_logic_vector(TB_N-1 downto 0);
    signal tb_count : std_logic_vector(TB_N-1 downto 0);

begin

    tb_rst <= '0', '1' after 30 ns, '0' after 50 ns;
    tb_clk <= not tb_clk after 5 ns;
    tb_value <= "0110";
    tb_load <= '0', '1' after 133 ns, '0' after 157 ns;
stop_simulation : process

begin
    wait for SIM_TIME_NS;--run the simulation for this duration
    assert false
        report "Simulation finished."
        severity failure;
end process;

I1: entity work.countLoad(countLoad_arq)
generic map(
    N=> TB_N
)
port map(
    
    rst => tb_rst,
    clk => tb_clk,
    load => tb_load,
    value => tb_value,
    count => tb_count
);
end behavioral;