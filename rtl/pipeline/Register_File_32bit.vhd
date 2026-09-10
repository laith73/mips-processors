------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;


entity Register_File_32bit is
  
  port(i_CLK        : in std_logic;                          -- Clock input
       i_RST        : in std_logic;                          -- Reset input
       i_WE         : in std_logic;                          -- Write enable input
       i_WSEL       : in std_logic_vector(4 downto 0);       -- Write select input
       i_RSEL1      : in std_logic_vector(4 downto 0);       -- Read select input
       i_RSEL2      : in std_logic_vector(4 downto 0);       -- Read select input
       i_Data       : in std_logic_vector(31 downto 0);      -- Data value input
       o_Q1         : out std_logic_vector(31 downto 0);     -- Data value output1
       o_Q2         : out std_logic_vector(31 downto 0));    -- Data value output2

end Register_File_32bit;

architecture structural of Register_File_32bit is

-- First Component

component decoder5to32 is

  port(i_EN           : in std_logic;
       i_SEL          : in std_logic_vector(4 downto 0);
       o_out          : out std_logic_vector(31 downto 0));

end component;

-- Second Component

component dffg_N is
  
  generic(N : integer := 32);
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output

end component;

-- Third Component

component MUX_32bit_32to1 is
   port(i_SEL          : in std_logic_vector(4 downto 0);
	i_D0           : in std_logic_vector(31 downto 0);
	i_D1           : in std_logic_vector(31 downto 0);
	i_D2           : in std_logic_vector(31 downto 0);
	i_D3           : in std_logic_vector(31 downto 0);
	i_D4           : in std_logic_vector(31 downto 0);
	i_D5           : in std_logic_vector(31 downto 0);
	i_D6           : in std_logic_vector(31 downto 0);
	i_D7           : in std_logic_vector(31 downto 0);
	i_D8           : in std_logic_vector(31 downto 0);
	i_D9           : in std_logic_vector(31 downto 0);
	i_D10          : in std_logic_vector(31 downto 0);
	i_D11          : in std_logic_vector(31 downto 0);
	i_D12          : in std_logic_vector(31 downto 0);
	i_D13          : in std_logic_vector(31 downto 0);
	i_D14          : in std_logic_vector(31 downto 0);
	i_D15          : in std_logic_vector(31 downto 0);
	i_D16          : in std_logic_vector(31 downto 0);
	i_D17          : in std_logic_vector(31 downto 0);
	i_D18          : in std_logic_vector(31 downto 0);
	i_D19          : in std_logic_vector(31 downto 0);
	i_D20          : in std_logic_vector(31 downto 0);
	i_D21          : in std_logic_vector(31 downto 0);
	i_D22          : in std_logic_vector(31 downto 0);
	i_D23          : in std_logic_vector(31 downto 0);
	i_D24          : in std_logic_vector(31 downto 0);
	i_D25          : in std_logic_vector(31 downto 0);
	i_D26          : in std_logic_vector(31 downto 0);
	i_D27          : in std_logic_vector(31 downto 0);
	i_D28          : in std_logic_vector(31 downto 0);
	i_D29          : in std_logic_vector(31 downto 0);
	i_D30          : in std_logic_vector(31 downto 0);
	i_D31          : in std_logic_vector(31 downto 0);
    o_out          : out std_logic_vector(31 downto 0));

