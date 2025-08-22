library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tipo.all;

entity descrambling is
    generic(
        filas    : integer := 10;
        columnas : integer := 10;
        semilla  : integer := 500000;  -- Semilla LFSR
        r        : integer := 3800000  -- Constante mapa caótico
    );
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        K1, K2, K3, K4      : in  byte_array(0 to 3);
        C1, C2      : in  byte_array(0 to 3);
        S1, S2, S3  : in  byte_array(0 to 3);
        matrix_in   : in  matrix(0 to filas-1, 0 to columnas-1);
        matrix_out  : out matrix(0 to filas-1, 0 to columnas-1);
		  ready        : out std_logic
    );
end entity descrambling;

architecture Behavioral of descrambling is
    type Estado is (start, Init, InvSbox, ComputeOrig, WriteOut, Done);
    signal current, next_state : Estado;
	 signal int_state   : byte_array(0 to 35);
	 signal a           : byte_array(0 to filas*columnas-1);


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
    -- FSM clock/reset
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current <= Start;
            else
                current <= next_state;
            end if;
        end if;
    end process;

    process(current)
        
        variable idx, i, j   : integer;
		  variable fragmento   : byte_array(0 to 35);
		  variable fragmento1  : byte_array(0 to 35);
		  variable fragmento2  : byte_array(0 to 35);
		  variable orig0       : byte_array(0 to 35);
		  variable orig1       : byte_array(0 to 35);
		  variable orig2       : byte_array(0 to 35);
	
        
    begin
        case current is
				when Start =>
					next_state <= Init;
            when Init =>
                -- 1) Inicializar internal_state igual que scrambler
                int_state(0 to 3)   <= K1;
                int_state(4 to 7)   <= S1;
                int_state(8 to 11)  <= S2;
                int_state(12 to 15) <= S3;
                int_state(16 to 19) <= K2;
                int_state(20 to 23) <= K4;
                int_state(24 to 27) <= C1;
                int_state(28 to 31) <= C2;
                int_state(32 to 35) <= K3;
                -- 2) Leer matrix_in en array lineal a
                idx := 0;
                for i in 0 to filas-1 loop
                    for j in 0 to columnas-1 loop
                        a(idx) <= matrix_in(i,j);
								assert false report "El valor de la matriz de entrada en descrambling en("& integer'image(i)&","& integer'image(j)&") es: " & integer'image(a(idx)) severity note;
                        idx := idx + 1;
                    end loop;
                end loop;
                next_state <= InvSbox;

            when InvSbox =>
                -- Invierte la S-box aplicada al final del scrambler
                for idx in 0 to filas*columnas-1 loop
                    a(idx) <= to_integer(unsigned(inv_sbox(a(idx))));
						  assert false report "El valor del array despues de la sbox en descrambling en("& integer'image(idx)&") es: " & integer'image(a(idx)) severity note;
                end loop;
                next_state <= ComputeOrig;

            when ComputeOrig =>
                -- Dividir a en fragmentos de 36 bytes (último con relleno)
                fragmento  := a(0 to 35);
                fragmento1 := a(36 to 71);
                fragmento2 := (others => 0);
                fragmento2(0 to 27) := a(72 to 99);
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del fragmento en descrambling en("& integer'image(idx)&") es: " & integer'image(fragmento(idx)) severity note;
                end loop;
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del fragmento1 en descrambling en("& integer'image(idx)&") es: " & integer'image(fragmento1(idx)) severity note;
                end loop;
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del fragmento2 en descrambling en("& integer'image(idx)&") es: " & integer'image(fragmento2(idx)) severity note;
                end loop;
					 
					 
                -- Recuperar datos originales: orig = fragmento XOR internal_state
                orig0 := xor_byte_array(int_state(0 to 35), fragmento);
                orig1 := xor_byte_array(int_state(0 to 35), fragmento1);
                orig2 := xor_byte_array(int_state(0 to 35), fragmento2);
					 
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del int_state en descrambling en("& integer'image(idx)&") es: " & integer'image(int_state(idx)) severity note;
                end loop;
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del orig en descrambling en("& integer'image(idx)&") es: " & integer'image(orig0(idx)) severity note;
                end loop;
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del orig1 en descrambling en("& integer'image(idx)&") es: " & integer'image(orig1(idx)) severity note;
                end loop;
					 for idx in 0 to 35 loop
                    
						  assert false report "El valor del orig2 en descrambling en("& integer'image(idx)&") es: " & integer'image(orig2(idx)) severity note;
                end loop;
					 
					 
                -- Reconstruir array a con orig0|orig1|orig2
                a(0 to 35)   <= orig0;
                a(36 to 71)  <= orig1;
                a(72 to 99)  <= orig2(0 to 27);
					 
                next_state <= WriteOut;
					 
					 

            when WriteOut =>
                -- Volcar a de nuevo en matrix_out
                idx := 0;
                for i in 0 to filas-1 loop
                    for j in 0 to columnas-1 loop
                        matrix_out(i,j) <= a(idx);
								assert false report "El valor de la matriz de salida en descrambling en("& integer'image(i)&","& integer'image(j)&") es: " & integer'image(a(idx)) severity note;
                        idx := idx + 1;
                    end loop;
                end loop;
					 
					 
					 
                next_state <= Done;

            when Done =>
					 ready <= '1';
                next_state <= Done;

        end case;
    end process;
end architecture Behavioral;
