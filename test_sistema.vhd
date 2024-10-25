-- Vhdl Test Bench template for design  :  sistema
-- Simulation tool : ModelSim-Altera (VHDL)
-- Author: Diego MeCha (2020-01)

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY test_sistema IS
END test_sistema;

ARCHITECTURE sistema_arch OF test_sistema IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC :='0';
SIGNAL rst_n : STD_LOGIC :='1';
SIGNAL valid : STD_LOGIC :='0';
SIGNAL switch_gpio : std_logic_vector(7 downto 0) := "00000000";
SIGNAL LED_gpio : std_logic_vector(7 downto 0) := "00000000";

constant clk_period : time := 1 us;


COMPONENT sistema 
    Port ( clk 			: in 	std_logic;
           rst_n 			: in 	std_logic;
           valid 			: in 	std_logic;
			  switch_gpio	: in	std_logic_vector(7 downto 0);
			  LED_gpio		: out std_logic_vector(7 downto 0)
			  );
end COMPONENT;

BEGIN

-- list connections between master ports and signals
	uut1 : sistema
	PORT MAP (
		--bus_data_out => bus_data_out,
		clk => clk,
		rst_n => rst_n,
		valid => valid,
		switch_gpio => switch_gpio,
		LED_gpio => LED_gpio
	);

-- clock generation (depends on clk_period constant)
   clk_process :PROCESS
   BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
   END PROCESS;

-- Testbench
	always : PROCESS                                              
	BEGIN                                                         
		-- code executes for every event on sensitivity list  
		valid <= '0';
		rst_n	<= '0', '1' after 5 us;
		wait for clk_period*100;	-- Se deja que el programa avance
		switch_gpio <= "10000010";	-- el usuario define la entrada de los interruptores
		wait for clk_period*50;
		valid <= '1';					-- el usuario oprime el botón de validación
		wait for clk_period*100;	
		valid <= '0';					-- el usuario suelta el botón de validación y los datos se cargan
		WAIT;                                                              
	END PROCESS always;                                         

END sistema_arch;
