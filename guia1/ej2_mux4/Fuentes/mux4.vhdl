library IEEE;
use IEEE.std_logic_1164.all;


entity mux4 is
    port(
        a    : in std_logic_vector(3 downto 0);
        b    : in std_logic_vector(3 downto 0);
        c    : in std_logic_vector(3 downto 0);
        d    : in std_logic_vector(3 downto 0);
		sel  : in std_logic_vector (1 downto 0);
		z    : out std_logic_vector(3 downto 0)
    );
end entity mux4;

architecture mux4_arq of mux4 is 

begin
    z <=     a when sel = "00"
        else b when sel = "01"
        else c when sel = "10"
        else d;

end architecture mux4_arq;