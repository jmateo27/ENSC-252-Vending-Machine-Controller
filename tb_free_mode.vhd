library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_free_mode is
end tb_free_mode;

architecture test of tb_free_mode is

component free_mode is
	port (clk, en : in std_logic;												-- declaring  clock and enabler
			product : in std_logic_vector(1 downto 0);					-- input of product number
			finished : out std_logic;											-- signalling that our free_mode has finished
			addr_out : out std_logic_vector(1 downto 0);					-- outputs the address of our product
			runtot, change, tot : out std_logic_vector(5 downto 0));	-- outputs the values of total, running total and change
end component;

	signal clksig, ensig, finishedsig : std_logic;
	signal productsig, addr_outsig : std_logic_vector(1 downto 0);
	signal runtotsig, changesig, totsig : std_logic_vector(5 downto 0);

begin

	DUT : free_mode
	port map(clksig, ensig, productsig, finishedsig, addr_outsig, runtotsig, changesig, totsig);
	
	process is
	
	begin
		
		for C in 0 to 20 loop									-- creating a loop that has 20 clock cycles
			
			if C = 1 or C = 6 or C = 11 or C = 16 then
				ensig <= '1';
			else
				ensig <= '0';
			end if;
			
			if C >= 1 and C < 6 then
				productsig <= "00";
			elsif C >= 6 and C < 11 then
				productsig <= "01";
			elsif C >= 11 and C < 16 then
				productsig <= "10";
			else
				productsig <= "11";
			end if;
	
			clksig <= '1';		-- clock is at 1 for 5ns
			wait for 5 ns;		-- then going to 0 for 5ns
			clksig <= '0';		-- clock cycle of 10ns
			wait for 5 ns;		-- duty cycle is 50%
		end loop;
	wait;
	end process;

end test;
