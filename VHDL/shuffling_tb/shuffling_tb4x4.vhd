library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.tipo.all;

entity shuffling_tb is
end shuffling_tb;

architecture testbench of shuffling_tb is
    -- Definir señales que conectarán con el DUT (Device Under Test)
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal matrix_in : matrix(0 to 3, 0 to 3) := (
        (1, 2, 3, 4),
        (5, 6, 7, 8),
        (9, 10, 11, 12),
		(13, 14, 15, 16)
    );
    signal matrix_out : matrix(0 to 3, 0 to 3);
    -- Señales internas
    constant filas : integer := 4;
    constant columnas : integer := 4;

begin
    -- Instanciación del DUT
    UUT: entity work.shuffling
    generic map(
        filas => filas,
        columnas => columnas,
        semilla => 500000,
        r => 3800000
    )
    port map(
        clk => clk,
        reset => reset,
        matrix_in => matrix_in,
        matrix_out => matrix_out
    );
    
    -- Proceso de generación de reloj (clk)
    clk_gen : process
    begin
			
        while true loop
            clk <= '1';
            wait for 100 ns;
            clk <= '0';
            wait for 100 ns;
        end loop;
    end process;

    -- Proceso de estimulación
    stim_proc : process
		
	 begin
		  
        -- Inicialización
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;
        
        -- Proporcionar valores a matrix_in
        

    
     
        
        -- Esperar tiempo suficiente para simular
        wait for 10000 ms;
        
        -- Parar simulación
        wait;
    end process;

end testbench;
