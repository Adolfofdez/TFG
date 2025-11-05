library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity shuffling_tb is
end shuffling_tb;

architecture testbench of shuffling_tb is

 signal clk        : std_logic := '0';
 signal reset      : std_logic := '0';
 signal done       : std_logic:='0';
 signal matrix_in  : matrix(0 to 9, 0 to 9) := (
 (1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
 (11, 12, 13, 14, 15, 16, 17, 18, 19, 20),
 (21, 22, 23, 24, 25, 26, 27, 28, 29, 30),
 (31, 32, 33, 34, 35, 36, 37, 38, 39, 40), 
 (41, 42, 43, 44, 45, 46, 47, 48, 49, 50),
 (51, 52, 53, 54, 55, 56, 57, 58, 59, 60),  
 (61, 62, 63, 64, 65, 66, 67, 68, 69, 70),
 (71, 72, 73, 74, 75, 76, 77, 78, 79, 80),
 (81, 82, 83, 84, 85, 86, 87, 88, 89, 90),
 (91, 92, 93, 94, 95, 96, 97, 98, 99, 100)
 );
 signal matrix_out : matrix(0 to 9, 0 to 9);

 constant filas    : integer := 10;
 constant columnas : integer := 10;
 constant clk_period : time := 5 ns;

begin

 U1: entity work.shuffling
 generic map(
  filas => filas,
  columnas => columnas,
  semilla => 500000,
  r => 3800000
 )
 port map(
  clk        => clk,
  reset      => reset,
  matrix_in  => matrix_in,
  matrix_out => matrix_out,
  done       => done
 );

 clk_process : process
 begin
  while true loop
   clk <= '1';
   wait for clk_period;
   clk <= '0';
   wait for clk_period;
  end loop;
 end process;

 stim_proc: process
 begin
  reset <= '1';
  wait for clk_period;
  reset <= '0';
  wait;
 end process;

end architecture;