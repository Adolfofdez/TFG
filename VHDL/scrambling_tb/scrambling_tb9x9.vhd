library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;  -- Asegúrate de que la librería `tipo` esté disponible

entity tb_scrambling is
end entity tb_scrambling;

architecture testbench of tb_scrambling is

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
    signal matrix_in : matrix(0 to 8, 0 to 8) := (
        (8, 232, 182, 2, 28, 47, 28, 93, 155),
        (40, 123, 94, 67, 23, 126, 30, 95, 18),
        (34, 182, 45, 23, 54, 38, 55, 45, 76),
        (94, 66, 9, 33, 78, 133, 36, 193, 38), 
        (2, 31, 87, 43, 98, 166, 182, 123, 41),
        (179, 71, 145, 53, 6, 67, 88, 99, 100),  
        (203, 63, 87, 63, 183, 87, 23, 12, 211),
        (20, 70, 54, 73, 193, 75, 136, 157, 138),
        (130, 228, 234, 83, 232, 19, 203, 1, 83)
    );
    signal matrix_out : matrix(0 to 8, 0 to 8);

    -- Periodo del reloj (por ejemplo, 20 ns)
    constant clk_period : time := 200 ns;

begin

    -- Instancia de la unidad bajo prueba (UUT)
    uut: entity work.scrambling
        generic map(
            filas => 9,
            columnas => 9,
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
