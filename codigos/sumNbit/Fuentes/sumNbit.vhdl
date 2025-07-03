library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity sumNbit is
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
end entity sumNbit;

architecture sumNbit_arq of sumNbit is 
    component sum is
        port(
            a_in	: in std_logic;
            b_in	: in std_logic;
            c_in   : in std_logic;
            sum_out	: out std_logic;
            c_out  : out std_logic
        );
    end component;

    signal aux:std_logic_vector(N downto 0) := (others => '0');

begin

    aux(0) <= c_in;

    sumNbgen: for i in 0 to N-1 generate
    sum_inst: sum
        port map(
            a_in	=> a_in(i),
            b_in	=> b_in(i),
            c_in	=> aux(i),
            sum_out	=> sum_out(i),
            c_out	=> aux(i+1)
        );
    end generate;

    c_out <= aux(N);


    
end architecture sumNbit_arq;
