library IEEE;
use IEEE.std_logic_1164.all;

entity FullAdder1bit is
port (i_Xi, i_Yi, i_Ci : in std_logic;
o_Ci1, o_Si : out std_logic);
end FullAdder1bit;

architecture structural of FullAdder1bit is

component andg2
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component org2
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component xorg2
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;


signal s1, c1, c2 : std_logic;

begin
   xor1 : xorg2
   port map( i_A => i_Xi,
	     i_B => i_Yi,
    	     o_F => s1);

   and1 : andg2
   port map( i_A => i_Xi,
	     i_B => i_Yi,
    	     o_F => c1);

   xor2 : xorg2
   port map( i_A => i_Ci,
	     i_B => s1,
    	     o_F => o_Si);

   and2 : andg2
   port map( i_A => i_Ci,
	     i_B => s1,
    	     o_F => c2);

   or1 : org2
   port map( i_A => c1,
	     i_B => c2,
    	     o_F => o_Ci1);

end structural;