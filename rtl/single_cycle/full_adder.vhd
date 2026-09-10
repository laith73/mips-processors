-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MUX2to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 2 to 1 MUX using structural VDHL
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity full_Adder is

  port(i_A         : in std_logic;
       i_B         : in std_logic;
       i_C_in      : in std_logic;
       o_C_out     : out std_logic;
       o_S         : out std_logic);

end full_Adder;

architecture structure of full_Adder is

component org2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

component xorg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;


  signal s_xor1, s_xor2, s_and1, s_and2, s_or: std_logic;

begin
  
  g_xor1: xorg2
    port MAP(i_A              => i_A,
             i_B              => i_B,
             o_F              => s_xor1);
  
  g_xor2: xorg2
    port MAP(i_A              => s_xor1,
             i_B              => i_C_in,
             o_F              => s_xor2);
   
  g_and1: andg2
    port MAP(i_A              => i_A,
             i_B              => i_B,
             o_F              => s_and1);
  
  g_and2: andg2
    port MAP(i_A              => s_xor1,
             i_B              => i_C_in,
             o_F              => s_and2);
  
  g_or1: org2
    port MAP(i_A              => s_and1,
             i_B              => s_and2,
             o_F              => s_or);

    o_C_out <= s_or;
    o_S     <= s_xor2;
  
end structure;
