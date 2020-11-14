LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY SevenSeg IS							-- creating the entity for sevenseg decoder
	Port(
		D : in std_logic_vector(3 downto 0);
		Y : out std_logic_vector(6 downto 0)
		);
END SevenSeg;

Architecture Behaviour OF SevenSeg IS
BEGIN

Process(D)			-- creating a case statement
Begin 
	case D is
		when "0000" =>				-- converting the values into the hex values need for the display to read
			Y <= "1000000";
		when "0001" =>
			Y <= "1111001";		-- we are doing it in active low logic, meaning that LED illuminate on 0's
		when "0010" =>
			Y <= "0100100";		-- we have tested our decoder to go from 0 to 9 which is the limiter on out hex_display
		when "0011" =>
			Y <= "0110000";
		when "0100" =>
			Y <= "0011001";
		when "0101" =>
			Y <= "0010010";
		when "0110" =>
			Y <= "0000010";
		when "0111" =>
			Y <= "1111000";
		when "1000" =>
			Y <= "0000000";
		when "1001" =>
			Y <= "0011000";
		when others =>
			Y <= "1111111";
	end case;
end process;
END Behaviour;