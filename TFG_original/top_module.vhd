-- ============================================================
--  top_module.vhd  (secuenciación: SHUF -> SCR -> DESCR -> DESH)
--  - Cada etapa permanece en RESET hasta que acaba la anterior
--  - Registros entre etapas para datos estables
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipo.all;

entity top_module is
  generic (
    filas    : integer := 10;
    columnas : integer := 10;
    semilla  : integer := 500000;
    r        : integer := 3800000
  );
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;  -- Activo ALTO

    -- Claves / constantes
    K1 : in byte_array(0 to 3);
    K2 : in byte_array(0 to 3);
    K3 : in byte_array(0 to 3);
    K4 : in byte_array(0 to 3);
    C1 : in byte_array(0 to 3);
    C2 : in byte_array(0 to 3);
    S1 : in byte_array(0 to 3);
    S2 : in byte_array(0 to 3);
    S3 : in byte_array(0 to 3);

    -- Datos
    matrix_in  : in  matrix(0 to filas-1, 0 to columnas-1);
    matrix_out : out matrix(0 to filas-1, 0 to columnas-1);

    -- Fin de la cadena completa
    done : out std_logic
  );
end entity;

architecture rtl of top_module is
  ----------------------------------------------------------------
  -- Señales de salida de etapas (combinacionales/internas)
  ----------------------------------------------------------------
  signal shuf_out    : matrix(0 to filas-1, 0 to columnas-1);
  signal scr_out     : matrix(0 to filas-1, 0 to columnas-1);
  signal descr_out   : matrix(0 to filas-1, 0 to columnas-1);
  signal desh_out    : matrix(0 to filas-1, 0 to columnas-1);

  signal done_shuf   : std_logic;
  signal done_scr    : std_logic;  -- 'scrambled_ready' en tu bloque
  signal done_descr  : std_logic;  -- 'ready' en tu bloque
  signal done_desh   : std_logic;

  ----------------------------------------------------------------
  -- Registros entre etapas (capturan al finalizar cada una)
  ----------------------------------------------------------------
  signal reg_after_shuf   : matrix(0 to filas-1, 0 to columnas-1);
  signal reg_after_scr    : matrix(0 to filas-1, 0 to columnas-1);
  signal reg_after_descr  : matrix(0 to filas-1, 0 to columnas-1);

  ----------------------------------------------------------------
  -- Resets encadenados (activos en '1')
  -- Cada bloque queda en reset hasta que ACABA el anterior
  ----------------------------------------------------------------
  signal rst_shuf  : std_logic;
  signal rst_scr   : std_logic;
  signal rst_descr : std_logic;
  signal rst_desh  : std_logic;
begin
  -- Encadenado de resets (activos a '1')
  rst_shuf  <= reset;                              -- arranca con el sistema
  rst_scr   <= reset or (not done_shuf);           -- sale de reset cuando shuf DONE
  rst_descr <= reset or (not done_scr);            -- sale cuando scr DONE
  rst_desh  <= reset or (not done_descr);          -- sale cuando descr DONE

  ----------------------------------------------------------------
  -- Etapa 1: Shuffling
  ----------------------------------------------------------------
  U_SHUF: entity work.shuffling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => rst_shuf,
      matrix_in  => matrix_in,
      matrix_out => shuf_out,
      done       => done_shuf
    );

  -- Registro al terminar SHUF (un solo muestreo cuando done sube)
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- opcional: limpiar a 0
      elsif done_shuf = '1' then
        reg_after_shuf <= shuf_out;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  -- Etapa 2: Scrambling
  ----------------------------------------------------------------
  U_SCR: entity work.scrambling
    generic map ( filas => filas, columnas => columnas, semilla => semilla, r => r )
    port map (
      clk   => clk,
      reset => rst_scr,
      K1 => K1, K2 => K2, K3 => K3, K4 => K4,
      C1 => C1, C2 => C2, S1 => S1, S2 => S2, S3 => S3,
      matrix_in        => reg_after_shuf,   -- datos estables
      matrix_out       => scr_out,
      scrambled_ready  => done_scr
    );

  -- Registro al terminar SCR
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- opcional: limpiar a 0
      elsif done_scr = '1' then
        reg_after_scr <= scr_out;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  -- Etapa 3: Descrambling
  ----------------------------------------------------------------
  U_DESCR: entity work.descrambling
    generic map ( filas => filas, columnas => columnas, semilla => semilla, r => r )
    port map (
      clk   => clk,
      reset => rst_descr,
      K1 => K1, K2 => K2, K3 => K3, K4 => K4,
      C1 => C1, C2 => C2, S1 => S1, S2 => S2, S3 => S3,
      matrix_in  => reg_after_scr,         -- datos estables
      matrix_out => descr_out,
      ready      => done_descr
    );

  -- Registro al terminar DESCR
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- opcional
      elsif done_descr = '1' then
        reg_after_descr <= descr_out;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  -- Etapa 4: Deshuffling
  ----------------------------------------------------------------
  U_DESH: entity work.deshuffling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => rst_desh,
      matrix_in  => reg_after_descr,       -- datos estables
      matrix_out => desh_out,
      done       => done_desh
    );

  ----------------------------------------------------------------
  -- Salidas del TOP
  ----------------------------------------------------------------
  matrix_out <= desh_out;
  done       <= done_desh;
end architecture;
