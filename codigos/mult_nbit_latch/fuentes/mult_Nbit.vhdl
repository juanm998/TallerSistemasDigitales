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

    component shift_register is
        generic (
            N : natural := 8
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            load  : in  std_logic;
            data_in : in  std_logic_vector(N-1 downto 0);
            q     : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal entP, entB, salP, salSum, salB, salA, aux : std_logic_vector(N-1 downto 0); 
    signal Co : std_logic;
    signal salida_aux : std_logic_vector(2*N-1 downto 0) := (others => '0');

    --señales para el shift register
    signal ok : std_logic_vector(N-1 downto 0) ;
    signal shift_reg_init : std_logic_vector(N-1 downto 0)  ;
    signal shift_reg_aux : std_logic_vector(N-1 downto 0) := (others => '0');
    signal load_pulse : std_logic := '0';
    signal load_prev : std_logic := '0';

begin
        -- Inicialización al tiempo 0
        init_proc: process
        begin
        -- ok = "000...001"
            ok <= (others => '0');
            ok(0) <= '1';
        -- shift_reg_init = "100...000"
            shift_reg_init <= (others => '0');
            shift_reg_init(N-1) <= '1';
            wait;  -- se suspende para no repetir
        end process;

        -- instanciación del registro A
        regA: registro generic map(N) port map(A, clk, '0', '1', salA);
        -- instanciación del registro B
        regB: registro generic map(N) port map(entB, clk, '0', '1', salB);
        -- instanciación del registro P
        regP: registro generic map(N) port map(entP, clk, load, '1', salP);
        -- instanciación del sumador
        sum: sumador generic map(N) port map(salP, aux, '0', salSum, Co);
        --instanciacion del registro de desplazamiento
        ShiftReg: shift_register generic map(N) port map( clk, '0', load_pulse, shift_reg_init, shift_reg_aux);

        entP <= Co & salSum(N-1 downto 1);
        entB <= B when load = '1' else
                    salSum(0) & salB(N-1 downto 1);
        aux <= salA when salB(0) = '1' else
                (others => '0');

        process(clk)
        begin
            if rising_edge(clk)  then
                if load = '1' and load_prev = '0' then
                    load_pulse <= '1';
                else
                    load_pulse <= '0';
                end if;

                if shift_reg_aux = ok then
                    salida_aux <= salP & salB;
                end if;
                
                load_prev <= load;    
            end if;
        end process;
        

    Sal <= salida_aux;

end architecture multiplicador_arq;
