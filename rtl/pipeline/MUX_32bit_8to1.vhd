-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- 32bit_8to1_MUX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity MUX_32bit_8to1 is

   port(i_SEL          : in std_logic_vector(2 downto 0);
	i_D0           : in std_logic_vector(31 downto 0);
	i_D1           : in std_logic_vector(31 downto 0);
	i_D2           : in std_logic_vector(31 downto 0);
	i_D3           : in std_logic_vector(31 downto 0);
	i_D4           : in std_logic_vector(31 downto 0);
	i_D5           : in std_logic_vector(31 downto 0);
	i_D6           : in std_logic_vector(31 downto 0);
	i_D7           : in std_logic_vector(31 downto 0);
    o_out          : out std_logic_vector(31 downto 0));

end MUX_32bit_8to1;

architecture dataflow of MUX_32bit_8to1 is

begin

	with i_SEL Select 
	o_out <= i_D0  when "000",
		 i_D1  when "001",
		 i_D2  when "010",
		 i_D3  when "011",
		 i_D4  when "100",
		 i_D5  when "101",
		 i_D6  when "110",
		 i_D7  when "111",
		 i_D1 when others;

end dataflow;
