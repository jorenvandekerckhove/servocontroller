 -----------------------------------------------------------------------------
 -- File           : servo.vhd
 -----------------------------------------------------------------------------
 -- Description    : fsm and pwm together
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

entity servo is
	generic(addr_sc: std_logic_vector(7 downto 0));
	port(
		clk: in std_logic;
		rst: in std_logic;
		servo_clk: in std_logic;
		set: in std_logic;
		addr_data: in std_logic_vector(7 downto 0);
		done: out std_logic;
		pwm: out std_logic;
		Ton_out: out natural;
		old_Ton_out: out natural;
		q_data: out std_logic_vector(7 downto 0)
		);
end servo;

architecture behavioral of servo is
signal s_done: std_logic;
signal s_data: std_logic_vector(7 downto 0);

component fsm_en is
generic(addr_sc: std_logic_vector(7 downto 0));
port(
	clk: in std_logic;
	rst: in std_logic;
	set: in std_logic;
	ok_flag: in std_logic;
	addr_data: in std_logic_vector(7 downto 0);
	q_data: out std_logic_vector(7 downto 0)
	);
end component;

component pwm_gen_en is
port (
	clk: in std_logic;
	rst: in std_logic;
	servo_pos: in std_logic_vector(7 downto 0);
	pwm: out std_logic;
	Ton_out: out natural;
	old_Ton_out: out natural;
	done: out std_logic
	);
end component;

begin
	fsm: fsm_en 
	generic map(addr_sc => "00000001")
	port map (
		clk => clk,
		rst => rst,
		set => set,
		ok_flag => s_done,
		addr_data => addr_data,
		q_data => s_data
	);	
	
	pwm_gen: pwm_gen_en port map (
		clk => servo_clk,
		rst => rst,
		servo_pos => s_data,
		pwm => pwm,
		Ton_out => Ton_out,
		old_Ton_out => old_Ton_out,
		done => s_done
	);
	
	q_data <= s_data;
	done <= s_done;
end architecture;