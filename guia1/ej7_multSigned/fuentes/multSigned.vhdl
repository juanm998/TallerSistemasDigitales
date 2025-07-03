library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multSigned is
    generic(N : natural := 8);
    port(
        a : in std_logic_vector(N-1 downto 0);
        b : in std_logic_vector(N-1 downto 0);
        y : out std_logic_vector(2*N-1 downto 0)
    );
end entity multSigned;

architecture multSigned_arq of multSigned is
    signal a_signed : signed(N-1 downto 0);
    signal b_signed : signed(N-1 downto 0);
    signal result   : signed(2*N-1 downto 0);
begin
    a_signed <= signed(a);
    b_signed <= signed(b);
    result <= a_signed * b_signed;
    y <= std_logic_vector(result);
end architecture multSigned_arq;