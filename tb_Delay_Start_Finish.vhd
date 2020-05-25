 -----------------------------------------------------------------------------
 -- File           : tb_servo.vhd
 -----------------------------------------------------------------------------
 -- Description    : Testbench for the servocontroller
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

entity tb_Delay_Start_Finish is
end entity;

architecture testbench of tb_Delay_Start_Finish is
    -- component initialisations begin
	component Delay_Start_Finish is
	Port(
		Clk: in std_logic;
		Reset: in std_logic;
		Start: in std_logic;
		iCnt_p_out: out natural;
    	iCnt_f_out: out natural;
		Finish: out std_logic
	);
	end component;
	-- component initialisations end
	signal clk: std_logic;
	signal Reset: std_logic;
	signal Start: std_logic;
	signal Finish: std_logic;
	signal iCnt_f_out: natural;
	signal iCnt_p_out: natural;
    signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 ns;

    -- begin architecture
    begin
        	
	clock: process
	begin
		clk <= '1';
		loop
		  wait for clkPeriod/2;
		  clk <= not clk;
		  wait for clkPeriod - clkPeriod/2;
		  clk <= not clk;
		  exit when EndOfSim;
		end loop;
		wait;
	end process;

	Delay_Start_Finish_1: Delay_Start_Finish
	port map(
		Clk => clk,
		Reset => Reset,
		Start => Start,
		iCnt_f_out => iCnt_f_out,
		iCnt_p_out => iCnt_p_out,
		Finish => Finish
	);

	process 
	begin
		Reset <= '0';
		Start <= '0';
		wait for 21 ns;
		Reset <= '0';
		Start <= '1';
		wait for 10 ns;
		Start <= '0';
		wait for 150 ns;
		EndOfSim <= true;
		wait;
	end process;
end architecture;