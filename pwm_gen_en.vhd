 -----------------------------------------------------------------------------
 -- File           : pwm_gen_en.vhd
 -----------------------------------------------------------------------------
 -- Description    : pwm generator
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

entity pwm_gen_en is
	port(
		clk: in std_logic;
		rst: in std_logic;
		servo_pos: in std_logic_vector(7 downto 0);
		Ton_out: out natural;
		old_Ton_out: out natural;
		done: out std_logic;
		pwm: out std_logic
		);
end pwm_gen_en;

architecture behavioral of pwm_gen_en is
signal count : std_logic_vector(10 downto 0) := (others => '0');
signal period: std_logic_vector(10 downto 0) := "11111010000"; --2000
signal Ton : natural := 150;
signal old_Ton: natural := 150;
signal done_s: std_logic := '0';
begin
	set_Ton_proc: process(rst, servo_pos)
	variable noffset: natural := 150;
	variable nposition: integer := 0;	
	begin
		if(rst = '1') then
			Ton <= 150;				
		else
			nposition := to_integer(signed(servo_pos))/5;
			Ton <= (noffset + nposition);
			Ton_out <= (noffset + nposition);
		end if;
	end process set_Ton_proc;
	
	cnt_proc: process(clk)
	begin	
		if clk'event and clk = '1' then
			-- if(Ton /= old_Ton) then
				-- done_s <= '0';
				-- old_Ton <= Ton;
			-- end if;
			if count = (period - 1) then
				old_Ton <= Ton;
				count <= (others => '0'); 
			else 
				count <= count + 1;			
			end if; 
		end if;
	end process cnt_proc;
	
	send_pwm_proc: process(count)
	begin
		if count < Ton then 
			pwm <= '1'; 
		else 
			pwm <= '0'; 
		end if;
	end process send_pwm_proc;
	
	old_Ton_out <= old_Ton;
	done_s <= '0' when Ton /= old_Ton else
			  '1' when Ton = old_Ton;
	done <= done_s;
end architecture;