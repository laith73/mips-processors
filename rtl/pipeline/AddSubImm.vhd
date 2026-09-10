-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- AdderSubtractor_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit adder 
-- and subtractor with control.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity AddSubImm is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_nAdd_Sub   : in std_logic;
       i_ALUSrc	    : in std_logic;
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       i_Imm        : in std_logic_vector(N-1 downto 0);
       o_DataOut    : out std_logic_vector(N-1 downto 0);
       o_Overflow   : out std_logic);

end AddSubImm;

architecture structural of AddSubImm is

  component OnesComp_N is
   generic(N : integer := 32);
   port(i_I         : in std_logic_vector(N-1 downto 0);
        o_O         : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
   generic(N : integer := 32);
   port(i_S          : in std_logic;
        i_D0         : in std_logic_vector(N-1 downto 0);
        i_D1         : in std_logic_vector(N-1 downto 0);
        o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component RippleCarry_N is
   generic(N : integer := 32);
   port(i_C0        : in std_logic;
        i_X         : in std_logic_vector(N-1 downto 0);
        i_Y         : in std_logic_vector(N-1 downto 0);
        o_S         : out std_logic_vector(N-1 downto 0);
        o_Cn        : out std_logic);
  end component;

signal s_invB, s_muxout0B, s_muxout1B : std_logic_vector(N-1 downto 0);

begin

--For selecting immediate or register input for B
    MUX1: mux2t1_N port map(
              i_S     => i_ALUSrc,  
              i_D0    => i_B,
	      i_D1    => i_Imm,
	      o_O     => s_muxout1B); 

    OCI: OnesComp_N port map(
              i_I     => s_muxout1B,  
              o_O     => s_invB);  

--For selecting add vs. sub
    MUX0: mux2t1_N port map(
          i_S     => i_nAdd_Sub,  
          i_D0    => s_muxout1B,
	     i_D1    => s_invB,
	     o_O     => s_muxout0B); 

    RCI: RippleCarry_N port map(
          i_C0    => i_nAdd_Sub,  
          i_X     => i_A,
	     i_Y     => s_muxout0B,
	     o_S     => o_DataOut,
	     o_Cn    => o_Overflow);  


  
end structural;
