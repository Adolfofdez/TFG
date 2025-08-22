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
  signal mat_in  : matrix(0 to 9, 0 to 9) := (
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
  signal mat_sh     : matrix(0 to filas-1, 0 to columnas-1);
  signal mat_latched     : matrix(0 to filas-1, 0 to columnas-1);
  signal mat_out    : matrix(0 to filas-1, 0 to columnas-1);
  signal done_sh    : std_logic:='1';
  signal done_de    : std_logic :='1';

begin

  -- Reloj 100 MHz
  clk_proc: process
  begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
  end process;

  -- Shuffler
  U_SHUFF: entity work.shuffling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => reset_sh,
      matrix_in  => mat_in,
      matrix_out => mat_sh,
      done       => done_sh
    );

  -- Deshuffler
  U_DESH: entity work.deshuffling
    generic map ( filas => filas, columnas => columnas )
    port map (
      clk        => clk,
      reset      => reset_de,
      matrix_in  => mat_latched,
      matrix_out => mat_out,
      done       => done_de
    );

  -- Estímulos y comprobación
  stim_proc: process
  begin
    -- Inicializo la matriz
    

    -- Aplico ambos resets
    reset_sh <= '1'; reset_de <= '1';
    wait for 20 ns;

    -- Suelto solo el shuffler
    reset_sh <= '0';
	 wait for 100 ns;

    -- Espero a que termine de barajar
    wait until done_sh = '1';
	 
    wait for 100 ns;  -- dar time para propagar mat_sh
	 
	 for i in 0 to filas-1 loop
      for j in 0 to columnas-1 loop
        mat_latched(i,j) <= mat_sh(i,j);
      end loop;
    end loop;
    wait for 100 ns;

    -- Ahora suelto el deshuffler
    reset_de <= '0';

    -- Espero a que termine de desbarajar
    wait until done_de = '1';
    wait for 1 ns;

    -- Compruebo resultado
    for i in 0 to filas-1 loop
      for j in 0 to columnas-1 loop
        assert mat_out(i,j) = mat_in(i,j)
          report "ERROR en (" & integer'image(i)&","& integer'image(j)&
                 ") esperado="&integer'image(mat_in(i,j))&
                 " obtenido="&integer'image(mat_out(i,j))
          severity error;
      end loop;
    end loop;

    report "¡OK! Shuffling ? Deshuffling funcionando." severity note;
    wait;
  end process;

end architecture sim;
