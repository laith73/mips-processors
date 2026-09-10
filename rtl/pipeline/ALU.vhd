-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of a 32-bit ALU
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;


entity ALU is

  port(i_ALUcontrol  : in std_logic_vector(4 downto 0);
	     i_A	         : in std_logic_vector(31 downto 0);
	     i_B	         : in std_logic_vector(31 downto 0);
	     o_zero        : out std_logic;
       o_overflow    : out std_logic;
	     o_result      : out std_logic_vector(31 downto 0));

end ALU;

architecture structural of ALU is

component mux2t1_N is

  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.

  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end component;

component MUX_32bit_8to1 is

  port(i_SEL          : in std_logic_vector(2 downto 0);
	     i_D0           : in std_logic_vector(31 downto 0);
	     i_D1           : in std_logic_vector(31 downto 0);
	     i_D2           : in std_logic_vector(31 downto 0);
	     i_D3           : in std_logic_vector(31 downto 0);
	     i_D4           : in std_logic_vector(31 downto 0);
	     i_D5           : in std_logic_vector(31 downto 0);
	     i_D6           : in std_logic_vector(31 downto 0);
	     i_D7           : in std_logic_vector(31 downto 0);
       o_out          : out std_logic_vector(31 downto 0));

end component;

component AddSub is

  generic(N : integer := 32);

  port(i_A          : in std_logic_vector(N-1 downto 0);      -- First Input
       i_B          : in std_logic_vector(N-1 downto 0);      -- Second Input
       i_addSub     : in std_logic;                           -- Add or Sub Select Line
       o_S          : out std_logic_vector(N-1 downto 0);     -- 
       o_overflow   : out std_logic);

end component;

component andg2_Nbit is
	  
  generic(N : integer := 32);

  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end component;

component invg2_Nbit is

  generic(N : integer := 32);

  port(
       i_D0         : in std_logic_vector(N-1 downto 0);
       o_O         : out std_logic_vector(N-1 downto 0));

end component;


component org2_Nbit is

  generic (N : integer := 32);

  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end component;

component xorg2_Nbit is

  generic(N : integer := 32);

  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end component;

component shifter is

  port(
	  i_ShiftAmount : in std_logic_vector(4 downto 0) := "00000";         -- Shift Amount
	  i_A	          : in std_logic_vector(31 downto 0):= X"00000000";     -- input value
	  i_LA	        : in std_logic  := '0';                               -- logical  / Arithmetic
	  i_LR          : in std_logic := '0';                                -- Left / Right
	  o_out         : out std_logic_vector(31 downto 0):= X"00000000");   -- Result

end component;

  signal s_andMuxA, s_andMuxB, s_notA, s_notB, s_addSub, s_and, s_or, s_xor, s_shifter1, s_shifter2, s_shifter3, s_muxOut, s_placeHolder :std_logic_vector(31 downto 0);  

begin

  g_mux8to1: MUX_32bit_8to1
  port map (
            i_SEL     => i_ALUcontrol(2 downto 0),
	          i_D0      => s_addSub,
	          i_D1      => s_and,
	          i_D2      => s_or,
	          i_D3      => s_xor,
	          i_D4      => s_shifter1,
	          i_D5      => s_shifter2,
	          i_D6      => s_shifter3,
	          i_D7      => s_placeHolder,
            o_out     => s_muxOut 
  );

  g_invg2A: invg2_Nbit
  port map (
            i_D0        => i_A, 
            o_O         => s_notA
  );

  g_invg2B: invg2_Nbit
  port map (
            i_D0        => i_B, 
            o_O         => s_notB
  );

  g_mux2to1A: mux2t1_N
  port map (
            i_S          => i_ALUcontrol(3),
            i_D0         => i_A,
            i_D1         => s_notA,
            o_O          => s_andMuxA
  );

  g_mux2to1B: mux2t1_N
  port map (
            i_S          => i_ALUcontrol(4),
            i_D0         => i_B,
            i_D1         => s_notB,
            o_O          => s_andMuxB
  );
  
  g_addSub: AddSub
  port map (
            i_A          => i_A,
            i_B          => i_B,   
            i_addSub     => i_ALUcontrol(3),
            o_S          => s_addSub,
            o_overflow   => o_overflow
  );

  g_andg2: andg2_Nbit
  port map (
            i_A         => s_andMuxA,
            i_B         => s_andMuxB,
            o_F         => s_and
  );
  
  g_org2: org2_Nbit
  port map (
            i_A         => i_A,
            i_B         => i_B,
            o_F         => s_or
  );

  g_xorg2: xorg2_Nbit
  port map (
            i_A         => i_A,
            i_B         => i_B,
            o_F         => s_xor
  );

  g_shifter1: shifter
  port map (
	          i_ShiftAmount => i_B(4 downto 0),     -- Shift Amount
	          i_A	          => i_A,                 -- input value
	          i_LA	        => i_ALUcontrol(4),     -- logical / Arithmetic
	          i_LR          => i_ALUcontrol(3),     -- Left / Right
	          o_out         => s_shifter1           -- Result
  );

  g_shifter2: shifter
  port map (
	          i_ShiftAmount => "10000",             -- Shift Amount
	          i_A	          => i_B,                 -- input value
	          i_LA	        => '0',                 -- logical / Arithmetic
	          i_LR          => '0',                 -- Left / Right
	          o_out         => s_shifter2           -- Result
  );

  g_shifter3: shifter
  port map (
	          i_ShiftAmount => "11111",             -- Shift Amount
	          i_A	          => s_addSub,            -- input value
	          i_LA	        => '0',                 -- logical / Arithmetic
	          i_LR          => '1',                 -- Left / Right
	          o_out         => s_shifter3           -- Result
  );

  o_result   <= s_muxOut;
  o_zero  <= nor_reduce(s_muxOut);

end structural;
