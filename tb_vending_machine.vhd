library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vending_machine is
end tb_vending_machine;

architecture test of tb_vending_machine is

component hex_display is
    port(
		bcd_in : in std_logic_vector(6 downto 0);
		number : out std.standard.integer
		);
end component;

component vending_machine is
	port (clock, reset, hard_reset, Start, set, N, D, Q : in std_logic;
			funct, prod : in std_logic_vector(1 downto 0);
			change0, change1, change2, runTotal0, runTotal1, runTotal2, total0, total1, total2 : out std_logic_vector(6 downto 0); --SevenSeg outputs
			finished : out std_logic);
end component;

signal sevchange0, sevchange1, sevchange2, sevtot0, sevtot1, sevtot2, sevrtot0, sevrtot1, sevrtot2 : integer := 0;
signal hexchange0, hexchange1, hexchange2, hextot0, hextot1, hextot2, hexrtot0, hexrtot1, hexrtot2 : std_logic_vector(6 downto 0);
signal functsig, prodsig : std_logic_vector(1 downto 0);
signal clocksig, resetsig, hard_resetsig, startsig, setsig, Nsig, Dsig, Qsig, finishedsig : std_logic;

begin

DUT : vending_machine 
port map(clocksig, resetsig, hard_resetsig, startsig, setsig, Nsig, Dsig, Qsig, functsig, prodsig, hexchange0, hexchange1, hexchange2, hexrtot0, hexrtot1, hexrtot2, hextot0, hextot1, hextot2, finishedsig);

change0seg7 : hex_display
port map (bcd_in => hexchange0, number => sevchange0);

change1seg7 : hex_display
port map (bcd_in => hexchange1, number => sevchange1);

change2seg7 : hex_display
port map (bcd_in => hexchange2, number => sevchange2);

tot0seg7 : hex_display
port map (bcd_in => hextot0, number => sevtot0);

tot1seg7 : hex_display
port map (bcd_in => hextot1, number => sevtot1);

tot2seg7 : hex_display
port map (bcd_in => hextot2, number => sevtot2);

rtot0seg7 : hex_display
port map (bcd_in => hexrtot0, number => sevrtot0);

rtot1seg7 : hex_display
port map (bcd_in => hexrtot1, number => sevrtot1);

rtot2seg7 : hex_display
port map (bcd_in => hexrtot2, number => sevrtot2);

