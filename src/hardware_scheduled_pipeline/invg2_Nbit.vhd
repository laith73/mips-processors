-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- invg2_Nbit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION:Implementation of a 2-input N-bit invert gate
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity invg2_Nbit is

  generic(N : integer := 32); -- default 32

  port(
       i_D0         : in std_logic_vector(N-1 downto 0);
       o_O         : out std_logic_vector(N-1 downto 0));

end invg2_Nbit;

architecture structural of invg2_Nbit is

  component invg is

    port(i_A                  : in std_logic;
         o_F                  : out std_logic);

  end component;

begin

  G_invg2: for i in 0 to N-1 generate

  g_invg2: invg port map(
              i_A     => i_D0(i),
              o_F     => o_O(i));

  end generate G_invg2;
  
end structural;
