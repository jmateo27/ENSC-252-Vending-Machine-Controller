library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine is										-- creating the overall component vending machine
	port (clock, reset, hard_reset, Start, set, N, D, Q : in std_logic;		-- inputs and outputs given in project manual
			funct, prod : in std_logic_vector(1 downto 0);							-- function and product input
			change0, change1, change2, runTotal0, runTotal1, runTotal2, total0, total1, total2 : out std_logic_vector(6 downto 0); --SevenSeg outputs
			finished : out std_logic);														-- outputting the finished once completed each function
end vending_machine;

architecture orange_juice of vending_machine is 		--disclaimer: k = {tot, rtot, change}, i = 1, 2, 3

	component SevenSeg is
		port (D : in std_logic_vector(3 downto 0);  --{k}bcd[i]
			   Y : out std_logic_vector(6 downto 0)); --{j}(i) where j = {total ,runTotal, change}
	end component;

	component convert2bcd is
		port (binary : in std_logic_vector(7 downto 0); --{k}bin5 where k = {tot, rtot, change}
				bcd : out std_logic_vector(11 downto 0); --{k}bcdgnd where k = {tot, rtot, change}
				bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0)); --{k}bcd[i] where i = 1, 2, 3 and k = {tot, rtot, change}
	end component;
	
	component mult5 is
		port (price : in std_logic_vector(5 downto 0); --{k}mult5
				mult : out std_logic_vector(7 downto 0)); --{k}bin5 where k = {tot, rtot, change}
	end component;

	component SRAM is
		port (address : in std_logic_vector(1 downto 0); --addrbridge
				clock : in std_logic := '1';
				data : in std_logic_vector(5 downto 0); --databridge
				rden : in std_logic:= '1'; --rdbridge
				wren : in std_logic;	--wenbridge
				q : out std_logic_vector(5 downto 0)); --sramout
	end component;

	component program_unit is
		port (clk, rst, hrst, en, set, N, D, Q : in std_logic; -- enprog
				product : in std_logic_vector(1 downto 0); --prod
				addr_out : out std_logic_vector(1 downto 0); -- addrprog
				data_mem : out std_logic_vector(5 downto 0); -- databridge
				wen, done : out std_logic); --wenbridge, doneprog
	end component;
	
	component display is											
		port (clk, start : in std_logic;
				product : in std_logic_vector(1 downto 0);
				arithprice : in std_logic_vector(5 downto 0);
				addr : out std_logic_vector(1 downto 0);
				rd, done : out std_logic;
				price_out : out std_logic_vector(5 downto 0));
	end component;

	component vend_unit is
		port (clk, rst, en, N, D, Q : in std_logic; --envend
				price_in : in std_logic_vector(5 downto 0); --sramout
				change, insert_out : out std_logic_vector(5 downto 0); -- vendchange, vendrtot
				done : out std_logic); --donevend
	end component;

	component free_mode is
		port (clk, en : in std_logic; --enfree
				product : in std_logic_vector(1 downto 0); --prod
				finished : out std_logic; -- donefree
				addr_out : out std_logic_vector(1 downto 0); --addrgnd
				runtot, change, tot : out std_logic_vector(5 downto 0)); -- freertot, freechange, freetot
	end component;

	type states is (idle, hardReset, program, displaying, vend, free);	-- declaring the states for our vending machine FSM
	signal cstate : states := idle;												-- intialized at idle
	type dispstates is (one, two, three);										-- declaring display state
	signal dispstate : dispstates := one;										-- initialized at idle
	type vendstates is (first, second, third);											-- declaring display state
	signal vendstate : vendstates := first;										-- initialized at idle
	
	signal changebcdgnd, totbcdgnd, rtotbcdgnd : std_logic_vector(11 downto 0);	-- creating grounded signals 
	signal totbin5, rtotbin5, changebin5 : std_logic_vector(7 downto 0);				
	signal sramout, databridge, vendchange, vendrtot, totmult5, rtotmult5, changemult5, freertot, freechange, freetot, price_outdisp : std_logic_vector(5 downto 0);
	signal totbcd1, totbcd2, totbcd3, rtotbcd1, rtotbcd2, rtotbcd3, changebcd1, changebcd2, changebcd3 : std_logic_vector(3 downto 0);
	signal addrbridge, addrprog, addrdisp, addrgnd : std_logic_vector(1 downto 0);
	signal rdbridge, wenbridge, enprog, doneprog, envend, donevend, enfree, donefree ,endisp, donedisp, enidle, rddisp : std_logic;
	
