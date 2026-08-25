

library IEEE;
use IEEE.std_logic_1164.all;

entity OnesComp_N is
   generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_I         : in std_logic_vector(N-1 downto 0);
        o_O         : out std_logic_vector(N-1 downto 0));
end OnesComp_N;

architecture structural of OnesComp_N is

   component invg is
      port(i_A          : in std_logic;
           o_F          : out std_logic);
   end component;

begin 

  -- Instantiate N inv instances.
  G_NBit_INV: for i in 0 to N-1 generate
    INVI: invg port map(
              i_A     => i_I(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              o_F     => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_INV;

end structural;