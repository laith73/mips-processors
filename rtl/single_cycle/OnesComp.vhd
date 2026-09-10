-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity OnesComp is
  port(
       i_D0        : in std_logic;
       o_O         : out std_logic);

end OnesComp;

architecture structural of OnesComp is

  component invg is
    port(i_A                  : in std_logic;
         o_F                  : out std_logic);

  end component;

begin
    g_invg: invg port map(
              i_A     => i_D0,
              o_F     => o_O);	
  
end structural;
