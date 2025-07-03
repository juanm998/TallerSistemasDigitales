library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd_tb is
end entity ffd_tb;

architecture ffd_tb_arq of ffd_tb is
    
    component ffd is
        port(
            d_i     : in std_logic;
            rst_i   : in std_logic;
            ena_i   : in std_logic;
            clk_i   : in std_logic;
            q_o     : out std_logic
        );
    end component ffd;

        signal d_tb     : std_logic := '0';
        signal rst_tb   : std_logic := '0';
        signal ena_tb   : std_logic := '0';
        signal clk_tb   : std_logic := '0';
        signal q_tb     : std_logic;

begin
    
    d_tb     <= '1' after 100 ns, '0' after 150 ns ,  '1' after 300 ns;
    rst_tb   <= '1' after 320 ns;
    ena_tb   <= '1' after 125 ns;
    clk_tb   <= not clk_tb after 10 ns;

    ffd_inst : ffd
        port map(
            d_i    => d_tb,
            rst_i  => rst_tb,
            ena_i  => ena_tb,
            clk_i  => clk_tb,
            q_o   => q_tb
        );

end architecture ffd_tb_arq;