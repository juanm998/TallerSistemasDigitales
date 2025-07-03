library IEEE;
use IEEE.std_logic_1164.all;

entity genEna_tb is
end genEna_tb;

architecture genEna_tb_arq of genEna_tb is

	signal clk_tb	: std_logic := '0';
	signal rst_tb	: std_logic := '1';
	signal ena_tb	: std_logic := '1';
	signal q_tb		: std_logic;
	constant N_tb	: natural := 10;
begin

	clk_tb <= not clk_tb after 10 ns;
	rst_tb <= '0' after 50 ns;
--	ena_tb <= '0' after 135 ns;
	
	DUT: entity work.genEna
		generic map(
			N => N_tb
		)
		port map(
			clk_i 	=> clk_tb,
			rst_i 	=> rst_tb,
			ena_i 	=> ena_tb,
			q_o		=> q_tb
		);

end genEna_tb_arq;