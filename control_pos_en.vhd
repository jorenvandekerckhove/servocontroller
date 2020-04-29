 -----------------------------------------------------------------------------
 -- File           : control_pos_en
 -----------------------------------------------------------------------------
 -- Description    : control_pos_en
 -- --------------------------------------------------------------------------
 -- Author         : Joren Vandekerckhove
 -- Date           : 20/03/2020
 -- Version        : 1.0
 -- Change history : 
 -----------------------------------------------------------------------------  
 -- This code was developed by Osman Allam during an internship at IMEC, 
 -- in collaboration with Geert Vanwijnsberghe, Tom Tassignon en Steven 
 -- Redant. The purpose of this code is to teach students good VHDL coding
 -- style for writing complex behavioural models.
 -----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.numeric_std.all;

entity control_pos_en is
	port(
		recr_pos: in std_logic_vector(7 downto 0);
		data_pos : in std_logic_vector(7 downto 0);
		ok_pos: out std_logic
		);
end control_pos_en;

architecture behavioral of control_pos_en is
signal s_position : std_logic_vector(7 downto 0) := (others=>'0');
begin
	process(data_pos)
	variable noffset: natural := 125;
	variable pos: natural := 0;
	begin
		pos := (to_integer(unsigned(data_pos))/5)+noffset;
		if(pos > 175) then pos := 175; end if;
		s_position <= std_logic_vector(to_unsigned(pos,8));
	end process;

	ok_pos <= '0' when recr_pos /= s_position else
			  '1' when recr_pos = s_position;	
end architecture;