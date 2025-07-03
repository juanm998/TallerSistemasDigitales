library IEEE;
use IEEE.std_logic_1164.all;

entity sum is
    port(
        a_in : in std_logic;
        b_in : in std_logic;
        c_in : in std_logic;
        sum_out: out std_logic;
        c_out: out std_logic
    );
end entity sum;

architecture sum_arq of sum is 
begin
    sum_out <= a_in xor b_in xor c_in;
    c_out   <= (a_in and b_in) or (a_in and c_in) or (b_in and c_in);
end architecture sum_arq;