end component;
	
	-- Signals
 	signal s_WE : std_logic_vector(31 downto 0);
  	signal s_Q1   : std_logic_vector(31 downto 0);
  	signal s_Q2   : std_logic_vector(31 downto 0);
	signal s_D0   : std_logic_vector(31 downto 0);
	signal s_D1   : std_logic_vector(31 downto 0);
	signal s_D2   : std_logic_vector(31 downto 0);
	signal s_D3   : std_logic_vector(31 downto 0);
	signal s_D4   : std_logic_vector(31 downto 0);
	signal s_D5   : std_logic_vector(31 downto 0);
	signal s_D6   : std_logic_vector(31 downto 0);
	signal s_D7   : std_logic_vector(31 downto 0);
	signal s_D8   : std_logic_vector(31 downto 0);
	signal s_D9   : std_logic_vector(31 downto 0);
	signal s_D10  : std_logic_vector(31 downto 0);
	signal s_D11  : std_logic_vector(31 downto 0);
	signal s_D12  : std_logic_vector(31 downto 0);
	signal s_D13  : std_logic_vector(31 downto 0);
	signal s_D14  : std_logic_vector(31 downto 0);
	signal s_D15  : std_logic_vector(31 downto 0);
	signal s_D16  : std_logic_vector(31 downto 0);
	signal s_D17  : std_logic_vector(31 downto 0);
	signal s_D18  : std_logic_vector(31 downto 0);
	signal s_D19  : std_logic_vector(31 downto 0);
	signal s_D20  : std_logic_vector(31 downto 0);
	signal s_D21  : std_logic_vector(31 downto 0);
	signal s_D22  : std_logic_vector(31 downto 0);
	signal s_D23  : std_logic_vector(31 downto 0);
	signal s_D24  : std_logic_vector(31 downto 0);
	signal s_D25  : std_logic_vector(31 downto 0);
	signal s_D26  : std_logic_vector(31 downto 0);
	signal s_D27  : std_logic_vector(31 downto 0);
	signal s_D28  : std_logic_vector(31 downto 0);
	signal s_D29  : std_logic_vector(31 downto 0);
	signal s_D30  : std_logic_vector(31 downto 0);
	signal s_D31  : std_logic_vector(31 downto 0);
	signal s_MUX1 : std_logic_vector(31 downto 0);
	signal s_MUX2 : std_logic_vector(31 downto 0);

begin

  g_decoder_0: decoder5to32 port map(
		i_EN  => i_WE,
		i_SEL => i_WSEL,
       	o_out => s_WE);

  g_MUX_0: MUX_32bit_32to1        
       port map(i_SEL => i_RSEL1,
		i_D0 => s_D0,
		i_D1 => s_D1,
		i_D2 => s_D2,
		i_D3 => s_D3,
		i_D4 => s_D4,
		i_D5 => s_D5,
		i_D6 => s_D6,
		i_D7 => s_D7,
		i_D8 => s_D8,
		i_D9 => s_D9,
		i_D10 => s_D10,
		i_D11 => s_D11,
		i_D12 => s_D12,
		i_D13 => s_D13,
		i_D14 => s_D14,
		i_D15 => s_D15,
		i_D16 => s_D16,
		i_D17 => s_D17,
		i_D18 => s_D18,
		i_D19 => s_D19,
		i_D20 => s_D20,
		i_D21 => s_D21,
		i_D22 => s_D22,
		i_D23 => s_D23,
		i_D24 => s_D24,
		i_D25 => s_D25,
		i_D26 => s_D26,
		i_D27 => s_D27,
		i_D28 => s_D28,
		i_D29 => s_D29,
		i_D30 => s_D30,
		i_D31 => s_D31,
       	o_out => s_Q1);

  g_MUX_1: MUX_32bit_32to1        
       port map(i_SEL => i_RSEL2,
		i_D0 => s_D0,
		i_D1 => s_D1,
		i_D2 => s_D2,
		i_D3 => s_D3,
		i_D4 => s_D4,
		i_D5 => s_D5,
		i_D6 => s_D6,
		i_D7 => s_D7,
		i_D8 => s_D8,
		i_D9 => s_D9,
		i_D10 => s_D10,
		i_D11 => s_D11,
		i_D12 => s_D12,
		i_D13 => s_D13,
		i_D14 => s_D14,
		i_D15 => s_D15,
		i_D16 => s_D16,
		i_D17 => s_D17,
		i_D18 => s_D18,
		i_D19 => s_D19,
		i_D20 => s_D20,
		i_D21 => s_D21,
		i_D22 => s_D22,
		i_D23 => s_D23,
		i_D24 => s_D24,
		i_D25 => s_D25,
		i_D26 => s_D26,
		i_D27 => s_D27,
		i_D28 => s_D28,
		i_D29 => s_D29,
		i_D30 => s_D30,
		i_D31 => s_D31,
       	o_out => s_Q2);

