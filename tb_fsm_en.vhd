 -----------------------------------------------------------------------------
 -- File           : tb_fsm_en.vhd
 -----------------------------------------------------------------------------
 -- Description    : testbench for fsm entity
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

entity tb_fsm_en is
end entity;

architecture test of tb_fsm_en is
	signal clk: std_logic;
	signal rst: std_logic;
	signal set: std_logic;
	signal ok_flag: std_logic;	
	signal addr_data: std_logic_vector(7 downto 0);
	signal q_data: std_logic_vector(7 downto 0);
  
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
  
	signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 ns;
	begin
  
	fsm_1: fsm_en 
	generic map(addr_sc => "10011111")
	port map (
		clk => clk,
		rst => rst,
		set => set,
		ok_flag => ok_flag,
		addr_data => addr_data,
		q_data => q_data
	);

	clk_gen: process
	begin
		clk <= '1';
		wait for 10 ms;
		clk <= '0';
		wait for 10 ms;
	end process;

	process 
	begin
		ok_flag <= '1';
		rst <= '1';  
		set <= '0';
		wait for 20 ms;
		addr_data <= "00010011";
		rst <= '0';
		set <= '1';
		wait for 20 ms;
		addr_data <= "10011111";
		wait for 20 ms;
		addr_data <= "00000001";
		ok_flag <= '0';
		wait for 20 ms;
		set <= '0';
		wait for 40 ms;
		ok_flag <= '1';
		wait for 20 ms;
		EndOfSim <= true;
		wait;
	end process;
end architecture;