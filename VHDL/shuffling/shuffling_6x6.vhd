library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.tipo.all;


entity shuffling is 
generic(
    filas : integer := 6; --Nº de filas
    columnas : integer := 6; --Nº de columnas
    semilla : integer := 500000; --Valor inicial de la generacion de numeros aleatorios
    r : integer := 3800000 --Numero inicializar la generacion del mapa caotico
	 
);
port(
    clk : in std_logic; --Señal de reloj
    reset : in std_logic; --Señal de reset
    matrix_in : in matrix(0 to filas-1, 0 to columnas-1); --Matriz de entrada
    matrix_out : out matrix(0 to filas-1, 0 to columnas-1) -- Matriz de salida
);
end entity shuffling;

architecture Behavorial of shuffling is
    type Estados is (State0, State1, State2, State3, State4, State5, State6, State7, State8, State9); --Estados de la maquina de estados
    signal estado_actual, estado_siguiente : Estados := State0; --Variables para los estados
    signal row, col : integer :=0; -- Variable para el tipo coordenada
	 --signal read_sequence : coordinate_array; --Array de orden de lectura
    
    
    
begin
    process(clk, reset)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                estado_actual<=State0;
            else    
                estado_actual<=estado_siguiente;
            end if;
        end if;
    end process;

    process(estado_actual)
		variable x_var : integer := semilla; --Variable para la generación del mapa caotico
		variable pseudorandom_var : byte_array(0 to 255); --Variable para almacenar el mapa caotico
		variable limit1, limit2, limit3, limit4 : integer;
		variable t1, t2, t3, t4, taux1, taux2, taux3, taux4 : integer := 0;
		constant max_limit1, max_limit2, max_limit3, max_limit4 : integer := 99; 
		variable a1, a2, a3, n, m, prueba : integer :=0; --Variables para los numeros pseudoaleatorios
		variable P, P1, P2, P3, P4, aux1, aux2, aux3, aux4, a, my_array : byte_array(0 to filas*columnas-1) := (others=>0); -- Arrays intermedios
      variable index, index1, i : integer :=0;  --Variable de indice de bucle
		variable sorted_a1, sorted_a2, sorted_a3 : integer :=0;
		variable Mtr : matrix(0 to filas-1, 0 to columnas-1); --Matriz intermedia
		variable read_sequence : coordinate_array; --Array de orden de lectura
		variable veces : integer :=0; -- Variable para bucle de estados
    begin
        
      case estado_actual is
        when State0 => --Paso 2: Almacenar matriz de entrada en array intermedio
            index:=0;
				veces:=0;
				--while matrix_in(0,1) = 0 loop
				--end loop;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    a(index) := matrix_in(i, j);  -- Almacenar elemento en el array de salida
						  --assert false report "a("& integer'image(index)&")="  & integer'image(a(index)) severity note;
                    index := index + 1;
                end loop;
            end loop;
				
				--assert false report "El valor de la señal a1 es: " & integer'image(a(0)) severity note;
				--assert false report "El valor de la señal m1 es: " & integer'image(matrix_in(0,0)) severity note;
				--assert false report "El valor de la señal a2 es: " & integer'image(a(1)) severity note;
				--assert false report "El valor de la señal m2 es: " & integer'image(matrix_in(0,1)) severity note;
				--assert false report "El valor de la señal a3 es: " & integer'image(a(2)) severity note;
				--assert false report "El valor de la señal m3 es: " & integer'image(matrix_in(0,2)) severity note;
				--assert false report "El valor de la señal a4 es: " & integer'image(a(3)) severity note;
				--assert false report "El valor de la señal m4 es: " & integer'image(matrix_in(0,3)) severity note;
				-- Assert para verificar que se ha cargado la matriz correctamente
                assert a(0) = matrix_in(0, 0) report "Error: Matrix_in not loaded correctly in array a" severity failure;
				
            estado_siguiente<=State1;
        when State1 => --Paso 3: Generacion de numeros pseudoaleatorios
            for k in 0 to 255 loop
                x_var := (r * x_var * (1000000 - x_var))/1000000;
                pseudorandom_var(k):= x_var mod 256;
            end loop;
            
				estado_siguiente<=State2;
		  when State2=>
				--prueba := pseudorandom_var(12) mod 100;
            a1 := pseudorandom_var(12) mod filas*columnas;
            a2 := pseudorandom_var(103) mod filas*columnas;
            a3 := pseudorandom_var(66) mod filas*columnas;
            n := pseudorandom_var(174) mod 4;
            m := pseudorandom_var(239) mod 4;
				--a1 <= 26;
				--a2 <= 47;
				--a3 <= 97;
				--n<= 2;
				--m<=1;
				--92 assert false report "El valor de la señal prueba es: " & integer'image(prueba) severity note;
				 -- Assert para verificar valores de los números pseudoaleatorios
					assert a1 >= 0 and a1 <= filas*columnas-1 report "Error: a1 fuera de rango" severity failure;
					--92 assert false report "El valor de la señal a1 es: " & integer'image(a1) severity note;

					assert a2 >= 0 and a2 <= filas*columnas-1 report "Error: a2 fuera de rango" severity failure;
					--31 assert false report "El valor de la señal a2 es: " & integer'image(a2) severity note;

					assert a3 >= 0 and a3 <= filas*columnas-1 report "Error: a3 fuera de rango" severity failure;
					--16 assert false report "El valor de la señal a3 es: " & integer'image(a3) severity note;

					assert n >= 0 and m <= 3 report "Error: n fuera de rango" severity failure;
					--assert false report "El valor de la señal n es: " & integer'image(n) severity note;

					assert m >= 0 and m <= 3 report "Error: m fuera de rango" severity failure;
					--0 assert false report "El valor de la señal m es: " & integer'image(m) severity note;

            estado_siguiente<=State3;
        when State3 => --Paso 4. Ordenar a1, a2 y a3 de menor a mayor con la variable temporal temp. Luego obtener los arrays P1, P2, P3 y P4
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
				--assert false report "El valor de la señal a1 es: " & integer'image(a(0)) severity note;
				--assert false report "El valor de la señal a2 es: " & integer'image(a(1)) severity note;
				--assert false report "El valor de la señal a3 es: " & integer'image(a(2)) severity note;
				--assert false report "El valor de la señal a4 es: " & integer'image(a(3)) severity note;
				
				 --assert false report "El valor de la señal sorted_a1 es: " & integer'image(sorted_a1) severity note;
				-- assert false report "El valor de la señal sorted_a2 es: " & integer'image(sorted_a2) severity note;
				-- assert false report "El valor de la señal sorted_a3 es: " & integer'image(sorted_a3) severity note;
				
				--index1:=0;
				--limit1:=sorted_a1-1;
				--for i in 0 to limit1 loop
					--	P1(index1) := a(i);
				--		assert false report "P1("& integer'image(index1)&")="  & integer'image(P1(index1)) severity note;
				--		index1:=index1+1;
				--end loop; 
				-- 16 assert false report "El valor de la señal index1 despues de p1 es: " & integer'image(index1) severity note; 
				--t1:=index1-1;
				--index1:=0;
				--limit2:=sorted_a2-1;
				--for j in sorted_a1 to limit2 loop
					
				--		P2(index1) := a(j);
				--		assert false report "P2("& integer'image(index1)&")="  & integer'image(P2(index1)) severity note;
				--		index1:=index1+1;
				--end loop;
				--31 assert false report "El valor de la señal index1 despues de p2 es: " & integer'image(index1) severity note;
				--t2:=index1-1;
				--index1:=0;
				--limit3:=sorted_a3-1;
				--for k in sorted_a2 to limit3 loop
					
				--		P3(index1) := a(k);
				--		assert false report "P3("& integer'image(index1)&")="  & integer'image(P3(index1)) severity note;
				--		index1:=index1+1;
					
				--end loop;
				--92 assert false report "El valor de la señal index1 despues de p3 es: " & integer'image(index1) severity note;
				--t3:=index1-1;
				--index1:=0;
				--limit4:=99;
				--for l in sorted_a3 to 8 loop
				--		P4(index1) := a(l);
				--		assert false report "P4("& integer'image(index1)&")="  & integer'image(P4(index1)) severity note;
				--		index1:=index1+1;
					
				--end loop;
				--t4:=index1-1;
				--100 assert false report "El valor de la señal index1 despues de p4 es: " & integer'image(index1) severity note;
				
				--15 assert false report "El valor de la señal limit1 es: " & integer'image(limit1) severity note;
				--30 assert false report "El valor de la señal limit2 es: " & integer'image(limit2) severity note;
				--91 assert false report "El valor de la señal limit3 es: " & integer'image(limit3) severity note;
				--99 assert false report "El valor de la señal limit4 es: " & integer'image(limit4) severity note;
				
				--assert false report "El valor de la señal t1 es: " & integer'image(t1) severity note;
				--assert false report "El valor de la señal t2 es: " & integer'image(t2) severity note;
				--assert false report "El valor de la señal t3 es: " & integer'image(t3) severity note;
				--assert false report "El valor de la señal t4 es: " & integer'image(t4) severity note;
				
				--0 assert false report "El valor de la señal a1 es: " & integer'image(a(0)) severity note;
				--1 assert false report "El valor de la señal a2 es: " & integer'image(a(1)) severity note;
				--2 assert false report "El valor de la señal a3 es: " & integer'image(a(2)) severity note;
				--3 assert false report "El valor de la señal a4 es: " & integer'image(a(3)) severity note;
				
				--assert false report "El valor de la señal 22 es: " & integer'image(a(22)) severity note;
				
				--assert false report "El valor de la señal P1 es: " & integer'image(P1(9)) severity note;
			--	assert false report "El valor de la señal P2 es: " & integer'image(P2(7)) severity note;
			--	assert false report "El valor de la señal P3 es: " & integer'image(P3(2)) severity note;
			--	assert false report "El valor de la señal P4 es: " & integer'image(P4(5)) severity note;
				-- Assert para verificar que los números están ordenados
            --    assert sorted_a1 <= sorted_a2 and sorted_a2 <= sorted_a3 report "Error: Los números no están ordenados correctamente" severity failure;
				
            estado_siguiente<=State4;

        when State4 => --Paso 5 Orden de lectura de los arrays P y lectura.
            case n is
					when 0 => --(P4, P1, P2, P3)
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
							if i< sorted_a1 then
							
									P2(index):=a(i);
								--	assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
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
							if  i>=sorted_a2 and i<sorted_a3  then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;
						
					when 1 => --(P2, P1, P4, P3)
					
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
								--	assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
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
						
					when 2 => --(P3, P1, P4, P2)
						index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i >= sorted_a2 and i<sorted_a3 then
								P1(index):=a(i);
								--assert false report "P1("& integer'image(index)&")="  & integer'image(P1(index)) severity note;
								index:=index+1;
							end if;
						 end loop;
						 index:=0;
						 for i in 0 to filas*columnas-1 loop
							if i< sorted_a1 then
							
									P2(index):=a(i);
								--	assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
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
							if i>=sorted_a1 and i<sorted_a2 then
								P4(index):=a(i);
								--assert false report "P4("& integer'image(index)&")="  & integer'image(P4(index)) severity note;
								index:=index+1;
							end if;
						
						 end loop;
						
					when 3 => --(P4, P3, P2, P1)
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
								--	assert false report "P2("& integer'image(index)&")="  & integer'image(P2(index)) severity note;
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
					
				end case;
				
				
					--assert false report "El valor de la señal P1 es: " & integer'image(P1(2)) severity note;
					--assert false report "El valor de la señal aux1 es: " & integer'image(aux1(0)) severity note;
					--assert false report "El valor de la señal P2 es: " & integer'image(P2(0)) severity note;
					--assert false report "El valor de la señal aux2 es: " & integer'image(aux2(0)) severity note;
					--assert false report "El valor de la señal P3 es: " & integer'image(P3(0)) severity note;
					--assert false report "El valor de la señal aux3 es: " & integer'image(aux3(0)) severity note;
					--assert false report "El valor de la señal P4 es: " & integer'image(P4(0)) severity note;
					--assert false report "El valor de la señal aux4 es: " & integer'image(aux4(0)) severity note;
					estado_siguiente<=State5;

        when State5 =>
		  
				--assert false report "El valor de la señal P1 es: " & integer'image(P1(9)) severity note;
				--assert false report "El valor de la señal P2 es: " & integer'image(P2(7)) severity note;
				--assert false report "El valor de la señal P3 es: " & integer'image(P3(2)) severity note;
				--assert false report "El valor de la señal P4 es: " & integer'image(P4(5)) severity note;
			--	assert false report "El valor de la señal t1 es: " & integer'image(t1) severity note;
			--	assert false report "El valor de la señal t2 es: " & integer'image(t2) severity note;
			--	assert false report "El valor de la señal t3 es: " & integer'image(t3) severity note;
			--	assert false report "El valor de la señal t4 es: " & integer'image(t4) severity note;
					i:=0;
					index:=0;
               while P1(index) /=0 and index <99 loop 
					 -- assert false report "El valor de la señal i en P1 es: " & integer'image(i) severity note;
					  --assert false report "El valor de la P1 en " & integer'image(index) &  "es: " & integer'image(P1(index)) severity note;
                   P(i) := P1(index);
					--	 assert false report "El valor de la señal my_array en P1 en: " & integer'image(i) & " es " &  integer'image(P(i)) severity note;
						 index:=index+1;
						 i:=i+1;
				 	 
					end loop;
                index:=0;
               while P2(index) /=0 and index <99 loop 
				--	  assert false report "El valor de la señal i en P2 es: " & integer'image(i) severity note;
                   P(i) := P2(index);
				--	  assert false report "El valor de la señal my_array en P2 en: " & integer'image(i) & " es " &  integer'image(P(i)) severity note;

						 i:=i+1;
						 index:=index+1;
					end loop;
					index:=0;
               while P3(index) /=0 and index <99 loop 
					--  assert false report "El valor de la señal i en P3 es: " & integer'image(i) severity note;
                   P(i) := P3(index);
					--	 assert false report "El valor de la señal my_array en P3 en: " & integer'image(i) & " es " &  integer'image(P(i)) severity note;
						 i:=i+1;
						 index:=index+1;
				 	 
					end loop;
					index:=0;
               while P4(index) /=0 and index <99 loop 
					 -- assert false report "El valor de la señal i en P4 es: " & integer'image(i) severity note;
                   P(i) := P4(index);
					---	 assert false report "El valor de la señal my_array en P4 en: " & integer'image(i) & " es " &  integer'image(P(i)) severity note;
						 --if i<99 then
							i:=i+1;
						 --end if;
						index:=index+1;
						 
				 	 
					end loop;
                
            
            
				-- Assert para verificar reorganización
                --assert P1 /= P2 report "Error: Los arrays P no se reorganizaron correctamente" severity failure;
				
            estado_siguiente<=State6;
        when State6 => --Paso 6 y 9: Almacenar array en matriz intermedia
            index:=0;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
                    Mtr(i,j):=P(index);
                    
							index:=index+1;
						 
                end loop;
            end loop;
				
				-- Assert para verificar que la matriz se reorganizó correctamente
               -- assert Mtr(0, 0) = P(0) report "Error: Reorganización de la matriz fallida" severity failure;
					--assert false report "El valor de la señal Mtr90 es: " & integer'image(Mtr(0,9)) severity note;
            estado_siguiente<=State7;
            
        when State7 => --Paso 7 y 8: Obtener secuencia de lectura
            
        case m is
            when 0 =>
                read_sequence := ((0,5),
                (0,4), (1,5),
                (0,3), (1,4), (2,5),
                (0,2), (1,3), (2,4), (3,5),
                (0,1), (1,2), (2,3), (3,4), (4,5),
                (0,0), (1,1), (2,2), (3,3), (4,4), (5,5),
                (1,0), (2,1), (3,2), (4,3), (5,4),
                (2,0), (3,1), (4,2), (5,3),
                (3,0), (4,1), (5,2),
                (4,0), (5,1),
                (5,0));

            when 1 =>
                read_sequence := ((5,0),
                (5,1), (4,0),
                (5,2), (4,1), (3,0),
                (5,3), (4,2), (3,1), (2,0),
                (5,4), (4,3), (3,2), (2,1), (1,0),
                (5,5), (4,4), (3,3), (2,2), (1,1), (0,0),
                (4,5), (3,4), (2,3), (1,2), (0,1),
                (3,5), (2,4), (1,3), (0,2),
                (2,5), (1,4), (0,3),
                (1,5), (0,4),
                (0,5));

            when 2 =>
                read_sequence := ((5,5),
                (4,5), (5,4),
                (3,5), (4,4), (5,3),
                (2,5), (3,4), (4,3), (5,2),
                (1,5), (2,4), (3,3), (4,2), (5,1),
                (0,5), (1,4), (2,3), (3,2), (4,1), (5,0),
                (0,4), (1,3), (2,2), (3,1), (4,0),
                (0,3), (1,2), (2,1), (3,0),
                (0,2), (1,1), (2,0),
                (0,1), (1,0),
                (0,0));
            when 3 =>
                read_sequence :=((0,0),
                (1,0), (0,1),
                (2,0), (1,1), (0,2),
                (3,0), (2,1), (1,2), (0,3),
                (4,0), (3,1), (2,2), (1,3), (0,4),
                (5,0), (4,1), (3,2), (2,3), (1,4), (0,5),
                (5,1), (4,2), (3,3), (2,4), (1,5),
                (5,2), (4,3), (3,4), (2,5),
                (5,3), (4,4),(3,5),
                (5,4), (4,5),
                (5,5));

            when others =>
                null;
        end case;
				for t in 0 to filas*columnas-1 loop
        
					my_array(t) := Mtr(read_sequence(t).row, read_sequence(t).col);
        
					
				end loop;

				
            for w in 0 to filas*columnas-1 loop
                P(w):=my_array(w);
					 --assert false report "El valor de la señal p es: " & integer'image(P(w)) severity note;
            end loop;
            
				--assert false report "El valor de la señal Mtr90 es: " & integer'image(Mtr(0,9)) severity note;
				--assert false report "El valor de la señal array0 es: " & integer'image(my_array(0)) severity note;
				-- Assert para verificar la secuencia de lectura
					--assert my_array(0) = Mtr(0,9) report "Error: La secuencia de lectura falló1" severity failure;
                --assert my_array(0) /= my_array(1) report "Error: La secuencia de lectura falló" severity failure;
					
				
            veces:=veces+1;
				--assert false report "LEIDA LA SECUENCIA " & integer'image(veces) & " VECES." severity note;
            if veces = 3 then
                estado_siguiente<=State8;
            else
                estado_siguiente<=State6;
            end if;
        when State8 => --Paso 10: Obtener la matriz de salida

            index:=0;
            for i in 0 to filas-1 loop
                for j in 0 to columnas-1 loop
						--	assert false report "El valor de la matriz de salida en la posicion (" & integer'image(i) & "," & integer'image(j) & ")" severity note;
							--assert false report "El valor de la señal my_array es: " & integer'image(my_array(index)) severity note;
                    matrix_out(i,j)<=my_array(index);
						  assert false report "El valor de la matriz de salida en la posicion (" & integer'image(i) & "," & integer'image(j) & ") es: " & integer'image(my_array(index)) severity note;
                    
							index:=index+1;
						 
                end loop;
            end loop;
				
				
				-- Assert para verificar la matriz de salida
            --    assert matrix_out(0, 0) /= matrix_out(0, 1) report "Error: La matriz de salida no es correcta" severity failure;
				
            --SALIR
				estado_siguiente<=State9;
			when State9 => 
			
            
        end case;
    end process;
    
end architecture behavorial;