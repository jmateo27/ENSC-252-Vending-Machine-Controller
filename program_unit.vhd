library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_unit is										-- declaring our inputs for our program unit
	port (clk, rst, hrst, en, set, N, D, Q : in std_logic;	
			product : in std_logic_vector(1 downto 0);
			addr_out : out std_logic_vector(1 downto 0);
			data_mem : out std_logic_vector(5 downto 0);
			wen, done: out std_logic);
end program_unit;

architecture behaviour of program_unit is
-- Create out cases for the program unit		
	type programstate is (idle, adding, mem_writing, hrststate);
	signal cstate : programstate := idle;			-- signal for our states initialized at idle
	signal res, hard, hdonesig, good : std_logic;-- more signals
	signal haddr : std_logic_vector(1 downto 0);	-- more signals
	signal accumsig : unsigned(5 downto 0);		-- more signals
	
	component accumulator is							--importing the accumulator component
	port (clk, reset, en : in std_logic;
			N, D,	Q : in std_logic;		
			accum_out : out unsigned(5 downto 0));
	end component;
	
	component hrst_state is								-- importing our hrst_state component
	port (clk, go : in std_logic;
			hrstdone : out std_logic;
			addr : out std_logic_vector(1 downto 0));
	end component;

begin
	-- Port Mapping out accumlulator and hrst_state together to produce our program unit with hrst functionality
	acc : accumulator																				
	port map(clk => clk, reset => res, en => good, N => N, D => D, Q => Q, accum_out => accumsig);
	
	hstate : hrst_state
	port map(clk => clk, go => hard, hrstdone => hdonesig, addr => haddr);
	
	res <= '1' when rst = '1' or hrst = '1' or cstate = hrststate else '0'; -- affirming the reset
	
	process(clk, hrst)
	begin
		if hrst = '0' then										-- if hrst is not exerted
			if rising_edge(clk) then
				case cstate is	
					when adding =>									-- setting the current state as adding
					
						if set = '0' then
							cstate <= cstate;						-- we hold our previous state if set is 0
						else --set = '1'
							cstate <= mem_writing;				-- we move onto to mem_writing state if set is 1
						end if;	
						
					when mem_writing =>
					
						cstate <= idle;							-- we write to memory and move to idle state
						
					when others => --idle
					
						if en = '1' then							-- when enable is 1, we go to accumulator state
							cstate <= adding;
						else -- en = '0'
							cstate <= idle;						-- once enable is 0, we stop accumulating and go to idle 
						end if;
						
				end case;
			end if;
		else
			if hdonesig = '1' then								-- if hard reset is done, we go to idle and recommence
				cstate <= idle;
			else
				cstate <= hrststate;								-- if hrst is still asserted, we remain in hrst_state
			end if;
		end if;
	end process;
	
	data_mem <= std_logic_Vector(accumsig) when cstate = adding else "000000";				-- routing the output of accumulator to the output data_mem
	wen <= '1' when (cstate = adding and set = '1') or cstate = hrststate else '0';	-- telling when we can write to SRAM
	addr_out <= haddr when cstate = hrststate else product;	-- associating the product address to the product number
	good <= '1' when cstate = adding and set = '0' else '0'; -- telling when we can have our accumulator add or not
	hard <= '1' when hrst = '1' else '0';				-- we can go to hrststate when hrst is exerted
	done <= '1' when cstate = mem_writing or hdonesig ='1' else '0'; --we output a done if we are in mem_writing state 
																						  -- or we are done with hard reset state
end behaviour;