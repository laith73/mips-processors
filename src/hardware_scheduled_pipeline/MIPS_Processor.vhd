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
use IEEE.std_logic_misc.all;

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

-- 5 bit signals
  signal s_ALUControl, sE_ALUControl, s_RegWrDestMux, sM_RegWrDest, sW_RegWrDest, s_RegWrDestMuxJAL: std_logic_vector(4 downto 0);

-- 2 bit signals
  signal s_Branch, s_ForwardingMuxA, s_ForwardingMuxB : std_logic_vector(1 downto 0);

--32 bit signals
  signal sD_Inst, sE_Inst, sD_PC4, sE_PC4, sM_PC4, sW_PC4, sW_Inst, s_PCIn, sE_RegOut0, sE_RegOut1, sM_RegOut1,
         sE_ExtImm, sM_ALUOut, sW_ALUOut, sW_DMemOut, s_LHinputMUX, s_LBinputMUX, sM_Inst,s_ExtImm, s_RegOut0, s_RegOut1,
         s_LHExtOut, s_LBExtOut, s_MuxOutLH, s_MuxOutLB, s_ALUOut, s_PC4, s_MuxROut, s_ALUinputA,s_toALUsrcMUX, s_ALUsrcMUX,
         s_ALUinputB, s_PCNextAddrInput, s_fetchLogicOut, s_ForwardingMuxAData, s_ForwardingMuxBData, sM_ForwardingMuxBData,
         s_FlushMuxInstIDEX, s_FlushMuxInstIFID, s_PC4ALUoutMux : std_logic_vector(31 downto 0);

--1 bit signals
  signal sD_Halt, sE_Halt, sM_Halt, s_Equal, s_OverflowEn, s_ALUInputShamt, s_ALUInputShiftV, sW_RegDst,
         sW_JAL, sM_JAL, sE_JAL, sE_sign, sM_sign, sW_sign, sE_ALUSrc, sE_ALUInputShiftV, sE_ALUInputShamt,
         sE_DMemWr, sD_DMemWr, sE_LH, sM_LH, sW_LH, sE_LB, sM_LB, sW_LB, sE_MemtoReg, sM_MemtoReg, sW_MemtoReg, 
         sE_RegDst, sM_RegDst, sE_RegWr, sM_RegWr, sM_DMemWr, sE_OverflowEn, s_PC4Ovfl, sD_RegWr, s_branchOrJump,
         s_Jump, s_MemRead, s_MemtoReg, s_ALUSrc, s_RegDst, s_JR, s_ALUZero, s_LH, s_LB, s_sign, s_JAL, s_OvflAlu,
         s_OvflResult, sM_Ovfl, s_Flush, s_Stall, s_FlushMuxReg, s_FlushMuxMem, s_HazardBranch : std_logic;

------------- Components -----------------------

 component IF_IDReg is -- Fetch / Decode Register
  port(
      i_CLK 	: in std_logic;
	    i_RST	  : in std_logic;
	    i_WE	  : in std_logic;
	    i_Inst	: in std_logic_vector(31 downto 0);
	    i_PC4	  : in std_logic_vector(31 downto 0);
	    o_Inst	: out std_logic_vector(31 downto 0);
	    o_PC4	  : out std_logic_vector(31 downto 0));
 end component;

