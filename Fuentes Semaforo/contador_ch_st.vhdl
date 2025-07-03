library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_pkg.all;

entity contador_ch_st is
    port(
        clk_i    : in std_logic;
        rst_i    : in std_logic;
        seg1_i   : in std_logic;
        estado_i : in t_estado;
        ch_st    : out std_logic
    );
end entity contador_ch_st;

architecture contador_ch_st_arq of contador_ch_st is
    signal aux   : unsigned(4 downto 0) := (others => '0');
    signal ch_st_aux : std_logic := '0';
    
    constant largo : unsigned(4 downto 0) := to_unsigned(30 -1 ,5); -- para 30s
    constant corto : unsigned(4 downto 0) := to_unsigned(3 - 1 ,5);  -- para 3s (0 a 2)

begin
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            aux <= (others => '0');
            ch_st_aux <= '0';
        elsif rising_edge(clk_i) then
            --la linea estaba aca
            if seg1_i = '1' then
                if estado_i = E_R1_V2 or estado_i = E_V1_R2 then
                    if aux = largo then
                        aux <= (others => '0');
                        ch_st_aux <= '1';
                    else
                        aux <= aux + 1;
                        ch_st_aux <= '0';
                    end if;
                else -- estados amarillos
                    if aux = corto then
                        aux <= (others => '0');
                        ch_st_aux <= '1';
                    else
                        aux <= aux + 1;
                        ch_st_aux <= '0';
                    end if;
                end if;
            else
                ch_st_aux <= '0';
            end if;
        end if;
    end process;

    ch_st <= ch_st_aux;

end architecture contador_ch_st_arq;