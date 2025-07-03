library IEEE;
use IEEE.std_logic_1164.all;


entity and is
    port(
        a: in std_logic;
		b: in std_logic;
		z: out std_logic
    );
end entity and;

architecture and_arq of and is 

begin
    z <= a and b;

end architecture and_arq;