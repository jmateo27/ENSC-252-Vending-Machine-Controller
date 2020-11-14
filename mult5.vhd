library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult5 is												-- declaring input and output to the multiplier
	port (price : in std_logic_vector(5 downto 0);
			mult : out std_logic_vector(7 downto 0));
end mult5;

architecture behaviour of mult5 is

	signal concat : std_logic_vector(7 downto 0);	-- creating internal signals for calculations
	signal uns : unsigned(7 downto 0);
	signal multiplied : unsigned(7 downto 0);
	
begin

	concat <= "00" & price;									-- concatenate 00 to the beginning of price to make 8 bit
	uns <= unsigned(concat);								-- make the concatenated number to unsigned
	multiplied <= (uns + uns + uns + uns + uns);		-- multiply the value by 5
	mult <= std_logic_vector(multiplied);				-- return to logic vector and output to mult
	
end behaviour;