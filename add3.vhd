library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add3 is													-- creating an add3 file to be used in the bcd converter
	port (A : in std_logic_vector(3 downto 0);		-- declaring inputs and outputs
			S : out std_logic_vector(3 downto 0)
			);
end add3;

architecture behaviour of add3 is						-- beginning the architecture for the file


begin
-- performing the calculations as outlined in the project outline--
	S(3) <= (A(3) or (A(2) and A(0)) or (A(2) and A(1)));	
	S(2) <= ((A(3) and A(0)) or (A(2) and not A(1) and not A(0)));
	S(1) <= ((A(3) and not A(0)) or (not A(2) and A(1)) or (A(1) and A(0)));
	S(0) <= ((A(3) and not A(0)) or (not A(3) and not A(2) and A(0)) or (A(2) and A(1) and not A(0)));

end behaviour;