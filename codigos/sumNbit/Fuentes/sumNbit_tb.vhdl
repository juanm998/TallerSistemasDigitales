library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sumNbit_tb is
end entity sumNbit_tb;

architecture sumNbit_tb_arq of sumNbit_tb is
    
    component sumNbit is
        generic(
            N : natural := 4
        );
        port(
            a_in : in std_logic_vector(N-1 downto 0);
            b_in : in std_logic_vector(N-1 downto 0);
            c_in : in std_logic;
            sum_out: out std_logic_vector(N-1 downto 0);
            c_out: out std_logic
        );
    end component sumNbit;

    constant N_tb: natural := 1024;

    signal a_tb : std_logic_vector(N_tb-1 downto 0) := std_logic_vector(to_unsigned(210, N_tb));
    signal b_tb : std_logic_vector(N_tb-1 downto 0) := std_logic_vector(to_unsigned(210, N_tb));
    signal c_tb : std_logic := '0';
    signal sum_tb: std_logic_vector(N_tb-1 downto 0);
    signal co_tb: std_logic;

begin


    sumNbit_inst : sumNbit
        generic map(
			N => N_tb
		)
        port map(
            a_in    => a_tb,
            b_in    => b_tb,
            c_in    => c_tb,
            sum_out => sum_tb,
            c_out   => co_tb
        );
        

end architecture sumNbit_tb_arq;