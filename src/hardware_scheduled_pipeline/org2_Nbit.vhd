-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- org2_NBit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input N-Bit 
-- OR gate.
-------------------------------------------------------------------------

library IEEE; use IEEE.std_logic_1164.all;

entity org2_Nbit is
  generic (N : integer := 32);
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end org2_Nbit;

architecture structural of org2_Nbit is

component org2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

begin

  G_org2: for i in 0 to N-1 generate

  g_org2: org2 port map(
	i_A => i_A(i),
	i_B => i_B(i),
	o_F => o_F(i));

  end generate G_org2;
  
end structural;
