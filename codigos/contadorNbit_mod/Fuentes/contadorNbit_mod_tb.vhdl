library IEEE;
use IEEE.std_logic_1164.all;

entity contNbits_Mod_tb is
end;

architecture contNbits_Mod_tb_arq of contNbits_Mod_tb is

	component contNbits_Mod is
		generic(
			N: natural := 4;
			MODULO: natural := 9
		);
		port(
			clk_i	: in  std_logic; 
			rst_i	: in  std_logic; 
			ena_i	: in  std_logic; 
			cuenta_o: out  std_logic_vector(N-1 downto 0); 
			max_o	: out std_logic
		);
	end component;

	constant N_tb: natural := 10;
	constant MODULO_tb: natural := 13;
	
	signal clk_tb: std_logic := '0';
	signal rst_tb: std_logic := '1';
	signal ena_tb: std_logic := '1';
	signal cuenta_tb: std_logic_vector(N_tb-1 downto 0) := (others => '0');
	signal max_tb: std_logic;
	
begin

	clk_tb <= not clk_tb after 10 ns;
	rst_tb <= '0' after 35 ns;
	ena_tb <= '0' after 105 ns, '1' after 120 ns;

	cont4bits_inst: contNbits_Mod
		generic map(
			N => N_tb,
			MODULO => MODULO_tb
		)
		port map(
			clk_i => clk_tb,
			rst_i => rst_tb,
			ena_i => ena_tb,
			cuenta_o => cuenta_tb,
			max_o => max_tb
		);

end;
