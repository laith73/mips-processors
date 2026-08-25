

-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ControlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a MIPS control unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ControlLogic is
  port(i_OpCode     	: in std_logic_vector(5 downto 0);
       i_Funct      	: in std_logic_vector(5 downto 0);
       o_Jump	    	: out std_logic;
       o_Branch	    	: out std_logic_vector(1 downto 0);
       o_MemRead    	: out std_logic;
       o_MemtoReg   	: out std_logic;
       o_ALUControl 	: out std_logic_vector(4 downto 0);
       o_DMemWr	    	: out std_logic;
       o_ALUSrc	    	: out std_logic;
       o_RegWr	    	: out std_logic;
       o_RegDst	    	: out std_logic;
       o_Halt       	: out std_logic;
       o_JR         	: out std_logic;
	   o_JAL			: out std_logic;
       o_LB	    		: out std_logic;
       o_LH	    		: out std_logic;
       o_sign       	: out std_logic;
       o_OverflowEn	  	: out std_logic;
	   o_ALUInputShamt	: out std_logic;
	   o_ALUInputShiftv : out std_logic);

end ControlLogic;

architecture dataflow of ControlLogic is

signal s_ALUControlOp, s_ALUControlFunct : std_logic_vector(4 downto 0);
signal s_OverflowOp, s_OverflowFunct, s_JumpOp, s_JumpFunct, s_JROp, s_JRFunct, s_ALUInputShamt, s_ALUInputShiftv: std_logic;

begin

with i_OpCode(5 downto 0) select
  o_JAL <=  '1' when "000011", --jal
    	'0' when others;

with i_Funct(5 downto 0) select
  s_ALUInputShiftv <= 
	    '1' when "000000",	--sll
	    '1' when "000010",	--srl
	    '1' when "000011",	--sra
	    '1' when "000100",	--sllv
	    '1' when "000110",	--srlv
	    '1' when "000111",	--srav
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_ALUInputShiftv <= s_ALUInputShiftv when "000000",
		'0'  when others;


with i_Funct(5 downto 0) select
  s_ALUInputShamt <= 
	    '1' when "000000",	--sll
	    '1' when "000010",	--srl
	    '1' when "000011",	--sra
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_ALUInputShamt <= s_ALUInputShamt when "000000",
		'0'  when others;

with i_OpCode(5 downto 0) select
  s_JumpOp <= 
	    '1' when "000010",	--j
	    '1' when "000011",	--jal
	    '0' when others;

with i_Funct(5 downto 0) select
  s_JumpFunct <= '1' when "001000", --jr
    	'0' when others;

with i_OpCode(5 downto 0) select
  o_Branch <=
	    "11" when "000100",	--beq
	    "10" when "000101",	--bne
	    "00" when others;

with i_OpCode(5 downto 0) select
  o_MemRead <= 
	    '1' when "100011",  --lw
	    '1' when "100000",	--lb
        '1' when "100001",	--lh
	    '1' when "100100",	--lbu
	    '1' when "100101",	--lhu
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_MemtoReg <=
	    '1' when "100011",  --lw
	    '1' when "100000",	--lb
        '1' when "100001",	--lh
	    '1' when "100100",	--lbu
	    '1' when "100101",	--lhu
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_DMemWr <= 
	    '1' when "101011",	--sw
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_ALUSrc <= '0' when "000000", --R-type
	    '1' when "001000", --addi
	    '1' when "001001", --addiu
	    '1' when "001100", --andi 
	    '1' when "001111", --lui
	    '1' when "100011",  --lw
	    '1' when "001110",  --xori
	    '1' when "001101",	--ori
	    '1' when "001010",	--slti
	    '1' when "101011",	--sw
	    '0' when "000100",	--beq
	    '0' when "000101",	--bne
	    '1' when "000010",	--j
	    '1' when "000011",	--jal
	    '1' when "100000",	--lb
        '1' when "100001",	--lh
	    '1' when "100100",	--lbu
	    '1' when "100101",	--lhu
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_RegWr <= 
	    '0' when "101011",	--sw
	    '0' when "000100",	--beq
	    '0' when "000101",	--bne
	    '0' when "000010",	--j
	    '1' when others;

