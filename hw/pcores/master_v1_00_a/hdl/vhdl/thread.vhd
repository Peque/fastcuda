--
-- thread.vhd
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
use ieee.std_logic_unsigned.all;


entity thread is

	port (

		-- General ports
		CLK                      : in  std_logic;
		RESETN                   : in  std_logic;

		-- DDR2
		DDR2_DATA_OUT            : in  std_logic_vector(31 downto 0);
		DDR2_DATA_IN             : out std_logic_vector(31 downto 0);
		DDR2_ADDRESS             : out std_logic_vector(31 downto 0);
		DDR2_READ_REQ            : out std_logic;
		DDR2_WRITE_REQ           : out std_logic;
		DDR2_RDY                 : in  std_logic;

		-- Shared memory
		SMEM_DO                  : in  std_logic_vector(31 downto 0);
		SMEM_IN                  : out std_logic_vector(31 downto 0);
		SMEM_ADDR                : out std_logic_vector(9 downto 0);
		SMEM_WE                  : out std_logic_vector(3 downto 0);
		SMEM_REQ                 : out std_logic;
		SMEM_RDY                 : in  std_logic;

		-- Registers
		REG_GO                   : in  std_logic;
		REG_READY                : out std_logic;
		REG_DDR2_ADDRESS         : in  std_logic_vector(31 downto 0);
		REG_SMEM_DO              : in  std_logic_vector(31 downto 0);
		REG_SMEM_DI              : in  std_logic_vector(31 downto 0);
		REG_SMEM_ADDR_READ       : in  std_logic_vector(9 downto 0);
		REG_SMEM_ADDR_WRITE      : in  std_logic_vector(9 downto 0);

		-- Data debug
		DATA_DEBUG               : out std_logic_vector(31 downto 0)

	);

end thread;


architecture thread_arch of thread is

	type state_t is (

		IDLE,
		READ_A, WAIT_RD_A,
		WRITE_C, WAIT_WR,
		READ_C, WAIT_RD_C,
		DONE

	);

	signal thread_state            : state_t;
	signal ddr2_data_out_signal    : std_logic_vector(31 downto 0);

begin

	thread_sm : process (CLK) is

	begin

		if ( clk'event and clk = '1' ) then

			if resetn = '0' then

				ddr2_data_out_signal     <= X"00000000";
				thread_state             <= IDLE;
				DDR2_DATA_IN             <= X"00000000";
				DDR2_ADDRESS             <= X"00000000";
				DDR2_READ_REQ            <= '0';
				DDR2_WRITE_REQ           <= '0';
				SMEM_IN                  <= X"00000000";
				SMEM_ADDR                <= "0000000000";
				SMEM_WE                  <= "0000";
				SMEM_REQ                 <= '0';
				REG_READY                <= '0';
				DATA_DEBUG               <= X"00000000";

			else

				case thread_state is

					when IDLE =>

						REG_READY <= '0';
						ddr2_data_out_signal <= (others => '0');
						DDR2_DATA_IN <= (others => '0');
						DDR2_ADDRESS <= (others => '0');
						DDR2_READ_REQ <= '0';
						DDR2_WRITE_REQ <= '0';
						REG_READY <= '0';
						DATA_DEBUG <= (others => '0');
						if REG_GO = '1' then thread_state <= READ_A;
						end if;

					when READ_A =>

						DDR2_ADDRESS <= REG_DDR2_ADDRESS;
						DDR2_READ_REQ <= '1';
						thread_state <= WAIT_RD_A;

					when WAIT_RD_A =>

						if DDR2_RDY = '1' then
							DDR2_READ_REQ <='0';
							ddr2_data_out_signal <= DDR2_DATA_OUT;
							DATA_DEBUG <= DDR2_DATA_OUT;
							thread_state <= WRITE_C;
						end if;

					when WRITE_C =>

						DDR2_ADDRESS <= REG_DDR2_ADDRESS;
						DDR2_DATA_IN <= REG_DDR2_ADDRESS-x"C0000000"+x"0000009";
						DDR2_WRITE_REQ <= '1';
						thread_state <= WAIT_WR;

					when WAIT_WR =>

						if DDR2_RDY = '1' then
							DDR2_WRITE_REQ <= '0';
							thread_state <= READ_C;
						end if;


					when READ_C =>

						DDR2_ADDRESS <= REG_DDR2_ADDRESS;
						DDR2_READ_REQ <= '1';
						thread_state <= WAIT_RD_C;

					when WAIT_RD_C =>

						if DDR2_RDY = '1' then
							DDR2_READ_REQ <='0';
							ddr2_data_out_signal <= DDR2_DATA_OUT;
							DATA_DEBUG <= DDR2_DATA_OUT;
							thread_state <= DONE;
						end if;

					when DONE =>

						REG_READY <= '1';
						thread_state <= DONE;

					when others => null;

				end case;

			end if;

		end if;

	end process thread_sm;

end thread_arch;

