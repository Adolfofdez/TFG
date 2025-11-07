library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;  -- Asegúrate de que la librería `tipo` esté disponible

entity tb_descrambling is
end entity tb_descrambling;

architecture testbench of tb_descrambling is

    -- Señales internas
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal K1: byte_array(0 to 3) := (19,72,29,12);
	 signal K2 : byte_array(0 to 3):= (129,93,123,233);
	 signal K3 : byte_array(0 to 3):= (32,35,76,86);
	 signal K4 : byte_array(0 to 3):= (54,78,66,92);
    signal C1: byte_array(0 to 3) := (23,54,29,32);
	 signal C2 : byte_array(0 to 3):= (176,193,183,2);
	 signal S1 : byte_array(0 to 3):= (87,77,89,32);
	 signal S2 : byte_array(0 to 3):= (53,75,33,45);
	 signal S3 : byte_array(0 to 3):= (14,44,67,76);
    signal matrix_in : matrix(0 to 9, 0 to 9) := (
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

    -- Periodo del reloj (por ejemplo, 20 ns)
    constant clk_period : time := 5 ns;

begin

    -- Instancia de la unidad bajo prueba (UUT)
    uut: entity work.descrambling
        generic map(
            filas => 10,
            columnas => 10,
            semilla => 500000,
            r => 3800000
        )
        port map(
            clk => clk,
            reset => reset,
            K1 => K1,
            K2 => K2,
            K3 => K3,
            K4 => K4,
            C1 => C1,
            C2 => C2,
            S1 => S1,
            S2 => S2,
            S3 => S3,
            matrix_in => matrix_in,
            matrix_out => matrix_out
        );

    -- Proceso para generar el reloj
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period ;
            clk <= '1';
            wait for clk_period ;
        end loop;
    end process;

    -- Proceso para aplicar estímulos
    stimulus_process : process
    begin
        -- Inicialización
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Inicializamos K1, K2, K3, K4, C1, C2, S1, S2, S3
        
        
       

        -- Esperar a que el módulo procese los datos
        wait for 100000 ms;  -- Ajusta según sea necesario

        -- Revisa el resultado en matrix_out
        -- Aquí podrías agregar verificaciones o inspecciones de los valores de salida.

        -- Final de la simulación
        wait;
    end process;

end architecture testbench;
