-------------------------------------------------------------------------
-- Laith Al Sairafi
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- HazardDetect.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Implementation of the hazard dection unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

entity HazardDetect2 is
   port(
   	iE_Inst_opcode      : in std_logic_vector(5 downto 0);
   	iD_Rs			 	: in std_logic_vector(4 downto 0);
   	iD_Rt  				: in std_logic_vector(4 downto 0);
	iE_RegWriteDest  	: in std_logic_vector(4 downto 0);
   	iM_RegWriteDest  	: in std_logic_vector(4 downto 0);
   	iW_RegWriteDest  	: in std_logic_vector(4 downto 0);
	i_RegWrite_MEM_WB   : in std_logic;
	i_Jump				: in std_logic;
	i_JR				: in std_logic;
	i_Branch			: in std_logic;
    i_takenBranch		: in std_logic;
	o_stall 			: out std_logic; -- bne and beq and jumps
	o_Flush 			: out std_logic
	);

end HazardDetect2;

architecture dataflow of HazardDetect2 is

signal s_loadStall, s_branchStall, s_load, s_writeBackStall, s_JrStall : std_logic;

begin

-- If the instruction is load s_load = 1 otherwise 0

with iE_Inst_opcode select
  	s_load <= 	'1' when "100011",  --lw
	    		'1' when "100000",	--lb
        		'1' when "100001",	--lh
	    		'1' when "100100",	--lbu
	    		'1' when "100101",	--lhu
	    		'0' when others;

-- When there is a producer in WB and a consumer in ID 

s_writeBackStall <= (i_RegWrite_MEM_WB) 
						and (not((or_reduce(iW_RegWriteDest xor iD_Rs))) 
							or (not(or_reduce(iW_RegWriteDest xor iD_Rt))))
								and (or_reduce(iW_RegWriteDest))
									and (((or_reduce(iM_RegWriteDest xor iD_Rs)))
										or ((or_reduce(iW_RegWriteDest xor iD_Rs)))) 
											and (((or_reduce(iM_RegWriteDest xor iD_Rt)))
												or ((or_reduce(iW_RegWriteDest xor iD_Rt))));

--When doing a lw and then using the value in the next instruction, need to stall 1 cycle even with forwarding.

s_loadStall <= (s_load) 
					and (not(or_reduce(iE_RegWriteDest xor iD_Rs))
						 or (not(or_reduce(iE_RegWriteDest xor iD_Rt))));


-- Branch Stall (Not Working Properly)


s_JrStall <= (i_JR)
				and ((not(or_reduce(iE_RegWriteDest xor iD_Rs)))
						or (not(or_reduce(iM_RegWriteDest xor iD_Rs))) 
						or (not(or_reduce(iW_RegWriteDest xor iD_Rs))));

s_branchStall <= (i_Branch) 
						and ((((not(or_reduce(iE_RegWriteDest xor iD_Rs)))
						  	or (not(or_reduce(iM_RegWriteDest xor iD_Rs)))
							 	or (not(or_reduce(iW_RegWriteDest xor iD_Rs)))) 
									and (or_reduce(iD_Rs)))
										or (((not(or_reduce(iE_RegWriteDest xor iD_Rt)))
											or (not(or_reduce(iM_RegWriteDest xor iD_Rt)))
												or (not(or_reduce(iW_RegWriteDest xor iD_Rt))))
													and (or_reduce(iD_Rt))));


o_stall <= s_writeBackStall or s_loadStall or s_branchStall or s_JrStall;

--When jumping or branching, flush (sel for mux to put 0s into IFID's s_Inst should be 1)

o_Flush <= i_takenBranch or i_Jump;

end dataflow;