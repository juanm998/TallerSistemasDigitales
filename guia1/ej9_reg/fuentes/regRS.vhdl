library IEEE;
use IEEE.std_logic_1164.all;

entity registro_reset_async is
    generic (
        N : integer := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        d   : in std_logic_vector(N-1 downto 0);
        q   : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture behavioral of registro_reset_async is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= (others => '0');
            else 
                q <= d;
            end if;
        end if;
    end process;
end architecture;
