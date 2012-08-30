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

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;



entity smem is

	port (

		DO_0, DO_1, DO_2, DO_3             : out std_logic_vector(31 downto 0);    -- Data output ports
		DI_0, DI_1, DI_2, DI_3             : in  std_logic_vector(31 downto 0);    -- Data input ports
		ADDR_0, ADDR_1, ADDR_2, ADDR_3     : in  std_logic_vector(9 downto 0);     -- Address input ports
		WE_0, WE_1, WE_2, WE_3             : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
		BRAM_CLK, TRIG_CLK, RST            : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3         : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3         : out std_logic                         -- Ready output port

	);

end smem;



architecture smem_arch of smem is


	constant DIP_value         : std_logic_vector(3 downto 0) := "0000";
	constant LOWADDR_value     : std_logic_vector(4 downto 0) := "00000";
	constant REGCE_value       : std_logic := '0';
	constant EN_value          : std_logic := '1';

	--
	-- Signals
	--
	--   k#_needs_attention   Flag which says wether kernel # needs to be attended
	--   k#_given_port        Within a BRAM, this bit sets with port (A|B) kernel # has been assigned
	--   k#_requested_bram    BRAM from/to which we need to read/write (first ADDR_# bits)
	--   k#_output_sel        Output port from which kernel # needs to read
	--
	--
	--   DO_#_[A|B]           Data output of BRAM # in port [A|B]
	--   DI_#_[A|B]           Data input of BRAM # in port [A|B]
	--   ADDR_#_[A|B]         Address input of BRAM # in port [A|B]
	--   WE_#_[A|B]           Byte write enable input of BRAM # in port [A|B]
	--   EN_#_[A|B]           Enable input of BRAM # in port [A|B]
	--
	--   bram_#_controller_din_[A|B]
	--   bram_#_controller_dout_[A|B]
	--   bram_#_controller_addr_[A|B]
	--   bram_#_controller_we_[A|B]
	--

	signal k0_needs_attention  : std_logic := '0';
	signal k0_given_port       : std_logic := '0';
	signal k0_ready            : std_logic := '1';
	signal k0_requested_bram   : std_logic_vector(0 downto 0) := "0";
	signal k0_output_sel       : std_logic_vector(1 downto 0) := "00";

	signal k1_needs_attention  : std_logic := '0';
	signal k1_given_port       : std_logic := '0';
	signal k1_ready            : std_logic := '1';
	signal k1_requested_bram   : std_logic_vector(0 downto 0) := "0";
	signal k1_output_sel       : std_logic_vector(1 downto 0) := "00";

	signal k2_needs_attention  : std_logic := '0';
	signal k2_given_port       : std_logic := '0';
	signal k2_ready            : std_logic := '1';
	signal k2_requested_bram   : std_logic_vector(0 downto 0) := "0";
	signal k2_output_sel       : std_logic_vector(1 downto 0) := "00";

	signal k3_needs_attention  : std_logic := '0';
	signal k3_given_port       : std_logic := '0';
	signal k3_ready            : std_logic := '1';
	signal k3_requested_bram   : std_logic_vector(0 downto 0) := "0";
	signal k3_output_sel       : std_logic_vector(1 downto 0) := "00";


	signal DO_0_A              : std_logic_vector(31 downto 0) := X"00000000";
	signal DO_0_B              : std_logic_vector(31 downto 0) := X"00000000";
	signal DI_0_A              : std_logic_vector(31 downto 0) := X"00000000";
	signal DI_0_B              : std_logic_vector(31 downto 0) := X"00000000";
	signal ADDR_0_A            : std_logic_vector(8 downto 0) := "000000000";
	signal ADDR_0_B            : std_logic_vector(8 downto 0) := "000000000";
	signal WE_0_A              : std_logic_vector(3 downto 0) := "0000";
	signal WE_0_B              : std_logic_vector(3 downto 0) := "0000";
	signal EN_0_A              : std_logic := '0';
	signal EN_0_B              : std_logic := '0';

	signal DO_1_A              : std_logic_vector(31 downto 0) := X"00000000";
	signal DO_1_B              : std_logic_vector(31 downto 0) := X"00000000";
	signal DI_1_A              : std_logic_vector(31 downto 0) := X"00000000";
	signal DI_1_B              : std_logic_vector(31 downto 0) := X"00000000";
	signal ADDR_1_A            : std_logic_vector(8 downto 0) := "000000000";
	signal ADDR_1_B            : std_logic_vector(8 downto 0) := "000000000";
	signal WE_1_A              : std_logic_vector(3 downto 0) := "0000";
	signal WE_1_B              : std_logic_vector(3 downto 0) := "0000";
	signal EN_1_A              : std_logic := '0';
	signal EN_1_B              : std_logic := '0';


	signal bram_0_controller_di_A     : std_logic_vector(31 downto 0) := X"00000000";
	signal bram_0_controller_do_A     : std_logic_vector(31 downto 0) := X"00000000";
	signal bram_0_controller_addr_A   : std_logic_vector(8 downto 0) := "000000000";
	signal bram_0_controller_we_A     : std_logic_vector(3 downto 0) := "0000";

	signal bram_0_controller_di_B     : std_logic_vector(31 downto 0) := X"00000000";
	signal bram_0_controller_do_B     : std_logic_vector(31 downto 0) := X"00000000";
	signal bram_0_controller_addr_B   : std_logic_vector(8 downto 0) := "000000000";
	signal bram_0_controller_we_B     : std_logic_vector(3 downto 0) := "0000";


