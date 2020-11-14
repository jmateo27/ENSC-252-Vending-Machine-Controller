library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity progsram_test is
	port (clk, rst, hrst, set, en, N, D, Q, rd : in std_logic;	-- declaring our inputs
			product : in std_logic_vector(1 downto 0);				-- input: product number
			data_mem, stored_mem : out std_logic_vector(5 downto 0); --output of program unit and sram
			addr_out : out std_logic_vector(1 downto 0);				-- output: address of our product
			done, wen : out std_logic);									-- done: tells us we successfully written
end progsram_test;															-- wen: tells us that we have allowed SRAM into writing data

architecture behaviour of progsram_test is

	signal addrbridge : std_logic_vector(1 downto 0);				-- address bridge between components
	signal databridge, sramout : std_logic_vector(5 downto 0);	-- bridges data output from program unit to input of SRAM
	signal wensig : std_logic;												-- wen signal to input of sram
	
	component SRAM IS															-- importing the SRAM component
	PORT	
	(
		address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
	);
	end component;

	component program_unit is												--importing the program_unit component
	port (clk, rst, hrst, en, set, N, D, Q : in std_logic;
			product : in std_logic_vector(1 downto 0);
			addr_out  : out std_logic_vector(1 downto 0);
			data_mem : out std_logic_vector(5 downto 0);
			wen, done : out std_logic);
	end component;
	
begin
	-- Port Mapping our components to their respective signals, inputs and outputs--
	mem : SRAM
	port map(address => addrbridge, clock => clk, data => databridge, rden => rd, wren => wensig, q => sramout);
	
	control : program_unit
	port map(clk, rst, hrst, en, set, N, D, Q, product, addrbridge, databridge, wensig, done);
	
-- done <= '1' when sramout = databridge and not (databridge = "000000") else '0'; --*ignore cases when clear*
	wen <= wensig;																						  -- connecting our signal to its output
	addr_out <= addrbridge;																			  -- connecting our signal to its output
	data_mem <= databridge;																			  -- connecting our signal to its output
	stored_mem <= sramout;												-- connecting our SRAM output to output of the progsram output
	
end behaviour;