library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_pkg.all;

entity fsm_semaforo is
    port(
        clk_i   : in std_logic;
        rst_i   : in std_logic;
        ch_st   : in std_logic;
        estado  : out t_estado
    );
end entity fsm_semaforo;

architecture fsm_semaforo_arq of fsm_semaforo is

    signal estado_aux : t_estado := E_R1_V2;

begin

    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            estado_aux <= E_R1_V2;
        elsif rising_edge(clk_i) then
            if ch_st = '1' then
                case estado_aux is
                    when E_R1_V2 =>
                        estado_aux <= E_R1_A2;
                    when E_R1_A2 =>
                        estado_aux <= E_A1_R2;
                    when E_A1_R2 =>
                        estado_aux <= E_V1_R2;
                    when E_V1_R2 =>
                        estado_aux <= E_R2_A1;
                    when E_R2_A1 =>
                        estado_aux <= E_A2_R1;
                    when E_A2_R1 =>
                        estado_aux <= E_R1_V2;
                end case;
            end if;
        end if;
    end process;

    estado <= estado_aux;

end architecture fsm_semaforo_arq;