library IEEE;
use IEEE.std_logic_1164.all;


entity or is
    port(
        a: in std_logic;
		b: in std_logic;
		z: out std_logic
    );
end entity or;

architecture or_arq of or is 

begin
    z <= a or b;

end architecture or_arq;