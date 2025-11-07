library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- Importar para convertir entre enteros y std_logic_vector

package tipo is
    subtype valor is integer range 0 to 255; --Valores que podrá tomar un vector de un byte de tamaño
    type matrix is array(natural range <>, natural range <>) of valor; --Tipo matriz de valor
    type byte_array is array(natural range <>) of valor; --Tipo array de valor
    type sbox_array is array(0 to 255) of std_logic_vector(0 to 7); --Tipo de array para los Sbox
    type coordinate is record -- Variable tipo para la secuencia de lectura
        row : integer range 0 to 9;
        col : integer range 0 to 9;
    end record;
    type coordinate_array is array (0 to 99) of coordinate; -- Tipo array para leer las coordenadas
function xor_byte_array(a, b : byte_array) return byte_array;

function sum_byte_array(a, b : byte_array) return byte_array;

function subtract_byte_array(a, b : byte_array) return byte_array;
end package tipo;

package body tipo is

function xor_byte_array(a, b : byte_array) return byte_array is
  variable result : byte_array(a'range); 
  variable temp_a, temp_b, temp_res : std_logic_vector(7 downto 0);
begin
  -- Comprobar que los arrays tienen el mismo tamaño
  if a'length /= b'length then
    report "Error: Arrays de diferentes tamaños." severity failure;
  end if;

  -- Realizar la operación XOR elemento por elemento
  for i in a'range loop
    -- Convertir cada entero a std_logic_vector de 8 bits
    temp_a := std_logic_vector(to_unsigned(a(i), 8));
    temp_b := std_logic_vector(to_unsigned(b(i), 8));

    -- Aplicar XOR a nivel de bits
    temp_res := temp_a xor temp_b;

    -- Convertir el resultado de nuevo a entero (0..255) sin recorte
    result(i) := to_integer(unsigned(temp_res));
  end loop;
  
  return result;
end function;

function sum_byte_array(a, b : byte_array) return byte_array is
        variable result : byte_array(a'range);
        variable temp_a, temp_b, temp_sum : integer;
    begin
        -- Comprobar que los arrays tienen el mismo tamaño
        if a'length /= b'length then
            report "Error: Arrays de diferentes tamaños." severity failure;
        end if;

        -- Realizar la operación de suma elemento por elemento
        for i in a'range loop
            -- Convertir cada valor a integer para la suma
            temp_a := a(i);
            temp_b := b(i);

            -- Sumar los valores y aplicar la saturación (si es necesario)
            temp_sum := (temp_a + temp_b) mod 255;
            if temp_sum > 255 then
                temp_sum := 255; -- Saturación para valores fuera del rango
            end if;

            -- Asignar el resultado al array
            result(i) := temp_sum;
        end loop;
        
        return result;
    end function;

function subtract_byte_array(a, b : byte_array) return byte_array is
        variable result : byte_array(a'range);
        variable temp_a, temp_b, temp_diff : integer;
    begin
        -- Comprobar que los arrays tienen el mismo tamaño
        if a'length /= b'length then
            report "Error: Arrays de diferentes tamaños." severity failure;
        end if;

        -- Realizar la operación de resta elemento por elemento
        for i in a'range loop
            -- Convertir cada valor a integer para la resta
            temp_a := a(i);
            temp_b := b(i);

            -- Restar los valores y aplicar la saturación (si es necesario)
            temp_diff := (temp_a - temp_b) mod 255;
            if temp_diff < 0 then
                temp_diff := 0; -- Saturación para valores negativos
            end if;

            -- Asignar el resultado al array
            result(i) := temp_diff;
        end loop;
        
        return result;
    end function;
 
end package body tipo;
