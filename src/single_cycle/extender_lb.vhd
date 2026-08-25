------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity extender_lb is

  port(
      i_sign         : in std_logic;
      i_in           : in std_logic_vector(31 downto 0);
      o_out          : out std_logic_vector(31 downto 0)
  );

end extender_lb;

architecture dataflow of extender_lb is

component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

begin
  G_NBit_andg2: for i in 0 to 23 generate
    g_andg2: andg2
      port map(
        i_A    => i_sign,
		    i_B    => i_in(7),
		    o_F    => o_out(i + 8)
      );
  end generate G_NBit_andg2;
	
  o_out(7 downto 0) <= i_in(7 downto 0);

end dataflow;
