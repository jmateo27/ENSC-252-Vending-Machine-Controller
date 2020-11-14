library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_SRAM is
end tb_SRAM;

architecture test of tb_SRAM is

component SRAM is
	port (address : in std_logic_vector (1 downto 0);
			clock : in std_logic := '1';
			data : in std_logic_vector (5 downto 0);
			rden : in std_logic:= '1';
			wren : in std_logic;
			q : out std_logic_vector (5 downto 0));
end component;

	signal clksig, rdensig, wrensig : std_logic;
	signal addresssig : std_logic_vector(1 downto 0);
	signal datasig, qsig : std_logic_vector(5 downto 0);

begin

	DUT : SRAM
	port map(addresssig, clksig, datasig, rdensig, wrensig, qsig);
	
	process is
	
	begin
		
		for C in 0 to 45 loop									-- creating a loop that has 40 clock cycles
			
			if C = 2 or C = 5 or C = 8 or C = 11 then
				wrensig <= '1';
			else
				wrensig <= '0';
			end if;
			
			if C = 2 then
				datasig <= "100100"; --36
			elsif C = 5 then
				datasig <= "011110"; --30
			elsif C = 8 then 
				datasig <= "000010"; --2
			elsif C = 11 then
				datasig <= "001010"; --10
			else 
				datasig <= "ZZZZZZ";
			end if;
			
			if C = 15 or C = 19 or C = 23 or C = 27 then
				rdensig <= '1';
			else
				rdensig <= '0';
			end if;
			
			if C = 15 or C = 2 then
				addresssig <= "00";
			elsif C = 19 or C = 5 then
				addresssig <= "01";
			elsif C = 23 or C = 8 then
				addresssig <= "10";
			elsif C = 27 or C = 11 then 
				addresssig <= "11";
			else
				addresssig <= "ZZ";
			end if;
			
			clksig <= '1';		-- clock is at 1 for 5ns
			wait for 5 ns;		-- then going to 0 for 5ns
			clksig <= '0';		-- clock cycle of 10ns
			wait for 5 ns;		-- duty cycle is 50%
			
		end loop;
	wait;
	end process;

end test;