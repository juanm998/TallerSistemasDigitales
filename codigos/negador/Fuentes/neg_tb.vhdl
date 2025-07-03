library IEEE;
use IEEE.std_logic_1164.all;

entity neg_tb is
end entity neg_tb;

architecture neg_tb_arq of neg_tb is
    
    component neg is
        port(
            x_in : in std_logic;
            z_out: out std_logic
        );
    end component;

    signal x_tb : std_logic := '0';
    signal z_tb : std_logic;

begin
    
    x_tb <= '1' after 100 ns, '0' after 200 ns,'1' after 300 ns; -- Ajuste de tiempos

    neg_inst : neg
        port map(
            x_in => x_tb,
            z_out => z_tb
        );

end architecture neg_tb_arq;