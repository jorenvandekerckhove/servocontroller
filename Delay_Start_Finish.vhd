library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Delay module
-- Start on a pulse of 1 clk on Start input
-- for the duration of Delay signal
-- at the end activate the Finish signal for 1 clk cycle
--
-- R.Beuchat
-- hepia/LSN 2016/01
-- Can be used in a state machine to activate delay to pass from one state to the other
-- Needs 3 signals to use it:
-- Start
-- Finish
-- Delay with as many bits as necessary with the clock frequency and the max delay needed
 --
 -- Start
 -- Implementation done with a FSM of 3 states Idle, Run, Finished
 --
entity Delay_Start_Finish is
Port(
    Clk: in std_logic;
    Reset: in std_logic;
    Start: in std_logic;
    iCnt_p_out: out natural;
    iCnt_f_out: out natural;
    Finish: out std_logic
);
end entity Delay_Start_Finish;

architecture bhv of Delay_Start_Finish is

type tSM is(Idle, Run, Finished);
signal iSM_p, iSM_f: tSM;
signal iCnt_p, iCnt_f: natural;
signal Finish_f:  std_logic;

begin
pReg:    -- Synchronous part of the FSM
process(Clk, Reset)
begin
    if Reset = '1' then
        iSM_p <= Idle;
        iCnt_p <= 0;
    elsif rising_edge(Clk) then
        iSM_p <=  iSM_f;
        iCnt_p <= iCnt_f;
        Finish <= Finish_f;
    end if;
end process pReg;

pComb:    -- Combinatorial Process of the state machine and output Finish
process(iSM_p, iCnt_p, Start)
variable Delay: natural := 5;
begin
        iSM_f <= iSM_p;
        iCnt_f <= iCnt_p;
        Finish_f <= '0';
        case iSM_p is
            when  Idle =>    
                if  Start = '1' then
                    iCnt_f <= Delay;
                    iSM_f <= Run;
                end if;
            when Run =>    
                iCnt_f <= iCnt_p - 1;
                if iCnt_p <= 1 then            -- Count from Delay to 1
                    Finish_f <= '1';
                    if Start = '0' then
                        iSM_f <= Idle;        -- Completed, Start desactivated
                    else 
                        iSM_f <= Finished;    -- Start still activated
                    end if;
                end if;
            when Finished =>                                    -- Wait until Start is desactivated
                if Start = '0' then
                    iSM_f <= Idle;
                end if;
            when others => null;
        end case;
        iCnt_f_out <= iCnt_f;
        iCnt_p_out <= iCnt_p;
end process pComb;
end architecture bhv;