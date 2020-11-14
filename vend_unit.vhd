library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vend_unit is															-- creating entity for the vend unit
	port (clk, rst, en, N, D, Q : in std_logic;						-- declaring the inputs and outputs		
			price_in : in std_logic_vector(5 downto 0);				-- the input of price from the memory unit
			change, insert_out : out std_logic_vector(5 downto 0);-- the outputs of change and running total
			done : out std_logic);											-- done signal when we complete vending
end vend_unit;

architecture behaviour of vend_unit is

	component accumulator2 is												-- importing the accumulator component
		port (clk, reset, en: in std_logic;			
				N, D,	Q : in std_logic;		
				accum_out : out std_logic_vector(5 downto 0));
	end component;

	component compare is														-- importing the compare component
		port (accum_in, price : in std_logic_vector(5 downto 0);
				nocoins : in std_logic;
				donecomp : out std_logic);
	end component;

	type states is (idle, calculating, convert);						-- creating the FSM states
	signal cstate : states := idle;										-- initialized at idle
	signal cprice, accumbridge, changebridge : std_logic_vector(5 downto 0);	-- various signals routed within
	signal enacc, donesig, noNDQ : std_logic;
	signal NDQ : std_logic_vector(2 downto 0);
	signal aaccum, aprice : unsigned(5 downto 0);
	
begin

	acc : accumulator2							-- port mapping the accumulator within the vend_unit
	port map(clk, rst, enacc, N, D, Q, accumbridge);
	
	comp : compare									-- port mapping the compare withing the vend_unit
	port map(accumbridge, cprice, noNDQ, donesig);
	
	NDQ <= (N, D, Q);								-- concatenating the coins as a string
	noNDQ <= '1' when NDQ = "000" else '0';-- checks whether we have no more inputs or not
	aaccum <= unsigned(accumbridge);			-- making accumulator and price as unsigned to calculate
	aprice <= unsigned(cprice);
	
	process(clk, rst)								-- creating a process
	begin
	
		if rst = '0' then							-- reset takes precedence and is asynchronous 
			if rising_edge(clk) then			-- when we have rising edge
				case cstate is
					when calculating =>			-- in calculating state
					
						if donesig = '1' then	-- checks if we exert donesig
							cstate <= convert;	-- move onto convert state if so
						else
							cstate <= calculating;-- remain in calculating if done is 0
						end if;
						
					when convert =>				-- in converting state
					
						cstate <= idle;			-- we move onto idle state
					
					when others => --idle		-- at idle
					
						if en = '1' then			-- if the circuit is enabled, we begin calculating
							cstate <= calculating;
						else
							cstate <= idle;		-- if the circuit isn't enabled we stay in idle
						end if;
						
				end case;
			else
				cstate <= cstate;					-- if theres no rising edge we maintain past state
			end if;
		else	--rst = '1'
			cstate <= idle;						-- go to idle if reset is asserted
		end if;
	end process;
	
	process(clk, rst)
	begin
		if rst = '0' then							-- rst takes precedence and is asserted asycnchronously
			if rising_edge(clk) then			
				if en = '1' then					-- if enabled we connect change to output
					cprice <= price_in;
				else
					cprice <= cprice;				-- maintain current value if not
				end if;
			else
				cprice <= cprice;					-- maintan current if not on rising edge
			end if;
		else
			cprice <= "000000";					-- the value is set to 0 if rst is enabled
		end if;
	end process;
	
	enacc <= '1' when cstate = calculating else '0';	-- enable accumulator when in calculating state
	done <= '1' when cstate = convert else '0';			-- done is asserted when in convert state
	insert_out <= accumbridge;									-- the running total gets the acummulator output
	change <= std_logic_vector(aaccum - aprice) when cstate = convert else "ZZZZZZ";	-- change is the difference of the 
																												-- price and accumulator output
																												-- and is asserted when in convert state
	
end behaviour;

