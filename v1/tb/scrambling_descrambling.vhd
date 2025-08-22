library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;  -- Define matrix, byte_array, etc.

entity tb_scrambling_descrambling is
end tb_scrambling_descrambling;

architecture tb of tb_scrambling_descrambling is

    constant filas    : integer := 10;
    constant columnas : integer := 10;

    -- Señales de reloj y reset
    signal clk   : std_logic := '0';
    signal reset_scr, reset_descr : std_logic := '1';
	 signal ready_scr : std_logic;
	 signal ready_descr : std_logic;

    -- Señales para claves y parámetros
    signal K1_scr : byte_array(0 to 3) := (19,72,29,12);
    signal K2_scr : byte_array(0 to 3):= (129,93,123,233);
    signal K3_scr : byte_array(0 to 3):= (32,35,76,86);
    signal K4_scr : byte_array(0 to 3):= (54,78,66,92);
    signal C1_scr : byte_array(0 to 3) := (23,54,29,32);
    signal C2_scr : byte_array(0 to 3):= (176,193,183,2);
    signal S1_scr : byte_array(0 to 3):= (87,77,89,32);
    signal S2_scr : byte_array(0 to 3):= (53,75,33,45);
    signal S3_scr : byte_array(0 to 3):= (14,44,67,76);
	 
	 signal K1_descr : byte_array(0 to 3) := (19,72,29,12);
    signal K2_descr : byte_array(0 to 3):= (129,93,123,233);
    signal K3_descr : byte_array(0 to 3):= (32,35,76,86);
    signal K4_descr : byte_array(0 to 3):= (54,78,66,92);
    signal C1_descr : byte_array(0 to 3) := (23,54,29,32);
    signal C2_descr : byte_array(0 to 3):= (176,193,183,2);
    signal S1_descr : byte_array(0 to 3):= (87,77,89,32);
    signal S2_descr : byte_array(0 to 3):= (53,75,33,45);
    signal S3_descr : byte_array(0 to 3):= (14,44,67,76);

    -- Matrices
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
    signal scrambled_out   : matrix(0 to filas-1, 0 to columnas-1);
    signal scrambled_latched : matrix(0 to filas-1, 0 to columnas-1);
    signal descrambled_out : matrix(0 to filas-1, 0 to columnas-1);
    signal stop_sim : boolean := false;

begin

    -- Instancia del módulo de scrambling
    UUT_scrambling: entity work.scrambling
        generic map (
            filas => filas,
            columnas => columnas,
            semilla => 500000,
            r => 3800000
        )
        port map (
            clk        => clk,
            reset      => reset_scr,
            K1         => K1_scr, K2 => K2_scr, K3 => K3_scr, K4 => K4_scr,
            C1         => C1_scr, C2 => C2_scr,
            S1         => S1_scr, S2 => S2_scr, S3 => S3_scr,
            matrix_in  => matrix_in,
            matrix_out => scrambled_out,
				scrambled_ready => ready_scr
        );

    -- Instancia del módulo de descrambling (¡fíjate aquí!)
    UUT_descrambling: entity work.descrambling
        generic map (
            filas => filas,
            columnas => columnas,
            semilla => 500000,
            r => 3800000
        )
        port map (
            clk        => clk,
            reset      => reset_descr,
            K1         => K1_descr, K2 => K2_descr, K3 => K3_descr, K4 => K4_descr,
            C1         => C1_descr, C2 => C2_descr,
            S1         => S1_descr, S2 => S2_descr, S3 => S3_descr,
            matrix_in  => scrambled_latched,  
            matrix_out => descrambled_out,
				ready      => ready_descr
        );

    -- Generación de reloj
    clk_process : process
    begin
        while not stop_sim loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
        wait;
    end process;

    -- Estímulo y verificación con latch
    stim_proc: process
begin
    reset_scr <= '1'; reset_descr <= '1';
    wait for 20 ns;
    reset_scr <= '0';

    -- Espera a que scrambling indique que ha terminado
    wait until ready_scr = '1';
    wait until rising_edge(clk); -- Por seguridad: asegura setup/hold
	 reset_scr <= '1';
    -- Latch
    for i in 0 to filas-1 loop
        for j in 0 to columnas-1 loop
            scrambled_latched(i,j) <= scrambled_out(i,j);
        end loop;
    end loop;

    -- Arranca descrambling solo ahora
    reset_descr <= '0';

    -- Espera tiempo suficiente para descrambling
    wait for 100 ns;

    -- Comprueba resultado
    for i in 0 to filas-1 loop
        for j in 0 to columnas-1 loop
            if descrambled_out(i, j) /= matrix_in(i, j) then
                report "ERROR: Elemento (" & integer'image(i) & "," & integer'image(j) &
                    ") original=" & integer'image(matrix_in(i, j)) &
                    ", recuperado=" & integer'image(descrambled_out(i, j)) severity error;
            end if;
        end loop;
    end loop;

    wait;
end process;

end tb;