begin


	-- TODO: remove the lines bellow (temporary workaround)
	EN_0_A <= '1';
	EN_0_B <= '1';
	EN_1_A <= '1';
	EN_1_B <= '1';
	k0_given_port <= '0';
	k1_given_port <= '1';
	k2_given_port <= '0';
	k3_given_port <= '1';


	k0_requested_bram <= ADDR_0(9 downto 9);
	k1_requested_bram <= ADDR_1(9 downto 9);
	k2_requested_bram <= ADDR_2(9 downto 9);
	k3_requested_bram <= ADDR_3(9 downto 9);

	RDY_0 <= k0_ready;
	RDY_1 <= k1_ready;
	RDY_2 <= k2_ready;
	RDY_3 <= k3_ready;


	input_controller : process (TRIG_CLK)

		variable bram_0_A_busy    : std_logic := '0';
		variable bram_0_B_busy    : std_logic := '0';
		variable bram_1_A_busy    : std_logic := '0';
		variable bram_1_B_busy    : std_logic := '0';

	begin

		if (TRIG_CLK = '1') then

			if (k0_requested_bram = "0" and REQ_0 = '1') then

				if (bram_0_A_busy = '0') then
					DI_0_A <= DI_0;
					ADDR_0_A <= ADDR_0(8 downto 0);
					WE_0_A <= WE_0;
					k0_ready <= '0';
					k0_output_sel <= "00";
					bram_0_A_busy := '1';
				elsif (bram_0_B_busy = '0') then
					DI_0_B <= DI_0;
					ADDR_0_B <= ADDR_0(8 downto 0);
					WE_0_B <= WE_0;
					k0_ready <= '0';
					k0_output_sel <= "01";
					bram_0_B_busy := '1';
				end if;

			end if;

			if (k1_requested_bram = "0" and REQ_1 = '1') then

				if (bram_0_A_busy = '0') then
					DI_0_A <= DI_1;
					ADDR_0_A <= ADDR_1(8 downto 0);
					WE_0_A <= WE_1;
					k1_ready <= '0';
					k1_output_sel <= "00";
					bram_0_A_busy := '1';
				elsif (bram_0_B_busy = '0') then
					DI_0_B <= DI_1;
					ADDR_0_B <= ADDR_1(8 downto 0);
					WE_0_B <= WE_1;
					k1_ready <= '0';
					k1_output_sel <= "01";
					bram_0_B_busy := '1';
				end if;

			end if;

			if (k2_requested_bram = "0" and REQ_2 = '1') then

				if (bram_0_A_busy = '0') then
					DI_0_A <= DI_2;
					ADDR_0_A <= ADDR_2(8 downto 0);
					WE_0_A <= WE_2;
					k2_ready <= '0';
					k2_output_sel <= "00";
					bram_0_A_busy := '1';
				elsif (bram_0_B_busy = '0') then
					DI_0_B <= DI_2;
					ADDR_0_B <= ADDR_2(8 downto 0);
					WE_0_B <= WE_2;
					k2_ready <= '0';
					k2_output_sel <= "01";
					bram_0_B_busy := '1';
				end if;

			end if;

			if (k3_requested_bram = "0" and REQ_3 = '1') then

				if (bram_0_A_busy = '0') then
					DI_0_A <= DI_3;
					ADDR_0_A <= ADDR_3(8 downto 0);
					WE_0_A <= WE_3;
					k3_ready <= '0';
					k3_output_sel <= "00";
					bram_0_A_busy := '1';
				elsif (bram_0_B_busy = '0') then
					DI_0_B <= DI_3;
					ADDR_0_B <= ADDR_3(8 downto 0);
					WE_0_B <= WE_3;
					k3_ready <= '0';
					k3_output_sel <= "01";
					bram_0_B_busy := '1';
				end if;

			end if;

			if (k0_requested_bram = "1" and REQ_0 = '1') then

				if (bram_1_A_busy = '0') then
					DI_1_A <= DI_0;
					ADDR_1_A <= ADDR_0(8 downto 0);
					WE_1_A <= WE_0;
					k0_ready <= '0';
					k0_output_sel <= "10";
					bram_1_A_busy := '1';
				elsif (bram_1_B_busy = '0') then
					DI_1_B <= DI_0;
					ADDR_1_B <= ADDR_0(8 downto 0);
					WE_1_B <= WE_0;
					k0_ready <= '0';
					k0_output_sel <= "11";
					bram_1_B_busy := '1';
				end if;

			end if;

			if (k1_requested_bram = "1" and REQ_1 = '1') then

				if (bram_1_A_busy = '0') then
					DI_1_A <= DI_1;
					ADDR_1_A <= ADDR_1(8 downto 0);
					WE_1_A <= WE_1;
					k1_ready <= '0';
					k1_output_sel <= "10";
					bram_1_A_busy := '1';
				elsif (bram_1_B_busy = '0') then
					DI_1_B <= DI_1;
					ADDR_1_B <= ADDR_1(8 downto 0);
					WE_1_B <= WE_1;
					k1_ready <= '0';
					k1_output_sel <= "11";
					bram_1_B_busy := '1';
				end if;

			end if;

			if (k2_requested_bram = "1" and REQ_2 = '1') then

				if (bram_1_A_busy = '0') then
					DI_1_A <= DI_2;
					ADDR_1_A <= ADDR_2(8 downto 0);
					WE_1_A <= WE_2;
					k2_ready <= '0';
					k2_output_sel <= "10";
					bram_1_A_busy := '1';
				elsif (bram_1_B_busy = '0') then
					DI_1_B <= DI_2;
					ADDR_1_B <= ADDR_2(8 downto 0);
					WE_1_B <= WE_2;
					k2_ready <= '0';
					k2_output_sel <= "11";
					bram_1_B_busy := '1';
				end if;

			end if;

			if (k3_requested_bram = "1" and REQ_3 = '1') then

				if (bram_1_A_busy = '0') then
					DI_1_A <= DI_3;
					ADDR_1_A <= ADDR_3(8 downto 0);
					WE_1_A <= WE_3;
					k3_ready <= '0';
					k3_output_sel <= "10";
					bram_1_A_busy := '1';
				elsif (bram_1_B_busy = '0') then
					DI_1_B <= DI_3;
					ADDR_1_B <= ADDR_3(8 downto 0);
					WE_1_B <= WE_3;
					k3_ready <= '0';
					k3_output_sel <= "11";
					bram_1_B_busy := '1';
				end if;

			end if;

		else

			if (k0_ready = '0') then k0_ready <= '1'; end if;
			if (k1_ready = '0') then k1_ready <= '1'; end if;
			if (k2_ready = '0') then k2_ready <= '1'; end if;
			if (k3_ready = '0') then k3_ready <= '1'; end if;

			bram_0_A_busy := '0';
			bram_0_B_busy := '0';
			bram_1_A_busy := '0';
			bram_1_B_busy := '0';

		end if;

	end process input_controller;


	output_controller : process (TRIG_CLK) begin

		if (k0_output_sel = "00") then DO_0 <= DO_0_A; elsif
		   (k0_output_sel = "01") then DO_0 <= DO_0_B; elsif
		   (k0_output_sel = "10") then DO_0 <= DO_1_A; elsif
		   (k0_output_sel = "11") then DO_0 <= DO_1_B;
		end if;
		if (k1_output_sel = "00") then DO_1 <= DO_0_A; elsif
		   (k1_output_sel = "01") then DO_1 <= DO_0_B; elsif
		   (k1_output_sel = "10") then DO_1 <= DO_1_A; elsif
		   (k1_output_sel = "11") then DO_1 <= DO_1_B;
		end if;
		if (k2_output_sel = "00") then DO_2 <= DO_0_A; elsif
		   (k2_output_sel = "01") then DO_2 <= DO_0_B; elsif
		   (k2_output_sel = "10") then DO_2 <= DO_1_A; elsif
		   (k2_output_sel = "11") then DO_2 <= DO_1_B;
		end if;
		if (k3_output_sel = "00") then DO_3 <= DO_0_A; elsif
		   (k3_output_sel = "01") then DO_3 <= DO_0_B; elsif
		   (k3_output_sel = "10") then DO_3 <= DO_1_A; elsif
		   (k3_output_sel = "11") then DO_3 <= DO_1_B;
		end if;

	end process output_controller;


	RAMB16BWER_0 : RAMB16BWER

	generic map (

		-- Configurable data with for ports A and B
		DATA_WIDTH_A => 36,
		DATA_WIDTH_B => 36,

		-- Enable RST capability
		EN_RSTRAM_A => TRUE,
		EN_RSTRAM_B => TRUE,

		-- Reset type
		RSTTYPE => "SYNC",

		-- Optional port output register
		DOA_REG => 0,
		DOB_REG => 0,
		-- Priority given to RAM RST over EN pin (when DO[A|B]_REG = 0)
		RST_PRIORITY_A => "SR",
		RST_PRIORITY_B => "SR",

		-- Initial values on ports
		INIT_A => X"000000000",
		INIT_B => X"000000000",
		INIT_FILE => "NONE",

		-- Warning produced and affected outputs/memory location go unknown
		SIM_COLLISION_CHECK => "ALL",

		-- Simulation device (must be set to "SPARTAN6" for proper simulation behavior
		SIM_DEVICE => "SPARTAN6",

		-- Output value on the DO ports upon the assertion of the syncronous reset signal
		SRVAL_A => X"000000000",
		SRVAL_B => X"000000000",

		-- NO_CHANGE mode: the output latches remain unchanged during a write operation
		WRITE_MODE_A => "READ_FIRST",
		WRITE_MODE_B => "READ_FIRST",

		-- Initial contents of the RAM
		INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",

		-- Parity bits initialization
		INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000"

	) port map (

		DOA                  => DO_0_A,              -- Output port-A data
		DOB                  => DO_0_B,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => DI_0_A,              -- Input port-A data
		DIB                  => DI_0_B,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => ADDR_0_A,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => ADDR_0_B,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => EN_0_A,              -- Input port-A enable
		ENB                  => EN_0_B,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => WE_0_A,              -- Input port-A write enable
		WEB                  => WE_0_B               -- Input port-B write enable

	);

	RAMB16BWER_1 : RAMB16BWER

	generic map (

		-- Configurable data with for ports A and B
		DATA_WIDTH_A => 36,
		DATA_WIDTH_B => 36,

		-- Enable RST capability
		EN_RSTRAM_A => TRUE,
		EN_RSTRAM_B => TRUE,

		-- Reset type
		RSTTYPE => "SYNC",

		-- Optional port output register
		DOA_REG => 0,
		DOB_REG => 0,
		-- Priority given to RAM RST over EN pin (when DO[A|B]_REG = 0)
		RST_PRIORITY_A => "SR",
		RST_PRIORITY_B => "SR",

		-- Initial values on ports
		INIT_A => X"000000000",
		INIT_B => X"000000000",
		INIT_FILE => "NONE",

		-- Warning produced and affected outputs/memory location go unknown
		SIM_COLLISION_CHECK => "ALL",

		-- Simulation device (must be set to "SPARTAN6" for proper simulation behavior
		SIM_DEVICE => "SPARTAN6",

		-- Output value on the DO ports upon the assertion of the syncronous reset signal
		SRVAL_A => X"000000000",
		SRVAL_B => X"000000000",

		-- NO_CHANGE mode: the output latches remain unchanged during a write operation
		WRITE_MODE_A => "READ_FIRST",
		WRITE_MODE_B => "READ_FIRST",

		-- Initial contents of the RAM
		INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",

		-- Parity bits initialization
		INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000"

	) port map (

		DOA                  => DO_1_A,              -- Output port-A data
		DOB                  => DO_1_B,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => DI_1_A,              -- Input port-A data
		DIB                  => DI_1_B,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => ADDR_1_A,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => ADDR_1_B,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => EN_1_A,              -- Input port-A enable
		ENB                  => EN_1_B,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => WE_1_A,              -- Input port-A write enable
		WEB                  => WE_1_B               -- Input port-B write enable

	);


end smem_arch;