with i_OpCode(5 downto 0) select
  o_RegDst <= '1' when "000000", --R-type
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_LB <= '0' when "000000", --R-type
	    '0' when "001000", --addi
	    '0' when "001001", --addiu
	    '0' when "001100", --andi 
	    '0' when "001111", --lui
	    '0' when "100011",  --lw
	    '0' when "001110",  --xori
	    '0' when "001101",	--ori
	    '0' when "001010",	--slti
	    '0' when "101011",	--sw
	    '0' when "000100",	--beq
	    '0' when "000101",	--bne
	    '0' when "000010",	--j
	    '0' when "000011",	--jal
	    '1' when "100000",	--lb
        '0' when "100001",	--lh
	    '1' when "100100",	--lbu
	    '0' when "100101",	--lhu
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_LH <=
        '1' when "100001",	--lh
	    '1' when "100101",	--lhu
	    '0' when others;

with i_OpCode(5 downto 0) select
  o_sign <= '0' when "000000", --R-type
	    '1' when "001000", --addi
	    '1' when "001001", --addiu
	    '0' when "001100", --andi 
	    '0' when "001111", --lui
	    '1' when "100011",  --lw
	    '0' when "001110",  --xori
	    '0' when "001101",	--ori
	    '1' when "001010",	--slti
	    '1' when "101011",	--sw
	    '1' when "000100",	--beq
	    '1' when "000101",	--bne
	    '0' when "000010",	--j
	    '0' when "000011",	--jal
	    '1' when "100000",	--lb
        '1' when "100001",	--lh
	    '0' when "100100",	--lbu
	    '0' when "100101",	--lhu
	    '0' when others;


with i_OpCode(5 downto 0) select 
  	o_Halt <= '1' when "010100", --Halt
	    '0' when others;

with i_OpCode(5 downto 0) select
  	s_JROp <= '1' when "000000", --R-type
	    '0' when others;

with i_Funct(5 downto 0) select
  	s_JRFunct <= '1' when "001000",	--jr 
	    '0' when others;

with i_OpCode(5 downto 0) select
  	o_JR   <= s_JRFunct when "000000",
	    s_JROp when others;


with i_OpCode(5 downto 0) select
  	s_ALUControlOp <= "00000" when "000000", --R-type
	    "00000" when "001000", --addi
	    "00000" when "001001", --addiu
	    "00001" when "001100", --andi 
	    "00101" when "001111", --lui
	    "00000" when "100011",  --lw
	    "00011" when "001110",  --xori
	    "00010" when "001101",	--ori
	    "01110" when "001010",	--slti
	    "00000" when "101011",	--sw
	    "01000" when "000100",	--beq
	    "01000" when "000101",	--bne
	    "00000" when "100000",	--lb
        "00000" when "100001",	--lh
	    "00000" when "100100",	--lbu
	    "00000" when "100101",	--lhu
	    "00000" when others;


with i_Funct(5 downto 0) select
  	s_ALUControlFunct <= "00000" when "100000",--add
	    "00000" when "100001",	--addu 
	    "00001" when "100100",	--and
	    "11001" when "100111",	--nor
	    "00011" when "100110",	--xor
        "00010" when "100101",	--or
	    "01110" when "101010",	--slt
	    "00100" when "000000",	--sll
	    "01100" when "000010",	--srl
	    "11100" when "000011",	--sra
	    "01000" when "100010",	--sub
	    "01000" when "100011",	--subu
	    "00100" when "000100",	--sllv
	    "01100" when "000110",	--srlv
	    "11100" when "000111",	--srav
	    "00000" when others;


with i_OpCode(5 downto 0) select
  	s_OverflowOp <= 
	    '1' when "001000", --addi
	    '0' when others;


with i_Funct(5 downto 0) select
  	s_OverflowFunct <= 
	    '1' when "100000",	--add 
	    '1' when "100010",	--sub
	    '0' when others;

with i_OpCode(5 downto 0) select
  	o_ALUControl <= s_ALUControlFunct when "000000",
		s_ALUControlOp    when others;

with i_OpCode(5 downto 0) select
  	o_OverflowEn <= s_OverflowFunct when "000000",
		s_OverflowOp   when others;

with i_OpCode(5 downto 0) select
  	o_Jump <= s_JumpFunct when "000000",
		s_JumpOp    when others;
  
end dataflow;