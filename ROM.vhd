-- ***********************************************************
-- ** PROYECTO PDUA                                         **
-- **   										                        **
-- ** Universidad de Los Andes                              **
-- ** Pontificia Universidad Javeriana                      **
-- **   										                        **
-- ** Rev 0.0 Arq Basica        Mauricio Guerrero   06/2007 **
-- ** Rev 0.1 Microprograma     Mauricio Guerrero           **
-- **         RAM doble puerto  Diego Méndez        11/2007 **
-- ** Rev 0.2 ALU bit-slice     MGH                 03/2008 **
-- ** Rev 0.3 Corrección Doc    DMCH                03/2009 **
-- ** Rev 0.4 ROM-RAM 128       DMCH                11/2009 **
-- ** Rev 0.5 PUSH-POP          DMCH                11/2009 **
-- ** Rev 0.6 Videos-Doc        DMCH                03/2021 **
-- ***********************************************************

-- ***********************************************************
-- Descripcion:
-- ROM (Solo lectura)
--                  _______
--    cs,iom,rd -->|       |
--          dir -->|       |--> data
--                 |_______|   
--        
-- ***********************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ROM is
    Port ( cs,rd,iom	: in std_logic;
           dir 	: in std_logic_vector(6 downto 0);
           data 	: out std_logic_vector(7 downto 0));
end ROM;

-- ROM para sondeo de GPIO
architecture Behavioral of ROM is
begin
process(cs,rd,dir)
begin
if cs = '1' and rd = '0' and iom = '1' then
       case dir is
        -- Inicio del programa
        when "0000000" => data <= "01010000";  -- JMP MAIN
        when "0000001" => data <= "00000011";  -- Dir MAIN
        when "0000010" => data <= "00000000";  -- No usado
        
        -- MAIN: Inicialización
        when "0000011" => data <= "00011000";  -- MOV ACC,CTE 
        when "0000100" => data <= "00000000";  -- CTE = 0x00 (LEDs apagados inicialmente)
        when "0000101" => data <= "00101000";  -- MOV DPTR,ACC
        when "0000110" => data <= "10100000";  -- SND [DPTR],ACC (apaga todos los LEDs)
        
        -- POLLING: Inicio del bucle de sondeo
        when "0000111" => data <= "00011000";  -- MOV ACC,CTE
        when "0001000" => data <= "00000101";  -- CTE = 0x05 (dir lectura switches)
        when "0001001" => data <= "00101000";  -- MOV DPTR,ACC
        when "0001010" => data <= "10011000";  -- RCV ACC,[DPTR] (lee estado de pulsadores)
        
        -- Guardar valor leído en RAM
        when "0001011" => data <= "00010000";  -- MOV A,ACC (guarda valor en A)
        when "0001100" => data <= "00011000";  -- MOV ACC,CTE
        when "0001101" => data <= "00000100";  -- CTE = 0x04 (dir escritura LED)
        when "0001110" => data <= "00101000";  -- MOV DPTR,ACC
        when "0001111" => data <= "00001000";  -- MOV ACC,A (recupera valor)
        when "0010000" => data <= "10100000";  -- SND [DPTR],ACC (actualiza LEDs)
        
        -- Volver a polling
        when "0010001" => data <= "01010000";  -- JMP POLLING
        when "0010010" => data <= "00000111";  -- Dir POLLING
        
        when others => data <= (others => 'X');
       end case;
else data <= (others => 'Z');
end if;  
end process;
end;