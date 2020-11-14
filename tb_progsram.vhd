library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_progsram is							-- declaring entity for the testbench
end tb_progsram;

architecture test of tb_progsram is			-- developping the testing architecture
		
	component progsram_test is					-- importing the component from progsram_test
	port (clk, rst, hrst, set, en, N, D, Q, rd : in std_logic;
			product : in std_logic_vector(1 downto 0);
			data_mem, stored_mem : out std_logic_vector(5 downto 0);
			addr_out : out std_logic_vector(1 downto 0);
			done, wen : out std_logic);
	end component;
-- declaring necessary signals needed to be specified in order to test--
	signal clksig, rstsig, hrstsig, ensig, setsig, Nsig, Dsig, Qsig, donesig, wensig, rdsig : std_logic;
	signal prodsig, addrsig : std_logic_vector(1 downto 0);
	signal data_memsig, stored_memsig : std_logic_vector(5 downto 0);
	
begin
	-- Port Mapping the progsram to its respective signals to be tested
	DUT : progsram_test	
	port map(clksig, rstsig, hrstsig, setsig, ensig, Nsig, Dsig, Qsig, rdsig, prodsig, data_memsig, stored_memsig, addrsig, donesig, wensig);

	process is
	begin

	for C in 0 to 130 loop	-- developping our loop to occur for 130 cycles
	
		if (C > 50 and C < 100) then -- stating when to apply nickel inputs
			Nsig <= '1';
		else
			Nsig <= '0';
		end if;
		
		if (C > 25 and C < 56) then -- stating when to apply dime inputs
			Dsig <= '1';
		else
			Dsig <= '0';
		end if;
		
		if (C > 2 and C < 30) then -- stating when to apply quarter inputs
			Qsig <= '1';				
		else
			Qsig <= '0';
		end if;
		
		if ((C > 0 and C < 6) or (C > 25 and C < 28) or (C > 57 and C < 59) or (C > 81 and C < 84)) then
			ensig <= '1';			-- stating which intervals to set enable=1
		else
			ensig <= '0';			-- stating which intervals to set enable=0
		end if;
		
		if C < 5 then				-- starting our simulation with a hrst to clar out any possible data that could clash
			hrstsig <= '1';
		else
			hrstsig <= '0';
		end if;
		
		if C <= 1 then				-- declaring which cycles we want which products
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
		elsif (C >= 122 and C < 124) then  -- testing to see if we properly applied the prices
			prodsig <= "01";
		elsif (C >= 124 and C < 126) then  -- so we apply the spurt of products to ensure correctness
			prodsig <= "10";
		else
			prodsig <= "11";
		end if;
		
		if ((C >= 18 and C < 26) or (C >= 48 and  C < 57) or (C >= 75 and  C < 81) or (C >= 104 and C < 111) or (C >= 120 and C < 127)) then
			rdsig <= '1';				-- stating when we want the read signal to be exerted and allow the SRAM to read outputs from accum_out
		else 
			rdsig <= '0';
		end if;
		
		if ((C >= 25 and C < 26) or (C >= 56 and  C < 57) or (C >= 80 and C < 81) or (C >= 110 and  C < 111)) then
			rstsig <= '1';				-- stating clock intervals we want to reset the value accumulated in our accumulator
		else
			rstsig <= '0';
		end if;
		
		if ((C >= 14 and C < 16) or (C >= 43 and  C < 45) or (C >= 69 and C < 71) or (C >= 99 and C < 101)) then
			setsig <= '1';				-- stating when we want to set our value in the accumulator as the product price
		else
			setsig <= '0';
		end if; 
		
		clksig <= '0';					-- creating our clock to be on 0 for 5ns then hit 1 for 5ns
		wait for 5 ns;					-- means that we have a clock cycle of 10ns
		clksig <= '1';					-- with a duty cycle of 50%
		wait for 5 ns;
		
		
	end loop;
	
	wait;
	end process;						-- ending the process, and testbench architecture
	
end test;