library IEEE;
use IEEE.std_logic_1164.all;

entity shift_register_en is
    generic (
        N : natural := 8
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        load    : in  std_logic;
        data_in : in  std_logic_vector(N-1 downto 0);
        q       : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture behavioral of shift_register_en is
    signal reg : std_logic_vector(N-1 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                if load = '1' then
                    reg <= data_in;  -- Carga directa
                else
                    reg <= '0' & reg(N-1 downto 1);  -- Desplazamiento a la derecha
                end if;
            end if;
        end if;
    end process;

    q <= reg;
end architecture;