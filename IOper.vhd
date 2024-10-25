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
	-- PERIFÉRICO DE EJEMPLO
	-- Uso de SND y RCV para transferencia de datos
	-- ***********************************************************


	library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

	entity IOper is
		 Port ( clk,rst_n,valid 	: in 	std_logic;
				  int 			: out std_logic;
				  iom 			: in  std_logic;		-- IO=0,M=1
				  rw 				: in  std_logic;		-- R=0,W=1
				  bus_dir 	  	: in std_logic_vector(7 downto 0);
				  bus_data_in 	: in 	std_logic_vector(7 downto 0);
				  bus_data_out	: out std_logic_vector(7 downto 0);
				  LED_gpio		: out std_logic_vector(7 downto 0);
				  switch_gpio 	: in 	std_logic_vector(7 downto 0));
	end IOper;


	architecture Behavioral of IOper is

	signal reg_switch,reg_LED : std_logic_vector(7 downto 0);
	signal CS_RD, CS_WR : std_logic;
	type RD_states is (S0,S1,S2,S3,S4);
	signal read_state : RD_states := S0;

	begin

	-- Proceso de Transferencia Procesador>Periférico

	CS_WR <= (not iom) and (rw) and (not bus_dir(7)) and (not bus_dir(6)) and (not bus_dir(5)) and (not bus_dir(4)) and (not bus_dir(3)) and ( bus_dir(2)) and (not bus_dir(1)) and (not bus_dir(0)); -- Write process in address 0x04

	process(rst_n,CS_WR,bus_data_in)
	begin
		if rst_n = '0' then
			reg_LED <= "00000000";
		elsif CS_WR = '1' then 
			reg_LED <= bus_data_in; -- Asignar el valor a los LED (encender los LED con el valor definido por el procesador)
		else
			reg_LED <= reg_LED;
		end if;
	end process;

	LED_gpio <= reg_LED;


	-- Proceso de Transferencia Periférico>Procesador

	CS_RD <= (not iom) and (not rw) and (not bus_dir(7)) and (not bus_dir(6)) and (not bus_dir(5)) and (not bus_dir(4)) and (not bus_dir(3)) and (bus_dir(2)) and (not bus_dir(1)) and (bus_dir(0)); -- Write process in address 0x04


	process(clk,rst_n,rw,bus_data_in,bus_dir)
	begin
		if rst_n = '0' then
			read_state <= S0;
		elsif clk'event and clk='1' then
			case read_state is
				when S0 =>
					if valid ='0' then
						read_state <= S0;
					else
						read_state <= S1;
					end if;
				when S1 =>
					if valid ='0' then
						read_state <= S2;
					else
						read_state <= S1;
					end if;
				when S2 =>
					read_state <= S3;
				when S3 =>
					if CS_RD ='0' then
						read_state <= S3;
					else
						read_state <= S4;
					end if;
				when S4 =>
					if CS_RD ='1' then
						read_state <= S4;
					else
						read_state <= S0;
					end if;
				when others =>
					read_state <= S0;
			end case;
		end if;
	end process;


	process(read_state,reg_switch,switch_gpio)
	begin
		if read_state = S0 then
			reg_switch <= "00000000";
			int <= '0';
			bus_data_out <= (others => 'Z');
		elsif read_state = S1 then
			int <= '0';
			bus_data_out <= (others => 'Z');
		elsif read_state = S2 then
			reg_switch <= switch_gpio;
			int <= '1';
			bus_data_out <= (others => 'Z');
		elsif read_state = S3 then
			int <= '1';
			bus_data_out <= (others => 'Z');
		elsif read_state = S4 then
			int <= '0';
			bus_data_out <= reg_switch;
		else
			bus_data_out <= (others => 'Z');
			int <= '0';
		end if;
	end process;


	end Behavioral;
