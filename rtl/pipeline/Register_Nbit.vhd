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

entity Register_Nbit is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
        o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output

end Register_Nbit;

architecture structural of Register_Nbit is

  component dffg is
   port(i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D          : in std_logic;     -- Data value input
        o_Q          : out std_logic);   -- Data value output
   end component;



begin

  -- Instantiate N inv instances.
  G_NBit_DFF: for i in 0 to N-1 generate
    DFFI: dffg port map(
              i_CLK     => i_CLK, 
              i_RST     => i_RST,
              i_WE      => i_WE,
              i_D       => i_D(i),
              o_Q       => o_Q(i)); 
  end generate G_NBit_DFF;


end structural;
