-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MUX4to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 4 to 1 MUX using structural VDHL
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity MUX_4to1_32bit is

  port(i_S          : in std_logic_vector(1 downto 0);
       i_D0         : in std_logic_vector(31 downto 0);
       i_D1         : in std_logic_vector(31 downto 0);
       i_D2         : in std_logic_vector(31 downto 0);
       i_D3         : in std_logic_vector(31 downto 0);
       o_O          : out std_logic_vector(31 downto 0));

end MUX_4to1_32bit;

architecture structure of MUX_4to1_32bit is

component mux2t1_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
end component;

  signal s_MuxAout, s_muxBout : std_logic_vector(31 downto 0);

begin

MuxA: mux2t1_N
  port map(
    i_S  => i_S(0),
    i_D0 => i_D0,
    i_D1 => i_D1,
    o_O  => s_MuxAout
);

MuxB: mux2t1_N
  port map(
    i_S  => i_S(0),
    i_D0 => i_D2,
    i_D1 => i_D3,
    o_O  => s_MuxBout
);

MuxC: mux2t1_N
  port map(
    i_S  => i_S(1),
    i_D0 => s_MuxAout,
    i_D1 => s_MuxBout,
    o_O  => o_O
);

end structure;
