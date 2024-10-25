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
-- Descripcion:  CLK|    |Rst_n
--            ______|____|_______ 
--           |                   |     
--    INT -->|                   |<-- Bus_DATA_in
--    IOM <--|                   |--> Bus_DATA_out
--     RW <--|                   |--> Bus_DIR
--           |___________________|            
-- ***********************************************************


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pdua is
    Port ( clk 			: in 	std_logic;
           rst_n 			: in 	std_logic;
           int 			: in 	std_logic;
           iom 			: out std_logic;		-- IO=0,M=1
           rw 				: out std_logic;		-- R=0,W=1
           bus_dir 	  	: out std_logic_vector(7 downto 0);
           bus_data_in 	: in 	std_logic_vector(7 downto 0);
			  bus_data_out	: out std_logic_vector(7 downto 0));
end pdua;

architecture Behavioral of pdua is

component ctrl is
    Port ( clk 	: in 	std_logic;
           rst_n 	: in 	std_logic;
		     urst_n : in 	std_logic;
           HRI 	: in 	std_logic;
           INST 	: in 	std_logic_vector(4 downto 0);
           C 		: in 	std_logic;
           Z 		: in 	std_logic;
           N 		: in 	std_logic;
           P 		: in 	std_logic;
           INT 	: in 	std_logic;
           COND 	: in 	std_logic_vector(2 downto 0);
           DIR 	: in 	std_logic_vector(2 downto 0);
           UI 		: out std_logic_vector(24 downto 0));
end component;

component banco is
    Port ( CLK 	: in 	std_logic;
    		 RESET_n	: in 	std_logic;
           HR		: in 	std_logic;
           SC,SB 	: in 	std_logic_vector(2 downto 0);
           BUSC 	: in 	std_logic_vector(7 downto 0);
           BUSA,BUSB : out std_logic_vector(7 downto 0)
		 );
end component;

component ALU is
    	Port (CLK,HF: in  std_logic; 
		      A 		: in 	std_logic_vector(7 downto 0);
            B 		: in 	std_logic_vector(7 downto 0);
            SELOP : in 	std_logic_vector(2 downto 0);
            DESP 	: in 	std_logic_vector(1 downto 0);
            S 		: inout 	std_logic_vector(7 downto 0);	  				
            C,N,Z,P 	: out std_logic
		 );
end component;

component MAR is
    Port ( CLK		: in 	std_logic;
    		  BUS_DIR: out std_logic_vector(7 downto 0);
           BUS_C 	: in 	std_logic_vector(7 downto 0);
           HMAR 	: in 	std_logic);
end component;

component MDR is
    Port ( DATA_EX_in 	: in 	std_logic_vector(7 downto 0);
			  DATA_EX_out 	: out std_logic_vector(7 downto 0);
           DATA_ALU 		: in 	std_logic_vector(7 downto 0);
           DATA_C 		: out std_logic_vector(7 downto 0);
           HMDR 			: in 	std_logic;
           RD_WR 			: in 	std_logic);
end component;

signal hf, hr, urst_n, hri, C, Z, N, P ,HMAR, HMDR : std_logic;
signal sc, sb, cond 	: std_logic_vector(2 downto 0);
signal func,dir 		: std_logic_vector(2 downto 0);
signal busa, busb, busc, bus_alu : std_logic_vector(7 downto 0);
signal desp 			: std_logic_vector(1 downto 0);
signal ui 				: std_logic_vector(24 downto 0);

begin
-- Microinstruccion
hf    	<= ui(24);					-- Habilitador de almacenamiento de banderas
sb 		<= ui(23 downto 21); 	-- Selector bus B (salida)
func 		<= ui(20 downto 18);   	-- Selector funcion ALU
desp 		<= ui(17 downto 16);   	-- Habilitador desplazamiento
sc 		<= ui(15 downto 13);		-- Selector bus C (entrada)
hr 		<= ui(12);					-- Habilitador registro destino
HMAR 		<= ui(11);					-- Habilitador MAR
HMDR 		<= ui(10);					-- Habilitador MDR
RW 		<= ui(9); 					-- Read/Write 0/1
iom 		<= ui(8);					-- IO/MEM 0/1
hri 		<= ui(7);					-- Habilitador registro instruccion
urst_n 	<= ui(6);					-- Reset de microcontador
cond 		<= ui(5 downto 3); 		-- Condicion de salto
dir 		<= ui(2 downto 0);		-- Micro-offset de salto

CONTROL: ctrl  port map (clk,rst_n,urst_n,hri,busc(7 downto 3),C,Z,N,P,int,cond,dir,ui);
BANREG: banco port map (clk, rst_n, hr, sc, sb, busc, busa, busb); 
ALU_T: alu 	 port map (clk,hf,busa, busb, func, desp, bus_alu, C, N, Z, P );
MAR_R: mar 	 port map (clk, bus_dir, busc, HMAR );
MDR_R: mdr 	 port map (bus_data_in,bus_data_out,bus_alu,busc,HMDR,ui(9));

end Behavioral;
