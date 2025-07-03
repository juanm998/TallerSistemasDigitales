library IEEE;
use IEEE.std_logic_1164.all;


entity oai is
    port(
        a,b,c,d: in std_logic;
		z: out std_logic
    );
end entity oai;

architecture oai_arq of oai is 

begin
    z <= not ((a or b) and (c or d));

end architecture oai_arq;