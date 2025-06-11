library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sum_rest is
    generic(
        TOTAL_SIZE : natural := 19;  -- ancho total (signo + exponente + mantisa)
        EXP_SIZE   : natural := 6    -- bits de exponente
    );
    port(
        rst_i           : in  std_logic;
        clk_i           : in  std_logic;
        sum_rest_select : in  std_logic;                                 -- 0 = sumar / 1 = restar
        operandoA_i     : in  std_logic_vector(TOTAL_SIZE-1 downto 0);
        operandoB_i     : in  std_logic_vector(TOTAL_SIZE-1 downto 0);
        resultado_o     : out std_logic_vector(TOTAL_SIZE-1 downto 0)
    );
end entity sum_rest;

architecture sum_rest_arq of sum_rest is

    ----------------------------------------------------------------------------
    --  Función para contar cuántos ceros preceden al primer '1'
    ----------------------------------------------------------------------------
    function count_leading_zeros(v : std_logic_vector) return integer is
        variable cnt : integer := 0;
    begin
        for i in v'high downto v'low loop
            if v(i) = '1' then
                return cnt;
            else
                cnt := cnt + 1;
            end if;
        end loop;
        return cnt;  -- si todo es '0', devuelve la longitud completa
    end function count_leading_zeros;

    signal zeros : integer := 0;

    ----------------------------------------------------------------------------
    --  Constantes derivadas de TOTAL_SIZE y EXP_SIZE
    ----------------------------------------------------------------------------
    constant SGFC_SIZE      : natural := TOTAL_SIZE - EXP_SIZE - 1;       
    constant MAX_EXP_NORMAL : integer := 2**EXP_SIZE - 2;               -- exponente máximo normal antes de Inf (valido)
    constant ZERO_MAN       : std_logic_vector(SGFC_SIZE-1 downto 0) := (others => '0'); -- mantisa cero para Inf
    constant ONE_MAN         : std_logic_vector(SGFC_SIZE-1 downto 0) := (others => '1'); -- mantisa cero para Inf
    constant ZERO_EXP       : std_logic_vector(EXP_SIZE-1 downto 0)    := (others => '0');

    -- Señales para detectar “operando = 0”
    signal is_zero_a, is_zero_b : std_logic := '0';

    ----------------------------------------------------------------------------
    --  Señales registradas (pipeline de entrada/salida)
    ----------------------------------------------------------------------------
    signal reg_opA         : std_logic_vector(TOTAL_SIZE-1 downto 0) := (others => '0');
    signal reg_opB         : std_logic_vector(TOTAL_SIZE-1 downto 0) := (others => '0');
    signal reg_resultado_d : std_logic_vector(TOTAL_SIZE-1 downto 0) := (others => '0');  -- resultado combinacional
    signal reg_resultado_o : std_logic_vector(TOTAL_SIZE-1 downto 0) := (others => '0');  -- salida registrada

    ----------------------------------------------------------------------------
    --  Señales internas para cálculo de punto flotante
    ----------------------------------------------------------------------------
    signal exp_a, exp_b               : std_logic_vector(EXP_SIZE-1 downto 0);
    signal dif_exp                    : signed(EXP_SIZE downto 0); --1 bit mas para ver comparar
    signal sign_grande, sign_chico    : std_logic;
    signal exp_grande, exp_chico      : std_logic_vector(EXP_SIZE-1 downto 0);
    signal sgfc_grande, sgfc_chico    : std_logic_vector(SGFC_SIZE-1 downto 0);

    signal mant_grande, mant_chico     : signed(SGFC_SIZE downto 0);
    signal mant_chico_shifted          : signed(SGFC_SIZE downto 0);

    signal mant_sum                   : signed(SGFC_SIZE+1 downto 0):= (others => '0'); --bit extra
    signal signo_result               : std_logic;
    signal exp_inter                  : signed(EXP_SIZE downto 0):= (others => '0');

    signal mant_norm                  : std_logic_vector(SGFC_SIZE downto 0):= (others => '0');
    signal exp_norm                   : signed(EXP_SIZE downto 0) := (others => '0');

