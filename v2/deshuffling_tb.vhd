library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity tb_deshuffling is
end entity tb_deshuffling;

architecture test of tb_deshuffling is

 signal clk : std_logic := '0';
 signal reset : std_logic := '0';
 signal done    : std_logic:='0';
 signal matrix_in : matrix(0 to 9, 0 to 9) := (
 (16, 48, 17, 24, 38, 12, 44, 72, 31, 62),
 (37, 46, 55, 25, 81, 13, 32, 7, 23, 73),
 (91, 33, 6, 28, 42, 36, 52, 67, 2, 27),
 (49, 10, 34, 4, 30, 5, 22, 61, 3, 66),
 (41, 47, 82, 98, 60, 11, 35, 1, 18, 96),
 (45, 63, 80, 86, 70, 21, 43, 39, 94, 100),
 (15, 78, 20, 59, 76, 51, 77, 87, 71, 92),
 (54, 79, 14, 29, 85, 99, 53, 75, 88, 50),
 (8, 58, 74, 89, 68, 40, 56, 26, 95, 84),
 (19, 90, 9, 97, 69, 83, 57, 64, 93, 65)  
 );
 signal matrix_out : matrix(0 to 9, 0 to 9);
 constant clk_period : time := 5 ns;
begin
 uut: entity work.deshuffling
 generic map (
  filas => 10,
  columnas => 10,
  semilla => 500000,
  r => 3800000
 )
 port map (
  clk => clk,
  matrix_in => matrix_in,
  matrix_out => matrix_out,
  reset =>reset,
  done  => done  
 );

 clk_process : process
 begin
  clk <= '0';
  wait for clk_period;
  clk <= '1';
  wait for clk_period;
 end process;

 stimulus_process : process
 begin
  reset <= '1';
  wait for clk_period;
  reset <= '0';
  wait;
 end process;
end architecture test;