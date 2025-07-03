library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg is
    generic(
        N: natural := 4
    );
    port(
        d_i     : in std_logic_vector(N-1 downto 0);
        rst_i   : in std_logic;
        ena_i   : in std_logic;
        clk_i   : in std_logic;
        q_o     : out std_logic_vector(N-1 downto 0)
    );
end entity reg;


architecture reg_arq of reg is 

signal q_reg : std_logic_vector(N-1 downto 0) := (others => '0');

begin
    
    process(clk_i)
	begin
		if rising_edge(clk_i) then	-- if clk_i'event and clk_i = '1' then
			if rst_i = '1' then
				q_o <= (others => '0');
			elsif ena_i = '1' then
				q_o <= d_i;         -- Proximo_estado <= Estado_actual  {F|P}
			end if;
		end if;
	end process;

end architecture reg_arq;