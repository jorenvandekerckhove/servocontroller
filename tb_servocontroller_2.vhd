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

entity tb_servocontroller is
end entity;

architecture testbench of tb_servocontroller is
    -- signals for servocontroller
	signal clk: std_logic;
	signal rst: std_logic;
	signal servo_clk: std_logic;
	signal set: std_logic;
	signal addr_data: std_logic_vector(7 downto 0);		
	-- signals for servocontroller 1
	signal done1: std_logic;
	signal pwm1: std_logic;
	signal Ton_out1: natural;
	signal old_Ton_out1: natural;
	signal q_data1: std_logic_vector(7 downto 0);
	-- signals for servocontroller 2
	signal done2: std_logic;
	signal pwm2: std_logic;
	signal Ton_out2: natural;
	signal old_Ton_out2: natural;
	signal q_data2: std_logic_vector(7 downto 0);
    -- signals for recreate position
	signal s_servo_pos1: std_logic_vector(7 downto 0);
	signal s_servo_pos2: std_logic_vector(7 downto 0);
    -- signals for control position
	signal s_ok_pos1: std_logic;
	signal s_ok_pos2: std_logic;
    -- general signals and constants
    signal EndOfSim : boolean := false; 
	constant clkPeriod : time := 10 ms;
	constant servoClkPeriod: time := 10 us;

    -- component initialisations begin
	component servocontroller is
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

    component recreate_pos_en is
    port(
        pwm: in std_logic;
		servo_pos : out std_logic_vector(7 downto 0)
    );
    end component;

    component control_pos_en is
    port(
        recr_pos: in std_logic_vector(7 downto 0);
		data_pos : in std_logic_vector(7 downto 0);
		ok_pos: out std_logic
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

	servocontroller_1: servocontroller 
	generic map(addr_sc => "00000000")
	port map (
		clk => clk,
		rst => rst,
		servo_clk => servo_clk,
		set => set,
		addr_data => addr_data,
		done => done1,
		pwm => pwm1,
		Ton_out => Ton_out1,
		old_Ton_out => old_Ton_out1,
		q_data => q_data1
    );
    
    recreate_pos_en_1: recreate_pos_en 
	port map (
		pwm => pwm1,
		servo_pos => s_servo_pos1
    );
    
    control_pos_en_1: control_pos_en 
	port map (
		recr_pos => s_servo_pos1,
		data_pos => q_data1,
		ok_pos => s_ok_pos1
	);
	
	servocontroller_2: servocontroller 
	generic map(addr_sc => "00000001")
	port map (
		clk => clk,
		rst => rst,
		servo_clk => servo_clk,
		set => set,
		addr_data => addr_data,
		done => done2,
		pwm => pwm2,
		Ton_out => Ton_out2,
		old_Ton_out => old_Ton_out2,
		q_data => q_data2
    );
    
    recreate_pos_en_2: recreate_pos_en 
	port map (
		pwm => pwm2,
		servo_pos => s_servo_pos2
    );
    
    control_pos_en_2: control_pos_en 
	port map (
		recr_pos => s_servo_pos2,
		data_pos => q_data2,
		ok_pos => s_ok_pos2
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