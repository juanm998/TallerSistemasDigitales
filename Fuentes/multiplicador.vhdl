library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplicador is
    generic(
        TOTAL_SIZE : natural := 22;  -- ancho total (1 bit signo + EXP_SIZE + mantSize)
        EXP_SIZE   : natural := 6    -- bits de exponente
    );
    port(
        rst_i       : in  std_logic;
        clk_i       : in  std_logic;
        operandoA_i : in  std_logic_vector(TOTAL_SIZE-1 downto 0);
        operandoB_i : in  std_logic_vector(TOTAL_SIZE-1 downto 0);
        resultado_o : out std_logic_vector(TOTAL_SIZE-1 downto 0)
    );
end entity multiplicador;

architecture multiplicador_arq of multiplicador is

    --Constantes genericas
    constant SGFC_SIZE       : natural := TOTAL_SIZE - EXP_SIZE - 1;    
    constant BIAS            : integer := 2**(EXP_SIZE-1) - 1;         
    constant MAX_EXP_NORMAL  : integer := 2**EXP_SIZE - 1;             
    constant ZERO_EXP        : std_logic_vector(EXP_SIZE-1 downto 0) := (others => '0');
    constant ZERO_MAN        : std_logic_vector(SGFC_SIZE-1 downto 0) := (others => '0');
    
    -- Señales para descomponer A y B
    signal is_zero_a, is_zero_b : std_logic;
    signal sign_a, sign_b       : std_logic;
    signal exp_a, exp_b         : unsigned(EXP_SIZE+1 downto 0); 
    signal mant_a, mant_b       : unsigned(SGFC_SIZE downto 0);
    
    -- Cálculos parciales
    signal exp_sum     : signed(EXP_SIZE+1 downto 0);  
    signal mant_prod   : unsigned(2*SGFC_SIZE+1 downto 0);  -- 48 bits
    signal temp_exp    : signed(EXP_SIZE+1 downto 0);            -- 10 bits si EXP_SIZE=8
    signal sgnf_norm   : std_logic_vector(SGFC_SIZE-1 downto 0);          -- 23 bits normalizados
    
    -- Resultado final
    signal sign_r      : std_logic;
    signal exp_r       : std_logic_vector(EXP_SIZE-1 downto 0);
    signal sgnf_r      : std_logic_vector(SGFC_SIZE-1 downto 0);

    -- Registros de input/output
    signal reg_operandoA_i : std_logic_vector(TOTAL_SIZE-1 downto 0);
    signal reg_operandoB_i : std_logic_vector(TOTAL_SIZE-1 downto 0);
    signal reg_resultado_o : std_logic_vector(TOTAL_SIZE-1 downto 0);

    signal reg_resultado_d : std_logic_vector(TOTAL_SIZE-1 downto 0);

-- 8 bits
-- -------
-- e_a     : 0 a 255   exp_a: -127 a + 128  ---> require 9 bits en 2C
-- e_b     : 0 a 255   exp_b: -127 a + 128  ---> require 9 bits en 2C
-- exp_r   : -254 a +256 --> require 10 bits en 2C
-- temp_exp: -254 a +257 --> require 10 bits en 2C
-- temp_exp_empaquetado : -127 a +384 ---> require 10 bits en 2C


