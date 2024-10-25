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
-- ** Rev 0.7 Soporte INT       DMCH                08/2021 **
-- ***********************************************************

-- ***********************************************************
-- ** FSM para Soportar INT por Flanco                      **
-- ***********************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity interrupt_support is
    Port ( int 		: in  STD_LOGIC;
           iom 		: in  STD_LOGIC;
           clk 		: in  STD_LOGIC;
           rst 		: in  STD_LOGIC;
           int_out	: out  STD_LOGIC);
end interrupt_support;

architecture Behavioral of interrupt_support is

    type states is (S0, S1, S2, S3);
    signal current_state: states;

begin

	process(int, iom, clk, rst)
	begin
		if rst = '0' then
			current_state <= S0;
		elsif clk'event and clk = '1' then
			case current_state is
				when S0 =>
					if int = '0' then 
						current_state <= S0;
					else
						current_state <= S2;
					end if;
				when S1 =>	
						current_state <= S2;
				when S2 =>	
					if iom = '1' then
						current_state <= S2;
					else
						current_state <= S3;
					end if;
				when S3 =>	
					if int = '1' then 
						current_state <= S3;
					else
						current_state <= S0;
					end if;
				when others =>
					current_state <= S0;
			end case;
		end if;
	end process;

	int_out <= '1' when current_state = S2 else '0'; 

end Behavioral;