-- Instantiate 32 dff instances.
  g_dffg_0: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => '0',
              	i_D      => i_Data,
              	o_Q      => s_D0);

  g_dffg_1: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(1),
              	i_D      => i_Data,
              	o_Q      => s_D1);

  g_dffg_2: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(2),
              	i_D      => i_Data,
              	o_Q      => s_D2);

  g_dffg_3: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(3),
              	i_D      => i_Data,
              	o_Q      => s_D3);

  g_dffg_4: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(4),
              	i_D      => i_Data,
              	o_Q      => s_D4);

  g_dffg_5: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(5),
              	i_D      => i_Data,
              	o_Q      => s_D5);

  g_dffg_6: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(6),
              	i_D      => i_Data,
              	o_Q      => s_D6);

  g_dffg_7: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(7),
              	i_D      => i_Data,
              	o_Q      => s_D7);

  g_dffg_8: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(8),
              	i_D      => i_Data,
              	o_Q      => s_D8);

  g_dffg_9: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(9),
              	i_D      => i_Data,
              	o_Q      => s_D9);

  g_dffg_10: dffg_N port map(
        i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(10),
        i_D      => i_Data,
        o_Q      => s_D10);

  g_dffg_11: dffg_N port map(
        i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(11),
        i_D      => i_Data,
        o_Q      => s_D11);

  g_dffg_12: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(12),
              	i_D      => i_Data,
              	o_Q      => s_D12);

  g_dffg_13: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(13),
              	i_D      => i_Data,
              	o_Q      => s_D13);

  g_dffg_14: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(14),
              	i_D      => i_Data,
              	o_Q      => s_D14);
  
  g_dffg_15: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(15),
              	i_D      => i_Data,
              	o_Q      => s_D15);

  g_dffg_16: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(16),
              	i_D      => i_Data,
              	o_Q      => s_D16);
  
  g_dffg_17: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(17),
              	i_D      => i_Data,
              	o_Q      => s_D17);

  g_dffg_18: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(18),
              	i_D      => i_Data,
              	o_Q      => s_D18);

  g_dffg_19: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(19),
              	i_D      => i_Data,
              	o_Q      => s_D19);

  g_dffg_20: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(20),
              	i_D      => i_Data,
              	o_Q      => s_D20);

  g_dffg_21: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(21),
              	i_D      => i_Data,
              	o_Q      => s_D21);

  g_dffg_22: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(22),
              	i_D      => i_Data,
              	o_Q      => s_D22);

  g_dffg_23: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(23),
              	i_D      => i_Data,
              	o_Q      => s_D23);

  g_dffg_24: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(24),
              	i_D      => i_Data,
              	o_Q      => s_D24);

  g_dffg_25: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(25),
              	i_D      => i_Data,
              	o_Q      => s_D25);

  g_dffg_26: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(26),
              	i_D      => i_Data,
              	o_Q      => s_D26);

  g_dffg_27: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(27),
              	i_D      => i_Data,
              	o_Q      => s_D27);

  g_dffg_28: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(28),
              	i_D      => i_Data,
              	o_Q      => s_D28);

  g_dffg_29: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(29),
              	i_D      => i_Data,
              	o_Q      => s_D29);

  g_dffg_30: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(30),
              	i_D      => i_Data,
              	o_Q      => s_D30);
  
  g_dffg_31: dffg_N port map(
              	i_CLK    => i_CLK,
		i_RST    => i_RST,
		i_WE     => s_WE(31),
              	i_D      => i_Data,
              	o_Q      => s_D31);

	-- Outputs 
		o_Q1 <= s_Q1;
		o_Q2 <= s_Q2;
end structural;
