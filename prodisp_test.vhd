library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prodisp_test is																-- declaring entity for our program_unit and display
	port (clk, start, rst, hrst, en, set, red, N, D, Q : in std_logic;-- declaring inputs
		 	product : in std_logic_vector(1 downto 0);						-- getting product input from user
			addr : out std_logic_vector(1 downto 0);							-- outputting address and done when appropriate
			donedisp, doneprog : out std_logic;									-- outputting further done signals when complete
			price_out : out std_logic_vector(5 downto 0));					-- outputting price accordingly
end prodisp_test;

architecture behaviour of prodisp_test is										-- creating the behaviour architecture

	signal rddisp, rdbridge, wensig : std_logic;								-- completing the read and wen signals
	signal sramout, databridge : std_logic_vector(5 downto 0);			-- completing signals connecting to SRAM
	signal addrbridge : std_logic_vector(1 downto 0);						-- further bridge to connect address
	
	component program_unit is														-- importing the program_unit component
		port (clk, rst, hrst, en, set, N, D, Q : in std_logic;
				product : in std_logic_vector(1 downto 0);
				addr_out : out std_logic_vector(1 downto 0);
				data_mem : out std_logic_vector(5 downto 0);
				wen, done : out std_logic);
	end component;
	
	component SRAM is																	-- importing the SRAM component
		port (address	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
				clock		: IN STD_LOGIC  := '1';
				data		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
				rden		: IN STD_LOGIC  := '1';
				wren		: IN STD_LOGIC ;
				q		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0));
	end component;
	
	component display is																-- importing the display component
		port (clk, start : in std_logic;
				product : in std_logic_vector(1 downto 0);
				arithprice : in std_logic_vector(5 downto 0);
				addr : out std_logic_vector(1 downto 0);
				rd, done : out std_logic;
				price_out : out std_logic_vector(5 downto 0));
	end component;

begin
	--Port mapping our components to their appropriate signals and ports)
	disp : display 
	port map(clk, start, product, sramout, addr, rddisp, donedisp, price_out);
	
	mem : SRAM
	port map(address => addrbridge, clock => clk, data => databridge, rden => rdbridge, wren => wensig, q => sramout);
	
	control : program_unit
	port map(clk, rst, hrst, en, set, N, D, Q, product, addrbridge, databridge, wensig, doneprog);
 
-- doneprog <= '1' when sramout = databridge and not (databridge = "000000") else '0'; -- programming our done signal for program unit
	rdbridge <= '1' when red = '1' or rddisp = '1' else '0';										-- programming our read signal for proper functionality

end behaviour;