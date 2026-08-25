-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RippleCarry_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit ripple 
-- carry adder.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity RippleCarry_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_C0        : in std_logic;
       i_X         : in std_logic_vector(N-1 downto 0);
       i_Y         : in std_logic_vector(N-1 downto 0);
       o_S         : out std_logic_vector(N-1 downto 0);
       o_Cn        : out std_logic);

end RippleCarry_N;

architecture structural of RippleCarry_N is

  component FullAdder1bit is
     port (i_Xi, i_Yi, i_Ci : in std_logic;
     o_Ci1, o_Si : out std_logic);
  end component;

signal s_tempCarry : std_logic_vector(N-1 downto 0);

begin

FA0 : FullAdder1bit port map(
              i_Ci     => i_C0,  
              i_Xi     => i_X(0),  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_Yi     => i_Y(0),  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_Si     => o_S(0),
	      o_Ci1     => s_tempCarry(0));


  -- Instantiate N mux instances.
  G_NBit_Adder: for i in 1 to N-2 generate

    FAI: FullAdder1bit port map(
              i_Ci     => s_tempCarry(i-1),  
              i_Xi     => i_X(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_Yi     => i_Y(i),  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_Si     => o_S(i),
	      o_Ci1     => s_tempCarry(i));  

  end generate G_NBit_Adder;


FANm1 : FullAdder1bit port map(
              i_Ci     => s_tempCarry(N-2),  
              i_Xi     => i_X(N-1),  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_Yi     => i_Y(N-1),  -- ith instance's data 1 input hooked up to ith data 1 input.
              o_Si     => o_S(N-1),
	      o_Ci1     => o_Cn);
  
end structural;