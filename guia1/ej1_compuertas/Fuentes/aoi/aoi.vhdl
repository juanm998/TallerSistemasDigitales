library IEEE;
use IEEE.std_logic_1164.all;


entity aoi is
    port(
        a,b,c,d: in std_logic;
		z: out std_logic
    );
end entity aoi;

architecture aoi_arq of aoi is 

begin
    z <= not ((a and b) or (c and d));

end architecture aoi_arq;