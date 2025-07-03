library ieee;
use ieee.std_logic_1164.all;

entity delay_gen is
    generic (
    N      : natural := 19;  -- ancho de palabra
    DELAY  : natural := 1    -- cantidad de ciclos de retardo
    );
    port (
        clk : in  std_logic;
        A   : in  std_logic_vector(N-1 downto 0);
        B   : out std_logic_vector(N-1 downto 0)
    );
end entity delay_gen;

architecture rtl of delay_gen is
    type arr is array (natural range <>) of std_logic_vector(N-1 downto 0);
    signal regs : arr(0 to DELAY) := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            regs(0) <= A;
            for i in 1 to DELAY loop
                regs(i) <= regs(i-1);
            end loop;
        end if;
    end process;

    B <= regs(DELAY);
end architecture rtl;