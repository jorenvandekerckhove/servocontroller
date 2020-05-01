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

entity tb_top_level is
end entity;

architecture testbench of tb_top_level is
    signal clk: std_logic;
	signal rst: std_logic;
	signal servo_clk: std_logic;
	signal set: std_logic;
	signal addr_data: std_logic_vector(7 downto 0);
	-- signals for servo controller 1
	signal done_1: std_logic;
	signal pwm_1: std_logic;
	signal Ton_out_1:  natural;
	signal old_Ton_out_1: natural;
	-- signals for servo controller 2
	signal done_2: std_logic;
	signal pwm_2: std_logic;
	signal Ton_out_2: natural;
	signal old_Ton_out_2: natural;
	-- signals for control position
	signal ok_pos_1: std_logic;
	signal ok_pos_2: std_logic;
	-- general signals and constants
	signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 ms;
	constant servoClkPeriod: time := 10 us;

    -- component initialisations begin
	component top_level is
		generic(
			addr_sc_1: std_logic_vector(7 downto 0);
			addr_sc_2: std_logic_vector(7 downto 0)
		);
		port(
			-- signals for servo controllers
			clk: in std_logic;
			rst: in std_logic;
			servo_clk: in std_logic;
			set: in std_logic;
			addr_data: in std_logic_vector(7 downto 0);
			-- signals for servo controller 1
			done_1: out std_logic;
			pwm_1: out std_logic;
			Ton_out_1: out natural;
			old_Ton_out_1: out natural;
			-- signals for servo controller 2
			done_2: out std_logic;
			pwm_2: out std_logic;
			Ton_out_2: out natural;
			old_Ton_out_2: out natural;
			-- signals for control position
			ok_pos_1: out std_logic;
			ok_pos_2: out std_logic
		);
	end component;
    -- component initialisations end
    
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
	
	servo_clock: process
	begin
		servo_clk <= '1';
		loop
		  wait for servoClkPeriod/2;
		  servo_clk <= not servo_clk;
		  wait for servoClkPeriod - servoClkPeriod/2;
		  servo_clk <= not servo_clk;
		  exit when EndOfSim;
		end loop;
		wait;
	end process;

	top_level_1: top_level
	generic map(
		addr_sc_1 => "00000000",
		addr_sc_2 => "00000001"
	)
	port map(
		-- signals for servo controllers
		clk => clk,
		rst => rst,
		servo_clk => servo_clk,
		set => set,
		addr_data => addr_data,
		-- signals for servo controller 1
		done_1 => done_1,
		pwm_1 => pwm_1,
		Ton_out_1 => Ton_out_1,
		old_Ton_out_1 => old_Ton_out_1,
		-- signals for servo controller 2
		done_2 => done_2,
		pwm_2 => pwm_2,
		Ton_out_2 => Ton_out_2,
		old_Ton_out_2 => old_Ton_out_2,
		-- signals for control position
		ok_pos_1 => ok_pos_1,
		ok_pos_2 => ok_pos_2
	);

	process 
	variable servo_data : integer := 0;
	begin
		rst <= '1'; 
		set <= '0';
		addr_data <= "00000000";
		wait for 5 ms;
		rst <= '0';
		wait for 25 ms; -- First the address will be wrong here to show that the data won't be catched by the servocontrollers
		set <= '1';		
		addr_data <= "00000010";
		wait for 10 ms;
		addr_data <= "00000001";
		wait for 10 ms;
		set <= '0';
		addr_data <= "00000000";
		wait for 20 ms; -- The broadcast address will now be set
		set <= '1';		
		addr_data <= "11111111";
		wait for 10 ms;
		addr_data <= "00001000";
		wait for 10 ms;
		set <= '0';
		addr_data <= "00000100";
		wait for 25 ms; -- Change time from to 20 ms to 25 ms to see a different effect
		set <= '1';
		addr_data <= "00000001";
		wait for 10 ms;
		addr_data <= "11111111";
		wait for 10 ms;
		set <= '0';
		addr_data <= "00000000";
		wait for 80 ms;
		EndOfSim <= true;
		wait;
	end process;
end architecture;