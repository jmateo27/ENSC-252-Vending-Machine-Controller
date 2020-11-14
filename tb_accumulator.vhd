library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_accumulator is
end tb_accumulator;

architecture test of tb_accumulator is

	component accumulator is							-- declaring the entity for the accumulator
		port (clk, reset, en: in std_logic;		-- inputting enabling and resetting signals
				N, D,	Q : in std_logic;				-- coin inputs
				accum_out : out unsigned(5 downto 0)); -- outputting accumulated value
	end component;
	
	signal clksig, rstsig, ensig, Nsig, Dsig, Qsig : std_logic;
	signal accum_outsig : unsigned(5 downto 0);
	
begin

	DUT : accumulator
	port map(clksig, rstsig, ensig, Nsig, Dsig, Qsig, accum_outsig);
	
	process is
	
	begin
		
		for C in 0 to 45 loop									-- creating a loop that has 40 clock cycles
			
			ensig <= '1';
			
			if C < 2 or C = 14 or C = 26 then
				rstsig <= '1';
			else
				rstsig <= '0';
			end if;
			
			if (C > 3 and C < 13) then
				Nsig <= '1';
			else
				Nsig <= '0';
			end if;
			
			if (C > 15 and C < 25) then
				Dsig <= '1';
			else
				Dsig <= '0';
			end if;
			
			if (C > 26 and C < 43) then
				Qsig <= '1';
			else
				Qsig <= '0';
			end if;
	
			clksig <= '1';		-- clock is at 1 for 5ns
			wait for 5 ns;		-- then going to 0 for 5ns
			clksig <= '0';		-- clock cycle of 10ns
			wait for 5 ns;		-- duty cycle is 50%
		end loop;
	wait;
	end process;

end test;
