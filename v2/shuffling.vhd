library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.tipo.all;


entity shuffling is 
generic(
 filas : integer := 10; 
 columnas : integer := 10;
 semilla : integer := 500000; 
 r : integer := 3800000 
);
port(
 clk : in std_logic; 
 reset : in std_logic; 
 matrix_in : in matrix(0 to filas-1, 0 to columnas-1); 
 matrix_out : out matrix(0 to filas-1, 0 to columnas-1); 
 done : out std_logic
);
end entity shuffling;

architecture Behavorial of shuffling is
 type Estados is (Start, State0, State1, State2, State3, State4, State5, State6, State7, State8, State9); 
 signal estado_actual, estado_siguiente : Estados := State0; 
 signal row, col : integer :=0;   
begin
process(clk, reset)
begin
 if clk'event and clk='1' then
  if reset='1' then
   estado_actual<=Start;
  else    
   estado_actual<=estado_siguiente;
  end if;
 end if;
end process;

process(estado_actual)
 variable x_var : integer := semilla; 
 variable pseudorandom_var : byte_array(0 to 255); 
 variable a1, a2, a3, n, m, prueba : integer :=0; 
 variable P, P1, P2, P3, P4, aux1, aux2, aux3, aux4, a, my_array : byte_array(0 to filas*columnas-1) := (others=>0); 
 variable index, index1, i : integer :=0; 
 variable sorted_a1, sorted_a2, sorted_a3 : integer :=0;
 variable Mtr : matrix(0 to filas-1, 0 to columnas-1); 
 variable read_sequence : coordinate_array; 
 variable veces : integer :=0; 