component ID_EXReg is -- Decode / Execute Register
  port(
    i_CLK	            : in std_logic;
    i_RST	            : in std_logic;
    i_WE	            : in std_logic;
    i_Inst	          : in std_logic_vector(31 downto 0);
    i_RegRs	          : in std_logic_vector(31 downto 0);
    i_RegRt	          : in std_logic_vector(31 downto 0);
    i_ExtImm          : in std_logic_vector(31 downto 0);
    i_PC4	            : in std_logic_vector(31 downto 0);
    i_Sign	 	        : in std_logic;
    i_ALUSrc	        : in std_logic;
    i_ALUInputShiftV  : in std_logic;
    i_ALUInputShamt	  : in std_logic;
    i_UnsignedInst	  : in std_logic;
    i_ALUControl 	    : in std_logic_vector(4 downto 0);
    i_DMemWr	        : in std_logic;
    i_LB	 	          : in std_logic;
    i_LH	 	          : in std_logic;
    i_MemtoReg	      : in std_logic;
    i_RegDst	        : in std_logic;
    i_RegWr	 	        : in std_logic;
    i_Halt	 	        : in std_logic;
    i_JAL	 	          : in std_logic;
    o_Inst	          : out std_logic_vector(31 downto 0);
    o_RegRs	          : out std_logic_vector(31 downto 0);
    o_RegRt	          : out std_logic_vector(31 downto 0);
    o_ExtImm          : out std_logic_vector(31 downto 0);
    o_PC4		          : out std_logic_vector(31 downto 0);
    o_Sign	 	        : out std_logic;
    o_ALUSrc	        : out std_logic;
    o_ALUInputShiftV  : out std_logic;
    o_ALUInputShamt	  : out std_logic;
    o_UnsignedInst	  : out std_logic;
    o_ALUControl 	    : out std_logic_vector(4 downto 0);
    o_DMemWr	        : out std_logic;
    o_LB	 	          : out std_logic;
    o_LH	 	          : out std_logic;
    o_MemtoReg	      : out std_logic;
    o_RegDst	        : out std_logic;
    o_RegWr	 	        : out std_logic;
    o_JAL		          : out std_logic;
    o_Halt	 	        : out std_logic); 
 end component;

  component EX_MEMReg is -- Execute / Memory Register
    port(
      i_CLK	      : in std_logic;
      i_RST	      : in std_logic;
      i_WE	      : in std_logic;
      i_Inst	    : in std_logic_vector(31 downto 0);
      i_ALUOut    : in std_logic_vector(31 downto 0);
      i_RegRt	    : in std_logic_vector(31 downto 0);
      i_PC4	      : in std_logic_vector(31 downto 0);
		  i_MemWrData	: in std_logic_vector(31 downto 0);	
      i_Sign	 	  : in std_logic;
      i_DMemWr	  : in std_logic;
      i_LB	 	    : in std_logic;
      i_LH	 	    : in std_logic;
      i_MemtoReg  : in std_logic;
      i_RegDst	  : in std_logic;
      i_RegWr	 	  : in std_logic;
      i_Halt	 	  : in std_logic;
      i_JAL	 	    : in std_logic;
      i_RegWrDest : in std_logic_vector(4 downto 0);
		  i_Ovfl	 	  : in std_logic;
		  o_Ovfl	 	  : out std_logic;
		  o_MemWrData	: out std_logic_vector(31 downto 0);	
      o_RegWrDest : out std_logic_vector(4 downto 0);
      o_ALUOut    : out std_logic_vector(31 downto 0);
      o_RegRt	    : out std_logic_vector(31 downto 0);
      o_Inst	    : out std_logic_vector(31 downto 0);
      o_PC4		    : out std_logic_vector(31 downto 0);
      o_Sign	 	  : out std_logic;
      o_DMemWr	  : out std_logic;
      o_LB	 	    : out std_logic;
      o_LH	 	    : out std_logic;
      o_MemtoReg	: out std_logic;
      o_RegDst	  : out std_logic;
      o_RegWr	 	  : out std_logic;
      o_JAL		    : out std_logic;
      o_Halt	 	  : out std_logic); 
  end component;

  component MEM_WBReg is -- Memory / Write Back Register
    port(
      i_CLK	      : in std_logic;
      i_RST	      : in std_logic;
      i_WE	      : in std_logic;
      i_Inst	    : in std_logic_vector(31 downto 0);
      i_PC4	      : in std_logic_vector(31 downto 0);
      i_ALUOut    : in std_logic_vector(31 downto 0);
      i_DMemOut   : in std_logic_vector(31 downto 0);
      i_Sign	 	  : in std_logic;
      i_LB	 	    : in std_logic;
      i_LH	 	    : in std_logic;
      i_MemtoReg	: in std_logic;
      i_RegDst	  : in std_logic;
      i_RegWr	 	  : in std_logic;
      i_Halt	 	  : in std_logic;
      i_JAL	 	    : in std_logic;
      i_RegWrDest : in std_logic_vector(4 downto 0);
		  i_Ovfl	 	  : in std_logic;
		  o_Ovfl	 	  : out std_logic;
      o_RegWrDest : out std_logic_vector(4 downto 0);
      o_PC4		    : out std_logic_vector(31 downto 0);
      o_ALUOut 	  : out std_logic_vector(31 downto 0);
      o_DMemOut 	: out std_logic_vector(31 downto 0);
      o_Inst	    : out std_logic_vector(31 downto 0);
      o_Sign	 	  : out std_logic;
      o_LB	 	    : out std_logic;
      o_LH	 	    : out std_logic;
      o_MemtoReg	: out std_logic;
      o_RegDst	  : out std_logic;
      o_RegWr	 	  : out std_logic;
      o_Halt	 	  : out std_logic;
      o_JAL	 	    : out std_logic);
  end component; 

  component EqualityUnit is -- BNE and BEQ Comparator
    port(
      i_RegRs	    : in std_logic_vector(31 downto 0);
      i_RegRt	    : in std_logic_vector(31 downto 0);
      o_Equal     : out std_logic); 
  end component;

  component FetchLogic is -- Fetch Logic
    port(
      i_Inst          : in std_logic_vector(31 downto 0);
      i_PC4	          : in std_logic_vector(31 downto 0);
      i_ExtImm        : in std_logic_vector(31 downto 0);
      i_Branch	      : in std_logic_vector(1 downto 0);
      i_Equal         : in std_logic;
      i_Jump          : in std_logic;
      i_JRAddr        : in std_logic_vector(31 downto 0);
      i_JR            : in std_logic; 
      o_NextInstAddr  : out std_logic_vector(31 downto 0);
      o_branchOrJump  : out std_logic);
  end component;

  component ControlLogic is -- Control Unit
    port(
      i_OpCode            : in std_logic_vector(5 downto 0);
      i_Funct             : in std_logic_vector(5 downto 0);
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

  component Register_File_32bit is -- Register File
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

  component Forwarding_unit is -- Forwarding Unit

   port(
      i_RegWrite_EX_MEM   : in std_logic;
      i_RegWrite_MEM_WB   : in std_logic;
      i_Rd_EX_MEM         : in std_logic_vector(4 downto 0);
      i_Rd_MEM_WB         : in std_logic_vector(4 downto 0);
      i_Rs_ID_EX          : in std_logic_vector(4 downto 0);
      i_Rt_ID_EX          : in std_logic_vector(4 downto 0);
      o_ForwardA          : out std_logic_vector(1 downto 0);
      o_ForwardB          : out std_logic_vector(1 downto 0)
   );
  end component;

  component ALU is -- ALU
    port( 
      i_ALUcontrol  : in std_logic_vector(4 downto 0);     -- ALU control Signal
	    i_A	          : in std_logic_vector(31 downto 0);    -- First Input
	    i_B	          : in std_logic_vector(31 downto 0);    -- Second Input
	    o_zero        : out std_logic;                       -- Zero Signal
      o_overflow    : out std_logic;                       -- Overflow
	    o_result      : out std_logic_vector(31 downto 0));  -- ALU output
  end component;

  component shifter is -- Shifter
    port(
	    i_ShiftAmount : in std_logic_vector(4 downto 0) := "00000";         -- Shift Amount
	    i_A	          : in std_logic_vector(31 downto 0):= X"00000000";     -- input value
	    i_LA	        : in std_logic  := '0';                               -- logical  / Arithmetic
	    i_LR          : in std_logic  := '0';                               -- Left / Right
	    o_out         : out std_logic_vector(31 downto 0):= X"00000000");   -- Result
  end component;

  component mux2t1_N is --  General N-Bit 2 to 1 Mux (Default 32)
    generic(N : integer := 32); 
    port(
      i_S          : in std_logic;
      i_D0         : in std_logic_vector(N-1 downto 0);
      i_D1         : in std_logic_vector(N-1 downto 0);
      o_O          : out std_logic_vector(N-1 downto 0));
  end component;

 component andg2 -- 2 input AND gate
    port(
      i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic);
 end component;

 component extender -- 16 to 32 bits extender 
    port(
      i_sign         : in std_logic;
      i_in           : in std_logic_vector(15 downto 0);
      o_out          : out std_logic_vector(31 downto 0));
 end component;

 component extender_lh -- Load byte word extender
  port(
      i_sign         : in std_logic;
      i_in           : in std_logic_vector(31 downto 0);
      o_out          : out std_logic_vector(31 downto 0));
 end component;

 component extender_lb -- Load half word extender
  port(
      i_sign         : in std_logic;
      i_in           : in std_logic_vector(31 downto 0);
      o_out          : out std_logic_vector(31 downto 0));
 end component;

 component Register_Nbit is -- General Register N bit
  generic(N : integer := 32);
  port(
      i_CLK        : in std_logic;   
      i_RST        : in std_logic;   
      i_WE         : in std_logic;  
      i_D          : in std_logic_vector(N-1 downto 0);
      o_Q          : out std_logic_vector(N-1 downto 0)); 
 end component;

  component AddSubImm is -- Adder / subtractor unit
    generic(N : integer := 32); 
    port(
      i_nAdd_Sub   : in std_logic;
      i_ALUSrc	    : in std_logic;
      i_A          : in std_logic_vector(N-1 downto 0);
      i_B          : in std_logic_vector(N-1 downto 0);
      i_Imm        : in std_logic_vector(N-1 downto 0);
      o_DataOut    : out std_logic_vector(N-1 downto 0);
      o_Overflow   : out std_logic);
  end component;

  component MUX_4to1_32bit is -- 32 bit 4 to 1 MUX
    port(
      i_S          : in std_logic_vector(1 downto 0);
      i_D0         : in std_logic_vector(31 downto 0);
      i_D1         : in std_logic_vector(31 downto 0);
      i_D2         : in std_logic_vector(31 downto 0);
      i_D3         : in std_logic_vector(31 downto 0);
      o_O          : out std_logic_vector(31 downto 0));
  end component;
  
  component HazardDetect2 is
    port(
   	    iE_Inst_opcode    : in std_logic_vector(5 downto 0);
   	    iD_Rs			 	      : in std_logic_vector(4 downto 0);
   	    iD_Rt  				    : in std_logic_vector(4 downto 0);
	      iE_RegWriteDest  	: in std_logic_vector(4 downto 0);
        iM_RegWriteDest  	: in std_logic_vector(4 downto 0);
        iW_RegWriteDest  	: in std_logic_vector(4 downto 0);
	      i_RegWrite_MEM_WB : in std_logic;
        i_Jump				    : in std_logic;
        i_JR 				      : in std_logic;
        i_Branch			    : in std_logic;
        i_takenBranch			: in std_logic;
        o_stall 			    : out std_logic; -- bne and beq and jumps
        o_Flush 			    : out std_logic
	);
  end component;

  component MUX_2to1 is -- 1-bit 2 to 1 Mux
    port(
        i_S          : in std_logic;
        i_D0         : in std_logic;
        i_D1         : in std_logic; 
        o_O          : out std_logic
    );
  end component;

begin

-- Data and intruction Memories
  with iInstLd select
  s_IMemAddr <= s_NextInstAddr when '0',
  iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => N)
    port map(
      clk  => iCLK,
      addr => s_IMemAddr(11 downto 2),
      data => iInstExt,
      we   => iInstLd,
      q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => N)
    port map(
      clk  => iCLK,
      addr => s_DMemAddr(11 downto 2),
      data => s_DMemData,
      we   => s_DMemWr,
      q    => s_DMemOut);