begin
-- port mapping the change to the sevenseg--
	SSchange1 : SevenSeg
	port map(changebcd1, change0);
	
	SSchange2 : SevenSeg
	port map(changebcd2, change1);
	
	SSchange3 : SevenSeg
	port map(changebcd3, change2);
-- port mapping the total to the sevenseg--
	SStot1 : SevenSeg
	port map(totbcd1, total0);
	
	SStot2 : SevenSeg
	port map(totbcd2, total1);
	
	SStot3 : SevenSeg
	port map(totbcd3, total2);
	
-- port mapping the runningtotal to sevenseg;
	SSrtot1 : SevenSeg
	port map(rtotbcd1, runTotal0);
	
	SSrtot2 : SevenSeg
	port map(rtotbcd2, runTotal1);
	
	SSrtot3 : SevenSeg
	port map(rtotbcd3, runTotal2);
	
-- port mapping the change to convert2bcd--
	changeconvert : convert2bcd
	port map(changebin5, changebcdgnd, changebcd1, changebcd2, changebcd3);
	
-- port mapping the total to convert2bcd--
	totconvert : convert2bcd
	port map(totbin5, totbcdgnd, totbcd1, totbcd2, totbcd3);

-- port mapping the runtotal to convert2bcd--
	rtotconvert : convert2bcd
	port map(rtotbin5, rtotbcdgnd, rtotbcd1, rtotbcd2, rtotbcd3);
	
-- connecting change to the muliplier
	change5 : mult5
	port map(changemult5, changebin5);
	
-- connecting total to the multiplier
	tot5 : mult5
	port map(totmult5, totbin5);
	
-- connecting runtotal to the multiplier
	rtot5 : mult5
	port map(rtotmult5, rtotbin5);
	
-- port mapping in the SRAM
	mem : SRAM 
	port map(addrbridge, clock, databridge, rdbridge, wenbridge, sramout);
	
-- port mapping in the program_unit
	prog : program_unit
	port map(clock, reset, hard_reset, enprog, set, N, D, Q, prod, addrprog, databridge, wenbridge, doneprog);
	
	disp : display 
	port map(clock, endisp, prod, sramout, addrdisp, rddisp, donedisp, price_outdisp);
	
-- port mapping in the vend_unit
	vendy : vend_unit
	port map(clock, reset, envend, N, D, Q, sramout, vendchange, vendrtot, donevend);
	
-- port mapping in the free_mode
	freee : free_mode
	port map(clock, enfree, prod, donefree, addrgnd, freertot, freechange, freetot);
	
-- connecting the addrbridge to the selector
	addrbridge <= addrprog when cstate = program or cstate = hardReset else prod;
	
-- setting the read bridge at 1
--	rdbridge <= '1';
	
-- connecting the done diplay to selector of display fsm
--	donedisp <= '1' when dispstate = three else '0';
	
-- defining when finished
	finished <= '1' when (donedisp = '1' and dispstate = two) or (donevend = '1' and vendstate = third) or doneprog = '1' or donefree = '1' else '0';

