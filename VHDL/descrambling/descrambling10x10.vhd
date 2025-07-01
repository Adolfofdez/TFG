library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity descrambling is
    generic(
        filas : integer := 10;
        columnas : integer := 10;
        semilla : integer := 500000; --Valor inicial de la generacion de numeros aleatorios
		  r : integer := 3800000 --Numero inicializar la generacion del mapa caotico
    );
    port(
        clk : in std_logic; --Señal de reloj
        reset : in std_logic; --Señal de reset
        K1, K2, K3, K4 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
		  C1, C2 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
        S1, S2, S3 : in byte_array(0 to 3); --Variables de inicializacion del estado interno
        matrix_in : in matrix(0 to filas-1, 0 to columnas-1); --Matriz de entrada proveniente del módulo shuffling
        matrix_out : out matrix(0 to filas-1, 0 to columnas-1) --Matriz de salida
    );
end entity descrambling;

architecture Behavorial of descrambling is
    
    type Estados is (State0, State1, State2, State3, State4, State5, State6, State7, State8); --Estados de la maquina de estados
    signal estado_actual, estado_siguiente : Estados;
    
    constant inv_sbox: sbox_array := (
        x"52", x"09", x"6a", x"d5", x"30", x"36", x"a5", x"38", x"bf", x"40", x"a3", x"9e", x"81", x"f3", x"d7", x"fb",
        x"7c", x"e3", x"39", x"82", x"9b", x"2f", x"ff", x"87", x"34", x"8e", x"43", x"44", x"c4", x"de", x"e9", x"cb",
        x"54", x"7b", x"94", x"32", x"a6", x"c2", x"23", x"3d", x"ee", x"4c", x"95", x"0b", x"42", x"fa", x"c3", x"4e",
        x"08", x"2e", x"a1", x"66", x"28", x"d9", x"24", x"b2", x"76", x"5b", x"a2", x"49", x"6d", x"8b", x"d1", x"25",
        x"72", x"f8", x"f6", x"64", x"86", x"68", x"98", x"16", x"d4", x"a4", x"5c", x"cc", x"5d", x"65", x"b6", x"92",
        x"6c", x"70", x"48", x"50", x"fd", x"ed", x"b9", x"da", x"5e", x"15", x"46", x"57", x"a7", x"8d", x"9d", x"84",
        x"90", x"d8", x"ab", x"00", x"8c", x"bc", x"d3", x"0a", x"f7", x"e4", x"58", x"05", x"b8", x"b3", x"45", x"06",
        x"d0", x"2c", x"1e", x"8f", x"ca", x"3f", x"0f", x"02", x"c1", x"af", x"bd", x"03", x"01", x"13", x"8a", x"6b",
        x"3a", x"91", x"11", x"41", x"4f", x"67", x"dc", x"ea", x"97", x"f2", x"cf", x"ce", x"f0", x"b4", x"e6", x"73",
        x"96", x"ac", x"74", x"22", x"e7", x"ad", x"35", x"85", x"e2", x"f9", x"37", x"e8", x"1c", x"75", x"df", x"6e",
        x"47", x"f1", x"1a", x"71", x"1d", x"29", x"c5", x"89", x"6f", x"b7", x"62", x"0e", x"aa", x"18", x"be", x"1b",
        x"fc", x"56", x"3e", x"4b", x"c6", x"d2", x"79", x"20", x"9a", x"db", x"c0", x"fe", x"78", x"cd", x"5a", x"f4",
        x"1f", x"dd", x"a8", x"33", x"88", x"07", x"c7", x"31", x"b1", x"12", x"10", x"59", x"27", x"80", x"ec", x"5f",
        x"60", x"51", x"7f", x"a9", x"19", x"b5", x"4a", x"0d", x"2d", x"e5", x"7a", x"9f", x"93", x"c9", x"9c", x"ef",
        x"a0", x"e0", x"3b", x"4d", x"ae", x"2a", x"f5", x"b0", x"c8", x"eb", x"bb", x"3c", x"83", x"53", x"99", x"61",
        x"17", x"2b", x"04", x"7e", x"ba", x"77", x"d6", x"26", x"e1", x"69", x"14", x"63", x"55", x"21", x"0c", x"7d"
    );

