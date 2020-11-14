library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_prodisp is		-- creating testbench entity
end tb_prodisp;

architecture test of tb_prodisp is

component prodisp_test is															--importing program_unit display 
	port (clk, start, rst, hrst, en, set, red, N, D, Q : in std_logic;
		 	product : in std_logic_vector(1 downto 0);
			addr : out std_logic_vector(1 downto 0);
			donedisp, doneprog : out std_logic;
			price_out : out std_logic_vector(5 downto 0));
end component;
-- Creating signals to route our testbench to its main unit (prodisp)--
	signal clksig, startsig, rstsig, hrstsig, ensig, setsig, Nsig, Dsig, Qsig, donedispsig, doneprogsig, rdsig : std_logic;
	signal prodsig, addrsig : std_logic_vector(1 downto 0);
	signal price_outsig : std_logic_vector(5 downto 0);
	
begin
-- port mapping prodisp as the device under test--
	DUT : prodisp_test
	port map(clksig, startsig, rstsig, hrstsig, ensig, setsig, rdsig, Nsig, Dsig, Qsig, prodsig, addrsig, donedispsig, doneprogsig, price_outsig);

	process is
	begin

	for C in 0 to 200 loop			-- creating a loop that occurs for 200 cycles (2000ns)
	
		if C < 130 then				-- C<130, we perform regular inputting of coins on different intervals
			if (C > 50 and C < 100) then
				Nsig <= '1';
			else
				Nsig <= '0';
			end if;
			
			if (C > 25 and C < 56) then
				Dsig <= '1';
			else
				Dsig <= '0';
			end if;
			
			if (C > 2 and C < 30) then
				Qsig <= '1';
			else
				Qsig <= '0';
			end if;
			
			if ((C > 0 and C < 6) or (C > 25 and C < 28) or (C > 57 and C < 59) or (C > 81 and C < 84)) then -- programming when to have enable on
				ensig <= '1';
			else
				ensig <= '0';
			end if;
			
			if C < 5 then			-- setting hrst to 1 for first 50ns to clear all past values
				hrstsig <= '1';
			else
				hrstsig <= '0';
			end if;
			
			if C <= 1 then			-- determining which intervals to act on each product number
				prodsig <= "00";
			elsif (C > 1 and C < 26) then
				prodsig <= "10";
			elsif (C >= 26 and C < 57) then
				prodsig <= "11";
			elsif (C >= 57 and C < 81) then
				prodsig <= "00";
			elsif (C >= 81 and C < 111) then
				prodsig <= "01";
			elsif (C >= 120 and C < 122) then	--2 long, right after eachother
				prodsig <= "00";		
			elsif (C >= 122 and C < 124) then	-- checks that all products have been saved
				prodsig <= "01";
			elsif (C >= 124 and C < 126) then	-- so we cycle through each of them for a little
				prodsig <= "10";
			else
				prodsig <= "11";
			end if;
			
			if ((C >= 18 and C < 26) or (C >= 48 and  C < 57) or (C >= 75 and  C < 81) or (C >= 104 and C < 111) or (C >= 120 and C < 127)) then
				rdsig <= '1';		-- interval during which the SRAM reads values from the accumulator
			else 
				rdsig <= '0';
			end if;
			
			if ((C >= 25 and C < 26) or (C >= 56 and  C < 57) or (C >= 80 and C < 81) or (C >= 110 and  C < 111)) then
				rstsig <= '1';		-- activating rst during intervals where we want to reset the value stored in the accumulator
			else
				rstsig <= '0';
			end if;
			
			if ((C >= 14 and C < 16) or (C >= 43 and  C < 45) or (C >= 69 and C < 71) or (C >= 99 and C < 101)) then
				setsig <= '1';		-- selecting intervals which we want to set a certain accum_out to the price of a product
			else
				setsig <= '0';
			end if;
			
		else
		
			if (C >= 140 and  C < 142) then		-- checking the price of product 00 for 20ns
				startsig <= '1';
				prodsig <= "00";
			elsif (C >= 155  and C < 157) then  -- checking the price of product 01 for 20ns
				startsig <= '1';
				prodsig <=  "01";
			elsif (C >= 170 and C < 172) then   -- checking the price of product 10 for 20ns
				startsig <= '1';
				prodsig <=  "10";
			elsif (C >= 185 and C < 187) then   -- checking the price of product 11 for 20ns
				startsig <= '1';
				prodsig <=  "11";
			else 
				startsig <= '0';						-- catch all statement, start=0 so nothing is happening
				prodsig <= "00";
			end if;
		
		end if;
		
		clksig <= '0';									-- creating the clock to be on 1 for 5ns, then on 0 for 5ns
		wait for 5 ns;									-- its a 10ns clock cycle
		clksig <= '1';									-- with duty cycle of 50%
		wait for 5 ns;									
		
		
	end loop;
	
	wait;
	end process;										-- ending process
	
end test;												-- ending our testbench