library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric.std.all;

entity fsm is
    port(
        rst: in std_logic;
        clk: in std_logic;
        data_in : in std_logic;
        detect : out std_logic;
    );
end entity fsm;

--architecture shift_reg_arq of fsm is
--    signal aux: std_logic_vector(6 downto 0);
--begin
--    process(clk,rst)
--        if rst = '1' then
--            aux <= (others => '0');
--        elsif clk = '1' and clk'event then
--            aux(6 downto 1) <= aux(5 downto 0);
--            aux(0) <= data_in;
--        end if;
--    end process;

--    detect <= '1' when aux ="0010110" else '0';

--end shift_reg_arq;

architecture state_arq of fsm is
    type t_state is (S0,S1,S2,S3,S4,S5,S6);
    signal state : t_state;
begin
    process(clk,rst)
        if rst = '1' then
            state <= S0;
        elsif clk = '1' and clk'event then
            case state is
                when S0 =>
                    if data_in = '0' then
                        state <= S1;
                    end if;
                when S1 =>
                    if data_in = '1' then
                        state <= S2;
                    end if;
                when S2 =>
                    if data_in = '0' then
                        state <= S3;
                    else
                        state <= S0;
                    end if;
                when S3 =>
                    if data_in = '1' then
                        state <= S4;
                    else
                        state <= S0;
                    end if;
                when S4 =>
                    if data_in = '1' then
                        state <= S5;
                    else
                        state <= S0;
                    end if;
                when S5 =>
                    if data_in = '0' then
                        state <= S6;
                    else
                        state <= S0;
                    end if;
                when S6 =>
                    if data_in = '0' then
                        state <= S1;
                    else
                        state <= S0;
                    end if;
            end case;
        end if;
    end process;

    detect <= '1' when state = S6 else '0';  --0101100

--    S0 -> "0"
--    S1 -> "00"
--    S2 -> "001"
--    S3 -> "0010"
--    S4 -> "00101"
--    S5 -> "001011"
--    S6-> "0010110"

end state_arq;