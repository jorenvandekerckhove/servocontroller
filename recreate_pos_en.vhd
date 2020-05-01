 -----------------------------------------------------------------------------
 -- File           : recreate_pos_en
 -----------------------------------------------------------------------------
 -- Description    : recreate_pos_en
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

entity recreate_pos_en is
	port(
		pwm: in std_logic;
		servo_pos : out std_logic_vector(7 downto 0)
		);
end recreate_pos_en;

architecture behavioral of recreate_pos_en is
begin
	detect_edge: process(pwm)
	variable t_rise : time := 0 ns;
	variable delay : time := 0 ns;
	variable position: natural := 0;
	begin
		if pwm'event and pwm = '1' then
			t_rise := now;
		elsif pwm'event and pwm = '0' then -- works in simulation, but not in elaboration of Xilinx
			delay := now - t_rise; -- max value is 1750000 ns, min value is 1250000 ns
			position := delay / 10000 ns;
			servo_pos <= std_logic_vector(to_unsigned(position, 8));
		end if;
	end process;
end architecture;