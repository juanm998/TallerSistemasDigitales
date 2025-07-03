-- Declaracion de biblioteca y paquetes
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Declaracion de entidad
entity contNbits_Mod is
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
end;

-- Arquitectura
architecture contNbits_Mod_arq of contNbits_Mod is
	-- Parte declarativa
	
	component reg is
		generic(
			N: natural := 4
		);
		port(
			clk_i: in  std_logic; 
			rst_i: in  std_logic; 
			ena_i: in  std_logic; 
			d_i  : in  std_logic_vector(N-1 downto 0); 
			q_o  : out std_logic_vector(N-1 downto 0)
		);
	end component;

	signal salReg, salSum: std_logic_vector(N-1 downto 0);
	signal salAnd, salOr, salComp: std_logic;
	
begin
	-- Parte descriptiva
	
	salSum  <= std_logic_vector(unsigned(salReg) + to_unsigned(1,N));
	
	salOr   <= rst_i or salAnd;
	
	salAnd  <= ena_i and salComp;
	
	salComp <= '1' when unsigned(salReg) = to_unsigned(MODULO,N) else '0';
	
	max_o    <= salComp;
	cuenta_o <= salReg;

	reg_inst: reg
		generic map(
			N => N
		)
		port map(
			clk_i => clk_i,
			rst_i => salOr,
			ena_i => ena_i,
			d_i   => salSum,
			q_o   => salReg
		);
end;