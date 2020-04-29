 -----------------------------------------------------------------------------
 -- File           : fsm_en.vhd
 -----------------------------------------------------------------------------
 -- Description    : fsm entity
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
 
 entity fsm_en is
	 generic(addr_sc: std_logic_vector(7 downto 0));
	 port(
		 clk: in std_logic;
		 rst: in std_logic;
		 set: in std_logic;
		 ok_flag: in std_logic;
		 addr_data: in std_logic_vector(7 downto 0);
		 q_data: out std_logic_vector(7 downto 0)
		 );
 end fsm_en;
 
 architecture behavioral of fsm_en is
	 type states is (check_address, reset_pwm, wait_for_done);
	 signal currentState, nextState: states;
	 signal broadcast_addr: std_logic_vector(7 downto 0) := (others => '1');
 begin
	 sync_proc: process (rst, clk)
	 begin
		 if (rst = '1') then
		   currentState <= reset_pwm;
		 elsif rising_edge (clk) then
		   currentState <= nextState;
		 end if;
	 end process;	
	 
	 next_state_logic: process (currentState, set, ok_flag)
	 begin
		 case currentState is
		 when reset_pwm =>
			 nextState <= check_address;
		 when check_address =>
			 if(set = '1' and ok_flag = '1' and (addr_data = addr_sc or addr_data = broadcast_addr)) then
				 nextState <= wait_for_done;
			 else
				 nextState <= check_address;
			 end if;
		 when wait_for_done =>
			 if(set = '0' and ok_flag = '1') then
				 nextState <= check_address;
			 else
				 nextState <= wait_for_done;
			 end if;
		 end case;
	 end process;
 
	 register_transfers: process(clk)
	 begin
		 if(clk'event and clk = '1') then
			 case(currentState) is
				 when reset_pwm =>
					 q_data <= "01111101";
				 when check_address =>
					 if(nextState = wait_for_done and set = '1' and ok_flag = '1') then
						 q_data <= addr_data;
					 end if;
				 when wait_for_done =>
			 end case;
		 end if;
	 end process;
 
 end architecture;