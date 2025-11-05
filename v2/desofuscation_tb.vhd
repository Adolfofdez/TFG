library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity desofuscation_tb is
end entity;

architecture sim of desofuscation_tb is
 constant filas    : integer := 10;
 constant columnas : integer := 10;
 signal clk        : std_logic := '0';
 signal reset_descr   : std_logic := '1';
 signal reset_desh   : std_logic := '1';
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

 signal deshuffling_in     : matrix(0 to filas-1, 0 to columnas-1);
 signal matrix_out    : matrix(0 to filas-1, 0 to columnas-1);
 signal descrambling_out     : matrix(0 to filas-1, 0 to columnas-1);
 signal done_descr    : std_logic:='1';
 signal done_desh    : std_logic :='1';
 signal K1_descr : byte_array(0 to 3) := (19,72,29,12);
 signal K2_descr : byte_array(0 to 3) := (129,93,123,233);
 signal K3_descr : byte_array(0 to 3) := (32,35,76,86);
 signal K4_descr : byte_array(0 to 3) := (54,78,66,92);
 signal C1_descr : byte_array(0 to 3) := (23,54,29,32);
 signal C2_descr : byte_array(0 to 3) := (176,193,183,2);
 signal S1_descr : byte_array(0 to 3) := (87,77,89,32);
 signal S2_descr : byte_array(0 to 3) := (53,75,33,45);
 signal S3_descr : byte_array(0 to 3) := (14,44,67,76);

begin
 clk_proc: process
 begin
  clk <= '0'; wait for 5 ns;
  clk <= '1'; wait for 5 ns;
 end process;

 U1: entity work.descrambling
 generic map ( filas => filas, columnas => columnas )
 port map (
  clk        => clk,
  reset      => reset_descr,
  matrix_in  => matrix_in,
  K1 => K1_descr,
  K2 => K2_descr,
  K3 => K3_descr,
  K4 => K4_descr,
  C1 => C1_descr,
  C2 => C2_descr,
  S1 => S1_descr,
  S2 => S2_descr,
  S3 => S3_descr,
  matrix_out => descrambling_out,
  ready       => done_descr
 );

 U2: entity work.deshuffling
 generic map ( filas => filas, columnas => columnas )
 port map (
  clk        => clk,
  reset      => reset_desh,
  matrix_in  => deshuffling_in,
  matrix_out => matrix_out,
  done       => done_desh
 );

 stim_proc: process
 begin
  reset_descr <= '1'; reset_desh <= '1';
  reset_descr <= '0';
  wait until done_descr = '1';
  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    deshuffling_in(i,j) <= descrambling_out(i,j);
   end loop;
  end loop;
  reset_desh <= '0';
  wait until done_desh = '1';
  wait;
 end process;
end architecture sim;
