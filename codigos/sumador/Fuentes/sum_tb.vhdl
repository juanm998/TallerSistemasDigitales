library IEEE;
use IEEE.std_logic_1164.all;

entity sum_tb is
end entity sum_tb;

architecture sum_tb_arq of sum_tb is
    
    component sum is
        port(
            a_in : in std_logic;
            b_in : in std_logic;
            c_in : in std_logic;
            sum_out: out std_logic;
            c_out: out std_logic
        );
    end component;

    signal a_tb : std_logic := '0';
    signal b_tb : std_logic := '0';
    signal c_tb : std_logic:= '0';
    signal sum_tb: std_logic;
    signal co_tb: std_logic;

begin
    
    a_tb <= '1' after 50 ns, '0' after 125 ns,'1' after 250 ns; -- Ajuste de tiempos
    b_tb <= '1' after 100 ns, '0' after 175 ns,'1' after 300 ns; -- Ajuste de tiempos
    c_tb <= '1' after 150 ns, '0' after 200 ns,'1' after 300 ns; -- Ajuste de tiempos

    sum_inst : sum
        port map(
            a_in   => a_tb,
            b_in   => b_tb,
            c_in   => c_tb,
            sum_out => sum_tb,
            c_out  => co_tb
        );

end architecture sum_tb_arq;