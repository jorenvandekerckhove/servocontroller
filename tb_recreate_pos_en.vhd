 -----------------------------------------------------------------------------
 -- File           : tb_recreate_pos_en.vhd
 -----------------------------------------------------------------------------
 -- Description    : Testbench for recreate_pos_en
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_recreate_pos_en is
end entity;

architecture test of tb_recreate_pos_en is
	signal clk: std_logic;
	signal rst: std_logic;
	signal servo_pos: std_logic_vector(7 downto 0);
	signal pwm: std_logic;
	signal Ton_out: natural;
	signal old_Ton_out: natural;
	signal done: std_logic;
	signal servo_pos_out: std_logic_vector(7 downto 0);
  
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
	
	component recreate_pos_en is
	port (
		pwm: in std_logic;
		servo_pos: out std_logic_vector(7 downto 0)
		);
	end component;
  
	signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 us;
	begin
  
	pwm_gen: pwm_gen_en port map (
		clk => clk,
		rst => rst,
		servo_pos => servo_pos,
		pwm => pwm,
		Ton_out => Ton_out,
		old_Ton_out => old_Ton_out,
		done => done
	);
	
	recreate_pos_1: recreate_pos_en port map (
		pwm => pwm,
		servo_pos => servo_pos_out
	);

	clock: process
	begin
	clk <= '0';
	loop
	  wait for clkPeriod/2;
	  clk <= not clk;
	  wait for clkPeriod - clkPeriod/2;
	  clk <= not clk;
	  exit when EndOfSim;
	end loop;
	wait;
	end process;

	process 
	begin
		rst <= '1';  
		servo_pos <= "01111111";
		wait for 10 ms;
		rst <= '0';
		wait for 20 ms;
		servo_pos <= "01100000";
		wait for 100 ms;
		EndOfSim <= true;
		wait;
	end process;
end architecture;