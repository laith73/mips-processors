-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- andg_Nbit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input N-bit 
-- AND gate.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity andg2_Nbit is
  generic(N : integer := 32);  -- Default 32 bit
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end andg2_Nbit;

architecture structural of andg2_Nbit is

component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component ;

begin

  G_andg2: for i in 0 to N-1 generate

  g_andg2: andg2 port map(
	i_A => i_A(i),
	i_B => i_B(i),
	o_F => o_F(i));

  end generate G_andg2;

end structural;
