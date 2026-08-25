-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- AddSub.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of an N-bit wide adder-subtrator
-- with overflow detection
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity AddSub is
  generic(N : integer := 32);  -- Default 32 bit
  port(
      i_A          : in std_logic_vector(N-1 downto 0);
      i_B          : in std_logic_vector(N-1 downto 0);
      i_addSub     : in std_logic;
      o_S          : out std_logic_vector(N-1 downto 0);
      o_overflow   : out std_logic);

end AddSub;

architecture structural of AddSub is

  component full_Adder is

  port(
      i_A         : in std_logic;
      i_B         : in std_logic;
      i_C_in      : in std_logic;
      o_C_out     : out std_logic;
      o_S         : out std_logic);

  end component;

  component MUX_2to1 is

 	port(
      i_D0         : in std_logic;
      i_D1         : in std_logic;
      i_S          : in std_logic;
      o_O          : out std_logic
  );

  end component MUX_2to1;


  component OnesComp is
  	port(
	    i_D0         : in std_logic;
      o_O          : out std_logic
    );

  end component;

  component xorg2 is

  port(
      i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic
  );

  end component;

	signal s_inverted, s_mux: std_logic_vector(N-1 downto 0);
	signal s_Curry:std_logic_vector(N downto 0);
  signal s_overflow: std_logic;
  
begin

	s_Curry(0) <= i_addSub;

  G_AddSub: for i in 0 to N-1 generate
	
	g_OnesComp: OnesComp port map(
		i_D0 => i_B(i),
		o_O => s_inverted(i));

	g_mux2t1: MUX_2to1 port map(
		i_S  => s_Curry(0),
		i_D0 => i_B(i),
		i_D1 => s_inverted(i),
		o_O  => s_mux(i));

  g_full_Adder: full_Adder port map(
    i_A     => i_A(i),
    i_B     => s_mux(i),
    i_C_in  => s_Curry(i),
    o_C_out => s_Curry(i+1), 
    o_S     => o_S(i));

  end generate G_AddSub;
	
  g_xorg2: xorg2 port map(
		i_A  => s_Curry(N-1),
		i_B  => s_Curry(N),
		O_F  => s_overflow
  );
  
  o_overflow <= s_overflow;
end structural;
