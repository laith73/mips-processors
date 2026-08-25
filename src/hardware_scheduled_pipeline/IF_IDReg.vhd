-------------------------------------------------------------------------
-- Chase O'Connell
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- IF_IDReg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the IF/ID Register.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity IF_IDReg is
   port(
	i_CLK	: in std_logic;
	i_RST	: in std_logic;
	i_WE	: in std_logic;
	i_Inst	: in std_logic_vector(31 downto 0);
	i_PC4	: in std_logic_vector(31 downto 0);
	o_Inst	: out std_logic_vector(31 downto 0);
	o_PC4	: out std_logic_vector(31 downto 0)
       );   

end IF_IDReg;

architecture structural of IF_IDReg is
  component Register_Nbit is
   	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   	port(
		i_CLK        : in std_logic;     					-- Clock input
        i_RST        : in std_logic;  					   	-- Reset input
        i_WE         : in std_logic;     					-- Write enable input
        i_D          : in std_logic_vector(N-1 downto 0);   -- Data value input
        o_Q          : out std_logic_vector(N-1 downto 0)	-- Data value output
	);   
end component;

begin

  REG0: Register_Nbit
	port map (
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_Inst,
		o_Q		=>	o_Inst
	);

  	REG1: Register_Nbit
		port map (
		i_CLK	=>	i_CLK,
		i_RST	=>	i_RST,
		i_WE	=>	i_WE,
		i_D		=>	i_PC4,
		o_Q		=>	o_PC4
	);

end structural;
