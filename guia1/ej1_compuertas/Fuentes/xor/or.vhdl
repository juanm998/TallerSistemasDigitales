library IEEE;
use IEEE.std_logic_1164.all;


entity xor is
    port(
        a: in std_logic;
		b: in std_logic;
		z: out std_logic
    );
end entity xor;

architecture xor_arq of xor is 

begin
    z <= a xor b;

end architecture xor_arq;