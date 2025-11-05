library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity scrambling is 
generic(
 filas : integer := 10; 
 columnas : integer := 10; 
 semilla : integer := 500000; 
 r : integer := 3800000
);
port(
 clk : in std_logic; 
 reset : in std_logic; 
 K1, K2, K3, K4 : in byte_array(0 to 3);
 C1, C2 : in byte_array(0 to 3);
 S1, S2, S3 : in byte_array(0 to 3); 
 matrix_in : in matrix(0 to filas-1, 0 to columnas-1); 
 matrix_out : out matrix(0 to filas-1, 0 to columnas-1); 
 scrambled_ready : out std_logic
);
end entity scrambling;

architecture Behavorial of scrambling is
 type Estados is (State0, State1, State2, State3, State4, State5, State6, State7, State8); 
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
  variable x_var : integer := semilla; 
  variable pseudorandom_var : byte_array(0 to 255); 
  variable fragmento, fragmento1, fragmento2 : byte_array(0 to 35); 
  variable internal_state : byte_array(0 to 35); 
  variable resultado, resultado1, resultado2 : byte_array(0 to 35); 
  variable a : byte_array(0 to filas*columnas-1); 
  variable scrambled : byte_array(0 to filas*columnas-1); 
  variable index : integer := 0; 
  variable chaotic : byte_array(0 to filas*columnas-1); 
  variable a1, a2, a3, a4 : integer; 
  variable aux0, aux1, aux2 : byte_array(0 to 3); 
  variable veces : integer;
 begin

  case estado_actual is
  when State0 => 

   scrambled_ready <= '0';
   veces := 0;
   index:=0;
   internal_state(0 to 3) := K1(0 to 3);
   internal_state(4 to 7) := S1(0 to 3);
   internal_state(8 to 11) := S2(0 to 3);
   internal_state(12 to 15) := S3(0 to 3);
   internal_state(16 to 19) := K2(0 to 3);
   internal_state(20 to 23) := K4(0 to 3);
   internal_state(24 to 27) := C1(0 to 3);
   internal_state(28 to 31) := C2(0 to 3);
   internal_state(32 to 35) := K3(0 to 3);

   for i in 0 to filas-1 loop
    for j in 0 to columnas-1 loop
     a(index) := matrix_in(i, j);  
     index := index + 1;
    end loop;
   
   end loop;

   estado_siguiente <= State1;

  when State1 => 

   fragmento(0 to 35) := a(0 to 35);
   fragmento1(0 to 35) := a(36 to 71);
   fragmento2(0 to 27) := a(72 to 99);
   fragmento2(28 to 35) := (others => 0);

   estado_siguiente <= State2;

  when State2 =>

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

  when State3 => 

   aux0 := internal_state(0 to 3);
   aux1 := internal_state(4 to 7);
   aux2 := internal_state(8 to 11);

   aux2 := xor_byte_array(aux2,(sum_byte_array(aux0,aux1)));
   aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
   aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));

   internal_state(0 to 3) := aux0; 
   internal_state(4 to 7) := aux1;
   internal_state(8 to 11) := aux2;


   aux0 := internal_state(12 to 15);
   aux1 := internal_state(16 to 19);
   aux2 := internal_state(20 to 23);

   aux2 := xor_byte_array(aux2,(sum_byte_array(aux1,aux0)));
   aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
   aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));

   internal_state(12 to 15) := aux0; 
   internal_state(16 to 19) := aux1;
   internal_state(20 to 23) := aux2;


   aux0 := internal_state(24 to 27);
   aux1 := internal_state(28 to 31);
   aux2 := internal_state(32 to 35);

   aux2 := xor_byte_array(aux2,(sum_byte_array(aux1,aux0)));
   aux1 := xor_byte_array(aux1,(sum_byte_array(aux2,aux0)));
   aux0 := xor_byte_array(aux0,(sum_byte_array(aux1,aux2)));

   internal_state(24 to 27) := aux0; 
   internal_state(28 to 31) := aux1;
   internal_state(32 to 35) := aux2;

   estado_siguiente <= State4;

  when State4 => 

   aux0 := internal_state(0 to 3);
   aux1 := internal_state(16 to 19) ;
   aux2 := internal_state(32 to 35);

   aux0 := sum_byte_array(aux0,chaotic(0 to 3));
   aux1 := sum_byte_array(aux1,chaotic(0 to 3));
   aux2 := sum_byte_array(aux2,chaotic(0 to 3));

   internal_state(0 to 3) := aux0; 
   internal_state(16 to 19) := aux1;
   internal_state(32 to 35) := aux2;

   estado_siguiente <= State5;

  when State5 => 

   a(0 to 35) := resultado(0 to 35);
   a(36 to 71) := resultado1(0 to 35);
   a(72 to 99) := resultado2(0 to 27);
   veces := veces + 1;

   if veces = 3 then
    estado_siguiente <= State6; 
   else
    estado_siguiente <= State3;
   end if;      

  when State6 => 

   for i in 0 to 99 loop
    scrambled(i) := to_integer(unsigned(sbox(a(i))));
   end loop;

   estado_siguiente <= State7;

  when State7 => 

   index := 0;
   for f in 0 to filas-1 loop
    for c in 0 to columnas-1 loop
     matrix_out(f, c) <= scrambled(index);
     index := index + 1;
    end loop;
   end loop;
   
   estado_siguiente <= State8;

  when State8 =>
   scrambled_ready <= '1';
  end case;
 end process;
end Behavorial;
