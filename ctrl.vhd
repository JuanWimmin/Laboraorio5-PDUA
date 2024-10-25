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
-- Descripcion:     CLK|    |Rst_n
--               ______|____|___________________ 
--              |    _________     __________   |
--        HRI-->|-->|         |   |          |  |
-- INST(7..3)-->|-->| OPCODE  |-->|Dir_H     |  |
--              |   |_________|   |  MEMORIA |->|-> Uinst
--              |    _________    |    uINST |  |
-- uDIR(2..0)-->|-->|   uPC   |-->| Dir_L    |  |
--              |   |_________|   |__________|  |
--              |     |                         |
--              |    _|_______                  |                                    
--       COND-->|-->| EVAL    |                 |
--      FLAGS-->|-->|_SALTOS__|                 |
-- (C,N,Z,P,INT)|_______________________________|      
-- ***********************************************************
 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  UNIDAD DE CONTROL MG

entity ctrl is
    Port ( clk 	: in std_logic;
           rst_n 	: in std_logic;
		     urst_n : in std_logic;
           HRI 	: in std_logic;
           INST 	: in std_logic_vector(4 downto 0);
           C 		: in std_logic;
           Z 		: in std_logic;
           N 		: in std_logic;
           P 		: in std_logic;
           INT 	: in std_logic;
           COND 	: in std_logic_vector(2 downto 0);
           DIR 	: in std_logic_vector(2 downto 0);
           UI 		: out std_logic_vector(24 downto 0));
end ctrl;

architecture Behavioral of ctrl is
signal load : std_logic;	     
signal uaddr: std_logic_vector(7 downto 0);

