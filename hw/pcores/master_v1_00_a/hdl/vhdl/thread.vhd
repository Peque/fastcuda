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
		SMEM_REQ                 : out std_logic_vector;
		SMEM_RDY                 : in  std_logic_vector;

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


architecture Behavioral of thread is

	type state_t is (
		IDLE,
		READ_DDR2, WAIT_READ_DDR2,
		WRITE_C, WAIT_WR,
		READ_C, WAIT_RD_C,
		DONE
	);

	signal state : state_t;
	signal aux : std_logic_vector (31 downto 0);

begin

thread_SM: process(clk) is
begin
    if ( clk'event and clk = '1' ) then
        if resetn = '0' then --reset
            aux <= (others => '0');
--            aux2 <= (others => '0');
            state <= IDLE;
            data_out_m <= (others => '0');
            address_m <= (others => '0');
            rd_req_m <= '0';
            wr_req_m <= '0';
            ready_r <= '0';
				DATA_DEBUG <= (others => '0');

        else

            case state is

            when IDLE =>
                ready_r <= '0';
                aux <= (others => '0');
--                aux2 <= (others => '0');
                data_out_m <= (others => '0');
                address_m <= (others => '0');
                rd_req_m <= '0';
                wr_req_m <= '0';
                ready_r <= '0';
					 DATA_DEBUG <= (others => '0');

                if go_r = '1' then state <= READ_A;
                end if;

            when READ_A =>
                address_m <= address_a_r;
                rd_req_m <= '1';
                state <= WAIT_RD_A;

            when WAIT_RD_A =>
                if ack_m = '1' then --wait for ack
                  rd_req_m <='0';
						aux <= data_in_m;
						DATA_DEBUG <= data_in_m;
						state <= WRITE_C;
                end if;

            when WRITE_C =>
                address_m <= address_a_r; --in address_a (could change)
					 data_out_m <= address_a_r-x"C0000000"+x"0000009"; --random number
                wr_req_m <= '1';
                state <= WAIT_WR;

            when WAIT_WR =>
                if ack_m = '1' then --wait for ack
                    wr_req_m <= '0';
                    state <= READ_C;
                end if;


				when READ_C =>
                address_m <= address_a_r;
                rd_req_m <= '1';
                state <= WAIT_RD_C;

            when WAIT_RD_C =>
                if ack_m = '1' then --wait for ack
                  rd_req_m <='0';
						aux <= data_in_m;
						DATA_DEBUG <= data_in_m;
						state <= DONE;
                end if;


            when DONE =>
                ready_r <= '1';
                state <= DONE;

            when others => null;

            end case; --state

        end if; --resetn
    end if; --clk
end process thread_SM;


end Behavioral;

