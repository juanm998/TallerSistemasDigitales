library IEEE;
use IEEE.std_logic_1164.all;

entity neg is
    port(
        x_in : in std_logic;
        z_out: out std_logic
    );
end entity neg;

architecture neg_arq of neg is 
begin
    z_out <= not x_in;
end architecture neg_arq;