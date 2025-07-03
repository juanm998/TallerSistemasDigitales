library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplicador is
    generic (
        N : natural := 4
    );
    port(
        A    : in std_logic_vector(N-1 downto 0);
        B    : in std_logic_vector(N-1 downto 0);
        load : in std_logic;
        clk  : in std_logic;
        Sal  : out std_logic_vector(2*N-1 downto 0)
    );
end entity multiplicador;

architecture multiplicador_arq of multiplicador is

    component registro is
        generic(N: integer:= 4);
        port(
            D    : in std_logic_vector(N-1 downto 0);
            clk  : in std_logic;
            rst  : in std_logic;
            ena  : in std_logic;
            Q    : out std_logic_vector(N-1 downto 0)  -- corregido también aquí
        );
    end component;

    component sumador is
        generic(N: integer:= 4);
        port(
            A    : in std_logic_vector(N-1 downto 0);
            B    : in std_logic_vector(N-1 downto 0);
            Cin  : in std_logic;
            Sal  : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component;

    signal entP, entB, salP, salSum, salB, salA, aux : std_logic_vector(N-1 downto 0); 
    signal Co : std_logic;

begin
        -- instanciación del registro A
        regA: registro generic map(N) port map(A, clk, '0', '1', salA);
        -- instanciación del registro B
        regB: registro generic map(N) port map(entB, clk, '0', '1', salB);
        -- instanciación del registro P
        regP: registro generic map(N) port map(entP, clk, load, '1', salP);
        -- instanciación del sumador
        sum: sumador generic map(N) port map(salP, aux, '0', salSum, Co);

        entP <= Co & salSum(N-1 downto 1);
        entB <= B when load = '1' else
                      salSum(0) & salB(N-1 downto 1);
        aux <= salA when salB(0) = '1' else
                   (others => '0');
        

    Sal <= salP & salB;

end architecture multiplicador_arq;
