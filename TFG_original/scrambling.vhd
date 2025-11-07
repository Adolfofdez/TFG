library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity scrambling is 
generic(
    filas : integer := 10; --Número de filas
    columnas : integer := 10; --Número de columnas
	 semilla : integer := 500000; --Valor inicial de la generacion de numeros aleatorios
    r : integer := 3800000 --Numero inicializar la generacion del mapa caotico
);
port(
    clk : in std_logic; --Reloj
    reset : in std_logic; --Señal de reset
    K1, K2, K3, K4 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
    C1, C2 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
    S1, S2, S3 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
    matrix_in : in matrix(0 to filas-1, 0 to columnas-1); --Matriz de entrada proveniente del módulo shuffling
    matrix_out : out matrix(0 to filas-1, 0 to columnas-1); --Matriz de salida
	 scrambled_ready : out std_logic
);
end entity scrambling;

architecture Behavorial of scrambling is
    
    
    type Estados is (State0, State1, State2, State3, State4, State5, State6, State7, State8); --Estados de la maquina de estados
    signal estado_actual, estado_siguiente : Estados;
   
	 
    constant sbox: sbox_array := (
        x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5", 
        x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
        x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", 
        x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
        x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", 
        x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
        x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", 
        x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
        x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", 
        x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
        x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", 
        x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
        x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", 
        x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
        x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", 
        x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
        x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", 
        x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
        x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", 
        x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
        x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", 
        x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
        x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", 
        x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
        x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", 
        x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
        x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", 
        x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
        x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", 
        x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
        x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", 
        x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16"
    );

