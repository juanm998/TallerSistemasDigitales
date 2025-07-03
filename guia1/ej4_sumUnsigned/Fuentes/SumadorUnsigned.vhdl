library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumadorUnsigned is
    
    generic(N : natural := 8);
    port(
        x0 : in std_logic_vector(N-1 downto 0);
        x1 : in std_logic_vector(N-1 downto 0);
        y : out std_logic_vector(N downto 0)
);
end sumadorUnsigned;

architecture sumadorUnsigned_arq of sumadorUnsigned is

signal extended_x0 : unsigned(N downto 0);
signal extended_x1 : unsigned(N downto 0);
begin
    extended_x0 <= '0' & unsigned(x0);
    extended_x1 <= '0' & unsigned(x1);
    y <= std_logic_vector(extended_x0 + extended_x1);
    
end sumadorUnsigned_arq;