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

	generic (

		TIME_TO_FINISH_WRITING  : integer := 1000  -- Time until the port finish writing and it can be freed (in picoseconds)

	);

	port (

		DO_0, DO_1, DO_2, DO_3           : out std_logic_vector(31 downto 0);    -- Data output ports
		DI_0, DI_1, DI_2, DI_3           : in  std_logic_vector(31 downto 0);    -- Data input ports
		ADDR_0, ADDR_1, ADDR_2, ADDR_3   : in  std_logic_vector(9 downto 0);     -- Address input ports
		WE_0, WE_1, WE_2, WE_3           : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
		CLK_EVEN, CLK_ODD, RST           : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3       : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3       : out std_logic_vector(1 downto 0) := "00"                  -- Ready output ports

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
	--   p#_busy              Set to 1 if port # is busy
	--   p#_enabled           Enable each port for write or reading
	--
	--   DO_#_[A|B]           Data output of BRAM # in port [A|B]
	--
	--   update_output_#      On change, the output selection for kernel # is updated
	--

	signal k0_needs_attention  : std_logic := '0';
	signal k0_being_served     : std_logic := '0';
	signal k0_has_been_served  : std_logic := '1';
	signal k0_given_port       : std_logic := '0';
	signal k0_requested_bram   : std_logic_vector(0 downto 0) := "0";

	signal k1_needs_attention  : std_logic := '0';
	signal k1_being_served     : std_logic := '0';
	signal k1_has_been_served  : std_logic := '1';
	signal k1_given_port       : std_logic := '0';
	signal k1_requested_bram   : std_logic_vector(0 downto 0) := "0";

	signal k2_needs_attention  : std_logic := '0';
	signal k2_being_served     : std_logic := '0';
	signal k2_has_been_served  : std_logic := '1';
	signal k2_given_port       : std_logic := '0';
	signal k2_requested_bram   : std_logic_vector(0 downto 0) := "0";

	signal k3_needs_attention  : std_logic := '0';
	signal k3_being_served     : std_logic := '0';
	signal k3_has_been_served  : std_logic := '1';
	signal k3_given_port       : std_logic := '0';
	signal k3_requested_bram   : std_logic_vector(0 downto 0) := "0";


	signal bram_0_A_busy       : std_logic := '0';
	signal bram_0_B_busy       : std_logic := '0';
	signal bram_1_A_busy       : std_logic := '0';
	signal bram_1_B_busy       : std_logic := '0';


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

	signal update_output_0     : std_logic := '0';
	signal update_output_1     : std_logic := '0';
	signal update_output_2     : std_logic := '0';
	signal update_output_3     : std_logic := '0';


begin


	-- TODO: review lines below (temporary workaround)
	EN_0_A    <= '1';
	EN_0_B    <= '1';
	EN_1_A    <= '1';
	EN_1_B    <= '1';
	RDY_0(0)  <= k0_being_served;
	RDY_1(0)  <= k1_being_served;
	RDY_2(0)  <= k2_being_served;
	RDY_3(0)  <= k3_being_served;
	RDY_0(1)  <= k0_has_been_served;
	RDY_1(1)  <= k1_has_been_served;
	RDY_2(1)  <= k2_has_been_served;
	RDY_3(1)  <= k3_has_been_served;


	k0_requested_bram <= ADDR_0(9 downto 9);
	k1_requested_bram <= ADDR_1(9 downto 9);
	k2_requested_bram <= ADDR_2(9 downto 9);
	k3_requested_bram <= ADDR_3(9 downto 9);


	input_controller_0 : process (

		bram_0_A_busy, bram_0_B_busy,
		REQ_0, REQ_1, REQ_2, REQ_3,
		CLK_EVEN, CLK_ODD,
		k0_has_been_served, k1_has_been_served, k2_has_been_served, k3_has_been_served

	)

	begin

		if (CLK_EVEN'event and CLK_EVEN = '1') then
			if (k0_being_served = '1' and k0_given_port = '0') then
				k0_being_served <= '0';
			end if;
			if (k1_being_served = '1' and k1_given_port = '0') then
				k1_being_served <= '0';
			end if;
			if (k2_being_served = '1' and k2_given_port = '0') then
				k2_being_served <= '0';
			end if;
			if (k3_being_served = '1' and k3_given_port = '0') then
				k3_being_served <= '0';
			end if;
		elsif (CLK_ODD'event and CLK_ODD = '1') then
			if (k0_being_served = '1' and k0_given_port = '1') then
				k0_being_served <= '0';
			end if;
			if (k1_being_served = '1' and k1_given_port = '1') then
				k1_being_served <= '0';
			end if;
			if (k2_being_served = '1' and k2_given_port = '1') then
				k2_being_served <= '0';
			end if;
			if (k3_being_served = '1' and k3_given_port = '1') then
				k3_being_served <= '0';
			end if;
		end if;

		if (REQ_0 = '1' and k0_requested_bram = "0" and k0_being_served = '0' and k0_has_been_served = '1') then
			if (bram_0_A_busy = '0') then
				bram_0_A_busy <= '1';
				DI_0_A <= DI_0;
				ADDR_0_A <= ADDR_0(8 downto 0);
				WE_0_A <= WE_0;
				k0_given_port <= '0';
				k0_being_served <= '1';
			elsif (bram_0_B_busy = '0') then
				bram_0_B_busy <= '1';
				DI_0_B <= DI_0;
				ADDR_0_B <= ADDR_0(8 downto 0);
				WE_0_B <= WE_0;
				k0_given_port <= '1';
				k0_being_served <= '1';
			end if;
		end if;

	end process input_controller_0;

	ready_signal_trigger_0 : process begin
		trigger_loop : loop
			wait until k0_being_served'event;
			if (k0_being_served = '0') then
				update_output_0 <= not update_output_0;
				k0_has_been_served <= '1' after 1 ns;
			else
				k0_has_been_served <= '0';
			end if;
		end loop trigger_loop;
	end process ready_signal_trigger_0;

	--
	-- data_output_#
	--
	-- This process selects the corresponding output port that the kernel
	-- needs depending on the requested bank (BRAM) and the assigned port
	-- that is given by the input per-BRAM controller.
	--

	data_output_0 : process (update_output_0) begin
		if (k0_requested_bram = "0") then
			if (k0_given_port = '0') then
				DO_0 <= DO_0_A;
			else
				DO_0 <= DO_0_B;
			end if;
		elsif (k0_requested_bram = "1") then
			if (k0_given_port = '0') then
				DO_0 <= DO_1_A;
			else
				DO_0 <= DO_1_B;
			end if;
		end if;
	end process data_output_0;

	data_output_1 : process (update_output_1) begin
		if (k1_requested_bram = "0") then
			if (k1_given_port = '0') then
				DO_1 <= DO_0_A;
			else
				DO_1 <= DO_0_B;
			end if;
		elsif (k1_requested_bram = "1") then
			if (k1_given_port = '0') then
				DO_1 <= DO_1_A;
			else
				DO_1 <= DO_1_B;
			end if;
		end if;
	end process data_output_1;

	data_output_2 : process (update_output_2) begin
		if (k2_requested_bram = "0") then
			if (k2_given_port = '0') then
				DO_2 <= DO_0_A;
			else
				DO_2 <= DO_0_B;
			end if;
		elsif (k2_requested_bram = "1") then
			if (k2_given_port = '0') then
				DO_2 <= DO_1_A;
			else
				DO_2 <= DO_1_B;
			end if;
		end if;
	end process data_output_2;

	data_output_3 : process (update_output_3) begin
		if (k3_requested_bram = "0") then
			if (k3_given_port = '0') then
				DO_3 <= DO_0_A;
			else
				DO_3 <= DO_0_B;
			end if;
		elsif (k3_requested_bram = "1") then
			if (k3_given_port = '0') then
				DO_3 <= DO_1_A;
			else
				DO_3 <= DO_1_B;
			end if;
		end if;
	end process data_output_3;


	--
	-- BRAM instantiation and configuration
	--

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
		WRITE_MODE_A => "NO_CHANGE",
		WRITE_MODE_B => "NO_CHANGE",

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
		ADDRA(13 downto 5)   => ADDR_0_A,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => ADDR_0_B,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => CLK_EVEN,            -- Input port-A clock
		CLKB                 => CLK_ODD,             -- Input port-B clock
		DIA                  => DI_0_A,              -- Input port-A data
		DIB                  => DI_0_B,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
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
		WRITE_MODE_A => "NO_CHANGE",
		WRITE_MODE_B => "NO_CHANGE",

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
		ADDRA(13 downto 5)   => ADDR_1_A,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => ADDR_1_B,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => CLK_EVEN,            -- Input port-A clock
		CLKB                 => CLK_ODD,             -- Input port-B clock
		DIA                  => DI_1_A,              -- Input port-A data
		DIB                  => DI_1_A,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
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
