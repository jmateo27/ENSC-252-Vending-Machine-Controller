library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator2 is
	port (clk, reset, en: in std_logic;			
			N, D,	Q : in std_logic;		
			accum_out : out std_logic_vector(5 downto 0));
end accumulator2;

architecture behaviour of accumulator2 is 
-- we will be interpreting 2.55 as 51, nickels will increment by 1, dimes by 2, quarters by 5
--nickels will be prioritized, then dimes then quarters, we'll make more money
	signal accumulated : unsigned(5 downto 0); -- 2^5 < ceil(log2(51)) < 2^6
	signal NDQe : std_logic_vector(3 downto 0);
	signal coinover: std_logic;
begin

	NDQe <= (N, D, Q, en);
	accumulated <= "000000" 		 when reset = '1' or coinover= '1' else
						"110011"  		 when (accumulated >= 51 and rising_edge(clk)) else
						"000000"        when NDQe = "---0" and rising_edge(clk) else 	--
						accumulated + 5 when NDQe = "0011" and rising_edge(clk) else 
						accumulated + 2 when NDQe = "0101" and rising_edge(clk) else
						accumulated + 7 when NDQe = "0111" and rising_edge(clk) else
						accumulated + 1 when NDQe = "1001" and rising_edge(clk) else
						accumulated + 6 when NDQe = "1011" and rising_edge(clk) else
						accumulated + 3 when NDQe = "1101" and rising_edge(clk) else
						accumulated + 8 when NDQe = "1111" and rising_edge(clk) else						
						accumulated;
	coinover <= '1' when accumulated>= 51 and rising_edge(clk) else
					'0' when coinover='1' and rising_edge(clk);
--	eat<= '1' when eater='1' else 0 when eater='0;
	accum_out <= std_logic_vector(accumulated);

end behaviour;