begin    
 case estado_actual is
 when Start=>
  estado_siguiente<=State0;
 when State0 => 
  index:=0;
  veces:=0;
  done<='0';
  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    a(index) := matrix_in(i, j);  
    index := index + 1;
   end loop;
  end loop;
  estado_siguiente<=State1;
 when State1 => 
  for k in 0 to 255 loop
   x_var := (r * x_var * (1000000 - x_var))/1000000;
   pseudorandom_var(k):= x_var mod 256;
  end loop; 
  estado_siguiente<=State2;
 when State2=>		
  a1 := pseudorandom_var(8) mod filas*columnas;
  a2 := pseudorandom_var(9) mod filas*columnas;
  a3 := pseudorandom_var(10) mod filas*columnas;
  n := pseudorandom_var(90) mod 4;
  m := pseudorandom_var(91) mod 4;
  estado_siguiente<=State3;
 when State3 => 
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
   estado_siguiente<=State4;
 when State4 => 
  case n is
  when 0 => 
   index:=0;
   for i in 0 to filas*columnas-1 loop
    if i >= sorted_a3 and i<=filas*columnas-1 then
     P1(index):=a(i);
     index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i< sorted_a1 then
	 P2(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a1 and i<sorted_a2 then
	 P3(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if  i>=sorted_a2 and i<sorted_a3  then
	 P4(index):=a(i);
	 index:=index+1;
	end if;
   end loop;					
  when 1 => 
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i >= sorted_a1 and i<sorted_a2 then
	 P1(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i< sorted_a1 then
	 P2(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a3 and i<=filas*columnas-1 then
     P3(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a2 and i<sorted_a3 then
	 P4(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
  when 2 => 
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i >= sorted_a2 and i<sorted_a3 then
	 P1(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i< sorted_a1 then
	 P2(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a3 and i<=filas*columnas-1 then
	 P3(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a1 and i<sorted_a2 then
	 P4(index):=a(i);
	 index:=index+1;
	end if;
   end loop;					
  when 3 =>
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i >= sorted_a3 and i<=filas*columnas-1 then
	 P1(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i >= sorted_a2 and i<sorted_a3 then						
	 P2(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i>=sorted_a1 and i<sorted_a2 then
	 P3(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
   index:=0;
   for i in 0 to filas*columnas-1 loop
	if i<sorted_a1 then
	 P4(index):=a(i);
	 index:=index+1;
	end if;
   end loop;
  when others =>
  end case;
  estado_siguiente<=State5;
 when State5 =>
  i:=0;
  index:=0;
  while P1(index) /=0 and index <99 loop 
   P(i) := P1(index);
   index:=index+1;
   i:=i+1;		 	 
  end loop;
  index:=0;
  while P2(index) /=0 and index <99 loop 
   P(i) := P2(index);
   i:=i+1;
   index:=index+1;
  end loop;
  index:=0;
  while P3(index) /=0 and index <99 loop 
   P(i) := P3(index);
   i:=i+1;
   index:=index+1;
  end loop;
  index:=0;
  while P4(index) /=0 and index <99 loop 
   P(i) := P4(index);
   i:=i+1;
   index:=index+1;
  end loop;
  estado_siguiente<=State6;
 when State6 => 
  index:=0;
  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    Mtr(i,j):=P(index);
	index:=index+1;
   end loop;
  end loop;		
  estado_siguiente<=State7;
            
 when State7 => 
            
  case m is
  when 0 =>
   read_sequence:=((0,9),
                  (0,8),(1,9),
                  (0,7),(1,8),(2,9),
                  (0,6),(1,7),(2,8),(3,9),
                  (0,5),(1,6),(2,7),(3,8),(4,9),
                  (0,4),(1,5),(2,6),(3,7),(4,8),(5,9),
                  (0,3),(1,4),(2,5),(3,6),(4,7),(5,8),(6,9),
                  (0,2),(1,3),(2,4),(3,5),(4,6),(5,7),(6,8),(7,9),
                  (0,1),(1,2),(2,3),(3,4),(4,5),(5,6),(6,7),(7,8),(8,9),
                  (0,0),(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),
                  (1,0),(2,1),(3,2),(4,3),(5,4),(6,5),(7,6),(8,7),(9,8),
                  (2,0),(3,1),(4,2),(5,3),(6,4),(7,5),(8,6),(9,7),
                  (3,0),(4,1),(5,2),(6,3),(7,4),(8,5),(9,6),
                  (4,0),(5,1),(6,2),(7,3),(8,4),(9,5),
                  (5,0),(6,1),(7,2),(8,3),(9,4),
                  (6,0),(7,1),(8,2),(9,3),
                  (7,0),(8,1),(9,2),
                  (8,0),(9,1),
                  (9,0));
										  
  when 1 =>
   read_sequence:=((9,0),
                  (9,1),(8,0),
                  (9,2),(8,1),(7,0),
                  (9,3),(8,2),(7,1),(6,0),
                  (9,4),(8,3),(7,2),(6,1),(5,0),
                  (9,5),(8,4),(7,3),(6,2),(5,1),(4,0),
                  (9,6),(8,5),(7,4),(6,3),(5,2),(4,1),(3,0),
                  (9,7),(8,6),(7,5),(6,4),(5,3),(4,2),(3,1),(2,0),
                  (9,8),(8,7),(7,6),(6,5),(5,4),(4,3),(3,2),(2,1),(1,0),
                  (9,9),(8,8),(7,7),(6,6),(5,5),(4,4),(3,3),(2,2),(1,1),(0,0),
                  (8,9),(7,8),(6,7),(5,6),(4,5),(3,4),(2,3),(1,2),(0,1),
                  (7,9),(6,8),(5,7),(4,6),(3,5),(2,4),(1,3),(0,2),
                  (6,9),(5,8),(4,7),(3,6),(2,5),(1,4),(0,3),
                  (5,9),(4,8),(3,7),(2,6),(1,5),(0,4),
                  (4,9),(3,8),(2,7),(1,6),(0,5),
                  (3,9),(2,8),(1,7),(0,6),
                  (2,9),(1,8),(0,7),
                  (1,9),(0,8),
                  (0,9));
									 
  when 2 => 
   read_sequence:=((9,9),
                  (8,9),(9,8),
                  (7,9),(8,8),(9,7),
                  (6,9),(7,8),(8,7),(9,6),
                  (5,9),(6,8),(7,7),(8,6),(9,5),
                  (4,9),(5,8),(6,7),(7,6),(8,5),(9,4),
                  (3,9),(4,8),(5,7),(6,6),(7,5),(8,4),(9,3),
                  (2,9),(3,8),(4,7),(5,6),(6,5),(7,4),(8,3),(9,2),
                  (1,9),(2,8),(3,7),(4,6),(5,5),(6,4),(7,3),(8,2),(9,1),
                  (0,9),(1,8),(2,7),(3,6),(4,5),(5,4),(6,3),(7,2),(8,1),(9,0),
                  (0,8),(1,7),(2,6),(3,5),(4,4),(5,3),(6,2),(7,1),(8,0),
                  (0,7),(1,6),(2,5),(3,4),(4,3),(5,2),(6,1),(7,0),
                  (0,6),(1,5),(2,4),(3,3),(4,2),(5,1),(6,0),
                  (0,5),(1,4),(2,3),(3,2),(4,1),(5,0),
                  (0,4),(1,3),(2,2),(3,1),(4,0),
                  (0,3),(1,2),(2,1),(3,0),
                  (0,2),(1,1),(2,0),
                  (0,1),(1,0),
                  (0,0));
									 
  when 3 => 
   read_sequence:=((0,0),
                  (1,0),(0,1),
                  (2,0),(1,1),(0,2),
                  (3,0),(2,1),(1,2),(0,3),
                  (4,0),(3,1),(2,2),(1,3),(0,4),
                  (5,0),(4,1),(3,2),(2,3),(1,4),(0,5),
                  (6,0),(5,1),(4,2),(3,3),(2,4),(1,5),(0,6),
                  (7,0),(6,1),(5,2),(4,3),(3,4),(2,5),(1,6),(0,7),
                  (8,0),(7,1),(6,2),(5,3),(4,4),(3,5),(2,6),(1,7),(0,8),
                  (9,0),(8,1),(7,2),(6,3),(5,4),(4,5),(3,6),(2,7),(1,8),(0,9),
                  (9,1),(8,2),(7,3),(6,4),(5,5),(4,6),(3,7),(2,8),(1,9),
                  (9,2),(8,3),(7,4),(6,5),(5,6),(4,7),(3,8),(2,9),
                  (9,3),(8,4),(7,5),(6,6),(5,7),(4,8),(3,9),
                  (9,4),(8,5),(7,6),(6,7),(5,8),(4,9),
                  (9,5),(8,6),(7,7),(6,8),(5,9),
                  (9,6),(8,7),(7,8),(6,9),
                  (9,7),(8,8),(7,9),
                  (9,8),(8,9),
                  (9,9));
									 
  when others =>
					 
  end case;
            
  for t in 0 to filas*columnas-1 loop      
   my_array(t) := Mtr(read_sequence(t).row, read_sequence(t).col);
  end loop;
  for w in 0 to filas*columnas-1 loop
   P(w):=my_array(w);
  end loop;
  veces:=veces+1;
  if veces = 3 then
   estado_siguiente<=State8;
  else
   estado_siguiente<=State6;
  end if;
 when State8 => 
  index:=0;
  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    matrix_out(i,j)<=my_array(index);
	index:=index+1;
   end loop;
  end loop;
  estado_siguiente<=State9;
 when State9 => 
  done<='1';            
 end case;
end process;   
end architecture Behavorial;