------------------Fetch Stage----------------

  MUXPC: mux2t1_N -- Load the PC register with an initial value 0x00400000
    port map(
      i_D0	    => s_PCNextAddrInput, --***
      i_D1	    => x"00400000", 
      i_S	      => iRST, 
      o_O	      => s_PCIn); 
  
  -- PC Register
  PCREG: Register_Nbit 
    port map(
      i_CLK     => iCLK, 
      i_RST     => '0', 
      i_WE      => not(s_Stall), 
      i_D       => s_PCIn, -- from MUXPC
      o_Q       => s_NextInstAddr);

  AddP4: AddSubImm -- increments the PC value by 4
    port map(
      i_nAdd_Sub     => '0', 
      i_ALUSrc       => '1', 
      i_A            => s_NextInstAddr,
      i_B            => x"00000000", 
      i_Imm          => x"00000004",  
      o_DataOut      => s_PC4,  --***
      o_Overflow     => s_PC4Ovfl);

  MUXFTCH_INIT: mux2t1_N  -- Jump or Branch Address
    port map(
      i_S	     => s_branchOrJump, 
      i_D0	   => s_PC4,
      i_D1	   => s_fetchLogicOut, 
      o_O	     => s_PCNextAddrInput);

-----------------(IF/ID)---------------
  
  IFIDFlushMux: mux2t1_N  -- Jump or Branch Address
    port map(
      i_S	     => s_Flush, 
      i_D0	   => s_Inst,
      i_D1	   => X"00000000", 
      o_O	     => s_FlushMuxInstIFID);

  IFIDREG: IF_IDReg -- Fetch / Decode Register
    port map(
      i_CLK  => iCLK,
      i_RST  => iRST,
      i_WE   => not(s_Stall), --***
      i_Inst => s_FlushMuxInstIFID,
      i_PC4  => s_PC4,
      o_Inst => sD_Inst,
      o_PC4  => sD_PC4
  );
