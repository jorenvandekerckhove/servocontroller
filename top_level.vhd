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

    entity top_level is
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
    end top_level;

    architecture structural of top_level is
    signal s_done: std_logic;
    signal s_data: std_logic_vector(7 downto 0);
    -- signals for recreate position
	signal s_servo_pos1: std_logic_vector(7 downto 0);
    signal s_servo_pos2: std_logic_vector(7 downto 0);
    
    component servocontroller is
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

    -- signals for servocontroller 1
    signal q_data_1: std_logic_vector(7 downto 0);
    signal s_pwm_1: std_logic;
    -- signals for servocontroller 2
    signal q_data_2: std_logic_vector(7 downto 0);
    signal s_pwm_2: std_logic;
    -- signals for recreate position
    signal s_servo_pos_1: std_logic_vector(7 downto 0);
    signal s_servo_pos_2: std_logic_vector(7 downto 0);

    begin        
        servocontroller_1: servocontroller 
        generic map(addr_sc => addr_sc_1)
        port map (
            clk => clk,
            rst => rst,
            servo_clk => servo_clk,
            set => set,
            addr_data => addr_data,
            done => done_1,
            pwm => s_pwm_1,
            Ton_out => Ton_out_1,
            old_Ton_out => old_Ton_out_1,
            q_data => q_data_1
        );

        recreate_pos_en_1: recreate_pos_en 
        port map (
            pwm => s_pwm_1,
            servo_pos => s_servo_pos_1
        );
        
        control_pos_en_1: control_pos_en 
        port map (
            recr_pos => s_servo_pos_1,
            data_pos => q_data_1,
            ok_pos => ok_pos_1
        );

        servocontroller_2: servocontroller 
        generic map(addr_sc => addr_sc_2)
        port map (
            clk => clk,
            rst => rst,
            servo_clk => servo_clk,
            set => set,
            addr_data => addr_data,
            done => done_2,
            pwm => s_pwm_2,
            Ton_out => Ton_out_2,
            old_Ton_out => old_Ton_out_2,
            q_data => q_data_2
        );
        
        recreate_pos_en_2: recreate_pos_en 
        port map (
            pwm => s_pwm_2,
            servo_pos => s_servo_pos_2
        );
        
        control_pos_en_2: control_pos_en 
        port map (
            recr_pos => s_servo_pos_2,
            data_pos => q_data_2,
            ok_pos => ok_pos_2
        );

        pwm_1 <= s_pwm_1;
        pwm_2 <= s_pwm_2;
    end architecture;