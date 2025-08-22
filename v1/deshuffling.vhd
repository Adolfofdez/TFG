library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity deshuffling is
    generic(
        filas : integer := 10;
        columnas : integer := 10;
        semilla : integer := 500000; --Valor inicial de la generacion de numeros aleatorios
			r : integer := 3800000 --Numero inicializar la generacion del mapa caotico
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        matrix_in : in matrix(0 to filas-1, 0 to columnas-1);
        matrix_out : out matrix(0 to filas-1, 0 to columnas-1);
		  done : out std_logic
    );
end entity deshuffling;

architecture Behavorial of deshuffling is
    type Estados is (Start, State0, State1, State2, State3, State4, State5, State6, State7, State8);
	 signal estado_actual, estado_siguiente : Estados;
    
begin
    process(clk, reset)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                estado_actual <= Start;
            else
                estado_actual <= estado_siguiente;
            end if;
        end if;
    end process;

    process(estado_actual)
		variable x_var : integer := semilla; --Variable para la generación del mapa caotico
		variable pseudorandom_var : byte_array(0 to 255); --Variable para almacenar el mapa caotico
		variable read_sequence : coordinate_array; --Array de orden de lectura
		variable a1, a2, a3, n, m : integer;
		variable t1, t2, t3, t4, taux1, taux2, taux3, taux4 : integer := 0;
		variable sorted_a1, sorted_a2, sorted_a3 : integer;
		variable P1, P2, P3, P4, aux1, aux2, aux3, aux4, a, array1, my_array : byte_array(0 to filas*columnas-1) := (others=>0);
		variable Mtr, Mtr1 : matrix(0 to filas-1, 0 to columnas-1);
		variable index, index1, i : integer := 0;
		variable limit1, limit2, limit3, limit4 : integer;
    begin
        case estado_actual is
		  when Start=>
		  
			estado_siguiente <= State0;
        when State0 => -- Paso 1: Calcular la misma secuencia de lectura que en el proceso de encriptación
				 
             for k in 0 to 255 loop
                x_var := (r * x_var * (1000000 - x_var))/1000000;
                pseudorandom_var(k):= x_var mod 256;
            end loop;

            a1 := pseudorandom_var(12) mod filas*columnas;
            a2 := pseudorandom_var(103) mod filas*columnas;
            a3 := pseudorandom_var(66) mod filas*columnas;
            n := pseudorandom_var(174) mod 4;
            m := pseudorandom_var(239) mod 4;
				-- Assert para verificar valores de los números pseudoaleatorios
				--	assert a1 >= 0 and a1 <= filas*columnas-1 report "Error: a1 fuera de rango" severity failure;
				--	assert false report "El valor de la señal a1 es: " & integer'image(a1) severity note;

				--	assert a2 >= 0 and a2 <= filas*columnas-1 report "Error: a2 fuera de rango" severity failure;
				--	assert false report "El valor de la señal a2 es: " & integer'image(a2) severity note;

				--	assert a3 >= 0 and a3 <= filas*columnas-1 report "Error: a3 fuera de rango" severity failure;
				--	assert false report "El valor de la señal a3 es: " & integer'image(a3) severity note;

				--	assert n >= 0 and m <= 3 report "Error: n fuera de rango" severity failure;
				--	assert false report "El valor de la señal n es: " & integer'image(n) severity note;

				--	assert m >= 0 and m <= 3 report "Error: m fuera de rango" severity failure;
				--	assert false report "El valor de la señal m es: " & integer'image(m) severity note;
            estado_siguiente <= State1;

				for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    Mtr1(i, j) := matrix_in(i,j);
					 end loop;
            end loop;
        when State1 => -- Paso 2: Aplicar la secuencia de lectura inversa para obtener la matriz original M
           case m is
            when 0 => --Leer así la matriz ?
                read_sequence:=((7,9), (3,0), (0,1), (4,1), (1,1), (5,0), (0,6), (5,6), (2,4), (4,0),
 								(8,5), (5,7), (0,4), (1,0), (2,5), (4,6), (3,2), (2,1), (1,6), (0,8),
 								(3,4), (7,3), (2,3), (2,9), (8,7), (1,3), (0,3), (1,8), (3,6), (5,5),
 								(6,2), (9,0), (4,8), (0,2), (0,0), (6,0), (7,2), (1,5), (0,5), (4,5),
								(3,1), (9,2), (8,0), (1,7), (2,2), (5,3), (3,3), (3,8), (2,8), (4,7),
 								(5,2), (7,1), (6,1), (6,6), (6,4), (7,7), (8,2), (1,9), (0,7), (6,8),
 								(4,5), (9,4), (8,4), (2,7), (3,9), (9,9), (9,7), (5,1), (0,9), (3,7),
 								(4,4), (3,6), (8,1), (9,6), (8,5), (1,2), (7,0), (7,6), (2,6), (6,5),
 								(9,1), (8,3), (7,8), (6,7), (5,3), (7,4), (8,9), (9,5), (4,2), (1,4),
								(5,9), (7,5), (4,3), (9,3), (4,9), (8,8), (5,8), (9,8), (6,9), (2,0)) ;
										  
            when 1 => --Leer así la matriz ?
            read_sequence:=((1,4), (4,2), (9,5), (8,9), (7,4), (5,3), (6,7), (7,8), (8,3), (9,1),
 							(6,5), (2,6), (7,6), (7,0), (1,2), (8,6), (9,6), (8,1), (6,3), (4,4),
							(2,0), (6,9), (9,8), (5,8), (8,8), (4,9), (9,3), (4,3), (7,5), (5,9),
 							(3,7), (0,9), (5,1), (9,7), (9,9), (3,9), (2,7), (8,4), (9,4), (5,4),
 							(6,8), (0,7), (1,9), (8,2), (7,7), (6,4), (6,6), (6,1), (7,1), (5,2),
 							(4,7), (2,8), (3,8), (3,3), (3,5), (2,2), (1,7), (8,0), (9,2), (3,1),
 							(4,5), (0,5), (1,5), (7,2), (6,0), (0,0), (0,2), (4,8), (9,0), (6,2),
 							(5,5), (3,6), (1,8), (0,3), (1,3), (8,7), (2,9), (2,3), (7,3), (3,4),
							(0,8), (1,6), (2,1), (3,2), (4,6), (2,5), (1,0), (0,4), (5,7), (8,5), 
							(4,0), (2,4), (5,6), (0,6), (5,0), (1,1), (4,1), (0,1), (3,0), (7,9));
									 
            when 2 => --Leer así la matriz ?
            read_sequence:=((9,9), (7,9), (9,6), (5,0), (3,6), (9,0), (6,9), (8,3), (8,9), (1,5),
							(9,4), (8,0), (5,9), (8,6), (5,1), (7,6), (8,2), (8,8), (2,1), (2,2),
							(4,5), (5,8), (5,5), (6,0), (7,5), (7,4), (8,1), (9,3), (2,9), (3,8),
							(4,7), (8,5), (6,8), (6,6), (5,6), (6,5), (8,7), (2,8), (3,7), (3,5),
							(9,7), (6,7), (4,6), (9,5), (9,8), (7,3), (9,2), (2,7), (0,8), (2,4),
							(5,7), (9,1), (7,2), (0,7), (2,6), (0,1), (0,4), (3,5), (2,3), (0,2),
							(6,4), (6,2), (7,1), (2,1), (3,4), (4,3), (3,3), (1,3), (1,4), (5,2),
							(6,1), (7,0), (0,6), (1,8), (2,5), (2,4), (3,9), (4,4), (4,1), (5,4),
							(7,7), (7,8), (1,1), (1,7), (2,3), (4,8), (1,3), (4,0), (1,9), (0,5),
							(8,4), (1,0), (1,6), (3,0), (0,9), (6,3), (4,9), (0,3), (2,0), (0,0));
									 
            when 3 => --Leer así la matriz ?
            read_sequence:=((0,0), (2,0), (0,3), (4,9), (6,3), (0,9), (3,0), (1,6), (1,0), (8,4),
							(0,5), (1,9), (4,0), (1,3), (4,8), (2,3), (2,7), (1,1), (7,8), (7,7),
							(5,4), (4,1), (4,4), (3,9), (2,4), (2,5), (1,8), (0,6), (7,0), (6,1),
							(5,2), (1,5), (3,1), (3,3), (4,3), (3,4), (1,2), (7,1), (6,2), (6,4),
							(0,2), (3,2), (5,3), (0,4), (0,1), (2,6), (0,7), (7,2), (9,1), (5,7),
							(4,2), (0,8), (2,7), (9,2), (7,3), (9,8), (9,5), (4,6), (6,7), (9,7),
							(3,5), (3,7), (2,8), (8,7), (6,5), (5,6), (6,6), (6,8), (8,5), (4,7),
							(3,8), (2,9), (9,3), (8,1), (7,4), (7,5), (6,0), (5,5), (5,8), (4,5),
							(2,2), (2,1), (8,8), (8,2), (7,6), (5,1), (8,6), (5,9), (8,0), (9,4),
							(1,5), (8,9), (8,3), (6,9), (9,0), (3,6), (5,0), (9,6), (7,9), (9,9));

            when others =>
                null;
        end case;
				estado_siguiente <= State2;
				
			when State2=>
				index:=0;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    Mtr(i, j) := Mtr1(read_sequence(index).row, read_sequence(index).col);
						  --assert false report "El valor de la señal Mtr en ("& integer'image(i)& "," & integer'image(j)&") es: " & integer'image(Mtr(i,j)) severity note;
						  --assert false report "El valor de la señal Mtr90 es: " & integer'image(matrix_in(read_sequence(i).row, read_sequence(j).col)) severity note;
						  --assert false report "ESTOY LEYENDO LA SECUENCIA" severity note;
							index:=index+1;
					 end loop;
            end loop;
				--assert Mtr(0,0) = matrix_in(0,9) report "Error: La secuencia de lectura falló" severity failure;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    Mtr1(i, j) := Mtr(i,j);
					 end loop;
            end loop;
			
			--	assert false report "LEIDA LA SECUENCIA " & integer'image(veces) & " VECES." severity note;
				
					estado_siguiente <= State3;
        when State3 => -- Paso 3: Reconstruir el array 'a' a partir de la matriz M
            index:=0;
				for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    a(index) := Mtr1(i, j);
						  index:=index+1;
                end loop;
            end loop;
				assert false report "El valor de la señal index es: " & integer'image(index) severity note;
				
				--for i in 0 to filas*columnas-1 loop
				--	a(i):=array1(filas*columnas-1-i);
				--	assert false report "El valor de array dado la vuelta es: " & integer'image(a(i)) severity note;
				--end loop;
            estado_siguiente <= State4;

        when State4 => -- Paso 4: Revertir el reordenamiento de segmentos
           if a1 <= a2 and a1 <= a3 then
                sorted_a1 := a1;
                if a2 <= a3 then
                    sorted_a2 := a2;
                    sorted_a3 := a3;
                else
                    sorted_a2 := a3;
                    sorted_a3 := a2;
                end if;
            elsif a2 <= a1 and a2<= a3 then
                sorted_a1 := a2;
                if a1 <= a3 then
                    sorted_a2 := a1;
                    sorted_a3 := a3;
                else
                    sorted_a2 := a3;
                    sorted_a3 := a1;
                end if;
            else
                sorted_a1 := a3;
                if a1 <= a2 then
                    sorted_a2 := a1;
                    sorted_a3 := a2;
                else
                    sorted_a2 := a2;
                    sorted_a3 := a1;
                end if;
            end if;
            --assert false report "El valor de la señal sorted_a1 es: " & integer'image(sorted_a1) severity note;
			   --assert false report "El valor de la señal sorted_a2 es: " & integer'image(sorted_a2) severity note;
            --assert false report "El valor de la señal sorted_a3 es: " & integer'image(sorted_a3) severity note;
				
				

				estado_siguiente<=State5;
			when State5 =>
            case n is
                when 0 =>
                   index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a1 and i<sorted_a2 then
								P1(index):=a(i);
								--assert false report "P1("& integer'image(index)&")="  & integer'image(P1(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a2 and i<sorted_a3 then
							
									P2(index):=a(i);
									--assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
									index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i>=sorted_a3 and i<=filas*columnas-1 then
								P3(index):=a(i);
								--assert false report "P3("& integer'image(index)&")="  & integer'image(P3(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i<sorted_a1 then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;
                when 1 =>
                  
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a1 and i<sorted_a2 then
								P1(index):=a(i);
								--assert false report "P1("& integer'image(index)&")="  & integer'image(P1(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i< sorted_a1 then
							
									P2(index):=a(i);
									--assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
									index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i>=sorted_a3 and i<=filas*columnas-1 then
								P3(index):=a(i);
								--assert false report "P3("& integer'image(index)&")="  & integer'image(P3(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i>=sorted_a2 and i<sorted_a3 then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;

						 
						
                when 2 =>
                    index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a1 and i<sorted_a2 then
								P1(index):=a(i);
								--assert false report "P1("& integer'image(index)&")="  & integer'image(P1(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a3 and i<=filas*columnas-1 then
							
									P2(index):=a(i);
									--assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
									index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i<sorted_a1 then
								P3(index):=a(i);
								--assert false report "P3("& integer'image(index)&")="  & integer'image(P3(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i>=sorted_a2 and i<sorted_a3 then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;
                when 3 =>
                   index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a3 and i<=filas*columnas-1 then
								P1(index):=a(i);
								--assert false report "P1("& integer'image(index)&")="  & integer'image(P1(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a2 and i<sorted_a3 then
							
									P2(index):=a(i);
									--assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
									index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i>=sorted_a1 and i<sorted_a2 then
								P3(index):=a(i);
								--assert false report "P3("& integer'image(index)&")="  & integer'image(P3(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i<sorted_a1 then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;
                when others =>
                    null;
            end case;



            estado_siguiente <= State6;

        when State6 => -- Paso 5: Unir segmentos para obtener la matriz original
					i:=0;
					index:=0;
               while P1(index)/=0 and index<99 loop 
					  --assert false report "El valor de la señal i en P1 es: " & integer'image(i) severity note;
					  --assert false report "El valor de la P1 en " & integer'image(index) &  "es: " & integer'image(P1(index)) severity note;
                   my_array(i) := P1(index);
						 --assert false report "El valor de la señal my_array en P1 en: " & integer'image(i) & " es " &  integer'image(my_array(i)) severity note;
						 index:=index+1;
						 i:=i+1;
				 	 
					end loop;
                index:=0;
               while P2(index)/=0 and index<99 loop 
					  --assert false report "El valor de la señal i en P2 es: " & integer'image(i) severity note;
                   my_array(i) := P2(index);
					  --assert false report "El valor de la señal my_array en P2 en: " & integer'image(i) & " es " &  integer'image(my_array(i)) severity note;

						 i:=i+1;
						 index:=index+1;
					end loop;
					index:=0;
               while P3(index)/=0 and index<99 loop 
					  --assert false report "El valor de la señal i en P3 es: " & integer'image(i) severity note;
                   my_array(i) := P3(index);
						 --assert false report "El valor de la señal my_array en P3 en: " & integer'image(i) & " es " &  integer'image(my_array(i)) severity note;
						 i:=i+1;
						 index:=index+1;
				 	 
					end loop;
					index:=0;
               while P4(index)/=0 and i<=filas*columnas-1 loop 
					  --assert false report "El valor de la señal i en P4 es: " & integer'image(i) severity note;
                   my_array(i) := P4(index);
						 --assert false report "El valor de la señal my_array en P4 en: " & integer'image(i) & " es " &  integer'image(my_array(i)) severity note;
						 
							i:=i+1;
						 
						index:=index+1;
						 
				 	 
					end loop;
                
            estado_siguiente <= State7;

        when State7 => -- Paso 6: Reconstruir la matriz de salida 'matrix_out'
			   index:=0;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    matrix_out(i, j) <= my_array(index);
						 assert false report "El valor de de salida de deshuffling en (" & integer'image(i) &"," & integer'image(j) &") en deshuffling es: " & integer'image(my_array(index)) severity note;

								index:=index+1;
						  
                end loop;
            end loop;
            estado_siguiente <= State8;
		  when State8 =>
				done<='1';
		  --when others =>
			--	estado_siguiente <= State0; -- Volver al estado inicial
        end case;
    end process;
end architecture Behavorial;