------------------Decode Stage-----------------

  FTCH: FetchLogic -- Fetch Logic
    port map(
      i_Inst          => sD_Inst,
      i_PC4           => sD_PC4,
      i_ExtImm        => s_ExtImm,
      i_Branch        => s_Branch, 
      i_Equal         => s_Equal,
      i_Jump          => s_Jump,
      i_JRAddr        => s_RegOut0, 
      i_JR            => s_JR,
      o_NextInstAddr  => s_fetchLogicOut,
      o_branchOrJump  => s_branchOrJump
    ); 

  CTRL: ControlLogic -- Control Logic 
    port map(
      i_OpCode          => sD_Inst(31 downto 26),
      i_Funct           => sD_Inst(5 downto 0),
      o_Jump	          => s_Jump,
      o_Branch	        => s_Branch,
      o_MemRead         => s_MemRead,
      o_MemtoReg        => s_MemtoReg,
      o_ALUControl      => s_ALUControl,
      o_DMemWr	        => sD_DMemWr,
      o_ALUSrc	        => s_ALUSrc,
      o_RegWr	          => sD_RegWr,
      o_RegDst	        => s_RegDst,
      o_Halt            => sD_Halt,
      o_JR              => s_JR,
      o_JAL             => s_JAL,
      o_LH              => s_LH,
      o_LB              => s_LB,
      o_sign            => s_sign,
      o_OverflowEn      => s_OverflowEn,
      o_ALUInputShamt   => s_ALUInputShamt,
      o_ALUInputShiftv  => s_ALUInputShiftv
    );
  
  HazardAND: andg2 -- If the instruction is Jump
    port map(
      i_A          => s_branchOrJump, 
      i_B          => s_Equal,
      o_F          => s_HazardBranch);

  HAZARD: HazardDetect2 -- Hazard Detection Unit  
    port map(
   	    iE_Inst_opcode    => sE_Inst(31 downto 26),
   	    iD_Rs			 	      => sD_Inst(25 downto 21),
   	    iD_Rt  				    => sD_Inst(20 downto 16),
	      iE_RegWriteDest  	=> s_RegWrDestMux,
        iM_RegWriteDest  	=> sM_RegWrDest,
        iW_RegWriteDest  	=> sW_RegWrDest,
        i_RegWrite_MEM_WB => s_RegWr,
        i_Jump				    => (s_Jump or s_JR),
        i_JR              => s_JR,
        i_Branch			    => s_branch(1),
        i_takenBranch     => (not (s_Branch(0)) and (or_reduce(s_Branch)) and (not(s_Equal))) or ((s_Branch(0)) and ((s_Equal))),
        o_stall 			    => s_Stall,
        o_Flush 			    => s_Flush
	);

  RF: Register_File_32bit -- Register File
    port map(
      i_Data  	   => s_RegWrData, --(from WB stage)
      i_WSEL       => s_RegWrAddr,
      i_WE         => s_RegWr,
      i_RST        => iRST,
      i_CLK        => iCLK,
      i_RSEL1      => sD_Inst(25 downto 21),
      i_RSEL2      => sD_Inst(20 downto 16),
      o_Q1         => s_RegOut0, 
      o_Q2         => s_RegOut1);

  EQU: EqualityUnit -- Equality Unit for branches
    port map(
      i_RegRs => s_RegOut0,
      i_RegRt => s_RegOut1,
      o_Equal => s_Equal);

  IMMEXT: extender -- Immediate etender
    port map( 
      i_sign    => s_sign, 
      i_in      => sD_Inst(15 downto 0),
      o_out     => s_ExtImm);

  MUXJAL: mux2t1_N --WB***
    generic map(N => 5)
    port map(
      i_S        =>  sW_JAL,
      i_D0       =>  sW_RegWrDest, 
      i_D1       =>  "11111",
      o_O        =>  s_RegWrAddr);

  MUXWD: mux2t1_N --WB***
    port map(
      i_S        =>  sW_JAL,
      i_D0       =>  s_MuxROut, 
      i_D1       =>  sW_PC4,
      o_O        =>  s_RegWrData); --(from WB)


