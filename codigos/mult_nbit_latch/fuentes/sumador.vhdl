library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sumador is
    generic(N: integer:= 4);
    port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Cin: in std_logic;
        Sal: out std_logic_vector(N-1 downto 0);
        Cout: out std_logic
    );
end entity;

architecture Behavioral of sumador is
  -- declaración de una señal auxiliar
  signal Sal_aux: std_logic_vector(N+1 downto 0);

begin

    Sal_aux <= std_logic_vector(
                        unsigned('0' & A & Cin) + unsigned('0' & B & '1')
                        );
    Sal <= Sal_aux(N downto 1);				
    Cout <= Sal_aux(N+1);				
    
end architecture Behavioral;