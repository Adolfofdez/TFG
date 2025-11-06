library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.tipo.all;
entity deshuffling is 
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
 done        : out std_logic
);
end entity deshuffling;

architecture Behavorial of deshuffling is
 type Estados is (State0, State1, State2, State3, State4, State5, State6, State7, State8);
 signal estado_actual, estado_siguiente : Estados := State0; 
 signal row, col : integer :=0; 
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
 variable x_var : integer := semilla; 
 variable pseudorandom_var : byte_array(0 to 255); 
 variable limit1, limit2, limit3, limit4 : integer;
 variable t1, t2, t3, t4, taux1, taux2, taux3, taux4 : integer := 0;
 constant max_limit1, max_limit2, max_limit3, max_limit4 : integer := 99; 
 variable a1, a2, a3, n, m : integer :=0; 
 variable P, P1, P2, P3, P4, aux1, aux2, aux3, aux4, a, my_array : byte_array(0 to filas*columnas-1) := (others=>0); 
 variable index, index1, i : integer :=0;  
 variable sorted_a1, sorted_a2, sorted_a3 : integer :=0;
 variable Mtr : matrix(0 to filas-1, 0 to columnas-1);
 variable read_sequence : coordinate_array; 
begin
 case estado_actual is
 when State0 =>
  index:=0;
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
  a1 := pseudorandom_var(12) mod filas*columnas;
  a2 := pseudorandom_var(103) mod filas*columnas;
  a3 := pseudorandom_var(66) mod filas*columnas;
  n := pseudorandom_var(174) mod 4;
  m := pseudorandom_var(239) mod 4;
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

  when 1 => 
   read_sequence:=((2,0), (6,9), (9,8), (5,8), (8,8), (4,9), (9,3), (4,3), (7,5), (5,9),
   (1,4), (4,2), (9,5), (8,9), (7,4), (5,3), (6,7), (7,8), (8,3), (9,1),
   (6,5), (2,6), (7,6), (7,0), (1,2), (8,6), (9,6), (8,1), (6,3), (4,4),
   (3,7), (0,9), (5,1), (9,7), (9,9), (3,9), (2,7), (8,4), (9,4), (5,4),
   (6,8), (0,7), (1,9), (8,2), (7,7), (6,4), (6,6), (6,1), (7,1), (5,2),
   (4,7), (2,8), (3,8), (3,3), (3,5), (2,2), (1,7), (8,0), (9,2), (3,1),
   (4,5), (0,5), (1,5), (7,2), (6,0), (0,0), (0,2), (4,8), (9,0), (6,2),
   (5,5), (3,6), (1,8), (0,3), (1,3), (8,7), (2,9), (2,3), (7,3), (3,4),
   (0,8), (1,6), (2,1), (3,2), (4,6), (2,5), (1,0), (0,4), (5,7), (8,5), 
   (4,0), (2,4), (5,6), (0,6), (5,0), (1,1), (4,1), (0,1), (3,0), (7,9));

  when 2 => 
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

  when 3 => 
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

  end case;

  for t in 0 to filas*columnas-1 loop
   my_array(t) := Mtr(read_sequence(t).row, read_sequence(t).col);
  end loop;
  for w in 0 to filas*columnas-1 loop
   P(w):=my_array(w);
  end loop;
  estado_siguiente<=State8;
 when State8 =>
  index:=0;
  for i in 0 to filas-1 loop
   for j in 0 to columnas-1 loop
    matrix_out(i,j)<=my_array(index);
    index:=index+1;
   end loop;
  end loop;
  estado_siguiente<=State0;
 end case;
end process;
end architecture behavorial;