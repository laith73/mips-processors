-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of a 32-bit shifter
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is

  port(
	  i_ShiftAmount : in std_logic_vector(4 downto 0) := "00000";         -- Shift Amount
	  i_A	          : in std_logic_vector(31 downto 0):= X"00000000";     -- input value
	  i_LA	        : in std_logic  := '0';                                  -- logical  / Arithmetic
	  I_LR          : in std_logic := '0';                                  -- Left / Right
	  o_out         : out std_logic_vector(31 downto 0):= X"00000000");   -- Result

end shifter;

architecture structural of shifter is

begin

  process (i_ShiftAmount, i_A, i_LA, I_LR)
    begin
    if i_LR = '0' then
      o_out <= std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_ShiftAmount))));
    else
      if i_LA = '0' then
        o_out <= std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_ShiftAmount))));
      else
        o_out <= std_logic_vector(shift_right(signed(i_A), to_integer(unsigned(i_ShiftAmount))));
      end if;
    end if;
  end process;

end structural;
