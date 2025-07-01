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
	 signal matrix_in : matrix(0 to 8, 0 to 8) := (
         ( 193, 94, 73, 23, 182, 138, 30, 48, 92),
			( 2, 23, 133, 87, 42, 157, 155, 83, 12),
			( 51, 93, 232, 87, 18, 28, 38, 23 , 83),
			( 123, 130, 28, 203, 203, 19, 211, 29, 1),
			( 25, 67, 41, 145, 94, 119, 47, 182, 54),
			( 126, 45, 3, 98, 34, 29, 95, 232, 88),
			( 75, 192, 20, 66, 182, 192, 102, 43, 102),
			( 36, 123, 136, 63, 166, 71, 193, 177, 87),
			( 234, 9, 26, 31, 45, 8, 78, 183, 67)
    );
    signal matrix_out : matrix(0 to 8, 0 to 8);

    -- Señal para la sincronización del reloj
    --constant clk_period : time := 10 ns;

begin
    -- Instanciación del diseño
    uut: entity work.deshuffling
        generic map (
            filas => 9,
            columnas => 9,
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