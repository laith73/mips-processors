-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- AdderSubtractor_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the MEM/WB Register.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_WBReg is
   	port(
		i_CLK	 		: in std_logic;
		i_RST	 		: in std_logic;
		i_WE	 		: in std_logic;
		i_Inst   		: in std_logic_vector(31 downto 0);
		i_PC4	 		: in std_logic_vector(31 downto 0);
		i_ALUOut 		: in std_logic_vector(31 downto 0);
		i_DMemOut 		: in std_logic_vector(31 downto 0);
		--Need the control signals for later stages to be passed through
		i_Sign	 	 	: in std_logic;
		i_LB	 	 	: in std_logic;
		i_LH	 	 	: in std_logic;
		i_MemtoReg	 	: in std_logic;
		i_RegDst	 	: in std_logic;
		i_RegWr	 	 	: in std_logic;
		i_Halt	 	 	: in std_logic;
		i_JAL	 	 	: in std_logic;
		i_RegWrDest 	: in std_logic_vector(4 downto 0);
		i_Ovfl	 		: in std_logic;
		o_Ovfl	 		: out std_logic;
		o_RegWrDest 	: out std_logic_vector(4 downto 0);
		o_Inst   		: out std_logic_vector(31 downto 0);
		o_PC4		 	: out std_logic_vector(31 downto 0);
		o_ALUOut 	 	: out std_logic_vector(31 downto 0);
		o_DMemOut 	 	: out std_logic_vector(31 downto 0);
		o_Sign	 	 	: out std_logic;
		o_LB	 		: out std_logic;
		o_LH	 	 	: out std_logic;
		o_MemtoReg	 	: out std_logic;
		o_RegDst	 	: out std_logic;
		o_RegWr	 	 	: out std_logic;
		o_Halt	 	 	: out std_logic;
		o_JAL	 	 	: out std_logic
    );   

end MEM_WBReg;

architecture structural of MEM_WBReg is

  component Register_Nbit is
   generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
        o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
   end component;

 component dffg is
  port(i_CLK        : in std_logic;     -- Clock input
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

  REGWRDEST: Register_Nbit
	generic map(N => 5)
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_RegWrDest,
		o_Q		=>	o_RegWrDest
	);

  ALUOUT: Register_Nbit
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_ALUOut,
	o_Q	=>	o_ALUOut
	);

  DMEMOUT: Register_Nbit
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_DMemOut,
	o_Q	=>	o_DMemOut
	);

  PC4: Register_Nbit
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_PC4,
	o_Q	=>	o_PC4
	);


  OVFL: dffg
	port map(
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D	=>	i_Ovfl,
		o_Q	=>	o_Ovfl
	);

  JAL: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_JAL,
	o_Q	=>	o_JAL
	);

  SIGN: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_Sign,
	o_Q	=>	o_Sign
	);

  LB: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_LB,
	o_Q	=>	o_LB
	);

  LH: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_LH,
	o_Q	=>	o_LH
	);

  MEMTOREG: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_MemtoReg,
	o_Q	=>	o_MemtoReg
	);

  REGDST: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_RegDst,
	o_Q	=>	o_RegDst
	);

  REGWR: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_RegWr,
	o_Q	=>	o_RegWr
	);

  HALT: dffg
	port map(
	i_CLK	=>	i_CLK,
	i_RST	=>	i_RST,
	i_WE	=>	i_WE,
	i_D	=>	i_Halt,
	o_Q	=>	o_Halt
	);



end structural;
