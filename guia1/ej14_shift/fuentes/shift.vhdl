library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
generic (
    N: natural := 8
);
port(
    rst : in std_logic;
    clk: in std_logic;
    data_in : in std_logic;
    data_out : out std_logic
);
end shift_reg;

architecture behavioral of shift_reg is
    signal sr : std_logic_vector(N-1 downto 0);
begin
    process(clk,rst)
    begin
        if rst='1' then
            sr <= (others => '0');
        elsif clk = '1' and clk'event then
            sr(N-1 downto 1) <= sr(N-2 downto 0);
            sr(0) <= data_in;
        end if;
    end process;
    data_out <= sr(N-1);
end behavioral;