begin
    process(clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                estado_actual <= State0;
            else    
                estado_actual <= estado_siguiente;
            end if;
        end if;
    end process;

    process(estado_actual)
		variable x_var : integer := semilla; --Variable para la generación del mapa caotico
		variable pseudorandom_var : byte_array(0 to 255); --Variable para almacenar el mapa caotico
		variable aux0, aux1, aux2 : byte_array(0 to 3); --Variables auxiliares para calculos
		variable scrambled : byte_array(0 to filas*columnas-1); --Array ya modificado
      variable index, veces : integer := 0; --Variables de bucles
      variable chaotic : byte_array(0 to 3); -- Array de pseudoaleatorios para las operaciones de actualizacion de Y11, Y22 e Y33.
      variable a1, a2, a3, a4 : integer; --Valores pseudoaleatorios para actualizar el array chaotic
		variable a : byte_array(0 to filas*columnas-1); --Array intermedio
      variable fragmento, fragmento1, fragmento2 : byte_array(0 to 35); --Arrays para realizar las operaciones
      variable internal_state : byte_array(0 to 35); --Estado interno
      variable resultado, resultado1, resultado2 : byte_array(0 to 35); --Array donde almacenar la operacion XOR entra el estado intenro y los fragmentos.
    begin
        
        case estado_actual is
            when State0 =>
					 veces := 0;
                -- Inicializar internal_state con los valores adecuados
                internal_state(0 to 3) := K1;
                internal_state(4 to 7) := S1;
                internal_state(8 to 11) := S2;
                internal_state(12 to 15) := S3;
                internal_state(16 to 19) := K2;
                internal_state(20 to 23) := K4;
                internal_state(24 to 27) := C1;
                internal_state(28 to 31) := C2;
                internal_state(32 to 35) := K3;
					 
					 index:=0;
                for i in 0 to filas-1 loop
                    for j in 0 to columnas-1 loop
                        a(index) := matrix_in(i, j); -- Almacenar elemento en el array intermedio
                        index := index + 1;
                    end loop;
                end loop;
                estado_siguiente <= State1;

            when State1 => -- PASO 2: Almacenar los distintos fragmentos con los que se realiza el scrambling.
                fragmento(0 to 35) := a(0 to 35);
                fragmento1(0 to 35) := a(36 to 71);
                fragmento2(0 to 27) := a(72 to 99);
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

                chaotic(0) := a1 mod 255;
                chaotic(1) := a2 mod 255;
                chaotic(2) := a3 mod 255;
                chaotic(3) := a4 mod 255;

                resultado := xor_byte_array(internal_state,fragmento);
                resultado1 := xor_byte_array(internal_state,fragmento1);
                resultado2 := xor_byte_array(internal_state,fragmento2);
                estado_siguiente <= State3;

            when State3 => -- PASO 4: Actualizar los valores del estado interno mediante las ecuaciones
                -- Invertir las operaciones realizadas en Y11, Y12, Y13, etc.
					 aux0 := internal_state(0 to 3);
					 aux1 := internal_state(4 to 7);
					 aux2 := internal_state(8 to 11);
					 --Y11
                aux0 := xor_byte_array(aux0,sum_byte_array(aux1,aux2));
                --Y12
					 aux1 := xor_byte_array(aux1,sum_byte_array(aux2,aux0));
                --Y13
					 aux2 := xor_byte_array(aux2,sum_byte_array(aux0,aux1));
                
					 internal_state(0 to 3) := aux0; 
					 internal_state(4 to 7) := aux1;
					 internal_state(8 to 11) := aux2;
					 
					 ----
					 
					 aux0 := internal_state(12 to 15);
					 aux1 := internal_state(16 to 19);
					 aux2 := internal_state(20 to 23);
					 
					 --Y21
					 aux0 := xor_byte_array(aux0,sum_byte_array(aux1,aux2));
                --Y22
					 aux1 := xor_byte_array(aux1,sum_byte_array(aux2,aux0));
                --Y23
					 aux2 := xor_byte_array(aux2,sum_byte_array(aux0,aux1));
                
					 internal_state(12 to 15) := aux0; 
					 internal_state(16 to 19) := aux1;
					 internal_state(20 to 23) := aux2;
					 
					 ----
					 
					 aux0 := internal_state(24 to 27);
					 aux1 := internal_state(28 to 31);
					 aux2 := internal_state(32 to 35);
					 
					 --Y31
					 aux0 := xor_byte_array(aux0,sum_byte_array(aux1,aux2));
                --Y32
					 aux1 := xor_byte_array(aux1,sum_byte_array(aux2,aux0));
                --Y33
					 aux2 := xor_byte_array(aux2,sum_byte_array(aux0,aux1));
					 
					 internal_state(24 to 27) := aux0; 
					 internal_state(28 to 31) := aux1;
					 internal_state(32 to 35) := aux2;
					 
					 estado_siguiente <= State4;

            when State4 => -- PASO 5: Actualizar los valores del estado interno mediante las ecuaciones
					 aux0 := internal_state(0 to 3);
					 aux1 := internal_state(16 to 19);
					 aux2 := internal_state(32 to 35);
				
					 --Y11
                aux0 := subtract_byte_array(aux0,chaotic);
                --Y22
					 aux1 := subtract_byte_array(aux1,chaotic);
                --Y33
					 aux2 := subtract_byte_array(aux2,chaotic);
                
					 internal_state(0 to 3) := aux0; 
					 internal_state(16 to 19) := aux1;
					 internal_state(32 to 35) := aux2;
					 
					 estado_siguiente <= State5;

            when State5 => --PASO 6: Guardar los resultados en a, si veces=3 salimos del bucle. En cambio, si veces!=3 volvemos al S2
                a(0 to 35) := resultado(0 to 35);
					 a(36 to 71) := resultado1(0 to 35);
					 a(72 to 99) := resultado2(0 to 27);
                veces := veces + 1;
                if veces = 3 then
                    estado_siguiente <= State6;
                else
                    estado_siguiente <= State2;
                end if;

            when State6 => -- PASO 7: Invertimos el array scrambled con sboxes.
                for i in 0 to filas*columnas-1 loop
                    scrambled(i) := to_integer(unsigned(inv_sbox(a(i))));
                end loop;
                estado_siguiente <= State7;

            when State7 => -- PASO 8: Guardamos el array scrambled en la matriz de salida matrix_out.
                index := 0;
                for f in 0 to filas-1 loop
                    for c in 0 to columnas-1 loop
                        matrix_out(f, c) <= scrambled(index);
								assert false report "El valor de la matriz de salida en("& integer'image(f)&","& integer'image(c)&") es: " & integer'image(scrambled(index)) severity note;

                        index := index + 1;
                    end loop;
                end loop;
					 estado_siguiente <= State8;
				when State8 =>
				
        end case;
    end process;
end Behavorial;
