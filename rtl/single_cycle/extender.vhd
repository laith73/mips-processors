-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an extender
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity extender is
  port(
       i_sign         : in std_logic;
       i_in           : in std_logic_vector(15 downto 0);
       o_out          : out std_logic_vector(31 downto 0));
end extender;

architecture dataflow of extender is

component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

begin
   G_NBit_andg2: for i in 0 to 15 generate
    g_andg2: andg2 port map(
        i_A    => i_sign,
		    i_B    => i_in(15),
		    o_F    => o_out(i + 16));
	      o_out(i) <= i_in(i);
  end generate G_NBit_andg2;

end dataflow;
