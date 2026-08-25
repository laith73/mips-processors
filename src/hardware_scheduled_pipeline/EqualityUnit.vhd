-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ControlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of the Equality Unit needed to check for 
-- equality of rs and rt registers during the decode stage of the pipeline.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

entity EqualityUnit is
   port(
	  i_RegRs	 : in std_logic_vector(31 downto 0);
	  i_RegRt	 : in std_logic_vector(31 downto 0);
    o_Equal  : out std_logic);

end EqualityUnit;

architecture mixed of EqualityUnit is

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

signal s_SubOut : std_logic_vector(31 downto 0);
signal s_SubOvfl : std_logic;

begin

    SUB: AddSubImm port map(
              i_nAdd_Sub     => '1', 
              i_ALUSrc       => '0', 
              i_A            => i_RegRs,
              i_B            => i_RegRt, 
              i_Imm          => x"00000000",  
              o_DataOut      => s_SubOut,  
              o_Overflow     => s_SubOvfl); 

o_Equal <= nor_reduce(s_SubOut);
  
end mixed;
