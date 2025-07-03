library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity restadorSigned is
    generic(
        N : natural := 8
    );
    port(
        a : in std_logic_vector(N-1 downto 0);
        b : in std_logic_vector(N-1 downto 0);
        y : out std_logic_vector(N-1 downto 0)
    );
end entity restadorSigned;

architecture restadorSigned_arq of restadorSigned is
    signal signed_a : signed(N-1 downto 0);
    signal signed_b : signed(N-1 downto 0);
    signal result   : signed(N-1 downto 0);
begin
    signed_a <= signed(a);
    signed_b <= signed(b);
    result   <= signed_a - signed_b;
    y        <= std_logic_vector(result);
end architecture restadorSigned_arq;