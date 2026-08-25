-------------------------------------------------------------------------
-- Project group 1 section 3 (Laith Al Sairafi and Chase O'Connell)
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;

architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal
  -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal
  -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;

  -- TODO: You may add any additional signals or components your implementation requires below this comment

  signal s_ExtImm, s_RegOut0, s_RegOut1, s_LHExtOut, s_LBExtOut, s_MuxOutLH, s_MuxOutLB, s_JumpAddr, s_ALUOut, s_PCOut,
  s_ALUsrcMUX, s_ALUinputA, s_ALUinputB, s_toALUsrcMUX, s_PC4, s_MuxROut, S_LBinputMUX, s_LHinputMUX: std_logic_vector(31 downto 0);
  signal s_Jump, s_MemRead, s_MemtoReg, s_ALUSrc, s_RegDst, s_JR, s_OverflowEn, s_ALUZero, s_LH, s_LB, s_sign, s_OvflAlu,
  s_ALUInputShamt, s_ALUInputShiftv, s_JAL: std_logic;
  signal s_ALUControl, s_MuxDOut : std_logic_vector(4 downto 0);
  signal s_Branch : std_logic_vector(1 downto 0);


  component FetchLogic is
    port(i_Inst   : in std_logic_vector(31 downto 0);
       i_ExtImm	    : in std_logic_vector(31 downto 0);
       i_Branch	    : in std_logic_vector(1 downto 0);
       i_ALUZero    : in std_logic;
       i_Jump       : in std_logic;
       i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_JRAddr     : in std_logic_vector(31 downto 0);
       i_JR         : in std_logic;
       o_PCOut      : out std_logic_vector(31 downto 0); 
       o_PC4        : out std_logic_vector(31 downto 0); 
       o_NextImmAddr: out std_logic_vector(31 downto 0); 
       o_JumpAddr   : out std_logic_vector(31 downto 0));
  end component;

  component ControlLogic is 
  port(i_OpCode           : in std_logic_vector(5 downto 0);
       i_Funct            : in std_logic_vector(5 downto 0);
       o_Jump	            : out std_logic;
       o_Branch	          : out std_logic_vector(1 downto 0);
       o_MemRead          : out std_logic;
       o_MemtoReg         : out std_logic;
       o_ALUControl       : out std_logic_vector(4 downto 0);
       o_DMemWr	          : out std_logic;
       o_ALUSrc	          : out std_logic;
       o_RegWr	          : out std_logic;
       o_RegDst	          : out std_logic;
       o_Halt             : out std_logic;
       o_JR               : out std_logic;
       o_JAL              : out std_logic;
       o_LB	              : out std_logic;
       o_LH	              : out std_logic;
       o_sign             : out std_logic;
       o_OverflowEn       : out std_logic;
       o_ALUInputShamt	  : out std_logic;
       o_ALUInputShiftv   : out std_logic);
  end component;

  component Register_File_32bit is
  port(i_CLK        : in std_logic;                          -- Clock input
       i_RST        : in std_logic;                          -- Reset input
       i_WE         : in std_logic;                          -- Write enable input
       i_WSEL       : in std_logic_vector(4 downto 0);       -- Write select input
       i_RSEL1      : in std_logic_vector(4 downto 0);       -- Read select input
       i_RSEL2      : in std_logic_vector(4 downto 0);       -- Read select input
       i_Data       : in std_logic_vector(31 downto 0);      -- Data value input
       o_Q1         : out std_logic_vector(31 downto 0);     -- Data value output1
       o_Q2         : out std_logic_vector(31 downto 0));    -- Data value output2
  end component;

  component ALU is
    port( 
      i_ALUcontrol  : in std_logic_vector(4 downto 0);     -- ALU control Signal
	    i_A	          : in std_logic_vector(31 downto 0);    -- First Input
	    i_B	          : in std_logic_vector(31 downto 0);    -- Second Input
	    o_zero        : out std_logic;                       -- Zero Signal
      o_overflow    : out std_logic;                       -- Overflow
	    o_result      : out std_logic_vector(31 downto 0));  -- ALU output
  end component;

  component shifter is
  port(
	  i_ShiftAmount : in std_logic_vector(4 downto 0) := "00000";         -- Shift Amount
	  i_A	          : in std_logic_vector(31 downto 0):= X"00000000";     -- input value
	  i_LA	        : in std_logic  := '0';                               -- logical  / Arithmetic
	  I_LR          : in std_logic  := '0';                               -- Left / Right
	  o_out         : out std_logic_vector(31 downto 0):= X"00000000");   -- Result
  end component;

  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(
      i_S          : in std_logic;
      i_D0         : in std_logic_vector(N-1 downto 0);
      i_D1         : in std_logic_vector(N-1 downto 0);
      o_O          : out std_logic_vector(N-1 downto 0));
  end component;

 component andg2
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
 end component;

 component extender
  port(
       i_sign         : in std_logic;
       i_in           : in std_logic_vector(15 downto 0);
       o_out          : out std_logic_vector(31 downto 0));
 end component;

 component extender_lh
  port(
       i_sign         : in std_logic;
       i_in           : in std_logic_vector(31 downto 0);
       o_out          : out std_logic_vector(31 downto 0));
 end component;

 component extender_lb
  port(
       i_sign         : in std_logic;
       i_in           : in std_logic_vector(31 downto 0);
       o_out          : out std_logic_vector(31 downto 0));
 end component;


component MUX_4to1_32bit is

  port(i_S          : in std_logic_vector(1 downto 0);
       i_D0         : in std_logic_vector(31 downto 0);
       i_D1         : in std_logic_vector(31 downto 0);
       i_D2         : in std_logic_vector(31 downto 0);
       i_D3         : in std_logic_vector(31 downto 0);
       o_O          : out std_logic_vector(31 downto 0));

end component;

begin
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means
  -- that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design
  -- is optimized out because the synthesis tool will believe the memory to be all zeros.

  with iInstLd select
  s_IMemAddr <= s_NextInstAddr when '0',
  iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)

  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

  CTRL: ControlLogic
    port map(
       i_OpCode          => s_Inst(31 downto 26),
       i_Funct           => s_Inst(5 downto 0),
       o_Jump	           => s_Jump,
       o_Branch	         => s_Branch,
       o_MemRead         => s_MemRead,
       o_MemtoReg        => s_MemtoReg,
       o_ALUControl      => s_ALUControl,
       o_DMemWr	         => s_DMemWr,
       o_ALUSrc	         => s_ALUSrc,
       o_RegWr	         => s_RegWr,
       o_RegDst	         => s_RegDst,
       o_Halt            => s_Halt,
       o_JR              => s_JR,
       o_JAL             => s_JAL,
       o_LH              => s_LH,
       o_LB              => s_LB,
       o_sign            => s_sign,
       o_OverflowEn      => s_OverflowEn,
       o_ALUInputShamt   => s_ALUInputShamt,
       o_ALUInputShiftv  => s_ALUInputShiftv);

  FTCH: FetchLogic
    port map(
             i_Inst          => s_Inst,
             i_ExtImm        => s_ExtImm,
             i_Branch        => s_Branch, 
             i_ALUZero       => s_ALUZero, --From ALU
             i_Jump          => s_Jump,
             i_CLK           => iCLK,
             i_RST           => iRST,
             i_JRAddr        => s_RegOut0, --From regfile, output A
             i_JR            => s_JR,
             o_PCOut         => s_NextInstAddr,
             o_PC4           => s_PC4,
             o_NextImmAddr   => s_PCOut,
             o_JumpAddr      => s_JumpAddr);


  MUXDST: mux2t1_N
    generic map(N => 5)
    port map(
      i_S        =>  s_RegDst,
      i_D0       =>  s_Inst(20 downto 16), 
      i_D1       =>  s_Inst(15 downto 11),
      o_O        =>  s_MuxDOut);

  MUXJAL: mux2t1_N
	generic map(N => 5)
	port map(
  	i_S    	=>  s_JAL,
  	i_D0   	=>  s_MuxDOut,
  	i_D1   	=>  "11111",
  	o_O    	=>  s_RegWrAddr);

  MUXWD: mux2t1_N
	port map(
  	i_S    	=>  s_JAL,
  	i_D0   	=>  s_MuxROut,
  	i_D1   	=>  s_PC4,
  	o_O    	=>  s_RegWrData);

  RF: Register_File_32bit
    port map(
       i_Data    => s_RegWrData, 
       i_WSEL    => s_RegWrAddr,
       i_WE      => s_RegWr,
       i_RST     => iRST,
       i_CLK     => iCLK,
       i_RSEL1   => s_Inst(25 downto 21),
       i_RSEL2   => s_Inst(20 downto 16),
       o_Q1      => s_RegOut0, 
       o_Q2      => s_RegOut1); 

  s_DMemData <= s_RegOut1;

  MUXRSRT_A: mux2t1_N
    generic map(N => 32)
    port map(
      i_S        =>  s_ALUInputShiftv,
      i_D0       =>  s_RegOut0, 
      i_D1       =>  s_RegOut1,
      o_O        =>  s_ALUinputA);

  MUXRSRT_B: mux2t1_N
    generic map(N => 32)
    port map(
      i_S        =>  s_ALUInputShiftV,
      i_D0       =>  s_RegOut1, 
      i_D1       =>  s_RegOut0,
      o_O        =>  s_toALUsrcMUX);

  MUXShamt: mux2t1_N
    generic map(N => 32)
    port map(
      i_S        =>  s_ALUInputShamt,
      i_D0       =>  s_ALUsrcMUX, 
      i_D1       =>  "000000000000000000000000000" & s_Inst(10 downto 6),
      o_O        =>  s_ALUinputB);

  IMMEXT: extender
    port map( 
      i_sign    => s_sign, 
      i_in      => s_Inst(15 downto 0),
      o_out     => s_ExtImm);

  MUXB: mux2t1_N
    generic map(N => 32)
    port map(
      i_S        =>  s_ALUSrc,
      i_D0       =>  s_toALUsrcMUX,
      i_D1       =>  s_ExtImm,
      o_O        =>  s_ALUsrcMUX);

  ALU0: ALU
    port map(
      i_ALUcontrol  => s_ALUControl,
	    i_A	          => s_ALUinputA,
	    i_B	          => s_ALUinputB,
	    o_zero        => s_ALUZero,
      o_overflow    => s_OvflAlu,
	    o_result      => s_ALUOut);

  oALUOut <= s_ALUOut;
  s_DMemAddr <= s_ALUOut;

  ANDOV: andg2
    port map(
       i_A          => s_OverflowEn, 
       i_B          => s_OvflAlu,
       o_F          => s_Ovfl);


  LBEXT: extender_lb
    port map(
       i_sign         => s_sign,
       i_in           => s_LBinputMUX,
       o_out          => s_LBExtOut);

  LHEXT: extender_lh
    port map(
       i_sign         => s_sign,
       i_in           => s_LHinputMUX,
       o_out          => s_LHExtOut);
  
  LBinputMUX:MUX_4to1_32bit
    port map(
      i_S        =>  s_DMemAddr(1 downto 0),
      i_D0       =>  X"000000" & s_DMemOut(7 downto 0),
      i_D1       =>  X"000000" & s_DMemOut(15 downto 8),
      i_D2       =>  X"000000" & s_DMemOut(23 downto 16),
      i_D3       =>  X"000000" & s_DMemOut(31 downto 24),
      o_O        =>  s_LBinputMUX);
  
  LHinputMUX: mux2t1_N
    port map(
      i_S        =>  s_DMemAddr(1),
      i_D0       =>  X"0000" & s_DMemOut(15 downto 0),
      i_D1       =>  X"0000" & s_DMemOut(31 downto 16),
      o_O        =>  s_LHinputMUX);

  MUXLH: mux2t1_N
    port map(
      i_S        =>  s_LH,
      i_D0       =>  s_DMemOut,
      i_D1       =>  s_LHExtOut,
      o_O        =>  s_MuxOutLH);

  MUXLB: mux2t1_N
    port map(
      i_S        =>  s_LB,
      i_D0       =>  s_MuxOutLH,
      i_D1       =>  s_LBEXTOut,
      o_O        =>  s_MuxOutLB);

  MUXR: mux2t1_N
    port map(
      i_S        =>  s_MemtoReg,
      i_D0       =>  s_ALUOut,
      i_D1       =>  s_MuxOutLB,
      o_O        =>  s_MuxROut);

end structure;

