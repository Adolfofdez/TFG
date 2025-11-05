library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

package tipo is
 subtype valor is integer range 0 to 255; 
 type matrix is array(natural range <>, natural range <>) of valor; 
 type byte_array is array(natural range <>) of valor; 
 type sbox_array is array(0 to 255) of std_logic_vector(0 to 7); 
 type coordinate is record
  row : integer range 0 to 9;
  col : integer range 0 to 9;
 end record;
 type coordinate_array is array (0 to 99) of coordinate; 

 function xor_byte_array(a, b : byte_array) return byte_array;
 function sum_byte_array(a, b : byte_array) return byte_array;
 function subtract_byte_array(a, b : byte_array) return byte_array;

end package tipo;

package body tipo is

 function xor_byte_array(a, b : byte_array) return byte_array is

  variable result : byte_array(a'range); 
  variable temp_a, temp_b, temp_res : std_logic_vector(7 downto 0);

 begin

  if a'length /= b'length then
   report "Error: Arrays de diferentes tama�os." severity failure;
  end if;
  for i in a'range loop
   temp_a := std_logic_vector(to_unsigned(a(i), 8));
   temp_b := std_logic_vector(to_unsigned(b(i), 8));
   temp_res := temp_a xor temp_b;
   result(i) := to_integer(unsigned(temp_res));
  end loop;
  return result;

 end function;

 function sum_byte_array(a, b : byte_array) return byte_array is

  variable result : byte_array(a'range);
  variable temp_a, temp_b, temp_sum : integer;

 begin

  if a'length /= b'length then
   report "Error: Arrays de diferentes tama�os." severity failure;
  end if;


  for i in a'range loop

   temp_a := a(i);
   temp_b := b(i);
   temp_sum := (temp_a + temp_b) mod 255;
   if temp_sum > 255 then
    temp_sum := 255; 
   end if;
   result(i) := temp_sum;
  end loop;

  return result;
 end function;

 function subtract_byte_array(a, b : byte_array) return byte_array is

  variable result : byte_array(a'range);
  variable temp_a, temp_b, temp_diff : integer;

 begin

  if a'length /= b'length then
   report "Error: Arrays de diferentes tama�os." severity failure;
  end if;

  for i in a'range loop
   temp_a := a(i);
   temp_b := b(i);
   temp_diff := (temp_a - temp_b) mod 255;
   if temp_diff < 0 then
    temp_diff := 0; 
   end if;
   result(i) := temp_diff;
  end loop;
  return result;
  
 end function;

end package body tipo;