begin
 RI: process(clk)
 begin
   if (clk'event and clk = '1') then
	if rst_n = '0' then 
	    uaddr(7 downto 3) <= (others => '0');
	  elsif HRI = '1' then
	    uaddr(7 downto 3) <= INST;
     elsif urst_n = '0' then
	  	  uaddr(7 downto 3) <= (others => '0');
	end if; 	
   end if;
 end process;

 CONT: process(clk)
 begin
   if (clk'event and clk = '1') then
	if rst_n = '0' or urst_n = '0' or HRI = '1' then
	      uaddr(2 downto 0) <= (others => '0');
   	elsif load = '1' then
	      uaddr(2 downto 0) <= DIR;
      else
	      uaddr(2 downto 0) <= uaddr(2 downto 0) + 1;
	end if;
   end if;
 end process;

 EVS: process(C,Z,N,P,INT,COND)
 begin
   case cond is
     when "000" => load <= '0';
     when "001" => load <= '1';
     when "010" => load <= Z;
     when "011" => load <= N;
     when "100" => load <= C;
     when "101" => load <= P;
     when "110" => load <= INT;
     when others => load <= '0';
   end case;
 end process;

 MUI: process(uaddr)
 begin
   case uaddr is
   -- HF BUSB(3) SELOP(3) DESP(2) BUSC(3) HR MAR MBR RW IOM HRI RUPC COND(3) OFFS(3)  

   -- FETCH 							    
	when "00000000" => UI <= "000100000XXX0100101110100"; -- JINT 100 (MAR=SP)
	when "00000001" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC,RD MREQ	
	when "00000010" => UI <= "0000110000001000101000XXX"; -- PC= PC+1,RD MREQ
	when "00000011" => UI <= "0000000000000010110000XXX"; -- MDR=DEX, INST=MDR, RD MREQ		
															  			   -- Reset UPC   
	-- INT
	when "00000100" => UI <= "000000000XXX0011101000XXX"; -- [SP]<-PC,WR MREQ
	when "00000101" => UI <= "0001110000011000101000XXX"; -- SP++	
	when "00000110" => UI <= "010000000XXX0100101000XXX"; -- MAR=vector,RD,MREQ IOM=1
	when "00000111" => UI <= "0000000000001010000000XXX"; -- PC<-[vector],rst upc IOM=0

   --00001	 MOV ACC,A 
	when "00001000" => UI <= "1011000001111000100000XXX"; -- ACC = A , Reset UPC
	when "00001001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00001010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00001011" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00001100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00001101" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00001110" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";  -- Las posiciones no utilizadas
	when "00001111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";  -- no importan (no existen)

   --00010  MOV A,ACC
	when "00010000" => UI <= "1111000000111000100000000";  -- PC = ACC, Reset UPC
	when "00010001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010011" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010101" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010110" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "00010111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   --00011	 MOV ACC,CTE
	when "00011000" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC, RD MREQ
	when "00011001" => UI <= "0000110000001000101000XXX"; -- PC = PC + 1, RD MREQ
	when "00011010" => UI <= "0000000001111010100000XXX"; -- ACC = DATA, RD MREQ, Reset UPC
	when "00011011" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   --00100  MOV ACC,[DPTR]
	when "00100000" => UI <= "001000000XXX0100101000XXX"; -- MAR = DPTR, RD MREQ
	when "00100001" => UI <= "0XXXXXXXX1111010100000XXX"; -- MDR=DEX,RD MREQ,ACC=MDR,RST UPC 
	when "00100010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   --00101  MOV DPTR,ACC
	when "00101000" => UI <= "1111000000101000100000XXX"; -- DPTR = ACC , Reset UPC
	when "00101001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   -- 00110 MOV [DPTR],ACC	
	when "00110000" => UI <= "001000000XXX0100101000XXX"; -- MAR=DPTR
	when "00110001" => UI <= "111100000XXX0011100000XXX"; -- MDR = ACC, WR MREQ, RST UPC
	when "00110010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";	  

    -- HF BUSB(3) SELOP(3) DESP(2) BUSC(3) HR MAR MBR RW IOM HRI RUPC COND(3) OFFS(3)  

   -- 00111 INV ACC
	when "00111000" => UI <= "1111001001111000100000XXX"; -- ACC = not ACC, Reset UPC
	when "00111001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	
    -- 01000 AND ACC,A	 
   when "01000000" => UI <= "1011010001111000100000XXX"; -- ACC = ACC and A, Reset UPC
	when "01000001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	
	-- 01001 ADD ACC,A
	when "01001000" => UI <= "1011101001111000100000XXX"; -- ACC = ACC + A, Reset UPC
	when "01001001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	
	-- 01010 JMP DIR
	when "01010000" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC,RD MREQ
	when "01010001" => UI <= "0000110000001000101000XXX"; -- PC= PC+1,RD MREQ
	when "01010010" => UI <= "XXXXXXXXX0001010100000XXX"; -- MDR=DEX,RD MREQ,PC=MDR,RST UPC
	when "01010011" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	
	-- 01011 JZ DIR
	when "01011000" => UI <= "0XXXXXXXXXXX0000101010010"; -- JZ 010 
	when "01011001" => UI <= "0000110000001000100000XXX"; -- PC=PC+1;Reset upc
	when "01011010" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC,RD MREQ
	when "01011011" => UI <= "0XXXXXXXX0001010100000XXX"; -- MDR=DEX,RD MREQ,PC=MDR,RST UPC
	when "01011100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; 

	-- 01100 JN DIR
	when "01100000" => UI <= "0XXXXXXXXXXX0000101011010"; -- JN 010 
	when "01100001" => UI <= "0000110000001000100000XXX"; -- PC=PC+1,Reset upc
	when "01100010" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC,RD MREQ
	when "01100011" => UI <= "0XXXXXXXX0001010100000XXX"; -- MDR=DEX,RD MREQ,PC=MDR,RST UPC
	when "01100100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	
	-- 01101 JC DIR
	when "01101000" => UI <= "0XXXXXXXXXXX0000101100010"; -- JC 010 
	when "01101001" => UI <= "0000110000001000100000XXX"; -- PC=PC+1,Reset upc
	when "01101010" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC,RD MREQ
	when "01101011" => UI <= "0XXXXXXXX0001010100000XXX"; -- MDR=DEX,RD MREQ,PC=MDR,RST UPC
	when "01101100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; 
	
	-- 01110  CALL DIR       
	when "01110000" => UI <= "000000000XXX0100101000XXX"; -- MAR = PC
	when "01110001" => UI <= "0XXXXXXXX1011010101000XXX"; -- MDR=DEX,RD MREQ,TEMP=DIR
	when "01110010" => UI <= "0000110000001000101000XXX"; -- PC= PC+1
	when "01110011" => UI <= "000100000XXX0100101000XXX"; -- MAR = SP
	when "01110100" => UI <= "000000000XXX0011101000XXX"; -- MDR = PC,WR MREQ,[SP]<-PC 
	when "01110101" => UI <= "0001110000011000101000XXX"; -- SP= SP+1
	when "01110110" => UI <= "0101000000001000100000XXX"; -- PC=temp, rst upc
	when "01110111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	
	-- 01111  RET
	when "01111000" => UI <= "0111000001011000101000XXX"; -- temp=acc
	when "01111001" => UI <= "0001000001111000101000XXX"; -- ACC = SP
	when "01111010" => UI <= "0110101000011000101000XXX"; -- SP= ACC+(-1)
	when "01111011" => UI <= "000100000XXX0100101000XXX"; -- MAR = SP
	when "01111100" => UI <= "0XXXXXXXX0001010101000XXX"; -- MDR=DEX,RD MREQ,PC=MDR
	when "01111101" => UI <= "0101000001111000100000XXX"; -- ACC = TEMP, RST upc
	when "01111110" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "01111111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

	-- HF BUSB(3) SELOP(3) DESP(2) BUSC(3) HR MAR MBR RW IOM HRI RUPC COND(3) OFFS(3)  
	
	-- 10000  COMP2 ACC	
	when "10000000" => UI <= "1111111001111000100000XXX"; -- ACC = NOT(ACC) + 1, Reset UPC
	when "10000001" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";	
	
	-- 10001  PUSH ACC
	when "10001000" => UI <= "000100000XXX0100101000XXX"; -- MAR = SP
	when "10001001" => UI <= "011100000XXX0011101000XXX"; -- MDR = ACC, WR MREQ
	when "10001010" => UI <= "0001110000011000100000XXX"; -- SP++, RST UPC
	when "10001011" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	when "10001100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	when "10001101" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	when "10001110" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "10001111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

	-- 10010  POP ACC
	when "10010000" => UI <= "0001000001111000101000XXX"; -- ACC = SP
	when "10010001" => UI <= "0110101000011000101000XXX"; -- SP= ACC+(-1)
	when "10010010" => UI <= "000100000XXX0100101000XXX"; -- MAR = SP
	when "10010011" => UI <= "0XXXXXXXX1111010100000XXX"; -- MDR=DEX,RD MREQ,ACC=MDR, RST UPC
	when "10010100" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	when "10010101" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX"; -- 
	when "10010110" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";
	when "10010111" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   -- HF BUSB(3) SELOP(3) DESP(2) BUSC(3) HR MAR MBR RW IOM HRI RUPC COND(3) OFFS(3)  
   -- 10011  RCV ACC,[DPTR]
	when "10011000" => UI <= "001000000XXX0100001000XXX"; -- MAR = DPTR, RD MREQ
	when "10011001" => UI <= "0XXXXXXXX1111010000000XXX"; -- MDR=DEX,RD MREQ,ACC=MDR, IOM=0, RST UPC 
	when "10011010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";

   -- 10100 SND [DPTR],ACC	
	when "10100000" => UI <= "001000000XXX0101001000XXX"; -- MAR=DPTR
	when "10100001" => UI <= "011100000XXX0011000000XXX"; -- MDR = ACC, WR MREQ, RST UPC
	when "10100010" => UI <= "XXXXXXXXXXXXXXXXXXXXXXXXX";	  
	when others => UI <= (others => 'X');
	
  end case;
 end process;
end Behavioral;



