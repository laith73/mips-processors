-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- AdderSubtractor_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the ID/EX Register.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EXReg is
   	port(
		i_CLK	 			: in std_logic;
		i_RST	 			: in std_logic;
		i_WE	 			: in std_logic;
		i_Inst				: in std_logic_vector(31 downto 0);
		i_RegRs	 			: in std_logic_vector(31 downto 0);
		i_RegRt	 			: in std_logic_vector(31 downto 0);
		i_ExtImm 			: in std_logic_vector(31 downto 0);
		i_PC4	 			: in std_logic_vector(31 downto 0);
		--Need the control signals for later stages to be passed through
		i_Sign	 	 		: in std_logic;
		i_ALUSrc	 		: in std_logic;
		i_ALUInputShiftV 	: in std_logic;
		i_ALUInputShamt	 	: in std_logic;
		i_UnsignedInst	 	: in std_logic;
		i_ALUControl 	 	: in std_logic_vector(4 downto 0);
		i_DMemWr	 		: in std_logic;
		i_LB	 			: in std_logic;
		i_LH	 	 		: in std_logic;
		i_MemtoReg	 		: in std_logic;
		i_RegDst	 		: in std_logic;
		i_RegWr	 	 		: in std_logic;
		i_Halt	 	 		: in std_logic;
		i_JAL	 	 		: in std_logic;
		o_Inst	 			: out std_logic_vector(31 downto 0);
		o_RegRs	 			: out std_logic_vector(31 downto 0);
		o_RegRt	 			: out std_logic_vector(31 downto 0);
		o_ExtImm 			: out std_logic_vector(31 downto 0);
		o_PC4		 		: out std_logic_vector(31 downto 0);
		o_Sign	 	 		: out std_logic;
		o_ALUSrc	 		: out std_logic;
		o_ALUInputShiftV 	: out std_logic;
		o_ALUInputShamt	 	: out std_logic;
		o_UnsignedInst	 	: out std_logic;
		o_ALUControl 	 	: out std_logic_vector(4 downto 0);
		o_DMemWr	 		: out std_logic;
		o_LB	 	 		: out std_logic;
		o_LH	 	 		: out std_logic;
		o_MemtoReg	 		: out std_logic;
		o_RegDst	 		: out std_logic;
		o_RegWr	 	 		: out std_logic;
		o_JAL		 		: out std_logic;
		o_Halt	 	 		: out std_logic
    );   

end ID_EXReg;

architecture structural of ID_EXReg is

  	component Register_Nbit is
		generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
		port(
			i_CLK        : in std_logic;     -- Clock input
			i_RST        : in std_logic;     -- Reset input
			i_WE         : in std_logic;     -- Write enable input
			i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
			o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	end component;

 component dffg is
	port(
		i_CLK        : in std_logic;     -- Clock input
		i_RST        : in std_logic;     -- Reset input
		i_WE         : in std_logic;     -- Write enable input
		i_D          : in std_logic;     -- Data value input
		o_Q          : out std_logic);   -- Data value output
 end component;

begin

   INST: Register_Nbit
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D	=>	i_Inst,
		o_Q	=>	o_Inst
	);

  REGRS: Register_Nbit
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_RegRs,
		o_Q		=>	o_RegRs
	);

  REGRT: Register_Nbit
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_RegRt,
		o_Q		=>	o_RegRt
	);

  EXTIMM: Register_Nbit
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_ExtImm,
		o_Q		=>	o_ExtImm
	);

  PC4: Register_Nbit
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_PC4,
		o_Q		=>	o_PC4
	);

  JAL: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_JAL,
		o_Q		=>	o_JAL
	);

  SIGN: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_Sign,
		o_Q		=>	o_Sign
	);

  ALUS: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_ALUSrc,
		o_Q		=>	o_ALUSrc
	);

  ALUISV: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_ALUInputShiftV,
		o_Q		=>	o_ALUInputShiftV
	);

  ALUISHMT: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_ALUInputShamt,
		o_Q		=>	o_ALUInputShamt
	);

  UNSIGN: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_UnsignedInst,
		o_Q		=>	o_UnsignedInst
	);

  ALUCTRL: Register_Nbit
    generic map(N => 5)
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_ALUControl,
		o_Q		=>	o_ALUControl
	);

  DMEMWR: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_DMemWr,
		o_Q		=>	o_DMemWr
	);

  LB: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_LB,
		o_Q		=>	o_LB
	);

  LH: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_LH,
		o_Q		=>	o_LH
	);

  MEMTOREG: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_MemtoReg,
		o_Q		=>	o_MemtoReg
	);

  REGDST: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_RegDst,
		o_Q		=>	o_RegDst
	);

  REGWR: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_RegWr,
		o_Q		=>	o_RegWr
	);


  HALT: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_Halt,
		o_Q		=>	o_Halt
	);

end structural;