begin
    process(clk, reset)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                estado_actual <= State0;
            else    
                estado_actual <= estado_siguiente;
					 
            end if;
        end if;
    end process;

    process(estado_actual)
		variable x_var : integer := semilla; --Variable para la generación del mapa caotico
		variable pseudorandom_var : byte_array(0 to 255); --Variable para almacenar el mapa caotico
		variable fragmento, fragmento1, fragmento2 : byte_array(0 to 35); --Arrays para realizar las operaciones
		variable internal_state : byte_array(0 to 35); --Estado interno
		variable resultado, resultado1, resultado2 : byte_array(0 to 35); --Array donde almacenar la operacion XOR entra el estado intenro y los fragmentos.
		variable a : byte_array(0 to filas*columnas-1); --Array intermedio
		variable scrambled : byte_array(0 to filas*columnas-1); --Array ya modificado
		variable index : integer := 0; --Variables de bucles
		variable chaotic : byte_array(0 to filas*columnas-1); -- Array de pseudoaleatorios para las operaciones de actualizacion de Y11, Y22 e Y33.
		variable a1, a2, a3, a4 : integer; --Valores pseudoaleatorios para actualizar el array chaotic
		variable aux0, aux1, aux2 : byte_array(0 to 3); --Variables auxiliares para calculos
		variable veces : integer;
		begin
        
        case estado_actual is
        when State0 => -- PASO 1
				veces := 0;
				assert K1(0) = 19 report "Error: K1(0) no es 19" severity error;
            -- Inicializamos el internal_state con los valores.
            internal_state(0 to 3) := K1(0 to 3);
				--assert false report "El valor de K1(0) es: " & integer'image(K1(0)) severity note;
				--assert false report "El valor de INTERNALSTATE(0) es: " & integer'image(internal_state(0)) severity note;
            internal_state(4 to 7) := S1(0 to 3);
				--assert false report "El valor de INTERNALSTATE(5) es: " & integer'image(internal_state(5)) severity note;
            internal_state(8 to 11) := S2(0 to 3);
				--assert false report "El valor de INTERNALSTATE(10) es: " & integer'image(internal_state(10)) severity note;
            internal_state(12 to 15) := S3(0 to 3);
				--assert false report "El valor de INTERNALSTATE(13) es: " & integer'image(internal_state(13)) severity note;
            internal_state(16 to 19) := K2(0 to 3);
				--assert false report "El valor de INTERNALSTATE(18) es: " & integer'image(internal_state(18)) severity note;
            internal_state(20 to 23) := K4(0 to 3);
				--assert false report "El valor de INTERNALSTATE(21) es: " & integer'image(internal_state(21)) severity note;
            internal_state(24 to 27) := C1(0 to 3);
				--assert false report "El valor de INTERNALSTATE(26) es: " & integer'image(internal_state(26)) severity note;
            internal_state(28 to 31) := C2(0 to 3);
				--assert false report "El valor de INTERNALSTATE(29) es: " & integer'image(internal_state(29)) severity note;
            internal_state(32 to 35) := K3(0 to 3);
				--assert false report "El valor de INTERNALSTATE(33) es: " & integer'image(internal_state(33)) severity note;
				index:=0;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    a(index) := matrix_in(i, j);  -- Almacenar elemento en el array intermedio
						 -- assert false report "P1("& integer'image(index)&")="  & integer'image(a(index)) severity note;
                    index := index + 1;
                end loop;
            end loop;
            estado_siguiente <= State1;
        when State1 => -- PASO 2: Almacenar los distintos fragmentos con los que se realiza el scrambling.
            fragmento(0 to 35) := a(0 to 35);
				--assert false report "fragmento(0)="  & integer'image(fragmento(0)) severity note;
            fragmento1(0 to 35) := a(36 to 71);
				--assert false report "fragmento1(0)="  & integer'image(fragmento1(0)) severity note;
            fragmento2(0 to 27) := a(72 to 99);
				--assert false report "fragmento2(0)="  & integer'image(fragmento2(0)) severity note;
            fragmento2(28 to 35) := (others => 0);
            estado_siguiente <= State2;
        when State2 => -- PASO 3: Generamos valores pseudoaleatorios y hacemos xor con el estado interno y los distintos fragmentos. 
                   --a1, a2, a3 y a4 para calcular los valores chaotic que se utilizarán para actualizar Y11, Y22 e Y33.
            for k in 0 to 255 loop
                x_var := (r * x_var * (1000000 - x_var))/1000000;
                pseudorandom_var(k):= x_var mod 256;
            end loop;
            a1 := pseudorandom_var(92);
            a2 := pseudorandom_var(228);
            a3 := pseudorandom_var(154);
            a4 := pseudorandom_var(183);
				
				--assert false report "El valor de la señal a1 es: " & integer'image(a1) severity note;
				--assert false report "El valor de la señal a2 es: " & integer'image(a2) severity note;
				--assert false report "El valor de la señal a3 es: " & integer'image(a3) severity note;
				--assert false report "El valor de la señal a4 es: " & integer'image(a4) severity note;
				
            chaotic(0) := a1 mod 255;
            chaotic(1) := a2 mod 255;
            chaotic(2) := a3 mod 255;
            chaotic(3) := a4 mod 255;
				
				--assert false report "El valor de la señal chaotic(0) es: " & integer'image(chaotic(0)) severity note;
				--assert false report "El valor de la señal chaotic(1) es: " & integer'image(chaotic(1)) severity note;
				--assert false report "El valor de la señal chaotic(2) es: " & integer'image(chaotic(2)) severity note;
				--assert false report "El valor de la señal chaotic(3) es: " & integer'image(chaotic(3)) severity note;

            resultado := xor_byte_array(internal_state,fragmento);
				--for i in 0 to 35 loop
				--	assert false report "El valor de la señal resultado("& integer'image(i)&") es: " & integer'image(resultado(i)) severity note;
				--end loop;
            resultado1 := xor_byte_array(internal_state,fragmento1);
				--for i in 0 to 35 loop
				--	assert false report "El valor de la señal resultado1("& integer'image(i)&") es: " & integer'image(resultado1(i)) severity note;
				--end loop;
            resultado2 := xor_byte_array(internal_state,fragmento2);
				--for i in 0 to 35 loop
				--	assert false report "El valor de la señal resultado2("& integer'image(i)&") es: " & integer'image(resultado2(i)) severity note;
				--end loop;
            estado_siguiente <= State3;
        when State3 => -- PASO 4: Actualizar los valores del estado interno mediante las ecuaciones (Nº de ecuaciones en TFG)
            
				aux0 := internal_state(0 to 3);
				aux1 := internal_state(4 to 7);
				aux2 := internal_state(8 to 11);
				-- Y13
            aux2 := xor_byte_array(aux2,(sum_byte_array(aux0,aux1)));
            -- Y12
            aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
            -- Y11
            aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));
				
				internal_state(0 to 3) := aux0; 
			   internal_state(4 to 7) := aux1;
				internal_state(8 to 11) := aux2;
				--for i in 0 to 11 loop
					--assert false report "El valor de la señal internal_state("& integer'image(i)&") es: " & integer'image(internal_state(i)) severity note;
				--end loop;
				-----
            
				aux0 := internal_state(12 to 15);
				aux1 := internal_state(16 to 19);
				aux2 := internal_state(20 to 23);
				-- Y23
            aux2 := xor_byte_array(aux2,(sum_byte_array(aux1,aux0)));
            -- Y22
            aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
            -- Y21
            aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));
				
				internal_state(12 to 15) := aux0; 
			   internal_state(16 to 19) := aux1;
				internal_state(20 to 23) := aux2;
				--for i in 12 to 23 loop
				--	assert false report "El valor de la señal internal_state("& integer'image(i)&") es: " & integer'image(internal_state(i)) severity note;
				--end loop;
				
            -----
				aux0 := internal_state(24 to 27);
				aux1 := internal_state(28 to 31);
				aux2 := internal_state(32 to 35);
				-- Y33
            aux2 := xor_byte_array(aux2,(sum_byte_array(aux1,aux0)));
            -- Y32
            aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
            -- Y31
            aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));
				
				internal_state(24 to 27) := aux0; 
			   internal_state(28 to 31) := aux1;
				internal_state(32 to 35) := aux2;
			--	for i in 24 to 35 loop
			--		assert false report "El valor de la señal internal_state("& integer'image(i)&") es: " & integer'image(internal_state(i)) severity note;
			--	end loop;
            estado_siguiente <= State4;
        when State4 => -- PASO 5: Actualizar los valores del estado interno mediante las ecuaciones (Nº de ecuaciones en TFG)
		  
				aux0 := internal_state(0 to 3);
				aux1 := internal_state(16 to 19) ;
				aux2 := internal_state(32 to 35);
            -- Y11
            aux0 := sum_byte_array(aux0,chaotic(0 to 3));
            -- Y22
            aux1 := sum_byte_array(aux1,chaotic(0 to 3));
            -- Y33
            aux2 := sum_byte_array(aux2,chaotic(0 to 3));
				
				internal_state(0 to 3) := aux0; 
			   internal_state(16 to 19) := aux1;
				internal_state(32 to 35) := aux2;
				
            estado_siguiente <= State5;
        when State5 => --PASO 6: Guardar los resultados en a, si veces=3 salimos del bucle. En cambio, si veces!=3 volvemos al S2
            a(0 to 35) := resultado(0 to 35);
            a(36 to 71) := resultado1(0 to 35);
            a(72 to 99) := resultado2(0 to 27);
            veces := veces + 1;
			 --  assert false report "EJECUTADO " & integer'image(veces) & " VECES." severity note;
            if veces = 3 then
                estado_siguiente <= State6; 
            else
                estado_siguiente <= State3;
            end if;      
        when State6 => -- PASO 7: Convertimos el array scrambled con sboxes.
            for i in 0 to 99 loop
                scrambled(i) := to_integer(unsigned(sbox(a(i))));
				--	 assert false report "El valor de la señal scrambled("& integer'image(i)&") es: " & integer'image(scrambled(i)) severity note;
            end loop;
            estado_siguiente <= State7;
        when State7 => -- PASO 8: Guardamos el array scrambled en la matriz de salida matrix_out.
            index := 0;
            for f in 0 to filas-1 loop
                for c in 0 to columnas-1 loop
                    matrix_out(f, c) <= scrambled(index);
						  --assert false report "El valor de la matriz de salida en scrambling en("& integer'image(f)&","& integer'image(c)&") es: " & integer'image(scrambled(index)) severity note;
                    index := index + 1;
                end loop;
            end loop;
				scrambled_ready <= '0';
				estado_siguiente <= State8;
		  when State8 =>
			scrambled_ready <= '1';
		  
        end case;
    end process;
    
end Behavorial;