begin

    ----------------------------------------------------------------------------
    --  Proceso síncrono: reset + registro de entradas y registro de salida
    ----------------------------------------------------------------------------
    pipeline_regs: process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            reg_opA         <= (others => '0');
            reg_opB         <= (others => '0');
            reg_resultado_o <= (others => '0');
        elsif rising_edge(clk_i) then
            -- Capturar entradas
            reg_opA         <= operandoA_i;
            reg_opB         <= operandoB_i;
            -- Registrar el resultado calculado combinacionalmente
            reg_resultado_o <= reg_resultado_d;
        end if;
    end process pipeline_regs;
    

    ----------------------------------------------------------------------------
    --  Extraer exponente de A y B desde los registros
    ----------------------------------------------------------------------------
    exp_a <= reg_opA(TOTAL_SIZE-2 downto SGFC_SIZE);
    exp_b <= reg_opB(TOTAL_SIZE-2 downto SGFC_SIZE);

    ----------------------------------------------------------------------------
    --  Comparar exponentes para distinguir “grande” vs “chico”
    ----------------------------------------------------------------------------
    dif_exp <= signed('0' & exp_a) - signed('0' & exp_b);

    sign_grande <= reg_opA(TOTAL_SIZE-1) when dif_exp(EXP_SIZE) = '0'
                else reg_opB(TOTAL_SIZE-1);
    exp_grande  <= reg_opA(TOTAL_SIZE-2 downto SGFC_SIZE) when dif_exp(EXP_SIZE) = '0'
                else reg_opB(TOTAL_SIZE-2 downto SGFC_SIZE);
    sgfc_grande <= reg_opA(SGFC_SIZE-1 downto 0) when dif_exp(EXP_SIZE) = '0'
                else reg_opB(SGFC_SIZE-1 downto 0);

    sign_chico  <= reg_opB(TOTAL_SIZE-1) when dif_exp(EXP_SIZE) = '0'
                else reg_opA(TOTAL_SIZE-1);
    exp_chico   <= reg_opB(TOTAL_SIZE-2 downto SGFC_SIZE) when dif_exp(EXP_SIZE) = '0'
                else reg_opA(TOTAL_SIZE-2 downto SGFC_SIZE);
    sgfc_chico  <= reg_opB(SGFC_SIZE-1 downto 0) when dif_exp(EXP_SIZE) = '0'
                else reg_opA(SGFC_SIZE-1 downto 0);

    ----------------------------------------------------------------------------
    --  Detectar cero en A y B
    ----------------------------------------------------------------------------
    is_zero_a <= '1' when exp_a = ZERO_EXP and reg_opA(SGFC_SIZE-1 downto 0) = ZERO_MAN
                    else '0';

    is_zero_b <= '1' when exp_b = ZERO_EXP and reg_opB(SGFC_SIZE-1 downto 0)  = ZERO_MAN
                else '0';


    ----------------------------------------------------------------------------
    --  Formar las mantizas con bit implícito = '1'
    --    ( que no hay entradas subnormales; exp=0 => cero)
    ----------------------------------------------------------------------------
    mant_grande <= '1' & signed(sgfc_grande);
    mant_chico  <= '1' & signed(sgfc_chico);

    ----------------------------------------------------------------------------
    --  Alinear mantisa “chica”: desplazar a la derecha
    ----------------------------------------------------------------------------
    mant_chico_shifted <= shift_right(mant_chico, abs(to_integer(signed('0' & exp_grande) - signed('0' & exp_chico))));
    
    exp_inter <= signed('0' & exp_grande);  -- partimos del exponente mayor
    ----------------------------------------------------------------------------
    --  Suma/resta de los “significandos” según signos y sum_rest_select
    ----------------------------------------------------------------------------
    comb_mant: process(mant_grande, mant_chico_shifted, sign_grande, sign_chico, sum_rest_select)
    begin

        if sign_grande = sign_chico then
            -- mismos signos: sumar o restar magnitudes (grande – chico)
            if sum_rest_select = '0' then
                mant_sum     <= signed('0' & mant_grande) + signed('0' & mant_chico_shifted);
                signo_result <= sign_grande;

            else
                mant_sum     <= signed('0' & mant_grande) - signed('0' & mant_chico_shifted);
                signo_result <= sign_grande;

            end if;
        else
            -- signos distintos: resta de magnitudes
            if mant_grande >= mant_chico_shifted then
                mant_sum     <= signed('0' & mant_grande) - signed('0' & mant_chico_shifted);
                signo_result <= sign_grande;

            else
                mant_sum     <= signed('0' & mant_chico_shifted) - signed('0' & mant_grande);
                signo_result <= sign_chico;

            end if;
        end if;
    end process comb_mant;

    ----------------------------------------------------------------------------
    --  Normalización: overflow de mantisa (carry) o underflow (leading zeros)
    ----------------------------------------------------------------------------

    zeros <= count_leading_zeros(std_logic_vector(mant_sum(SGFC_SIZE downto 0)));

    normalize: process(mant_sum, exp_inter, zeros)
    begin
        mant_norm <= (others => '0');
        exp_norm  <= exp_inter; -- default

        if mant_sum(SGFC_SIZE+1) = '1' then
            mant_norm <= std_logic_vector(mant_sum(SGFC_SIZE+1 downto 1));
            exp_norm  <= exp_inter + 1;
            
            elsif zeros > 0 then
                mant_norm <= std_logic_vector( shift_left(mant_sum(SGFC_SIZE downto 0) , zeros) );
                exp_norm <= exp_inter - zeros;
        else
            mant_norm <= std_logic_vector(mant_sum(SGFC_SIZE downto 0));
            exp_norm  <= exp_inter;
        end if;
    end process normalize;

    ----------------------------------------------------------------------------
    --  Empaquetado final: cero total, infinito o valor normalizado
    ----------------------------------------------------------------------------
    comb_result: process(rst_i, is_zero_a, is_zero_b, mant_norm, exp_norm, signo_result)
    begin
        -- 1) Reset → salida a 0
        if rst_i = '1' then
            reg_resultado_d <= (others => '0');

    -- 2) Caso especial 0 + 0 → resultado 0
        elsif is_zero_a = '1' and is_zero_b = '1' then
        reg_resultado_d <= (others => '0');

        -- 3) Overflow → saturación al máximo finito
        elsif exp_norm > to_signed(MAX_EXP_NORMAL, exp_norm'length) then
            reg_resultado_d <= signo_result
                            & std_logic_vector(to_unsigned(MAX_EXP_NORMAL, EXP_SIZE))
                            & ONE_MAN;

        -- 4) Underflow total → cero
        elsif exp_norm <= 0 then
            reg_resultado_d <= (others => '0');

        -- 5) Caso normal
        else
            reg_resultado_d <= signo_result
                            & std_logic_vector(exp_norm(EXP_SIZE-1 downto 0))
                            & mant_norm(SGFC_SIZE-1 downto 0);
        end if;
    end process comb_result;

    ----------------------------------------------------------------------------
    --  Conectar la salida del puerto al registro de salida
    ----------------------------------------------------------------------------
    resultado_o <= reg_resultado_o;

end architecture sum_rest_arq;
