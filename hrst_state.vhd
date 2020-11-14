library ieee;
use ieee.stD_logic_1164.all;
use ieee.numeric_std.all;

entity hrst_state is										-- creating the hard reset state to reset everything to 0
	port (clk, go : in std_logic;						-- initialize input clk and go signal
			hrstdone : out std_logic;					-- output to show that we have succesfully latched
			addr : out std_logic_vector(1 downto 0)); -- output of address
end hrst_state;

architecture behaviour of hrst_state is

	type state is (s1, s2, s3, s4, s5);	-- creating the states as each address
	signal cstate : state := s1;			-- internal signal for current state initialized at idle

begin

process(clk)
begin

	if rising_edge(clk) then				-- upon rising edge
		if go = '1' then						-- and our go signal is exerted
			case cstate is
				when s2 =>						-- when is state 2
					addr <= "01";				-- our address is 01
					cstate <= s3;				-- and we move onto state 3
				when s3 =>						-- when in state 3
					addr <= "10";				-- our address is 10
					cstate <= s4;				-- move onto state 4
				when s4 =>						-- when we are in state 4
					addr <= "11";				-- our address is 11
					cstate <= s5;				-- and we move onto next state
				when s5 =>						-- when we are in state 5
					addr <= "00";				-- our address is 00
					cstate <= s1;				-- and we move
				when others => --s1			-- catch all (state 1)
					if go = '1' then
						addr <= "00";				-- address is 00 
						cstate <= s2;				-- we restart in the loop
					else
						cstate <= s1;
					end if;
			end case;
		else
			addr <= "00";						-- if go signal isn't asserted, we stay in 00
			cstate <= s1;						-- and go to our idle state
		end if;
	end if;
end process;

	hrstdone <= '1' when cstate = s5 else '0'; -- we signal done signal once we set all product prices to 0
															 -- if not we don't exert the signal until we cycle through all addresses
end behaviour;