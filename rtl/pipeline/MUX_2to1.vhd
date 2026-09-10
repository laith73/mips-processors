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

entity MUX_2to1 is

  port(i_D0         : in std_logic;
       i_D1         : in std_logic;
       i_S          : in std_logic;
       o_O          : out std_logic);

end MUX_2to1;

architecture structure of MUX_2to1 is

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

component invg is

  port(i_A          : in std_logic;
       o_F          : out std_logic);

end component;


  signal s_or, s_not, s_and1, s_and2: std_logic;

begin
  
  g_not1: invg
    port MAP(i_A              => i_S,
             o_F              => s_not);
   
  g_and1: andg2
    port MAP(i_A              => i_D0,
             i_B              => s_not,
             o_F              => s_and1);
  
  g_and2: andg2
    port MAP(i_A              => i_D1,
             i_B              => i_S,
             o_F              => s_and2);
  
  g_or1: org2
    port MAP(i_A              => s_and1,
             i_B              => s_and2,
             o_F              => s_or);

    o_O <= s_or;
  
end structure;
