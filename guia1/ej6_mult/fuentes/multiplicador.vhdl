library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity multiplicador is
    generic (N : natural:= 8);
    port(
        x1: in std_logic_vector(N-1 downto 0);
        x2: in std_logic_vector(N-1 downto 0);
        y : out std_logic_vector(2*(N-1) downto 0)
    );
end multiplicador;

architecture multiplicador_arq of multiplicador is

begin
    y <= std_logic_vector(unsigned(x1) * unsigned(x2));
end multiplicador_arq ; 