library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity free_mode is
	port (clk, en : in std_logic;												-- declaring  clock and enabler
			product : in std_logic_vector(1 downto 0);					-- input of product number
			finished : out std_logic;											-- signalling that our free_mode has finished
			addr_out : out std_logic_vector(1 downto 0);					-- outputs the address of our product
			runtot, change, tot : out std_logic_vector(5 downto 0));	-- outputs the values of total, running total and change
end free_mode;

architecture behaviour of free_mode is

	type states is (idle, free, finisher);									-- creating state signals
	signal cstate : states := idle;											-- initializing current state at 0
	signal addrbridge : std_logic_vector(1 downto 0);					-- creating bridge between 2 functions

begin

	addrbridge <= product when cstate = free else "ZZ";				-- if we are in free mode, the product number flows to addrbridge
																						-- that will connect to the address 
	process(clk)
	begin
		if rising_edge(clk) then												-- entering the FSM
			case cstate is													
				when free =>														-- we dont care about outputs of the displays in this state
					runtot <= "ZZZZZZ";
					change <= "ZZZZZZ";
					tot <= "ZZZZZZ";
					cstate <= finisher;											-- signal to the finish state
				when finisher =>
					cstate <= idle;												-- return to idle once we finish signalling
				when idle =>
					if en = '1' then
						cstate <= free;											-- go to the free state when we enable the free mode
					else
						cstate <= idle;											-- we remain in idle if out enable is off
					end if;
			end case;
		else
			cstate <= cstate;														-- stay in current state if we don't have rising edge
		end if;
	end process;
	
	
	addr_out <= addrbridge;														-- address connected to addrbridge
	finished <= '1' when cstate = finisher else '0';					-- we signal finished in its respective state
		
end behaviour;