---------------(ID/EX)----------------
  
  IDEXFlushMuxMem: MUX_2to1 -- Decode/Execute Memory Write Flush Mux
    port map(
        i_S	     => s_Stall, 
        i_D0	   => sD_DMemWr,
        i_D1	   => '0', 
        o_O	     => s_FlushMuxMem
    );

  IDEXFlushMuxReg: MUX_2to1  -- Decode/Execute Register Write Flush Mux 
    port map(
        i_S	     => s_Stall, 
        i_D0	   => sD_RegWr,
        i_D1	   => '0', 
        o_O	     => s_FlushMuxReg
    );

  IDEXFlushMuxINST: mux2t1_N  -- Decode/Execute instruction Flush Mux 
    port map(
        i_S	     => s_Stall, 
        i_D0	   => sD_Inst,
        i_D1	   => X"00000000", 
        o_O	     => s_FlushMuxInstIDEX
    );

  IDEXREG: ID_EXReg -- Fetch / Decode Register
    port map(
      i_CLK  	 	        => iCLK,
      i_RST  		        => iRST,
      i_WE   		        => '1', --***
      i_Inst 		        => s_FlushMuxInstIDEX,
      i_RegRs  	        => s_RegOut0,
      i_RegRt  	        => s_RegOut1,
      i_ExtImm  	      => s_ExtImm,
      i_PC4  		        => sD_PC4,
      i_Sign  	        => s_sign,
      i_ALUSrc  	      => s_ALUSrc,
      i_ALUInputShiftV  => s_ALUInputShiftV,
      i_ALUInputShamt   => s_ALUInputShamt,
      i_UnsignedInst    => s_OverflowEn,
      i_ALUControl      => s_ALUControl,
      i_DMemWr  	      => s_FlushMuxMem,
      i_LB  		        => s_LB,
      i_LH  		        => s_LH,
      i_MemtoReg  	    => s_MemtoReg,
      i_RegDst  	      => s_RegDst,
      i_RegWr  	        => s_FlushMuxReg,
      i_Halt            => sD_Halt,
      i_JAL   	        => s_JAL,
      o_UnsignedInst    => sE_OverflowEn,
      o_Inst 		        => sE_Inst,
      o_RegRs  	        => sE_RegOut0,
      o_RegRt  	        => sE_RegOut1,
      o_ExtImm  	      => sE_ExtImm,
      o_PC4  		        => sE_PC4,
      o_Sign  	        => sE_sign,
      o_ALUSrc  	      => sE_ALUSrc,
      o_ALUInputShiftV  => sE_ALUInputShiftV,
      o_ALUInputShamt   => sE_ALUInputShamt,
      o_ALUControl      => sE_ALUControl,
      o_DMemWr  	      => sE_DMemWr,
      o_LB  		        => sE_LB,
      o_LH  		        => sE_LH,
      o_MemtoReg  	    => sE_MemtoReg,
      o_RegDst  	      => sE_RegDst,
      o_RegWr  	        => sE_RegWr,
      o_Halt  	        => sE_Halt,
      o_JAL   	        => sE_JAL
  );

