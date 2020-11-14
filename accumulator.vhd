library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is							-- declaring the entity for the accumulator
	port (clk, reset, en: in std_logic;		-- inputting enabling and resetting signals
			N, D,	Q : in std_logic;				-- coin inputs
			accum_out : out unsigned(5 downto 0)); -- outputting accumulated value
end accumulator;

architecture behaviour of accumulator is 
-- we will be interpreting 2.55 as 51, nickels will increment by 1, dimes by 2, quarters by 5
--nickels will be prioritized, then dimes then quarters, we'll make more money
	signal accumulated : unsigned(5 downto 0); -- 2^5 < ceil(log2(51)) < 2^6
	signal NDQe : std_logic_vector(3 downto 0);
	signal coinover: std_logic;
begin

	NDQe <= (N, D, Q, en);
	accumulated <= "000000" 		 when reset = '1' or coinover= '1' else			-- we set to 0 if reset is on
						"110011"  		 when (accumulated >= 51 and rising_edge(clk)) else -- output $2.55 given any accumulation reaching max
						"000000"        when NDQe = "---0" and rising_edge(clk) else 	-- if enable is 0 we are not accumulating
						accumulated + 5 when NDQe = "0011" and rising_edge(clk) else 	-- add 5 if we input a quarter
						accumulated + 2 when NDQe = "0101" and rising_edge(clk) else	-- add 2 if we input a dime
						accumulated + 7 when NDQe = "0111" and rising_edge(clk) else	-- add 7 if we input a dime and quarter
						accumulated + 1 when NDQe = "1001" and rising_edge(clk) else	-- add 1 if we input a nickel
						accumulated + 6 when NDQe = "1011" and rising_edge(clk) else	-- add 6 if we input a nickel and quarter
						accumulated + 3 when NDQe = "1101" and rising_edge(clk) else	-- add 3 if we input a dime and nickel
						accumulated + 8 when NDQe = "1111" and rising_edge(clk) else	-- add 8 if we input one of each coin
						accumulated;																	-- stay in old state if other situations
	coinover <= '1' when accumulated>= 51 and rising_edge(clk) else					-- if we reach a value above 51 we output a coinover since we eat the money
					'0' when coinover='1' and rising_edge(clk);
--	eat<= '1' when eater='1' else 0 when eater='0;
	accum_out <= accumulated;												-- outputting the accumulated value as logic vector

end behaviour;