--	states are idle, hardReset, program, display, vend, free
	
	process(clock, hard_reset)
	begin
	
		if hard_reset = '0' then		-- hard reset is asynchronous and prioritized
			if reset = '0' then
				if rising_edge(clock) then
					case cstate is				-- on rising edge we shuffle between the FSM
						when hardReset =>				-- in hardReset mode
						
							if doneprog = '1' then	-- if done is asserted
								cstate <= idle;		-- we return to idle
							else
								cstate <= cstate;		-- if not we stay in hardReset
							end if;
							
						when program =>				-- in program mode
						
							if doneprog = '1' then	-- if we're done programming
								cstate <= idle;		-- we return to idle
							else
								cstate <= cstate;		-- if not we remain in the program state
							end if;
							
						when displaying =>				-- in display mode 	signal dispstate : dispstates := one;
							case dispstate is
								when two =>
									endisp <= '1';
									if donedisp = '1' then
										cstate <= idle;
										dispstate <= one;
									else
										cstate <= cstate;
										dispstate <= dispstate;
									end if;
								when others =>
									endisp <= '0';
									dispstate <= two;
									cstate <= cstate;
							end case;
							
						when vend =>					-- in vending mode
							
							case vendstate is
								when second =>
									envend <= '1';
									cstate <= cstate;
									vendstate <= third;
								when third =>
									envend <= '0';
									if donevend = '1' then
										cstate <= idle;
										vendstate <= first;
									else
										cstate <= cstate;
									end if;
								when others =>
									vendstate <= second;
									envend <= '0';
									cstate <= cstate;
							end case;
							
						when free =>					-- in free mode
						
							if donefree = '1' then	-- if we are done dispensing the product
								cstate <= idle;		-- we return to idle state
							else
								cstate <= cstate;		-- we remain in free mode until we dispense the product
							end if;
						
						when others =>-- idle		
							envend <= '0';									-- in idle state we can go to any state depending on the function
							if start = '1' then			-- if start is asserted
								if funct = "00" then		-- we go to program mode on function 00
									cstate <= program;
								elsif funct = "01" then -- we go to display mode on function 01
									cstate <= displaying;
								elsif funct = "10" then	-- we go to vending mode on function 10
									cstate <= vend;
								elsif funct = "11" then	-- we go to free mode on function 11
									cstate <= free;
								else
									cstate <= cstate;		-- remain in idle if function isn't asserted
								end if;
							else
								cstate <= cstate;			-- stay in idle unless start is asserted
							end if;
					
					end case;
				else
					cstate <= cstate;						-- if not on rising edge we maintain our previous state
					dispstate <= dispstate;
					vendstate <= vendstate;
				end if;
			else --reset = '1'
				cstate <= idle;
				dispstate <= one;
				vendstate <= first;
			end if;
		else
			cstate <= hardReset;						-- reset our values in hard reset mode
			dispstate <= one;							-- and out display buffer state is in idle (one)
			vendstate <= first;
		end if;
	
	end process;
	
	process(clock) --enables					-- controlling the various enable signals
	begin
		if rising_edge(clock) then
			case cstate is
				when idle =>						-- control which enable signal should be asserted
					if start = '1' then
						if funct = "00" then		-- in programming mode, the enprog signal is asserted
							enprog <= '1';
						elsif funct = "11" then	-- in free mode, the enfree signal is asserted
							enfree <= '1';
						else
							enidle <= '1';			-- for others we are enabling the idle
						end if;
					end if;					
				when others =>
					enprog <= '0';					-- in all other states, the enable signals are 0
					enfree <= '0';
					enidle <= '0';
			end case;
		end if;
	end process;
	
	process(clock) --change					-- creating our fsm for output of change
	begin
		if rising_edge(clock) then
			case cstate is
			
				when vend =>					-- in vending mode the vending change is asserted to multiplier
					changemult5 <= vendchange;
				when free =>
					changemult5 <= freechange; -- in free mode the free change is asserted to multiplier
				when others =>
					changemult5 <= "000000";	-- for all else we send "000000"
					
			end case;
		end if;
	end process;
	
	process(clock) --tot						-- creating our fsm for output of total
	begin
		if rising_edge(clock) then
			case cstate is
			
				when displaying =>
					case dispstate is
						when two =>
							if donedisp = '1' then
								totmult5 <= price_outdisp;
							else
								totmult5 <= "000000";
							end if;
						when others =>
							totmult5 <= "000000";
					end case;
				when free =>
					totmult5 <= freetot;
				when others =>
					totmult5 <= "000000";
					
			end case;
		end if;
	end process;
	
	process(clock) --rtot					-- creating our fsm for output running total
	begin
		if rising_edge(clock) then
			case cstate is
			
				when vend =>					--in vend mode the vendrtot can go to the multiplier
					rtotmult5 <= vendrtot;
				when program =>
					rtotmult5 <= databridge;-- in program mode the output can go to the multiplier
				when free =>
					rtotmult5 <= freertot;	-- in free mode the freertot can go to its multiplier
				when others =>
					rtotmult5 <= "000000";  -- in all other states we send 000000 to the multiplier
					
			end case;
		end if;
	end process;
	
	process(clock) --read
	begin
	
		if rising_edge(clock) then
			if start = '1' then 
				case funct is
					when "00" =>
						rdbridge <= '0';
					when "01" =>
						rdbridge <= '1';
					when "10" =>
						rdbridge <= '1';
					when "11" =>
						rdbridge <= '0';
					when others =>
						rdbridge <= '0';
				end case;
			else
				rdbridge <= '0';
			end if;

		else
			rdbridge <= rdbridge;
		end if;
	
	end process;
	
end orange_juice;