process is
	begin

	for C in 0 to 370 loop
			
		--hardreset1, < 80 ns ------------------------------------------------- associated signals : hard_reset
		if C <= 8 then
		
			if C < 5 then 
				hard_resetsig <= '1';
			else
				hard_resetsig <= '0';
			end if;
		
		--program mode, < 1000 ns --------------------------------------------- associated signals : start, funct, product, set, NDQ, reset
		elsif C > 8 and C < 100 then
				
			if C > 8 and C < 10 then --start and funct
				startsig <= '1';
				functsig <= "00";
			elsif C > 20 and C < 22 then
				startsig <= '1';
				functsig <= "00";
			elsif C > 49 and C < 51 then
				startsig <= '1';
				functsig <= "00";
			elsif C > 76 and C < 78 then
				startsig <= '1';
				functsig <= "00";
			else
				startsig <= '0';
				functsig <= "ZZ";
			end if;
			
			if C = 19 or C = 48 or C = 75 or C = 99 then
				resetsig <= '1';
			else
				resetsig <= '0';
			end if;
	
			if C = 18 then
				setsig <= '1';
				prodsig <= "00";
			elsif	C = 47 then
				setsig <= '1';
				prodsig <= "01";
			elsif C = 74 then
				setsig <= '1';
				prodsig <= "10";
			elsif C = 98 then
				setsig <= '1';
				prodsig <= "11";
			else
				setsig <= '0';
				prodsig <= "ZZ";
			end if;
			
			if (C > 10 and C < 20) or (C > 30 and C < 40) or (C > 50 and C < 60) or (C > 90 and C < 100) then --nickels
				Nsig <= '1';
			else
				Nsig <= '0';
			end if;
			
			if (C > 18 and C < 25) or (C > 58 and C < 65) or (C > 78 and C < 85) then -- dimes
				Dsig <= '1';
			else
				Dsig <= '0';
			end if;
		
			if (C > 25 and C < 30) or (C > 85 and C < 91) then -- quarters
				Qsig <= '1';
			else
				Qsig <= '0';
			end if;
		
		--display mode1, < 500 ns ---------------------------------------------- associated signals : start, funct, product
		elsif C >= 100 and C < 150 then
		
			if (C > 105 and C < 107) then --start and funct
				startsig <= '1';
				functsig <= "01";
			elsif	(C > 115 and C < 117) then
				startsig <= '1';
				functsig <= "01";
			elsif(C > 125 and  C < 127) then
				startsig <= '1';
				functsig <= "01";
			elsif(C > 135 and C < 137) then
				startsig <= '1';
				functsig <= "01";
			else
				startsig <= '0';
				functsig <= "ZZ";
			end if;
			
			if (C > 103 and C < 108) then
				prodsig <= "00";
			elsif (C > 113 and C < 118) then
				prodsig <= "11";
			elsif (C > 123 and C < 128) then
				prodsig <= "10";
			elsif (C > 133 and C < 138) then
				prodsig <= "01";
			else
				prodsig <= "ZZ";
			end if;
			
			if C = 149 then
				resetsig <= '1';
			else
				resetsig <= '0';
			end if;
		
		--vending mode, < 1500 ns ---------------------------------------------- associated signals : start, funct, reset, product, NDQ
		elsif C >= 150 and C < 300 then
		
			if C > 152 and C < 154 then
				startsig <= '1';
				functsig <= "10";
			elsif C > 192 and C < 194 then
				startsig <= '1';
				functsig <= "10";
			elsif C > 232 and C < 234 then
				startsig <= '1';
				functsig <= "10";
			elsif C > 272 and C < 274 then
				startsig <= '1';
				functsig <= "10";
			else
				startsig <= '0';
				functsig <= "ZZ";
			end if;
			
			if C > 150 and C < 157 then
				prodsig <= "00";
			elsif C > 190 and C < 197 then
				prodsig <= "01";
			elsif C > 230 and C < 237 then
				prodsig <= "10";
			elsif C > 270 and C < 277 then
				prodsig <= "11";
			else
				prodsig <= "ZZ";
			end if;
			
			if C = 189 or C = 229 or C = 269 then
				resetsig <= '1';
			else
				resetsig <= '0';
			end if;
			
			if (C > 150 and C < 160) or (C > 170 and C < 180) or (C > 190 and C < 200) or (C > 210 and C < 220) or (C > 230 and C < 240) or (C > 250 and C < 259) or (C > 270 and C < 298) then --nickels
				Nsig <= '1';
			else
				Nsig <= '0';
			end if;
			
			if (C > 150 and C < 155) or (C > 166 and C < 180) or (C > 190 and C < 195) or (C > 205 and C < 220) or (C > 230 and C < 238) or (C > 250 and C < 257) or (C > 270 and C < 280) or (C > 295 and C < 298) then -- dimes
				Dsig <= '1';
			else
				Dsig <= '0';
			end if;
		
			if (C > 150 and C < 158) or (C > 168 and C < 180) or (C > 190 and C < 194) or (C > 200 and C < 209) or (C > 214 and C < 220) or (C > 230 and C < 237) or (C > 250 and C < 256) or (C > 270 and C < 274) or (C > 282 and C < 286) then -- quarters
				Qsig <= '1';
			else
				Qsig <= '0';
			end if;
		
		--free mode, ~ 200 ns --------------------------------------------------- associated signals : start, funct, product
		elsif C >= 300 and C < 325 then 
		
			if (C > 300 and C < 302) or (C > 306 and C < 308) or (C > 312 and C < 314) or (C > 318 and C < 320) then
				startsig <= '1';
				functsig <= "11";
			else
				startsig <= '0';
				functsig <= "ZZ";
			end if;
			
			if (C > 300 and C < 303) then
				prodsig <= "00";
			elsif (C > 306 and C < 309) then
				prodsig <= "01";
			elsif (C > 312 and C < 315) then
				prodsig <= "10";
			elsif (C > 318 and C < 321) then
				prodsig <= "11";
			else
				prodsig <= "ZZ";
			end if;
		
		--hardreset2, < 80 ns --------------------------------------------------
		elsif C >= 325 and C < 333 then
		
 			if C > 325 and C < 330 then 
				hard_resetsig <= '1';
			else
				hard_resetsig <= '0';
			end if;		
		
		--display mode2, < 500 ns ----------------------------------------------
		else -- C >=332 and C < 378...
		
			if (C > 334 and C < 336) then --start and funct
				startsig <= '1';
				functsig <= "01";
			elsif	(C > 342 and C < 344) then
				startsig <= '1';
				functsig <= "01";
			elsif(C > 350 and  C < 352) then
				startsig <= '1';
				functsig <= "01";
			elsif(C > 358 and C < 360) then
				startsig <= '1';
				functsig <= "01";
			else
				startsig <= '0';
				functsig <= "ZZ";
			end if;
			
			if (C > 334 and C < 341) then
				prodsig <= "11";
			elsif (C > 342 and C < 349) then
				prodsig <= "00";
			elsif (C > 350 and C < 357) then
				prodsig <= "10";
			elsif (C > 358 and C < 365) then
				prodsig <= "01";
			else
				prodsig <= "ZZ";
			end if;
		
		end if;
		
		clocksig <= '0';
		wait for 5 ns;
		clocksig <= '1';
		wait for 5 ns;
		
	end loop;
	
	wait;
	end process;

end test;