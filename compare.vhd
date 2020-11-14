library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compare is																-- declaring the entity compare for out vend unit
	port (accum_in, price : in std_logic_vector(5 downto 0);		-- inputting the accumulator output and product price
			nocoins : in std_logic;											-- 2 other signalling enablers
			donecomp : out std_logic);
end compare;

architecture behaviour of compare is									-- beginning the architecture

	signal aaccum, aprice, changesig : unsigned(5 downto 0);		-- internal signals

begin

	aaccum <= unsigned(accum_in);											-- creating the inputs as unsigned to act on
	aprice <= unsigned(price);

	process(accum_in, nocoins)												-- beginnig the process statement 
	begin
	
	if (aprice <= aaccum) and not (aprice = "000000")then			-- checks to see if our coins inputted are enough
		if (nocoins = '1') then												-- checks if we stop inputting coins
			donecomp <= '1';													-- if so we output the done signal
		else
			donecomp <= '0';													-- if not we wait for the incrementing to stop
		end if;
	else	
		donecomp <= '0';														-- no done is asserted if its not enough money
	end if;
	end process;

end behaviour;