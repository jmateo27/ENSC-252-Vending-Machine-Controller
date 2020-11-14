library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convert2bcd is
	port (binary : in std_logic_vector(7 downto 0);					-- converting input in binary
			bcd : out std_logic_vector(11 downto 0); 					-- binary coded decimal output
			bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0));	-- splitting values into 3 displays
end convert2bcd;

architecture behaviour of convert2bcd is

	component add3 is															-- importing component add3
		port (A : in std_logic_vector(3 downto 0);					-- in order to perform out bcd compositions
				S : out std_logic_vector(3 downto 0));
	end component;
	
		signal addyin1, addyin2, addyin3, addyin4, addyin5, addyin6 ,addyin7 : std_logic_vector(3 downto 0);		-- input and output signals
		signal addyout1, addyout2, addyout3, addyout4, addyout5, addyout6, addyout7 : std_logic_vector(3 downto 0);
begin

	
-- performing standard calculations given in the lab outline--
	addyin1 <= '0' & binary(7 downto 5);						
	addyin2 <= addyout1(2 downto 0) & binary(4);	
	addyin3 <= addyout2(2 downto 0) & binary(3);
	addyin4 <= '0' & addyout1(3) & addyout2(3) & addyout3(3);
	addyin5 <= addyout3(2 downto 0) & binary(2);
	addyin6 <= addyout4(2 downto 0) & addyout5(3);
	addyin7 <= addyout5(2 downto 0) & binary(1);
-- applying the inputs and outputs of the above calculation to utilize add3 file
		addy1: add3
		port map(addyin1, addyout1);
	
		addy2 : add3
		port map(addyin2, addyout2);
	
		addy3 : add3
		port map(addyin3, addyout3);
	
		addy4 : add3
		port map(addyin4, addyout4);

		addy5 : add3
		port map(addyin5, addyout5);
	
		addy6 : add3
		port map(addyin6, addyout6);

		addy7 : add3
		port map(addyin7, addyout7);
	
-- connecting the outputs of the addr3 with their respective location in vector--
	bcd <= "00" & addyout4(3) & addyout6 & addyout7 & binary(0);
	bcd1 <= "00" & addyout4(3) & addyout6(3);		-- split up the values according to how they should display
	bcd2 <= addyout6(2 downto 0) & addyout7(3);	-- we will later use these values to connect to a segment decoder
	bcd3 <= addyout7(2 downto 0) & binary(0);		-- to connect to out display on the vending machine
	
end behaviour;