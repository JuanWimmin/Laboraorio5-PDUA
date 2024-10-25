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

-- ***********************************************
-- Descripcion:
-- RAM (Buses de datos independientes in-out)
--                   _______
--     cs,rw,iom -->|       |
-- dir(direccion)-->|       |--> data_out
--       data_in -->|_______|   
--        
-- ***********************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    Port ( cs,rw,iom	   : in std_logic;
           dir 	   : in std_logic_vector(6 downto 0);
           data_in 	: in std_logic_vector(7 downto 0);
			  data_out 	: out std_logic_vector(7 downto 0));
end RAM;

architecture Behavioral of RAM is

type memoria is array (127 downto 0) of std_logic_vector(7 downto 0);
signal mem: memoria;

begin
process(cs,rw,dir,data_in,mem)
begin
if cs = '1' and iom = '1'  then
   if rw = '0' then  -- Read
       case dir is
	    when "0000000" => data_out <= mem(0);
	    when "0000001" => data_out <= mem(1);
	    when "0000010" => data_out <= mem(2);
	    when "0000011" => data_out <= mem(3);
	    when "0000100" => data_out <= mem(4);
	    when "0000101" => data_out <= mem(5);
	    when "0000110" => data_out <= mem(6);
	    when "0000111" => data_out <= mem(7);
		 when "0001000" => data_out <= mem(8); -- Inicio del Stack (SP = 0x88)
		 when "0001001" => data_out <= mem(9);
		 when "0001010" => data_out <= mem(10);
		 when "0001011" => data_out <= mem(11);
		 when "0001100" => data_out <= mem(12);
		 when "0001101" => data_out <= mem(13);
		 when "0001110" => data_out <= mem(14);
		 when "0001111" => data_out <= mem(15);
	    when others => data_out <= (others => 'X'); 
       end case;
   else 					-- Write
       case dir is
	    when "0000000" => mem(0) <= Data_in;
	    when "0000001" => mem(1) <= Data_in;
	    when "0000010" => mem(2) <= Data_in;
	    when "0000011" => mem(3) <= Data_in;
	    when "0000100" => mem(4) <= Data_in;
	    when "0000101" => mem(5) <= Data_in;
	    when "0000110" => mem(6) <= Data_in;
	    when "0000111" => mem(7) <= Data_in;
		 when "0001000" => mem(8) <= Data_in;
		 when "0001001" => mem(9) <= Data_in;
		 when "0001010" => mem(10) <= Data_in;
		 when "0001011" => mem(11) <= Data_in;
		 when "0001100" => mem(12) <= Data_in;
		 when "0001101" => mem(13) <= Data_in;
		 when "0001110" => mem(14) <= Data_in;
		 when "0001111" => mem(15) <= Data_in;
	    when others => mem(15) <= Data_in;
       end case;
    end if;
else data_out <= (others => 'Z');
end if;  
end process;

end Behavioral;