------------------Execute Stage-----------------
  
  FORWARDING: Forwarding_unit -- Forwarding Unit
    port map(
      i_RegWrite_EX_MEM   => sM_RegWr,
      i_RegWrite_MEM_WB   => s_RegWr,
      i_Rd_EX_MEM         => sM_RegWrDest,
      i_Rd_MEM_WB         => sW_RegWrDest,
      i_Rs_ID_EX          => sE_Inst(25 downto 21),
      i_Rt_ID_EX          => sE_Inst(20 downto 16),
      o_ForwardA          => s_ForwardingMuxA,
      o_ForwardB          => s_ForwardingMuxB
    );

  ForwardingInputMuxA: MUX_4to1_32bit -- Forwarding Unit Mux input A
    port map(
      i_S        =>  s_ForwardingMuxA,
      i_D0       =>  sE_RegOut0,
      i_D1       =>  s_MuxROut,
      i_D2       =>  sM_ALUOut,
      i_D3       =>  X"00000000",
      o_O        =>  s_ForwardingMuxAData);

  ForwardingInputMuxB: MUX_4to1_32bit -- Forwarding Unit Mux input B
    port map(
      i_S        =>  s_ForwardingMuxB,
      i_D0       =>  sE_RegOut1,
      i_D1       =>  s_MuxROut,
      i_D2       =>  sM_ALUOut,
      i_D3       =>  X"00000000",
      o_O        =>  s_ForwardingMuxBData);

  MUXDST: mux2t1_N -- Destination Register Mux
    generic map(N => 5)
    port map(
      i_S        =>  sE_RegDst,
      i_D0       =>  s_RegWrDestMuxJAL, 
      i_D1       =>  sE_Inst(15 downto 11),
      o_O        =>  s_RegWrDestMux);

  MUXEXJAL: mux2t1_N -- DEst Reg if JAL
    generic map(N => 5)
    port map(
      i_S        =>  sE_JAL,
      i_D0       =>  sE_Inst(20 downto 16), 
      i_D1       =>  "11111",
      o_O        =>  s_RegWrDestMuxJAL);

  MUXEXPC4ALUout: mux2t1_N -- PC Value instead of ALU Out
    port map(
      i_S        =>  sE_JAL,
      i_D0       =>  s_ALUOut, 
      i_D1       =>  sE_PC4,
      o_O        =>  s_PC4ALUoutMux);
      
  MUXRSRT_A: mux2t1_N -- sllv, srlv, srav Mux
    generic map(N => 32)
      port map(
        i_S        =>  sE_ALUInputShiftv,
        i_D0       =>  s_ForwardingMuxAData, 
        i_D1       =>  s_ForwardingMuxBData,
        o_O        =>  s_ALUinputA);

  MUXRSRT_B: mux2t1_N -- sllv, srlv, srav Mux
    generic map(N => 32)
      port map(
        i_S        =>  sE_ALUInputShiftV,
        i_D0       =>  s_ForwardingMuxBData, 
        i_D1       =>  s_ForwardingMuxAData,
        o_O        =>  s_toALUsrcMUX);


  MUXShamt: mux2t1_N -- Shift Amout Mux
    generic map(N => 32)
      port map(
        i_S        =>  sE_ALUInputShamt,
        i_D0       =>  s_ALUsrcMUX, 
        i_D1       =>  "000000000000000000000000000" & sE_Inst(10 downto 6),
        o_O        =>  s_ALUinputB);

  MUXB: mux2t1_N -- ALU source Mux
    generic map(N => 32)
      port map(
        i_S        =>  sE_ALUSrc,
        i_D0       =>  s_toALUsrcMUX,
        i_D1       =>  sE_ExtImm,
        o_O        =>  s_ALUsrcMUX);

  ALU0: ALU -- ALU Unit
    port map(
      i_ALUcontrol  => sE_ALUControl,
	    i_A	          => s_ALUinputA,
	    i_B	          => s_ALUinputB,
	    o_zero        => s_ALUZero,
      o_overflow    => s_OvflAlu,
	    o_result      => s_ALUOut);

  oALUOut <= s_ALUOut;

  ANDOV: andg2 --Overflow signal
    port map(
      i_A          => sE_OverflowEn, 
      i_B          => s_OvflAlu,
      o_F          => s_OvflResult);

