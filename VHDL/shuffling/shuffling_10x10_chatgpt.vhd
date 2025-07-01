library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.tipo.all;

entity shuffling is
  generic(
    filas    : integer := 10;
    columnas : integer := 10;
    semilla  : integer := 500000;
    r        : integer := 3800000
  );
  port(
    clk        : in  std_logic;
    reset      : in  std_logic;
    matrix_in  : in  matrix(0 to filas-1, 0 to columnas-1);
    matrix_out : out matrix(0 to filas-1, 0 to columnas-1)
  );
end entity;

architecture Behavioral of shuffling is

  type Estados is (Init, LoadMatrix, GenerateRand, SortIndices, RearrangeArrays, MergeArrays, StoreMatrix, ReadSequence, OutputMatrix, Done);
  signal state, next_state : Estados := Init;

  signal iteration  : integer := 0;
  signal rnd_array  : byte_array(0 to 255);
  signal flat_array : byte_array(0 to filas*columnas-1);
  signal sorted_a   : integer_array(0 to 2);
  signal n, m       : integer;
  signal matrix_buf : matrix(0 to filas-1, 0 to columnas-1);

begin

  Control : process(clk, reset)
  begin
    if reset = '1' then
      state <= Init;
      iteration <= 0;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;

  DataPath : process(state)
    variable x_var : integer;
    variable index : integer;
  begin
    case state is
      when Init =>
        matrix_out <= (others => (others => 0));
        next_state <= LoadMatrix;

      when LoadMatrix =>
        index := 0;
        for i in 0 to filas-1 loop
          for j in 0 to columnas-1 loop
            flat_array(index) <= matrix_in(i, j);
            index := index + 1;
          end loop;
        end loop;
        next_state <= GenerateRand;

      when GenerateRand =>
        x_var := semilla;
        for k in 0 to 255 loop
          x_var := (r * x_var * (1000000 - x_var)) / 1000000;
          rnd_array(k) <= x_var mod 256;
        end loop;
        sorted_a(0) <= rnd_array(12) mod (filas * columnas);
        sorted_a(1) <= rnd_array(103) mod (filas * columnas);
        sorted_a(2) <= rnd_array(66) mod (filas * columnas);
        n <= rnd_array(174) mod 4;
        m <= rnd_array(239) mod 4;
        next_state <= SortIndices;

      when SortIndices =>
        sorted_a <= sort(sorted_a);
        next_state <= RearrangeArrays;

      when RearrangeArrays =>
        flat_array <= rearrange_arrays(flat_array, sorted_a, n);
        next_state <= MergeArrays;

      when MergeArrays =>
        matrix_buf <= array_to_matrix(flat_array, filas, columnas);
        next_state <= StoreMatrix;

      when StoreMatrix =>
        flat_array <= matrix_to_array(matrix_buf, m);
        if iteration < 2 then
          iteration <= iteration + 1;
          next_state <= MergeArrays;
        else
          next_state <= OutputMatrix;
        end if;

      when OutputMatrix =>
        index := 0;
        for i in 0 to filas-1 loop
          for j in 0 to columnas-1 loop
            matrix_out(i, j) <= flat_array(index);
            index := index + 1;
          end loop;
        end loop;
        next_state <= Done;

      when Done =>
        null;

      when others =>
        next_state <= Init;
    end case;
  end process;

end Behavioral;