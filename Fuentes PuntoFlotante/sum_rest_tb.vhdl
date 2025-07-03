library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity pf_testbench is
end entity pf_testbench;

architecture pf_testbench_arq of pf_testbench is
    constant TCK         : time    := 20 ns;
    constant DELAY       : natural := 1;
    constant WORD_SIZE_T : natural := 16+6+1;
    constant EXP_SIZE_T  : natural := 6;

    signal rst           : std_logic := '1';
    signal clk           : std_logic := '0';
    signal sel           : std_logic := '0'; -- '0' suma: '1' resta
    signal a_file        : unsigned(WORD_SIZE_T-1 downto 0) := (others => '0');
    signal b_file        : unsigned(WORD_SIZE_T-1 downto 0) := (others => '0');
    signal z_file        : unsigned(WORD_SIZE_T-1 downto 0) := (others => '0');
    signal z_del         : unsigned(WORD_SIZE_T-1 downto 0) := (others => '0');
    signal z_duv         : unsigned(WORD_SIZE_T-1 downto 0) := (others => '0');
    
    signal ciclos        : integer := 0;
    signal errores       : integer := 0;

    signal z_duv_aux : std_logic_vector(WORD_SIZE_T-1 downto 0) := (others => '0');
    signal z_del_aux : std_logic_vector(WORD_SIZE_T-1 downto 0) := (others => '0');

    file datos : text open read_mode is "prueba.txt";

    component suma_resta is
        generic(
            TAM_PALABRA         : natural := 16+6+1;  -- ancho total del dato (signo+exponente+mantisa)
            TAM_EXP             : natural := 6    -- ancho del campo exponente
        );
        port(
            clk                 : in  std_logic;                            -- señal de reloj
            rst                 : in  std_logic;                            -- señal de reset síncrono
            dato_a              : in  std_logic_vector(TAM_PALABRA-1 downto 0);
            dato_b              : in  std_logic_vector(TAM_PALABRA-1 downto 0);
            operacion           : in  std_logic;                            -- '0' = suma, '1' = resta
            resultado           : out std_logic_vector(TAM_PALABRA-1 downto 0) -- salida registrada
        );
    end component;

    component delay_gen is
        generic(
            N     : natural := WORD_SIZE_T;
            DELAY : natural := DELAY
        );
        port(
            clk : in  std_logic;
            A   : in  std_logic_vector(N-1 downto 0);
            B   : out std_logic_vector(N-1 downto 0)
        );
    end component;

begin

    rst <= '0' after 5 ns;
    clk <= not clk after TCK/2;

    Test_Sequence: process
        variable l   : line;
        variable aux : integer;
        variable ch  : character;
    begin
        while not endfile(datos) loop
            wait until rising_edge(clk);
            ciclos <= ciclos + 1;

            readline(datos, l);
            read(l, aux);
            a_file <= to_unsigned(aux, WORD_SIZE_T);

            read(l, ch);
            read(l, aux);
            b_file <= to_unsigned(aux, WORD_SIZE_T);

            read(l, ch);
            read(l, aux);
            z_file <= to_unsigned(aux, WORD_SIZE_T);
        end loop;

        file_close(datos);
        wait for TCK*(DELAY+1);
        report "Fin de la simulación: todos los vectores procesados." severity note;
        wait;
    end process Test_Sequence;

    DUV: suma_resta
        generic map(
            TAM_PALABRA => WORD_SIZE_T,
            TAM_EXP   => EXP_SIZE_T
        )
        port map(
            rst           => rst,
            clk           => clk,
            operacion     => sel,
            dato_a        => std_logic_vector(a_file),
            dato_b        => std_logic_vector(b_file),
            resultado     => z_duv_aux
        );

    z_duv <= unsigned(z_duv_aux);

    DEL: delay_gen
        generic map (
            N     => WORD_SIZE_T,
            DELAY => DELAY
        )
        port map (
            clk => clk,
            A   => std_logic_vector(z_file),
            B   => z_del_aux
        );

    z_del <= unsigned(z_del_aux);

    verificacion: process(clk)
    begin
        if rising_edge(clk) then
            assert to_integer(z_del) = to_integer(z_duv)
                report "Error: DUV=" & integer'image(to_integer(z_duv)) &
                    " ref=" & integer'image(to_integer(z_del))
                severity warning;--failure
            if to_integer(z_del) /= to_integer(z_duv) then
                errores <= errores + 1;
            end if;
        end if;
    end process verificacion;

end architecture pf_testbench_arq;