-------------------(EX/MEM)-------------------

EXMEMREG: EX_MEMReg -- Execute / Memory Register
  port map(
    i_CLK  	 	  => iCLK,
    i_RST  		  => iRST,
    i_WE   		  => '1', --***
    i_Inst 		  => sE_Inst,
    i_RegRt  	  => sE_RegOut1,
    i_ALUOut 	  => s_PC4ALUoutMux,
    i_PC4  		  => sE_PC4,
    i_Sign  	  => sE_sign,
    i_DMemWr  	=> sE_DMemWr,
    i_LB  		  => sE_LB,
    i_LH  		  => sE_LH,
    i_MemtoReg  => sE_MemtoReg,
    i_RegDst  	=> sE_RegDst,
    i_RegWr  	  => sE_RegWr,
    i_Halt  	  => sE_Halt,
    i_JAL   	  => sE_JAL,
    i_RegWrDest => s_RegWrDestMux,
    i_Ovfl      => s_OvflResult,
    i_MemWrData => s_ForwardingMuxBData,
    o_MemWrData => sM_ForwardingMuxBData,
    o_Ovfl      => sM_Ovfl,
    o_RegWrDest => sM_RegWrDest,
    o_Inst 		  => sM_Inst,
    o_RegRt  	  => sM_RegOut1,
    o_ALUOut 	  => sM_ALUOut,
    o_PC4  		  => sM_PC4,
    o_Sign  	  => sM_sign,
    o_DMemWr  	=> sM_DMemWr,
    o_LB  		  => sM_LB,
    o_LH  		  => sM_LH,
    o_MemtoReg  => sM_MemtoReg,
    o_RegDst  	=> sM_RegDst,
    o_RegWr  	  => sM_RegWr,
    o_Halt  	  => sM_Halt,
    o_JAL   	  => sM_JAL
);

