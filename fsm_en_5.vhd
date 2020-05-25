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
		q_data: out std_logic_vector(7 downto 0);
		done: out std_logic
		);
end fsm_en;

architecture behavioral of fsm_en is
	type states is (reset_pwm, check_address, run, finished);
	signal currentState, nextState: states;
	signal broadcast_addr: std_logic_vector(7 downto 0) := (others => '1');
	signal iCnt_p, iCnt_f: integer;
	signal t_rise : time := 0 ns;
begin
	sync_proc: process (rst, clk)
	begin
		if (rst = '1') then
			currentState <= reset_pwm;
			iCnt_p <= 0;
		elsif rising_edge (clk) then
			t_rise <= now;
			iCnt_p <= iCnt_f;
			currentState <= nextState;
		end if;
	end process;	
	
	next_state_logic: process (currentState, set, ok_flag, iCnt_p)
	variable delay: integer := 2;
	begin
		iCnt_f <= iCnt_p;
		case currentState is
		when reset_pwm =>
			nextState <= check_address;
		when check_address =>
			if(set = '1' and (addr_data = addr_sc or addr_data = broadcast_addr)) then
				iCnt_f <= delay;
				nextState <= run;
			end if;
		when run =>
			iCnt_f <= iCnt_p - 1;			
		when finished =>
		end case;
	end process;

	register_transfers: process(clk)
	begin
		if(clk'event and clk = '1') then
			case(currentState) is
				when reset_pwm =>
					q_data <= "01111101";
					done <= '0';
				when check_address =>
					if(nextState = send_data and set = '1' and ok_flag = '1' and iCnt_f = 2) then
						q_data <= addr_data;
						done <= '0';
					else
						done <= '1';
					end if;
				when run =>	
					if iCnt_p <= 1 then
						done <= '1';
					end if;				
				when finished =>
			end case;
		end if;
	end process;

end architecture;