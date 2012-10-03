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

	generic (

		N_PORTS         : integer := 8;
		N_BRAMS         : integer := 4;
		LOG2_N_PORTS    : integer := 3  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code

	);

end smem_tb;



architecture smem_tb_arch of smem_tb is


	type state_t is (

		IDLE,
		SMEM_WRITE_0,
		FOO_0,
		SMEM_READ_0,
		FOO_1,
		SMEM_WRITE_1,
		FOO_2,
		SMEM_READ_1,
		FOO_3,
		SMEM_WRITE_2,
		FOO_4,
		SMEM_READ_2,
		DONE

	);

	component smem

		port (

			DO                     : out std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data output ports
			DI                     : in  std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data input ports
			ADDR_0, ADDR_1, ADDR_2, ADDR_3, ADDR_4, ADDR_5, ADDR_6, ADDR_7     : in  std_logic_vector(10 downto 0);    -- Address input ports
			WE_0, WE_1, WE_2, WE_3, WE_4, WE_5, WE_6, WE_7                     : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
			BRAM_CLK, TRIG_CLK, RST                                            : in  std_logic;                        -- Clock and reset input ports
			REQ_0, REQ_1, REQ_2, REQ_3, REQ_4, REQ_5, REQ_6, REQ_7             : in  std_logic;                        -- Request input ports
			RDY_0, RDY_1, RDY_2, RDY_3, RDY_4, RDY_5, RDY_6, RDY_7             : out std_logic                         -- Ready output ports

		);

	end component;


	signal DO_0, DO_1, DO_2, DO_3, DO_4, DO_5, DO_6, DO_7                     : std_logic_vector(31 downto 0);
	signal DI_0, DI_1, DI_2, DI_3, DI_4, DI_5, DI_6, DI_7                     : std_logic_vector(31 downto 0) := x"00000000";
	signal ADDR_0, ADDR_1, ADDR_2, ADDR_3, ADDR_4, ADDR_5, ADDR_6, ADDR_7     : std_logic_vector(10 downto 0) := "00000000000";
	signal WE_0, WE_1, WE_2, WE_3, WE_4, WE_5, WE_6, WE_7                     : std_logic_vector(3 downto 0) := "0000";
	signal BRAM_CLK, TRIG_CLK, RST                                            : std_logic := '0';
	signal REQ_0, REQ_1, REQ_2, REQ_3, REQ_4, REQ_5, REQ_6, REQ_7             : std_logic := '0';
	signal RDY_0, RDY_1, RDY_2, RDY_3, RDY_4, RDY_5, RDY_6, RDY_7             : std_logic := '0';
	signal start_test_bench                                                   : std_logic := '0';

	signal kernel_0_state                       : state_t;
	signal kernel_1_state                       : state_t;
	signal kernel_2_state                       : state_t;
	signal kernel_3_state                       : state_t;
	signal kernel_4_state                       : state_t;
	signal kernel_5_state                       : state_t;
	signal kernel_6_state                       : state_t;
	signal kernel_7_state                       : state_t;


