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
	 signal matrix_in : matrix(0 to 6, 0 to 6) := (
         ( 3, 22, 23, 10, 38, 26, 16),
			( 5, 44, 49, 37, 15, 31, 34),
			( 29, 8, 43, 11, 24, 48, 25),
			( 4, 30, 36, 39, 42, 13, 46),
			( 18, 2, 19, 32, 7, 35, 14),
			( 9, 12, 28, 41, 1, 6, 45),
			( 27, 17, 40, 33, 20, 21, 47)
    );
    signal matrix_out : matrix(0 to 6, 0 to 6);

    -- Señal para la sincronización del reloj
    --constant clk_period : time := 10 ns;

begin
    -- Instanciación del diseño
    uut: entity work.deshuffling
        generic map (
            filas => 7,
            columnas => 7,
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