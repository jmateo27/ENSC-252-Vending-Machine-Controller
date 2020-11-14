library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vendsram is														-- creating an eneity for vendsram
	port (clk, rst, en, N, D, Q, wen, rd : in std_logic;		-- declaring inputs and outputs
			prod : in std_logic_vector(1 downto 0);
			price_in : in std_logic_vector(5 downto 0);
			change, insert_out, sramout : out std_logic_vector(5 downto 0);
			done : out std_logic);
end vendsram;

architecture behaviour of vendsram is

component vend_unit is													-- importing the vend unit component
	port (clk, rst, en, N, D, Q : in std_logic;
			price_in : in std_logic_vector(5 downto 0);
			change, insert_out : out std_logic_vector(5 downto 0);
			done : out std_logic);
end component;

component SRAM IS															-- importing the SRAM component
	PORT
	(
		address : in std_logic_vector(1 DOWNTO 0);
		clock : in std_logic := '1';
		data : in std_logic_vector(5 DOWNTO 0);
		rden : in std_logic:= '1';
		wren : in std_logic;
		q : out std_logic_vector(5 DOWNTO 0)
	);
END component;

	signal pricebridge : std_logic_vector(5 downto 0);			-- a shared signal to write to 

begin

	vend : vend_unit 														-- port mapping the vend unit to vendsram
	port map(clk, rst, en, N, D, Q, pricebridge, change, insert_out, done);
	
	mem : SRAM																-- port mapping the SRAM to vendsram as memory unit
	port map(prod, clk, price_in, rd, wen, pricebridge);
	
	sramout <= pricebridge;												-- connecting to the output

end behaviour;																-- ending the architecture
