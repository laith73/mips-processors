-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ControlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of the Fetch Logic needed to update the PC.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity FetchLogic is
     port(i_Inst         : in std_logic_vector(31 downto 0);
          i_PC4	     : in std_logic_vector(31 downto 0);
          i_ExtImm       : in std_logic_vector(31 downto 0);
          i_Branch	     : in std_logic_vector(1 downto 0);
          i_Equal        : in std_logic;
          i_Jump         : in std_logic;
          i_JRAddr       : in std_logic_vector(31 downto 0);
          i_JR           : in std_logic; 
          o_NextInstAddr : out std_logic_vector(31 downto 0);
          o_branchOrJump : out std_logic);

end FetchLogic;

architecture mixed of FetchLogic is

  component AddSubImm is
  generic(N : integer := 32); 
  port(i_nAdd_Sub   : in std_logic;
       i_ALUSrc	    : in std_logic;
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       i_Imm        : in std_logic_vector(N-1 downto 0);
       o_DataOut    : out std_logic_vector(N-1 downto 0);
       o_Overflow   : out std_logic);
  end component;

  component mux2t1_N is
   generic(N : integer := 32);
   port(i_S          : in std_logic;
        i_D0         : in std_logic_vector(N-1 downto 0);
        i_D1         : in std_logic_vector(N-1 downto 0);
        o_O          : out std_logic_vector(N-1 downto 0));
  end component;

    component MUX_2to1 is
   port(i_S          : in std_logic;
        i_D0         : in std_logic;
        i_D1         : in std_logic;
        o_O          : out std_logic);
  end component;

  component andg2 is
   port(i_A         : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

  component shifter is
   port(
	  i_ShiftAmount : in std_logic_vector(4 downto 0) := "00000";         -- Shift Amount
	  i_A	          : in std_logic_vector(31 downto 0):= X"00000000";     -- input value
	  i_LA	        : in std_logic  := '0';                                  -- logical  / Arithmetic
	  I_LR          : in std_logic := '0';                                  -- Left / Right
	  o_out         : out std_logic_vector(31 downto 0):= X"00000000");   -- Result
  end component;

  component invg is
  port(i_A          : in std_logic;
       o_F          : out std_logic);
  end component;

  component Register_Nbit is 
   generic(N : integer := 32);
   port(i_CLK        : in std_logic;   
        i_RST        : in std_logic;   
        i_WE         : in std_logic;  
        i_D          : in std_logic_vector(N-1 downto 0);
        o_Q          : out std_logic_vector(N-1 downto 0)); 
  end component;

signal s_ImmAddrOffset, s_PC4Offset, s_Mux0Out, s_Mux1Out, s_JConcat : std_logic_vector(31 downto 0);
signal s_ShiftJOut : std_logic_vector(27 downto 0);
signal s_PC4Ovfl, s_AddOffsOvfl, s_AndOut, s_MuxAOut, s_nEqual : std_logic;
signal s_Mux2Out : std_logic_vector(31 downto 0) := x"00000000";

begin

   ShiftExtImm: Shifter port map(
	      i_ShiftAmount  => "00010",
	      i_A            => i_ExtImm,
	      i_LA           => '0',
	      i_LR           => '0',
	      o_out          => s_ImmAddrOffset);

    AddOffset: AddSubImm port map(
              i_nAdd_Sub     => '0', 
              i_ALUSrc       => '0', 
              i_A            => i_PC4,
              i_B            => s_ImmAddrOffset, 
              i_Imm          => x"00000000",  
              o_DataOut      => s_PC4Offset,  
              o_Overflow     => s_AddOffsOvfl);

   NOTA: invg
     port map(
          i_A  =>  i_Equal,
          o_F  =>  s_nEqual);

   MUXA: MUX_2to1
     port map(
   	     i_D0	     => s_nEqual,
   	     i_D1	     => i_Equal, 
   	     i_S	     => i_Branch(0), 
   	     o_O	     => s_MuxAOut); 

    And1: andg2 port map( 
	      i_A        => i_Branch(1),
	      i_B        => s_MuxAOut,
	      o_F        => s_AndOut);


    MUX0: mux2t1_N port map(
   	      i_D0	     => i_PC4,
   	      i_D1	     => s_PC4Offset, 
   	      i_S	     => s_AndOut, 
   	      o_O	     => s_Mux0Out); 


  s_ShiftJOut <= i_Inst(25 downto 0) & "00";

  s_JConcat <= i_PC4(31 downto 28) & s_ShiftJout(27 downto 0);


    MUX1: mux2t1_N port map(
   	      i_D0	     => s_Mux0Out,
   	      i_D1	     => s_JConcat, 
   	      i_S	     => i_Jump, 
   	      o_O	     => s_Mux1Out); 


    MUX2: mux2t1_N port map(
   	      i_D0	     => s_Mux1Out,
   	      i_D1	     => i_JRAddr, 
   	      i_S	     => i_JR, 
   	      o_O	     => s_Mux2Out); 

o_NextInstAddr <= s_Mux2Out; --Issue with output here
o_branchOrJump <= s_AndOut or i_Jump or i_JR;
  
end mixed;