---------------------Memory Stage-------------------

--(DMem above)
s_DMemWr <= sM_DMemWr;
s_DMemAddr <= sM_ALUOut; --***
s_DMemData <= sM_ForwardingMuxBData;

---------------------(MEM/WB)-------------------

MEMWBREG: MEM_WBReg --  Memory / Write Back Register
  port map(
    i_CLK  	 	  => iCLK,
    i_RST  		  => iRST,
    i_WE   		  => '1', --***
    i_ALUOut 	  => sM_ALUOut,
    i_DMemOut 	=> s_DMemOut,
    i_PC4  		  => sM_PC4,
    i_Sign  	  => sM_sign,
    i_LB  		  => sM_LB,
    i_LH  		  => sM_LH,
    i_MemtoReg  => sM_MemtoReg,
    i_RegDst  	=> sM_RegDst,
    i_RegWr  	  => sM_RegWr,
    i_Halt  	  => sM_Halt,
    i_JAL   	  => sM_JAL,
    i_Inst 		  => sM_Inst,
    i_RegWrDest => sM_RegWrDest,
    i_Ovfl      => sM_Ovfl,
    o_Ovfl      => s_Ovfl,
    o_RegWrDest => sW_RegWrDest,
    o_Inst 		  => sW_Inst,
    o_ALUOut 	  => sW_ALUOut,
    o_DMemOut 	=> sW_DMemOut,
    o_PC4  		  => sW_PC4,
    o_Sign  	  => sW_sign,
    o_LB  		  => sW_LB,
    o_LH  		  => sW_LH,
    o_MemtoReg  => sW_MemtoReg,
    o_RegDst  	=> sW_RegDst,
    o_RegWr  	  => s_RegWr,
    o_Halt  	  => s_Halt,
    o_JAL   	  => sW_JAL
);

--------------------Write Back Stage--------------------

  LBEXT: extender_lb
    port map(
      i_sign         => sW_sign,
      i_in           => s_LBinputMUX,
      o_out          => s_LBExtOut);

  LHEXT: extender_lh
    port map(
      i_sign         => sW_sign,
      i_in           => s_LHinputMUX,
      o_out          => s_LHExtOut);

  LBinputMUX:MUX_4to1_32bit
    port map(
      i_S        =>  sW_ALUOut(1 downto 0),
      i_D0       =>  X"000000" & sW_DMemOut(7 downto 0),
      i_D1       =>  X"000000" & sW_DMemOut(15 downto 8),
      i_D2       =>  X"000000" & sW_DMemOut(23 downto 16),
      i_D3       =>  X"000000" & sW_DMemOut(31 downto 24),
      o_O        =>  s_LBinputMUX);
  
  LHinputMUX: mux2t1_N
    port map(
      i_S        =>  sW_ALUOut(1),
      i_D0       =>  X"0000" & sW_DMemOut(15 downto 0),
      i_D1       =>  X"0000" & sW_DMemOut(31 downto 16),
      o_O        =>  s_LHinputMUX);

  MUXLH: mux2t1_N
    port map(
      i_S        =>  sW_LH,
      i_D0       =>  sW_DMemOut,
      i_D1       =>  s_LHExtOut,
      o_O        =>  s_MuxOutLH);

  MUXLB: mux2t1_N
    port map(
      i_S        =>  sW_LB,
      i_D0       =>  s_MuxOutLH,
      i_D1       =>  s_LBEXTOut,
      o_O        =>  s_MuxOutLB);

  MUXR: mux2t1_N
    port map(
      i_S        =>  sW_MemtoReg,
      i_D0       =>  sW_ALUOut,
      i_D1       =>  s_MuxOutLB,
      o_O        =>  s_MuxROut);

end structure;