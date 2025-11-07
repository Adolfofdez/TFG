library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity ofuscation_tb is
end entity;

architecture sim of ofuscation_tb is

  constant filas    : integer := 10;
  constant columnas : integer := 10;

  signal clk        : std_logic := '0';
  signal reset_sh   : std_logic := '1';
  signal reset_scr   : std_logic := '1';

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
  signal scrambling_in     : matrix(0 to filas-1, 0 to columnas-1);

  signal shuffling_out    : matrix(0 to filas-1, 0 to columnas-1);
  signal scrambling_out     : matrix(0 to filas-1, 0 to columnas-1);
  
  signal done_sh    : std_logic:='1';
  signal done_scr    : std_logic:='1';

  
  
  signal K1_scr : byte_array(0 to 3) := (19,72,29,12);
  signal K2_scr : byte_array(0 to 3) := (129,93,123,233);
  signal K3_scr : byte_array(0 to 3) := (32,35,76,86);
  signal K4_scr : byte_array(0 to 3) := (54,78,66,92);
  signal C1_scr : byte_array(0 to 3) := (23,54,29,32);
  signal C2_scr : byte_array(0 to 3) := (176,193,183,2);
  signal S1_scr : byte_array(0 to 3) := (87,77,89,32);
  signal S2_scr : byte_array(0 to 3) := (53,75,33,45);
  signal S3_scr : byte_array(0 to 3) := (14,44,67,76);


begin

  -- Reloj 100 MHz
  clk_proc: process
  begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
  end process;

  -- Shuffler
  U1: entity work.shuffling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => reset_sh,
      matrix_in  => matrix_in,
      matrix_out => shuffling_out,
      done       => done_sh
    );

  -- Scrambler
  U2: entity work.scrambling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => reset_scr,
      matrix_in  => scrambling_in,
		K1 => K1_scr,
      K2 => K2_scr,
      K3 => K3_scr,
      K4 => K4_scr,
      C1 => C1_scr,
      C2 => C2_scr,
      S1 => S1_scr,
      S2 => S2_scr,
      S3 => S3_scr,
      matrix_out => scrambling_out,
      scrambled_ready       => done_scr
    );
	 
  


  
	 

  -- Estímulos y comprobación
  stim_proc: process
  begin
    
    

    -- Aplico resets
    reset_sh <= '1'; reset_scr <= '1'; 
   -- wait for 20 ns;

    -- Suelto solo el shuffler
    reset_sh <= '0';
	-- wait for 100 ns;

    -- Espero a que termine de barajar
    wait until done_sh = '1';
	 
   -- wait for 100 ns;  -- dar time para propagar mat_sh
	 
	 for i in 0 to filas-1 loop
      for j in 0 to columnas-1 loop
        scrambling_in(i,j) <= shuffling_out(i,j);
      end loop;
    end loop;
   -- wait for 100 ns;
	 
	 -- Ahora suelto el scrambler
    reset_scr <= '0';
	-- wait for 100 ns;

    -- Espero a que termine de barajar
    wait until done_scr = '1';
	 
   -- wait for 100 ns;  -- dar time para propagar mat_sh
	 
	
  end process;

end architecture sim;

