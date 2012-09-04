--
-- smem_tb.vhd
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

			DO_0, DO_1, DO_2, DO_3              : out std_logic_vector(31 downto 0);    -- Data output ports
			DI_0, DI_1, DI_2, DI_3              : in  std_logic_vector(31 downto 0);    -- Data input ports
			ADDR_0, ADDR_1, ADDR_2, ADDR_3      : in  std_logic_vector(9 downto 0);     -- Address input ports
			WE_0, WE_1, WE_2, WE_3              : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
			BRAM_CLK, TRIG_CLK, RST             : in  std_logic;                        -- Clock and reset input ports
			REQ_0, REQ_1, REQ_2, REQ_3          : in  std_logic;                        -- Request input ports
			RDY_0, RDY_1, RDY_2, RDY_3          : out std_logic                         -- Ready output ports

		);

	end component;


	signal DO_0, DO_1, DO_2, DO_3             : std_logic_vector(31 downto 0);
	signal DI_0, DI_1, DI_2, DI_3             : std_logic_vector(31 downto 0) := x"00000000";
	signal ADDR_0, ADDR_1, ADDR_2, ADDR_3     : std_logic_vector(9 downto 0) := "0000000000";
	signal WE_0, WE_1, WE_2, WE_3             : std_logic_vector(3 downto 0) := "0000";
	signal BRAM_CLK, TRIG_CLK, RST            : std_logic := '0';
	signal REQ_0, REQ_1, REQ_2, REQ_3         : std_logic := '0';
	signal RDY_0, RDY_1, RDY_2, RDY_3         : std_logic := '0';
	signal run_same_bram_access               : std_logic := '0';
	signal run_same_address_access            : std_logic := '0';
	signal run_fast_access                    : std_logic := '0';


begin


	uut : smem

	port map (

		DO_0 => DO_0,
		DO_1 => DO_1,
		DO_2 => DO_2,
		DO_3 => DO_3,

		ADDR_0 => ADDR_0,
		ADDR_1 => ADDR_1,
		ADDR_2 => ADDR_2,
		ADDR_3 => ADDR_3,

		BRAM_CLK => BRAM_CLK,
		TRIG_CLK => TRIG_CLK,
		RST => RST,

		DI_0 => DI_0,
		DI_1 => DI_1,
		DI_2 => DI_2,
		DI_3 => DI_3,

		WE_0 => WE_0,
		WE_1 => WE_1,
		WE_2 => WE_2,
		WE_3 => WE_3,

		REQ_0 => REQ_0,
		REQ_1 => REQ_1,
		REQ_2 => REQ_2,
		REQ_3 => REQ_3,

		RDY_0 => RDY_0,
		RDY_1 => RDY_1,
		RDY_2 => RDY_2,
		RDY_3 => RDY_3

	);


	clock_gen : process begin

		clock_loop : loop

			BRAM_CLK <= '0';
			wait for 2.5 ns;
			TRIG_CLK <= '1';
			wait for 2.5 ns;
			BRAM_CLK <= '1';
			wait for 2.5 ns;
			TRIG_CLK <= '0';
			wait for 2.5 ns;

		end loop clock_loop;

	end process clock_gen;


	test_bench : process begin

		wait for 100 ns; -- Wait until global set/reset completes
		wait for 1 ns;

		run_same_bram_access <= '1';

		wait for 50 ns;

		run_same_address_access <= '1';

		wait for 20 ns;

		run_fast_access <= '1';

	end process test_bench;


	thread_0 : process begin

		wait until run_same_bram_access = '1';

		DI_0 <= x"AAAAAAAA";
		ADDR_0 <= "1000000000";
		WE_0 <= "1111";
		REQ_0 <= '1';

		wait until RDY_0 = '0';

		REQ_0 <= '0';

		wait until RDY_0 = '1';

		WE_0 <= "0000";
		REQ_0 <= '1';

		wait until RDY_0 = '0';

		REQ_0 <= '0';

		wait until RDY_0 = '1';

		wait until run_same_address_access = '1';

		ADDR_0 <= "1000000000";
		WE_0 <= "0000";
		REQ_0 <= '1';

		wait until RDY_0 = '0';

		REQ_0 <= '0';

		wait until RDY_0 = '1';

		wait;

	end process thread_0;

	thread_1 : process begin

		wait until run_same_bram_access = '1';

		DI_1 <= x"BBBBBBBB";
		ADDR_1 <= "1000000001";
		WE_1 <= "1111";
		REQ_1 <= '1';

		wait until RDY_1 = '0';

		REQ_1 <= '0';

		wait until RDY_1 = '1';

		WE_1 <= "0000";
		REQ_1 <= '1';

		wait until RDY_1 = '0';

		REQ_1 <= '0';

		wait until RDY_1 = '1';

		wait until run_same_address_access = '1';

		ADDR_1 <= "1000000000";
		WE_1 <= "0000";
		REQ_1 <= '1';

		wait until RDY_1 = '0';

		REQ_1 <= '0';

		wait until RDY_1 = '1';

		wait;

	end process thread_1;

	thread_2 : process begin

		wait until run_same_bram_access = '1';

		DI_2 <= x"CCCCCCCC";
		ADDR_2 <= "1000000010";
		WE_2 <= "1111";
		REQ_2 <= '1';

		wait until RDY_2 = '0';

		REQ_2 <= '0';

		wait until RDY_2 = '1';

		WE_2 <= "0000";
		REQ_2 <= '1';

		wait until RDY_2 = '0';

		REQ_2 <= '0';

		wait until RDY_2 = '1';

		wait until run_same_address_access = '1';

		ADDR_2 <= "1000000000";
		WE_2 <= "0000";
		REQ_2 <= '1';

		wait until RDY_2 = '0';

		REQ_2 <= '0';

		wait until RDY_2 = '1';

		wait;

	end process thread_2;

	thread_3 : process begin

		wait until run_same_bram_access = '1';

		DI_3 <= x"DDDDDDDD";
		ADDR_3 <= "1000000011";
		WE_3 <= "1111";
		REQ_3 <= '1';

		wait until RDY_3 = '0';

		REQ_3 <= '0';

		wait until RDY_3 = '1';

		WE_3 <= "0000";
		REQ_3 <= '1';

		wait until RDY_3 = '0';

		REQ_3 <= '0';

		wait until RDY_3 = '1';

		wait until run_same_address_access = '1';

		ADDR_3 <= "1000000000";
		WE_3 <= "0000";
		REQ_3 <= '1';

		wait until RDY_3 = '0';

		REQ_3 <= '0';

		wait until RDY_3 = '1';

		wait;

	end process thread_3;


end smem_tb_arch;