begin

    process(clk_i,rst_i) begin
        if rst_i = '1' then
            reg_operandoA_i <= (others => '0');
            reg_operandoB_i <= (others => '0');
            reg_resultado_o <= (others => '0');
        elsif clk_i='1' and clk_i'event then                    
            reg_operandoA_i <= operandoA_i;
            reg_operandoB_i <= operandoB_i;
            reg_resultado_o <= reg_resultado_d;
        end if;
    end process;


    is_zero_a <= '1'
        when (   reg_operandoA_i(TOTAL_SIZE-2 downto SGFC_SIZE) = ZERO_EXP
                and reg_operandoA_i(SGFC_SIZE-1 downto 0)       = ZERO_MAN )
        else '0';

    is_zero_b <= '1'
        when (   reg_operandoB_i(TOTAL_SIZE-2 downto SGFC_SIZE) = ZERO_EXP
                and reg_operandoB_i(SGFC_SIZE-1 downto 0)       = ZERO_MAN )
        else '0';

    -- 2) Descomponer A 
    sign_a <= reg_operandoA_i(TOTAL_SIZE-1);
    exp_a  <= unsigned("00" & reg_operandoA_i(TOTAL_SIZE-2 downto SGFC_SIZE));
    mant_a <= unsigned('1' & reg_operandoA_i(SGFC_SIZE-1 downto 0));

    

    --Descomponer B
    sign_b <= reg_operandoB_i(TOTAL_SIZE-1);
    exp_b  <= unsigned("00" & reg_operandoB_i(TOTAL_SIZE-2 downto SGFC_SIZE));
    mant_b <= unsigned('1' & reg_operandoB_i(SGFC_SIZE-1 downto 0));


    -- sumar exponentes y restar bias (ajustado con resize)
    exp_sum <= signed(exp_a) + signed(exp_b) - to_signed(BIAS, EXP_SIZE+2);

    -- producto de mantisas
    mant_prod <= mant_a * mant_b;

    -- normalización
    process(mant_prod, exp_sum)
    begin
        if mant_prod(2*SGFC_SIZE+1) = '1' then
            -- El bit 47 = '1' → producto en [2.0, 4.0)
            sgnf_norm <= std_logic_vector(mant_prod(2*SGFC_SIZE downto SGFC_SIZE +1));
            -- mant_prod(47 downto 24)
            temp_exp  <= exp_sum + 1;
        else
            -- El bit 47 = '0' → producto en [1.0, 2.0)
            sgnf_norm <= std_logic_vector(mant_prod(2*SGFC_SIZE-1 downto SGFC_SIZE));  
            -- mant_prod(46 downto 23)
            temp_exp  <= exp_sum;
        end if;
    end process;

    -- ----------------------------------------------------------------
    --Empaquetado
    -- ----------------------------------------------------------------

    -- signo resultado
    sign_r <= sign_a xor sign_b;

    process(is_zero_a, is_zero_b, temp_exp, sgnf_norm, rst_i)
    begin
        if rst_i = '1' then
            -- Durante reset, forzamos salida a cero (evitamos comparar temp_exp)
            sgnf_r <= (others => '0');
            exp_r  <= (others => '0');

        elsif is_zero_a = '1' or is_zero_b = '1' then
            -- Caso +0/–0 exactos (sin reset activo)
            sgnf_r <= (others => '0');
            exp_r  <= (others => '0');

        -- Underflow (temp_exp < 0) → +0
        elsif temp_exp(EXP_SIZE+1) = '1' then
            sgnf_r <= (others => '0');
            exp_r  <= (others => '0');

        -- temp_exp = 0 → +0 (flush‐to‐zero, sin denormales)
        elsif temp_exp = to_signed(0, EXP_SIZE+2) then
            sgnf_r <= (others => '0');
            exp_r  <= (others => '0');

        -- Overflow (temp_exp ≥ MAX_EXP_NORMAL) → saturar al finito máximo
        elsif temp_exp >= to_signed(MAX_EXP_NORMAL, EXP_SIZE+2) then
            sgnf_r <= (others => '1');
            exp_r  <= std_logic_vector(to_unsigned(MAX_EXP_NORMAL-1, EXP_SIZE));

        else
            -- Caso normal (1 ≤ temp_exp ≤ MAX_EXP_NORMAL–1)
            sgnf_r <= sgnf_norm;
            exp_r  <= std_logic_vector(temp_exp(EXP_SIZE-1 downto 0));
        end if;
    end process;

    reg_resultado_d <= sign_r & exp_r & sgnf_r;
    -- ----------------------------------------------------------------

    -- Asigno la salida
    resultado_o <= reg_resultado_o;
    
end architecture multiplicador_arq;