library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity tb_shuff_deshuff is
end entity;

architecture sim of tb_shuff_deshuff is

 constant filas    : integer := 10;
 constant columnas : integer := 10;
 signal clk        : std_logic := '0';
 signal reset_sh   : std_logic := '1';
 signal reset_de   : std_logic := '1';
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
 signal shuffling_out     : matrix(0 to filas-1, 0 to columnas-1);
 signal deshuffling_in     : matrix(0 to filas-1, 0 to columnas-1);
 signal matrix_out    : matrix(0 to filas-1, 0 to columnas-1);
 signal done_sh    : std_logic:='0';
 signal done_de    : std_logic :='0';

begin

 clk_proc: process
 begin
  clk <= '0'; 
  wait for 5 ns;
  clk <= '1'; 
  wait for 5 ns;
 end process;


 U1: entity work.shuffling
 generic map ( filas => filas, columnas => columnas )
 port map (
  clk        => clk,
  reset      => reset_sh,
  matrix_in  => matrix_in,
  matrix_out => shuffling_out,
  done       => done_sh
 );


 U2: entity work.deshuffling
 generic map ( filas => filas, columnas => columnas )
 port map (
  clk        => clk,
  reset      => reset_de,
  matrix_in  => deshuffling_in,
  matrix_out => matix_out,
  done       => done_de
 );


 stim_proc: process
 begin

  reset_sh <= '1'; reset_de <= '1';
  reset_sh <= '0';
  wait until done_sh = '1';

  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    deshuffling_in(i,j) <= shuffling_out(i,j);
   end loop;
  end loop;

  reset_de <= '0';
  wait until done_de = '1';

  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    assert mat_out(i,j) = mat_in(i,j)
    report "ERROR en (" & integer'image(i)&","& integer'image(j)&
    ") esperado="&integer'image(mat_in(i,j))&
    " obtenido="&integer'image(mat_out(i,j))
    severity error;
   end loop;
  end loop;

 end process;

end architecture sim;
