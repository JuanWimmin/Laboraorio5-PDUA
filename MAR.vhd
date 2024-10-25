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
-- ALU Bit_Slice de N Bits
--             Clk HMAR (habilitador) 
--             _|___|_
--            |       |
--  BUS_DIR ->|       |--> BUS_C 
--            |_______|   
--        
-- ***********************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MAR is
    Port ( CLK		 	: in std_logic;
    		  BUS_DIR 	: out std_logic_vector(7 downto 0);
           BUS_C 		: in std_logic_vector(7 downto 0);
           HMAR 		: in std_logic);
end MAR;


architecture Behavioral of MAR is

begin
process(CLK)
begin
if (CLK'event and CLK ='0')then
if HMAR = '1' then
   BUS_DIR <= BUS_C;
end if;
end if;
end process;
end Behavioral;
