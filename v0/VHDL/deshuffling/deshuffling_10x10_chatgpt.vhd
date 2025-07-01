-- Módulo DESHUFFLING: inverso del algoritmo de SHUFFLING
-- Reconstruye la matriz original a partir de la matriz mezclada

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.tipo.all;

entity deshuffling is
  generic(
    filas : integer := 10;
    columnas : integer := 10;
    semilla : integer := 500000;
    r : integer := 3800000
  );
  port(
    clk         : in std_logic;
    reset       : in std_logic;
    start       : in std_logic;
    matrix_in   : in matrix(0 to filas-1, 0 to columnas-1);
    matrix_out  : out matrix(0 to filas-1, 0 to columnas-1);
    done        : out std_logic
  );
end entity;

architecture Behavioral of deshuffling is

  type Estados is (Idle, Carga, Caos, Aleatorios, Ordena, InversaLectura, RestaurarBloques, Reconstruye, Salida, Fin);
  signal estado_actual, estado_siguiente : Estados := Idle;

  signal pseudorandom : byte_array(0 to 255) := (others => 0);
  signal x : integer := semilla;

  signal a1, a2, a3 : integer := 0;
  signal n, m : integer range 0 to 3 := 0;
  signal sorted : integer_vector(0 to 2) := (others => 0);

  signal read_sequence : coordinate_array;
  signal index_global : integer range 0 to filas*columnas := 0;
  signal flat_array : byte_array(0 to filas*columnas-1) := (others => 0);
  signal reordered : byte_array(0 to filas*columnas-1) := (others => 0);
  signal output_matrix : matrix(0 to filas-1, 0 to columnas-1);

  -- Variables convertidas a señales locales para evitar errores de sintaxis
  signal temp : integer_vector(0 to 2);
  signal lim1, lim2, lim3 : integer := 0;
  signal idx : integer := 0;

begin

  process(clk, reset)
  begin
    if reset = '1' then
      estado_actual <= Idle;
    elsif rising_edge(clk) then
      estado_actual <= estado_siguiente;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      case estado_actual is

        when Idle =>
          if start = '1' then
            done <= '0';
            estado_siguiente <= Carga;
          else
            estado_siguiente <= Idle;
          end if;

        when Carga =>
          index_global <= 0;
          for i in 0 to filas-1 loop
            for j in 0 to columnas-1 loop
              flat_array(index_global) <= matrix_in(i,j);
              index_global <= index_global + 1;
            end loop;
          end loop;
          estado_siguiente <= Caos;

        when Caos =>
          for i in 0 to 255 loop
            x := (r * x * (1000000 - x))/1000000;
            pseudorandom(i) <= x mod 256;
          end loop;
          estado_siguiente <= Aleatorios;

        when Aleatorios =>
          a1 <= pseudorandom(12) mod (filas*columnas);
          a2 <= pseudorandom(103) mod (filas*columnas);
          a3 <= pseudorandom(66) mod (filas*columnas);
          n <= pseudorandom(174) mod 4;
          m <= pseudorandom(239) mod 4;
          estado_siguiente <= Ordena;

        when Ordena =>
          temp(0) <= a1;
          temp(1) <= a2;
          temp(2) <= a3;
          if temp(0) > temp(1) then
            variable swap : integer := temp(0);
            temp(0) <= temp(1);
            temp(1) <= swap;
          end if;
          if temp(1) > temp(2) then
            variable swap : integer := temp(1);
            temp(1) <= temp(2);
            temp(2) <= swap;
          end if;
          if temp(0) > temp(1) then
            variable swap : integer := temp(0);
            temp(0) <= temp(1);
            temp(1) <= swap;
          end if;
          sorted <= temp;
          estado_siguiente <= InversaLectura;

        when InversaLectura =>
          for t in 0 to filas*columnas-1 loop
            case m is
              when 0 => read_sequence(t) <= (row => t / columnas, col => columnas - 1 - (t mod columnas));
              when 1 => read_sequence(t) <= (row => filas - 1 - (t / columnas), col => t mod columnas);
              when 2 => read_sequence(t) <= (row => filas - 1 - (t / columnas), col => columnas - 1 - (t mod columnas));
              when others => read_sequence(t) <= (row => t / columnas, col => t mod columnas);
            end case;
          end loop;

          for t in 0 to filas*columnas-1 loop
            reordered(t) <= matrix_in(read_sequence(t).row, read_sequence(t).col);
          end loop;
          estado_siguiente <= RestaurarBloques;

        when RestaurarBloques =>
          idx <= 0;
          lim1 <= sorted(0);
          lim2 <= sorted(1);
          lim3 <= sorted(2);

          for i in 0 to filas*columnas-1 loop
            case n is
              when 0 =>
                if i < (filas*columnas - lim3) then flat_array(lim3 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < lim1 then flat_array(i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim2 - lim1) then flat_array(lim1 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim3 - lim2) then flat_array(lim2 + i) <= reordered(idx); idx <= idx + 1; end if;
              when 1 =>
                if i < (lim2 - lim1) then flat_array(lim1 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < lim1 then flat_array(i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (filas*columnas - lim3) then flat_array(lim3 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim3 - lim2) then flat_array(lim2 + i) <= reordered(idx); idx <= idx + 1; end if;
              when 2 =>
                if i < (lim3 - lim2) then flat_array(lim2 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < lim1 then flat_array(i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (filas*columnas - lim3) then flat_array(lim3 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim2 - lim1) then flat_array(lim1 + i) <= reordered(idx); idx <= idx + 1; end if;
              when others =>
                if i < (filas*columnas - lim3) then flat_array(lim3 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim3 - lim2) then flat_array(lim2 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < (lim2 - lim1) then flat_array(lim1 + i) <= reordered(idx); idx <= idx + 1; end if;
                if i < lim1 then flat_array(i) <= reordered(idx); idx <= idx + 1; end if;
            end case;
          end loop;
          estado_siguiente <= Reconstruye;

        when Reconstruye =>
          index_global <= 0;
          for i in 0 to filas-1 loop
            for j in 0 to columnas-1 loop
              output_matrix(i,j) <= flat_array(index_global);
              index_global <= index_global + 1;
            end loop;
          end loop;
          matrix_out <= output_matrix;
          estado_siguiente <= Salida;

        when Salida =>
          done <= '1';
          estado_siguiente <= Fin;

        when Fin =>
          estado_siguiente <= Idle;

        when others =>
          estado_siguiente <= Idle;

      end case;
    end if;
  end process;

end architecture;