begin


	uut : smem

	port map (

		DO(32 * 1 - 1 downto 32 * 0) => DO_0,
		DO(32 * 2 - 1 downto 32 * 1) => DO_1,
		DO(32 * 3 - 1 downto 32 * 2) => DO_2,
		DO(32 * 4 - 1 downto 32 * 3) => DO_3,
		DO(32 * 5 - 1 downto 32 * 4) => DO_4,
		DO(32 * 6 - 1 downto 32 * 5) => DO_5,
		DO(32 * 7 - 1 downto 32 * 6) => DO_6,
		DO(32 * 8 - 1 downto 32 * 7) => DO_7,

		ADDR_0 => ADDR_0,
		ADDR_1 => ADDR_1,
		ADDR_2 => ADDR_2,
		ADDR_3 => ADDR_3,
		ADDR_4 => ADDR_4,
		ADDR_5 => ADDR_5,
		ADDR_6 => ADDR_6,
		ADDR_7 => ADDR_7,

		BRAM_CLK => BRAM_CLK,
		TRIG_CLK => TRIG_CLK,
		RST => RST,

		DI(32 * 1 - 1 downto 32 * 0) => DI_0,
		DI(32 * 2 - 1 downto 32 * 1) => DI_1,
		DI(32 * 3 - 1 downto 32 * 2) => DI_2,
		DI(32 * 4 - 1 downto 32 * 3) => DI_3,
		DI(32 * 5 - 1 downto 32 * 4) => DI_4,
		DI(32 * 6 - 1 downto 32 * 5) => DI_5,
		DI(32 * 7 - 1 downto 32 * 6) => DI_6,
		DI(32 * 8 - 1 downto 32 * 7) => DI_7,

		WE_0 => WE_0,
		WE_1 => WE_1,
		WE_2 => WE_2,
		WE_3 => WE_3,
		WE_4 => WE_4,
		WE_5 => WE_5,
		WE_6 => WE_6,
		WE_7 => WE_7,

		REQ_0 => REQ_0,
		REQ_1 => REQ_1,
		REQ_2 => REQ_2,
		REQ_3 => REQ_3,
		REQ_4 => REQ_4,
		REQ_5 => REQ_5,
		REQ_6 => REQ_6,
		REQ_7 => REQ_7,

		RDY_0 => RDY_0,
		RDY_1 => RDY_1,
		RDY_2 => RDY_2,
		RDY_3 => RDY_3,
		RDY_4 => RDY_4,
		RDY_5 => RDY_5,
		RDY_6 => RDY_6,
		RDY_7 => RDY_7

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

		start_test_bench <= '1';

	end process test_bench;


	thread_0 : process (TRIG_CLK)

	begin

		if (TRIG_CLK'event and TRIG_CLK = '1') then

			case kernel_0_state is

				when IDLE =>

					if start_test_bench = '1' then
						kernel_0_state <= SMEM_WRITE_0;
					end if;

				when SMEM_WRITE_0 =>

					DI_0 <= x"AAAAAAAA";
					ADDR_0 <= "00000000000";
					WE_0 <= "1111";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= FOO_0;
					end if;

				when FOO_0 =>

					kernel_0_state <= SMEM_READ_0;

				when SMEM_READ_0 =>

					ADDR_0 <= "00000000000";
					WE_0 <= "0000";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= FOO_1;
					end if;

				when FOO_1 =>

					kernel_0_state <= SMEM_WRITE_1;

				when SMEM_WRITE_1 =>

					DI_0 <= x"AAAAAAAA";
					ADDR_0 <= "00000000000";
					WE_0 <= "1111";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= FOO_2;
					end if;

				when FOO_2 =>

					kernel_0_state <= SMEM_READ_1;

				when SMEM_READ_1 =>

					ADDR_0 <= "10000000001";
					WE_0 <= "0000";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= FOO_3;
					end if;

				when FOO_3 =>

					kernel_0_state <= SMEM_WRITE_2;

				when SMEM_WRITE_2 =>

					DI_0 <= x"AAAAAAAA";
					ADDR_0 <= "00000000010";
					WE_0 <= "1111";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= FOO_4;
					end if;

				when FOO_4 =>

					kernel_0_state <= SMEM_READ_2;

				when SMEM_READ_2 =>

					ADDR_0 <= "00000001110";
					WE_0 <= "0000";
					REQ_0 <= '1';
					if (RDY_0 = '1') then
						REQ_0 <= '0';
						kernel_0_state <= DONE;
					end if;

				when DONE =>

					null;

			end case;

		end if;

	end process thread_0;


	thread_1 : process (TRIG_CLK)

	begin

		if (TRIG_CLK'event and TRIG_CLK = '1') then

			case kernel_1_state is

				when IDLE =>

					if start_test_bench = '1' then
						kernel_1_state <= SMEM_WRITE_0;
					end if;

				when SMEM_WRITE_0 =>

					DI_1 <= x"BBBBBBBB";
					ADDR_1 <= "00000000000";
					WE_1 <= "1111";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= FOO_0;
					end if;

				when FOO_0 =>

					kernel_1_state <= SMEM_READ_0;

				when SMEM_READ_0 =>

					ADDR_1 <= "00000000000";
					WE_1 <= "0000";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= FOO_1;
					end if;

				when FOO_1 =>

					kernel_1_state <= SMEM_WRITE_1;

				when SMEM_WRITE_1 =>

					DI_1 <= x"BBBBBBBB";
					ADDR_1 <= "00000000001";
					WE_1 <= "1111";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= FOO_2;
					end if;

				when FOO_2 =>

					kernel_1_state <= SMEM_READ_1;

				when SMEM_READ_1 =>

					ADDR_1 <= "10000000000";
					WE_1 <= "0000";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= FOO_3;
					end if;

				when FOO_3 =>

					kernel_1_state <= SMEM_WRITE_2;

				when SMEM_WRITE_2 =>

					DI_1 <= x"BBBBBBBB";
					ADDR_1 <= "00000000110";
					WE_1 <= "1111";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= FOO_4;
					end if;

				when FOO_4 =>

					kernel_1_state <= SMEM_READ_2;

				when SMEM_READ_2 =>

					ADDR_1 <= "00000001010";
					WE_1 <= "0000";
					REQ_1 <= '1';
					if (RDY_1 = '1') then
						REQ_1 <= '0';
						kernel_1_state <= DONE;
					end if;

				when DONE =>

					null;

			end case;

		end if;

	end process thread_1;


	thread_2 : process (TRIG_CLK)

	begin

		if (TRIG_CLK'event and TRIG_CLK = '1') then

			case kernel_2_state is

				when IDLE =>

					if start_test_bench = '1' then
						kernel_2_state <= SMEM_WRITE_0;
					end if;

				when SMEM_WRITE_0 =>

					DI_2 <= x"CCCCCCCC";
					ADDR_2 <= "00000000000";
					WE_2 <= "1111";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= FOO_0;
					end if;

				when FOO_0 =>

					kernel_2_state <= SMEM_READ_0;

				when SMEM_READ_0 =>

					ADDR_2 <= "00000000000";
					WE_2 <= "0000";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= FOO_1;
					end if;

				when FOO_1 =>

					kernel_2_state <= SMEM_WRITE_1;

				when SMEM_WRITE_1 =>

					DI_2 <= x"CCCCCCCC";
					ADDR_2 <= "10000000000";
					WE_2 <= "1111";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= FOO_2;
					end if;

				when FOO_2 =>

					kernel_2_state <= SMEM_READ_1;

				when SMEM_READ_1 =>

					ADDR_2 <= "00000000001";
					WE_2 <= "0000";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= FOO_3;
					end if;

				when FOO_3 =>

					kernel_2_state <= SMEM_WRITE_2;

				when SMEM_WRITE_2 =>

					DI_2 <= x"CCCCCCCC";
					ADDR_2 <= "00000001010";
					WE_2 <= "1111";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= FOO_4;
					end if;

				when FOO_4 =>

					kernel_2_state <= SMEM_READ_2;

				when SMEM_READ_2 =>

					ADDR_2 <= "00000000110";
					WE_2 <= "0000";
					REQ_2 <= '1';
					if (RDY_2 = '1') then
						REQ_2 <= '0';
						kernel_2_state <= DONE;
					end if;

				when DONE =>

					null;

			end case;

		end if;

	end process thread_2;


	thread_3 : process (TRIG_CLK)

	begin

		if (TRIG_CLK'event and TRIG_CLK = '1') then

			case kernel_3_state is

				when IDLE =>

					if start_test_bench = '1' then
						kernel_3_state <= SMEM_WRITE_0;
					end if;

				when SMEM_WRITE_0 =>

					DI_3 <= x"DDDDDDDD";
					ADDR_3 <= "00000000000";
					WE_3 <= "1111";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= FOO_0;
					end if;

				when FOO_0 =>

					kernel_3_state <= SMEM_READ_0;

				when SMEM_READ_0 =>

					ADDR_3 <= "00000000000";
					WE_3 <= "0000";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= FOO_1;
					end if;

				when FOO_1 =>

					kernel_3_state <= SMEM_WRITE_1;

				when SMEM_WRITE_1 =>

					DI_3 <= x"DDDDDDDD";
					ADDR_3 <= "10000000001";
					WE_3 <= "1111";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= FOO_2;
					end if;

				when FOO_2 =>

					kernel_3_state <= SMEM_READ_1;

				when SMEM_READ_1 =>

					ADDR_3 <= "00000000000";
					WE_3 <= "0000";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= FOO_3;
					end if;

				when FOO_3 =>

					kernel_3_state <= SMEM_WRITE_2;

				when SMEM_WRITE_2 =>

					DI_3 <= x"DDDDDDDD";
					ADDR_3 <= "00000001110";
					WE_3 <= "1111";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= FOO_4;
					end if;

				when FOO_4 =>

					kernel_3_state <= SMEM_READ_2;

				when SMEM_READ_2 =>

					ADDR_3 <= "00000000010";
					WE_3 <= "0000";
					REQ_3 <= '1';
					if (RDY_3 = '1') then
						REQ_3 <= '0';
						kernel_3_state <= DONE;
					end if;

				when DONE =>

					null;

			end case;

		end if;

	end process thread_3;


end smem_tb_arch;
