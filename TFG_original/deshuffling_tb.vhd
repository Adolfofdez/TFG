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
	 signal matrix_in : matrix(0 to 9, 0 to 9) := (
         (26, 34, 200, 60, 97, 232, 97, 159, 117, 232),
        (191, 172, 253, 251, 184, 48, 98, 100, 249, 114),
        (25, 177, 197, 104, 153, 117, 89, 228, 110, 40),
        (124, 86, 91, 183, 126, 240, 209, 107, 32, 226), 
        (27, 216, 82, 98, 207, 136, 111, 37, 32, 141),
        (37, 100, 88, 121, 201, 159, 109, 236, 11, 49),  
        (156, 231, 56, 82, 72, 55, 211, 132, 72, 187),
        (90, 130, 183, 20, 209, 81, 50, 251, 203, 76),
        (69, 3, 113, 208, 227, 149, 153, 18, 148, 27),
        (44, 78, 187, 211, 198, 204, 207, 157, 29, 172)  
    );
    signal matrix_out : matrix(0 to 9, 0 to 9);

    -- Señal para la sincronización del reloj
    constant clk_period : time := 5 ns;

begin
    -- Instanciación del diseño
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
				reset =>reset
        );

    -- Generación del reloj
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period;
        clk <= '1';
        wait for clk_period;
    end process;

    -- Proceso de testbench
    stimulus_process : process
    begin
        -- Inicialización
        reset <= '1';
        wait for clk_period;
        reset <= '0';

        wait;
    end process;
end architecture test;