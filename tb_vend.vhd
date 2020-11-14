library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vend is																		-- creating a testbench entity for the vend unit
end tb_vend;

architecture test of tb_vend is

component vendsram is																-- importing the vend with sram component
	port (clk, rst, en, N, D, Q, wen, rd : in std_logic;
			prod : in std_logic_vector(1 downto 0);
			price_in : in std_logic_vector(5 downto 0);
			change, insert_out, sramout : out std_logic_vector(5 downto 0);
			done : out std_logic);
end component;

	signal clksig, rstsig, ensig, Nsig, Dsig, Qsig, wensig, rdsig, donesig : std_logic;				-- creating internals signals to 
	signal prodsig : std_logic_vector(1 downto 0);																-- route between the component and tb
	signal price_insig, changesig, insert_outsig, sramoutsig : std_logic_vector(5 downto 0);

begin

	DUT : vendsram 						-- setting the vendsram as the device under test and port mapping it
	port map(clksig, rstsig, ensig, Nsig, Dsig, Qsig, wensig, rdsig, prodsig, price_insig, changesig, insert_outsig, sramoutsig, donesig);
	
	process is
	
	begin
		
		for C in 0 to 120 loop									-- creating a loop that has 120 clock cycles
			if C < 30 then 										--initializing sram values
			
				if C < 3 then										-- setting where we reset the value
					rstsig <= '1';
				else
					rstsig <= '0';
				end if;
	-- inputting product prices into the SRAM
				if (C > 4 and C < 7) then						-- inputting price for product 0 as $1.90
					wensig <= '1';
					prodsig <= "00";
					price_insig <= "100010"; --34		
				elsif (C > 8 and C < 11 ) then				-- inputting price for product 1 as $1.75
					wensig <= '1';
					prodsig <= "01";
					price_insig <= "011111"; --31
				elsif (C > 12 and C < 15) then				-- inputting price for product 2 as $0.20
					wensig <= '1';
					prodsig <= "10";
					price_insig <= "000100"; --4
				elsif (C > 16 and C < 19) then				-- inputting price for product 3 as $0.45
					wensig <= '1';
					prodsig <= "11";
					price_insig <= "001001"; --9
				else													-- all else are 0
					wensig <= '0';
					prodsig <= "ZZ";
					price_insig <= "000000";
				end if;
				
			else --vend functionality
			
				if C = 32 or C = 58 or C = 81 or C = 92 then	-- setting regions where reset is asserted
					rstsig <= '1';
				else
					rstsig <= '0';
				end if;
				
				if C > 34 and C < 38 then							-- beginning with product 0
					prodsig <= "00";
					rdsig <= '1';
				elsif C > 59 and C < 63 then						-- followed by product 1
					prodsig <= "01";
					rdsig <= '1';
				elsif C > 82 and C < 86 then						-- followed by product 2
					prodsig <= "10";
					rdsig <= '1';
				elsif C > 93 and C < 97 then						-- finally product 3
					prodsig <= "11";
					rdsig <= '1';
				else
					prodsig <= "ZZ";
					rdsig <= 'Z';
				end if;
				
				if C = 37 or C = 62 or C = 85 or C = 96 then	-- we enable the vend to work on these intervals
					ensig <= '1';
				else
					ensig <= '0';
				end if;
	-- inputting the coin values at different time intervals--
				if (C > 37 and C < 43) or (C > 49 and C < 57) or (C > 61 and C < 66) or (C > 69 and C < 78) or (C > 84 and C < 90) or (C > 96 and C < 105) then
					Nsig <= '1';
				else
					Nsig <= '0';
				end if;
				
				if (C > 38 and C < 42) or (C > 43 and C < 52) or (C > 62 and C < 69) or (C > 72 and C < 79) or (C > 97 and C < 102) then
					Dsig <= '1';
				else
					Dsig <= '0';
				end if;
				
				if (C > 39 and C < 46) or (C > 48 and C < 51) or (C > 63 and C < 68) or (C > 73 and C < 79) or (C > 99 and C < 101) then
					Qsig <= '1';
				else
					Qsig <= '0';
				end if;
			
			end if;
	
			clksig <= '1';		-- clock is at 1 for 5ns
			wait for 5 ns;		-- then going to 0 for 5ns
			clksig <= '0';		-- clock cycle of 10ns
			wait for 5 ns;		-- duty cycle is 50%
		end loop;
	wait;
	end process;

end test;						-- ending the testbench