--*********************************************************************
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
-- 02111-1307, USA.
--
-- © 2014 - Tobias Müller (twam.info)
-- based on https://github.com/xesscorp/StickIt/blob/master/modules/LedDigits/FPGA/LedDigitsTest/LedDigits.vhd
-- © 2011 - X Engineering Software Systems Corp. (www.xess.com)
--*********************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity pmodcharlie is
	generic (
		CLK_FREQUENCY : real := 100.0E6;      						-- Frequency of the CLK supplied
		DISPLAY_FREQUENCY : real := 1.0E3 							-- Update frequency of the display
	);
	port (
		clk : in std_logic;
		display_data : in unsigned(31 downto 0);
		pmod_pins : out std_logic_vector(7 downto 0)
	);
end pmodcharlie;

architecture Behavioral of pmodcharlie is
	signal active_digit : unsigned(pmod_pins'range) := "00000001";  -- Current active digit
	signal active_segment : unsigned(pmod_pins'range) := "00000001";-- Current active segment
	signal tristate_pins : std_logic_vector(pmod_pins'range);  		-- Tristate status of output pins
	signal digit_data : unsigned(3 downto 0);						-- (Binary) data for current active digit
	signal segments : unsigned(6 downto 0);							-- Active segments for current digit
begin

	-- Calculate the current active digit/segment
	process (clk)
		constant SEGMENT_TIMER_MAX : natural := integer(ceil(CLK_FREQUENCY / (DISPLAY_FREQUENCY * real(active_digit'length*segments'length))));
		variable segment_timer : natural range 0 to SEGMENT_TIMER_MAX;
		variable segment_counter : natural range pmod_pins'range;
	begin
		if rising_edge(clk) then
			if segment_timer /= 0 then
				segment_timer := segment_timer - 1;
			else
				active_segment <= active_segment rol 1;
				segment_timer := SEGMENT_TIMER_MAX;
				if segment_counter /= 0 then
					segment_counter := segment_counter - 1;
				else
					active_digit <= active_digit rol 1;
					segment_counter := pmod_pins'high;
				end if;
			end if;
		end if;
	end process;

	-- Get the correct data for the current active digit
	with active_digit select digit_data <=
		display_data( 3 downto  0) when "00000001",
		display_data( 7 downto  4) when "00000010",
		display_data(11 downto  8) when "00000100",
		display_data(15 downto 12) when "00001000",
		display_data(19 downto 16) when "00010000",
		display_data(23 downto 20) when "00100000",
		display_data(27 downto 24) when "01000000",
		display_data(31 downto 28) when others;

	-- Get the active segments for the current digit depending on the data
	with digit_data select
		segments <=
		 "0111111" when "0000", -- 0
		 "0000110" when "0001", -- 1
		 "1011011" when "0010", -- 2
		 "1001111" when "0011", -- 3
		 "1100110" when "0100", -- 4
		 "1101101" when "0101", -- 5
		 "1111101" when "0110", -- 6
		 "0000111" when "0111", -- 7
		 "1111111" when "1000", -- 8
		 "1101111" when "1001", -- 9
		 "1110111" when "1010", -- A
		 "1111100" when "1011", -- B
		 "1111001" when "1100", -- C
		 "1011110" when "1101", -- D
		 "1111001" when "1110", -- E
		 "1110001" when others; -- F


	-- Tristate everything except for the current segment and current digit
	process(active_digit, active_segment, segments)
		variable j : natural range active_digit'range := 0;
	begin
		j := 0;
		tristate_pins <= not std_logic_vector(active_digit);

		for i in active_digit'low to active_digit'high loop
			if active_digit(i) = '0' then
				if active_segment(i) = '1' and segments(j) = '1' then
					tristate_pins(i) <= '0';
				end if;
				j := j + 1;
			end if;
		end loop;
	end process;

	UObuft0 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(0), I => active_digit(0), O => pmod_pins(0));
	UObuft1 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(1), I => active_digit(1), O => pmod_pins(5));
	UObuft2 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(2), I => active_digit(2), O => pmod_pins(3));
	UObuft3 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(3), I => active_digit(3), O => pmod_pins(7));
	UObuft4 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(4), I => active_digit(4), O => pmod_pins(6));
	UObuft5 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(5), I => active_digit(5), O => pmod_pins(1));
	UObuft6 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(6), I => active_digit(6), O => pmod_pins(4));
	UObuft7 : OBUFT generic map(DRIVE => 24, IOSTANDARD => "LVTTL") port map(T => tristate_pins(7), I => active_digit(7), O => pmod_pins(2));

end Behavioral;
