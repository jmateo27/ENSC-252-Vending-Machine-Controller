library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display is												-- declaring entity for the display mode
	port (clk, start : in std_logic;
		 	product : in std_logic_vector(1 downto 0);
			arithprice : in std_logic_vector(5 downto 0);
			addr : out std_logic_vector(1 downto 0);
			rd, done : out std_logic;
			price_out : out std_logic_vector(5 downto 0));
end display;

architecture behaviour of display is					-- creating the architecture for display

	signal price : std_logic_vector(5 downto 0);
	signal state : std_logic_vector(1 downto 0) := "00";
	
begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			price <= arithprice;								
			case state is
					
				when "01" =>									-- creating holder state
				
					state <= "10";
				
				when "10" =>									-- secondary holder state and move onto idle
					
					state <= "00";
					
				when others => --state "00"
				
					if start = '1' then						-- exit idle if start signal is asserted
						state <= "01";
					else
						state <= "00";
					end if;
					
			end case;
			
		else
			state <= state;									-- if not on rising edge, we maintain old values
			price <= price;
		end if;
		
	end process;
	
	done <= '1' when state = "10" else '0';			-- we assert done signal if in secondary state
	rd <= '1' when state = "01" else '0';				-- reading from SRAM in the primary state
	addr <= product when state = "01" else "00";		-- connect product address in state 1
	price_out <= price;										-- connecting the price output
	
end behaviour;		
