 -----------------------------------------------------------------------------
 -- File           : tb_servo.vhd
 -----------------------------------------------------------------------------
 -- Description    : Testbench for fsm and pwm together
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

entity tb_servo is
end entity;

architecture test of tb_servo is
	signal clk: std_logic;
	signal rst: std_logic;
	signal servo_clk: std_logic;
	signal set: std_logic;
	signal addr_data: std_logic_vector(7 downto 0);
	signal done: std_logic;
	signal pwm: std_logic;
	signal Ton_out: natural;
	signal old_Ton_out: natural;
	signal q_data: std_logic_vector(7 downto 0);
  
	component servo is
	generic(addr_sc: std_logic_vector(7 downto 0));
	port (
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
	end component;
  
	signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 ms;
	constant servoClkPeriod: time := 10 us;
	
	begin
	
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
	
	servo_clock: process
	begin
		servo_clk <= '0';
		loop
		  wait for servoClkPeriod/2;
		  servo_clk <= not servo_clk;
		  wait for servoClkPeriod - servoClkPeriod/2;
		  servo_clk <= not servo_clk;
		  exit when EndOfSim;
		end loop;
		wait;
	end process;

	servo_1: servo 
	generic map(addr_sc => "10011111")
	port map (
		clk => clk,
		rst => rst,
		servo_clk => servo_clk,
		set => set,
		addr_data => addr_data,
		done => done,
		pwm => pwm,
		Ton_out => Ton_out,
		old_Ton_out => old_Ton_out,
		q_data => q_data
	);
	
	process 
	begin
		rst <= '1'; 
		set <= '1';
		addr_data <= "00000000";
		wait for 55 ms;
		addr_data <= "10011111";
		rst <= '0';
		wait for 10 ms;
		addr_data <= "01100000";
		wait for 10 ms;
		addr_data <= (others => '0');
		set <= '0';
		wait for 100 ms;
		EndOfSim <= true;
		wait;
	end process;
end architecture;