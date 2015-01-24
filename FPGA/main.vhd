library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.MATH_REAL.ALL;

entity main is
 	port (
		clk : in std_logic;
		JB : out std_logic_vector(7 downto 0)
	);
end main;

architecture Behavioral of main is
signal data : unsigned(31 downto 0) := x"deadbeef";
begin

	pmodcharliedisp : entity work.pmodcharlie
	port map (
		clk => clk,
		display_data => data,
		pmod_pins => JB
	);

end Behavioral;
