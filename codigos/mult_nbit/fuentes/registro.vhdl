library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registro is
    generic(N: integer:= 4);		-- valor genérico
    port(
         D: in std_logic_vector(N-1 downto 0);	-- entrada del registro
         clk: in std_logic;			-- señal de reloj
         rst: in std_logic;			-- señal de reset
         ena: in std_logic;		-- señal de habilitación
         Q: out std_logic_vector(N-1 downto 0)	-- salida del registro
    );
end;

architecture reg_arq of registro is 
    begin
        
        process(clk)
        begin
            if rising_edge(clk) then	-- if clk_i'event and clk_i = '1' then
                if rst = '1' then
                    Q <= (others => '0');
                elsif ena = '1' then
                    Q <= D;         -- Proximo_estado <= Estado_actual  {F|P}
                end if;
            end if;
        end process;
    
    end architecture reg_arq;