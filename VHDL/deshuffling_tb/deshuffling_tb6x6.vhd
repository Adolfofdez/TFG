library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity tb_deshuffling is
end entity tb_deshuffling;

architecture test of tb_deshuffling is
    -- Parámetros de la matriz
   

    -- Señales del diseño
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
	 signal matrix_in : matrix(0 to 5, 0 to 5) := (
         ( 10, 5, 8, 3, 2, 25),
			( 16, 34, 15, 19, 14, 17),
			( 1, 32, 30, 7, 31, 21),
			( 4, 12, 36, 13, 11, 24),
			( 26, 29, 6, 28, 9, 27),
			( 18, 23, 22, 35, 20, 33)
    );
    signal matrix_out : matrix(0 to 5, 0 to 5);

    -- Señal para la sincronización del reloj
    --constant clk_period : time := 10 ns;

begin
    -- Instanciación del diseño
    uut: entity work.deshuffling
        generic map (
            filas => 6,
            columnas => 6,
				semilla => 500000,
				r => 3800000
        )
        port map (
            clk => clk,
            reset => reset,
            matrix_in => matrix_in,
            matrix_out => matrix_out
        );

    -- Generación del reloj
    clk_process : process
    begin
        clk <= '0';
        wait for 100 ns;
        clk <= '1';
        wait for 100 ns;
    end process;

    -- Proceso de testbench
    stimulus_process : process
    begin
        -- Inicialización
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- Configuración inicial de matrix_in (puedes personalizar este valor)
        

        -- Esperar el ciclo de reloj para ver la salida
        wait for 1000 ms;

        -- Finalizar simulación
        --assert false report "Simulation completed" severity note;
        wait;
    end process;
end architecture test;