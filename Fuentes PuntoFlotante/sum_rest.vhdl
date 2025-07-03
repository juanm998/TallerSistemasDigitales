library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- =====================================================================
--  Sumador/restador en formato flotante sign-magnitude de 19 bits
--  Formato: S | Exponente(6) | Mantisa(12)
--  • Bias = 0 (exponente sin sesgo)
--  • Bit oculto implícito cuando Exponente ≠ 0
--  • Saturación simétrica: exp = "111110", mant = "111…1"
--  • Sin redondeo: los desplazamientos simplemente TRUNCAN
--  • Un registro de latencia (la TB lo tiene en cuenta)
-- =====================================================================

entity suma_resta is
    generic(
        TAM_PALABRA : natural := 16+6+1;  -- 1 signo + 6 exp + 12 mant
        TAM_EXP     : natural := 6    -- bits de exponente
    );
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        dato_a     : in  std_logic_vector(TAM_PALABRA-1 downto 0);
        dato_b     : in  std_logic_vector(TAM_PALABRA-1 downto 0);
        operacion  : in  std_logic;      -- '0' = suma, '1' = resta
        resultado  : out std_logic_vector(TAM_PALABRA-1 downto 0)
    );
end entity;

architecture suma_resta_arq of suma_resta is
    ---------------------------------------------------------------------------
    --  Cálculo de tamaños derivados
    ---------------------------------------------------------------------------
    constant TAM_SIGNIFICAND : natural := TAM_PALABRA - TAM_EXP - 1;  -- 12 bits

    ---------------------------------------------------------------------------
    --  Constantes de formato
    ---------------------------------------------------------------------------                
    constant EXP_MAX_FINITO  : unsigned(TAM_EXP-1 downto 0) := to_unsigned(2**TAM_EXP-2, TAM_EXP); -- 62 = "111110"            -- 13 bits (con bit oculto)
    constant MANT_MAX        : std_logic_vector(TAM_SIGNIFICAND-1 downto 0) := (others => '1'); -- 12 bits
    constant ZERO_EXP        : std_logic_vector(TAM_EXP-1 downto 0) := (others => '0');
    constant ZERO_MAN        : std_logic_vector(TAM_SIGNIFICAND-1 downto 0) := (others => '0');
    ----------------------------------------------------------------------------
    --Funciones Utiles
    ----------------------------------------------------------------------------
    function shift_right_ones(A : unsigned; N : natural) return unsigned is
    variable shifted : unsigned(A'range);
    variable result  : unsigned(A'range);
    begin
        
        shifted := shift_right(A, N);
        result := shifted;

        if N >= A'length then
            result := (others => '1');
        else
            result(A'left downto A'left-N+1) := (others => '1');
        end if;
        return result;
    end function;

    -- Conteo de ceros líderes (para normalizar)
    function contar_ceros_lider(v : std_logic_vector) return integer is
        variable cnt : integer := 0;
    begin
        for i in v'high downto v'low loop
            if v(i) = '1' then
                return cnt;
            else
                cnt := cnt + 1;
            end if;
        end loop;
        return cnt;
    end function;

    ---------------------------------------------------------------------------
    --  Registros de I/O y señales internas
    ---------------------------------------------------------------------------
    signal reg_dato_a, reg_dato_b : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    signal reg_operacion          : std_logic;
    signal reg_resultado_o        : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    signal reg_resultado_d        : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');

    -- Campos desempaquetados
    signal signo_a, signo_b                 : std_logic;
    signal exp_a_prima, exp_b_prima, dif_exponentes     : unsigned(TAM_EXP-1 downto 0);
    signal a_prima, b_prima                 : unsigned(TAM_PALABRA-1 downto 0);
    signal mantisa_a,mantisa_b              : unsigned(TAM_SIGNIFICAND downto 0);
    signal mantisa_b_prima_inter            : unsigned(TAM_SIGNIFICAND downto 0);
    signal reg_p_bit                        : unsigned(TAM_SIGNIFICAND + 1 downto 0); --para la guarda
    signal significand_b_shifted            : unsigned(TAM_SIGNIFICAND + 1 downto 0);
    signal exp_resultado_tent               : unsigned(TAM_EXP-1 downto 0);
    signal mantisa_pre_sum                  : unsigned(TAM_SIGNIFICAND downto 0);
    signal mantisa_sum                      : unsigned(TAM_SIGNIFICAND + 1 downto 0); --uno mas para el carry-out
    signal mantisa_preliminar               : unsigned(TAM_SIGNIFICAND  downto 0);
    signal mantisa_ext                      : unsigned(TAM_SIGNIFICAND + 1 downto 0); -- 13 bits + 1 para shiftear con el bit de guarda

    --flags
    signal zero_a,zero_b      : std_logic;
    signal swap               : std_logic;
    signal sign_difrent       : std_logic;
    signal guarda             : std_logic;
    signal carry              : std_logic;
    signal complemento_paso_4 : std_logic;

    signal sign_r : std_logic;
    signal exp_r  : std_logic_vector(TAM_EXP-1 downto 0);
    signal sgnf_r : std_logic_vector(TAM_SIGNIFICAND-1 downto 0);
    

begin
    process(clk, rst) 
    begin
        if rst = '1' then
            reg_dato_a <= (others => '0');
            reg_dato_b <= (others => '0');
            reg_operacion <= '0';
            reg_resultado_o <= (others => '0');
        elsif clk='1' and clk'event then                    
            reg_dato_a <= dato_a;
            reg_dato_b <= dato_b;
            reg_operacion <= operacion;
            reg_resultado_o <= reg_resultado_d;
        end if;
    end process;
    ---------------------------------------------------------------------------
    --  Paso 1
    ---------------------------------------------------------------------------
    
    swap <= '1' when reg_dato_a(TAM_PALABRA-2 downto TAM_SIGNIFICAND) < reg_dato_b(TAM_PALABRA-2 downto TAM_SIGNIFICAND) else '0'; 
    --swapeo si swap es 1
    a_prima <= unsigned(reg_dato_a(TAM_PALABRA-1 downto 0)) when swap = '0' else unsigned(reg_dato_b(TAM_PALABRA-1 downto 0));
    b_prima <= unsigned(reg_dato_b(TAM_PALABRA-1 downto 0)) when swap = '0' else unsigned(reg_dato_a(TAM_PALABRA-1 downto 0));

    exp_a_prima    <= unsigned(a_prima(TAM_PALABRA-2 downto TAM_SIGNIFICAND));
    exp_b_prima    <= unsigned(b_prima(TAM_PALABRA-2 downto TAM_SIGNIFICAND));

    --elijo tentativamente el exponente de a
    exp_resultado_tent <= exp_a_prima(TAM_EXP-1 downto 0);

    zero_a <= '1'
        when (   reg_dato_a(TAM_PALABRA-2 downto TAM_SIGNIFICAND) = ZERO_EXP
                and reg_dato_a(TAM_SIGNIFICAND-1 downto 0)       = ZERO_MAN )
        else '0';

    zero_b <= '1'
        when (   reg_dato_b(TAM_PALABRA-2 downto TAM_SIGNIFICAND) = ZERO_EXP
                and reg_dato_b(TAM_SIGNIFICAND-1 downto 0)       = ZERO_MAN )
        else '0';
    -------------------------------------------------------------------------
    --  Paso 2
    -------------------------------------------------------------------------

    signo_a       <= a_prima(TAM_PALABRA-1);
    signo_b       <= b_prima(TAM_PALABRA-1) when reg_operacion = '0' else not b_prima(TAM_PALABRA-1);
    sign_difrent  <= '1' when signo_a /= signo_b else '0';
    
    mantisa_b <= '1' & b_prima(TAM_SIGNIFICAND-1 downto 0);
    mantisa_b_prima_inter <= ((not mantisa_b(TAM_SIGNIFICAND downto 0)) + 1) when sign_difrent = '1' else mantisa_b(TAM_SIGNIFICAND downto 0);

    -------------------------------------------------------------------------
    --  Paso 3
    -------------------------------------------------------------------------

    reg_p_bit  <= mantisa_b_prima_inter(TAM_SIGNIFICAND downto 0) & '0';

    dif_exponentes <= exp_a_prima - exp_b_prima;

    --En el LSB tiene la guarda
    significand_b_shifted <=  shift_right(reg_p_bit, to_integer(dif_exponentes)) when sign_difrent = '0' else shift_right_ones(reg_p_bit, to_integer(dif_exponentes));

    guarda <= significand_b_shifted(significand_b_shifted'right);
    
    mantisa_pre_sum <= guarda & significand_b_shifted(TAM_SIGNIFICAND downto 1);

    -------------------------------------------------------------------------
    --  Paso 4
    -------------------------------------------------------------------------

    mantisa_a <= '1' & a_prima(TAM_SIGNIFICAND-1 downto 0);
    mantisa_sum <= unsigned('0' & mantisa_a) + unsigned('0' & mantisa_pre_sum); --HASTA ACA VA BIEN
    carry <= mantisa_sum(mantisa_sum'left);
    complemento_paso_4 <= '1' when (sign_difrent = '1' and mantisa_sum(mantisa_sum'left-2) = '1' and carry = '0') else '0'; --PREGUNTAR POR ESTA CONDICION

    mantisa_preliminar <= ((not mantisa_sum(TAM_SIGNIFICAND downto 0)) + 1) when 
                                                    complemento_paso_4 = '1' else           
                                                    mantisa_sum(TAM_SIGNIFICAND downto 0);
    
    -------------------------------------------------------------------------
    --  Paso 5
    -------------------------------------------------------------------------
    process(mantisa_preliminar, exp_resultado_tent, sign_difrent, carry)
    begin
        if sign_difrent = '0' and carry ='1' then
            sgnf_r <= carry & std_logic_vector(mantisa_preliminar(TAM_SIGNIFICAND downto 2));
            exp_r  <= std_logic_vector(exp_resultado_tent + 1);
        else
            mantisa_ext <= mantisa_preliminar(TAM_SIGNIFICAND downto 0) & guarda;
            sgnf_r <= std_logic_vector(shift_left(mantisa_ext, contar_ceros_lider(std_logic_vector(mantisa_ext)))(TAM_SIGNIFICAND  downto 1));
            exp_r  <= std_logic_vector(exp_resultado_tent - contar_ceros_lider(std_logic_vector(mantisa_ext)));
        end if ;

    end process;
    

    -------------------------------------------------------------------------
    --  Paso 6
    -------------------------------------------------------------------------
    process(sign_difrent, swap, complemento_paso_4)
    begin
        if sign_difrent ='0' then
            sign_r <= signo_a; 
        elsif swap = '1' then
            sign_r <= signo_b;
        elsif swap = '0' and complemento_paso_4 ='0' then --complemento_paso_4 = '0'
            sign_r <= signo_a;
        elsif swap = '0' and complemento_paso_4 ='1' then --complemento_paso_4 = '1'
            sign_r <= signo_b;
        end if ;

    end process;

    process(exp_r, reg_dato_a, reg_dato_b)
    begin
        if zero_a = '1' and zero_b = '1' then
            reg_resultado_d <= sign_r & ZERO_EXP & ZERO_MAN;
        elsif zero_a ='1' then
            reg_resultado_d <= signo_b & std_logic_vector(exp_b_prima) & reg_dato_b(TAM_SIGNIFICAND-1 downto 0);
        elsif zero_b ='1' then
            reg_resultado_d <= signo_a & std_logic_vector(exp_a_prima) & reg_dato_a(TAM_SIGNIFICAND-1 downto 0);
        elsif unsigned(exp_r) > EXP_MAX_FINITO then
            reg_resultado_d <= sign_r & std_logic_vector(EXP_MAX_FINITO) & MANT_MAX;
        elsif exp_r = ZERO_EXP then
            reg_resultado_d <= sign_r & ZERO_EXP & ZERO_MAN;
        else
            reg_resultado_d <= sign_r & exp_r & sgnf_r;
        end if;

    end process;

    resultado <= reg_resultado_o;

end architecture suma_resta_arq;