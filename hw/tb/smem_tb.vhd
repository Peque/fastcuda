--
-- smem.vhd
--
-- Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
-- MA 02110-1301, USA.
--
--



library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity smem_tb is
end smem_tb;



architecture smem_tb_arch of smem_tb is


	component smem

		port (

			DOA, DOB                                          : out std_logic_vector(31 downto 0);   -- Output port data
			ADDRA, ADDRB                                      : in  std_logic_vector(8 downto 0);    -- Input port address
			CLKA, CLKB, ENA, ENB, REGCEA, REGCEB, RSTA, RSTB  : in  std_logic;                        -- Input port clock, enable, output register enable and reset
			DIA, DIB                                          : in  std_logic_vector(31 downto 0);   -- Input port-B data
			WEA, WEB                                          : in  std_logic_vector(3 downto 0)

		);

	end component;


	signal DOA, DOB                                          : std_logic_vector(31 downto 0);
	signal ADDRA, ADDRB                                      : std_logic_vector(8 downto 0) := "000000000";
	signal CLKA, CLKB, ENA, ENB, REGCEA, REGCEB, RSTA, RSTB  : std_logic := '0';
	signal DIA, DIB                                          : std_logic_vector(31 downto 0) := x"00000000";
	signal WEA, WEB                                          : std_logic_vector(3 downto 0) := "0000";


begin


	uut : smem

	port map (

		DOA => DOA,        -- Output port-A data
		DOB => DOB,        -- Output port-B data
		ADDRA => ADDRA,    -- Input port-A address
		ADDRB => ADDRB,    -- Input port-B address
		CLKA => CLKA,      -- Input port-A clock
		CLKB => CLKB,      -- Input port-B clock
		DIA => DIA,        -- Input port-A data
		DIB => DIB,        -- Input port-B data
		ENA => ENA,        -- Input port-A enable
		ENB => ENB,        -- Input port-B enable
		REGCEA => REGCEA,  -- Input port-A output register enable
		REGCEB => REGCEB,  -- Input port-B output register enable
		RSTA => RSTA,      -- Input port-A reset
		RSTB => RSTB,      -- Input port-B reset
		WEA => WEA,        -- Input port-A write enable
		WEB => WEB         -- Input port-B write enable

	);


	clock_gen : process begin

		clock_loop : loop

			CLKA <= '0';
			CLKB <= '1';
			wait for 5 ns;
			CLKA <= '1';
			CLKB <= '0';
			wait for 5 ns;

		end loop clock_loop;

	end process clock_gen;


	testbench : process begin

		wait for 100 ns; -- Wait until global set/reset completes

		ENA <= '1';
		ENB <= '1';

		wait for 1 ns;

		DIA <= x"F0F0F0F0";
		DIB <= x"FFFFFFFF";
		ADDRA <= "000000000";
		ADDRB <= "111111111";
		WEA <= "1111";
		WEB <= "1111";

		wait for 5 ns;

		WEA <= "0000";

		wait for 5 ns;

		WEB <= "0000";


		wait;

	end process testbench;


end smem_tb_arch;
