library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity tb_descrambling is
end entity tb_descrambling;

architecture testbench of tb_descrambling is

 signal clk : std_logic := '0';
 signal reset : std_logic := '0';
 signal ready : std_logic;
 signal K1: byte_array(0 to 3) := (19,72,29,12);
 signal K2 : byte_array(0 to 3):= (129,93,123,233);
 signal K3 : byte_array(0 to 3):= (32,35,76,86);
 signal K4 : byte_array(0 to 3):= (54,78,66,92);
 signal C1 : byte_array(0 to 3) := (23,54,29,32);
 signal C2 : byte_array(0 to 3):= (176,193,183,2);
 signal S1 : byte_array(0 to 3):= (87,77,89,32);
 signal S2 : byte_array(0 to 3):= (53,75,33,45);
 signal S3 : byte_array(0 to 3):= (14,44,67,76);
 signal matrix_in : matrix(0 to 9, 0 to 9) := (
 (201, 214, 114, 48, 0, 179, 88, 52, 235, 131),
 (229, 253, 123, 147, 41, 74, 96, 132, 69, 84),
 (38, 106, 252, 27, 171, 113, 111, 235, 149, 158),
 (194, 147, 124, 124, 168, 64, 5, 159, 128, 54),
 (243, 133, 64, 254, 173, 77, 171, 164, 117, 114),
 (81, 188, 141, 127, 41, 62, 118, 146, 182, 208),
 (229, 48, 147, 208, 161, 236, 191, 90, 77, 77),
 (43, 114, 190, 119, 177, 9, 162, 123, 71, 81),
 (67, 212, 64, 182, 57, 218, 250, 250, 97, 197),
 (183, 213, 127, 202, 164, 235, 56, 32, 243, 27)		  
 );
 signal matrix_out : matrix(0 to 9, 0 to 9);

 constant clk_period : time := 5 ns;

begin

 U1: entity work.descrambling
 generic map(
  filas => 10,
  columnas => 10,
  semilla => 500000,
  r => 3800000
 )
port map (
  clk        => clk,
  reset      => reset,
  K1         => K1, 
  K2         => K2, 
  K3         => K3, 
  K4         => K4,
  C1         => C1, 
  C2         => C2,
  S1         => S1, 
  S2         => S2, 
  S3         => S3,
  matrix_in  => matrix_in,  
  matrix_out => matrix_out,
  ready      => ready
 );

 clk_process : process
 begin
  while true loop
   clk <= '0';
   wait for clk_period ;
   clk <= '1';
   wait for clk_period ;
  end loop;
 end process;


 stimulus_process : process
 begin
  reset <= '1';
  wait for clk_period;
  reset <= '0';
  wait;
 end process;

end architecture testbench;
