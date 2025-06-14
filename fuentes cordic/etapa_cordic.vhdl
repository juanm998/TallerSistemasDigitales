library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity etapa_cordic is
    generic(
        N : natural := 16;
        NL : natural := 4  -- clog2(N)
    );
    port(
        xi   : in  signed(N+1 downto 0);
        yi   : in  signed(N+1 downto 0);
        zi   : in  signed(N+1 downto 0);
        bi   : in  signed(N+1 downto 0);
        i    : in  std_logic_vector(NL-1 downto 0);
        xip1 : out signed(N+1 downto 0);
        yip1 : out signed(N+1 downto 0);
        zip1 : out signed(N+1 downto 0)
    );
end entity etapa_cordic;

architecture etapa_cordic_arq of etapa_cordic is

    function shift_right(x: in signed(N+1 downto 0); i: in std_logic_vector(NL-1 downto 0)) return signed(N+1 downto 0) is
        variable result : signed(N+1 downto 0);
        variable shift_amt : integer;
    begin
        shift_amt := to_integer(unsigned(i));
        result := shift_right(x, shift_amt);  -- lógica aritmética
        return result;
    end function;

    signal xsr : signed(N+1 downto 0);
    signal ysr : signed(N+1 downto 0);
    signal di  : std_logic;

begin
    xsr  <= shift_right(xi, i);
    ysr  <= shift_right(yi, i);
    di   <= zi(N+1);  -- bit de signo

    xip1 <= xi - ysr when di = '0' else xi + ysr;
    yip1 <= yi + xsr when di = '0' else yi - xsr;
    zip1 <= zi - bi  when di = '0' else zi + bi;

end architecture;