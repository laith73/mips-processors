-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- Forwarding_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: pipelined MIPS processor forwarding unit 
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

entity Forwarding_unit is

   port(
      i_RegWrite_EX_MEM   : in std_logic;
      i_RegWrite_MEM_WB   : in std_logic;
      i_Rd_EX_MEM         : in std_logic_vector(4 downto 0);
      i_Rd_MEM_WB         : in std_logic_vector(4 downto 0);
      i_Rs_ID_EX          : in std_logic_vector(4 downto 0);
      i_Rt_ID_EX          : in std_logic_vector(4 downto 0);
      o_ForwardA          : out std_logic_vector(1 downto 0);
      o_ForwardB          : out std_logic_vector(1 downto 0)
   );

end Forwarding_unit;

architecture dataflow of Forwarding_unit is

-- Signals and Components

signal s_ForwardA0, s_ForwardA1, s_ForwardB0, s_ForwardB1: std_logic;

begin 

-- if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) ForwardA = 10
s_ForwardA1 <= i_RegWrite_EX_MEM and (or_reduce(i_Rd_EX_MEM)) and (not(or_reduce(i_Rd_EX_MEM xor i_Rs_ID_EX)));

-- if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0) and not (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs))
-- and (MEM/WB.RegisterRd = ID/EX.RegisterRs)) ForwardA = 01
s_ForwardA0 <= i_RegWrite_MEM_WB and (or_reduce(i_Rd_MEM_WB)) and (not(s_ForwardA1)) and (not(or_reduce(i_Rd_MEM_WB xor i_Rs_ID_EX)));

-- if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt)) ForwardB = 10
s_ForwardB1 <= i_RegWrite_EX_MEM and (or_reduce(i_Rd_EX_MEM)) and (not(or_reduce(i_Rd_EX_MEM xor i_Rt_ID_EX)));

-- if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0) and not (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt))
-- and (MEM/WB.RegisterRd = ID/EX.RegisterRt)) ForwardB = 01
s_ForwardB0 <= i_RegWrite_MEM_WB and (or_reduce(i_Rd_MEM_WB)) and (not(s_ForwardB1)) and (not(or_reduce(i_Rd_MEM_WB xor i_Rt_ID_EX)));

o_ForwardA <= s_ForwardA1 & s_ForwardA0;
o_ForwardB <= s_ForwardB1 & s_ForwardB0;

end dataflow;