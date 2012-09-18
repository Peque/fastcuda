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
	--   TODO: update comments bellow! (outdated signals)
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

	signal k0_output_sel       : bit_vector(1 downto 0) := "00";
	signal k1_output_sel       : bit_vector(1 downto 0) := "00";
	signal k2_output_sel       : bit_vector(1 downto 0) := "00";
	signal k3_output_sel       : bit_vector(1 downto 0) := "00";

	signal k0_being_served     : bit := '0';
	signal k1_being_served     : bit := '0';
	signal k2_being_served     : bit := '0';
	signal k3_being_served     : bit := '0';

	signal bram_0_A_input_sel  : bit_vector(1 downto 0) := "00";
	signal bram_0_B_input_sel  : bit_vector(1 downto 0) := "00";
	signal bram_1_A_input_sel  : bit_vector(1 downto 0) := "00";
	signal bram_1_B_input_sel  : bit_vector(1 downto 0) := "00";

	signal do_0_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal do_0_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_0_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_0_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal addr_0_a            : std_logic_vector(8 downto 0) := "000000000";
	signal addr_0_b            : std_logic_vector(8 downto 0) := "000000000";
	signal we_0_a              : std_logic_vector(3 downto 0) := "0000";
	signal we_0_b              : std_logic_vector(3 downto 0) := "0000";
	signal en_0_a              : std_logic := '0';
	signal en_0_b              : std_logic := '0';

	signal do_1_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal do_1_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_1_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_1_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal addr_1_a            : std_logic_vector(8 downto 0) := "000000000";
	signal addr_1_b            : std_logic_vector(8 downto 0) := "000000000";
	signal we_1_a              : std_logic_vector(3 downto 0) := "0000";
	signal we_1_b              : std_logic_vector(3 downto 0) := "0000";
	signal en_1_a              : std_logic := '0';
	signal en_1_b              : std_logic := '0';


begin


	-- TODO: decide if enable signals should always be set to 1...
	en_0_a <= '1';
	en_0_b <= '1';
	en_1_a <= '1';
	en_1_b <= '1';


	-- TODO: implement a decent input and output controller block
	bram_0_A_input_sel <= "00";
	bram_0_B_input_sel <= "01";
	bram_1_A_input_sel <= "10";
	bram_1_B_input_sel <= "11";


	k0_being_served <= REQ_0 and ( (not bram_0_A_input_sel(1) and not bram_0_A_input_sel(0)) or
	                               (not bram_0_B_input_sel(1) and not bram_0_B_input_sel(0)) or
	                               (not bram_1_A_input_sel(1) and not bram_1_A_input_sel(0)) or
	                               (not bram_1_B_input_sel(1) and not bram_1_B_input_sel(0)) );

	k1_being_served <= REQ_1 and ( (not bram_0_A_input_sel(1) and     bram_0_A_input_sel(0)) or
	                               (not bram_0_B_input_sel(1) and     bram_0_B_input_sel(0)) or
	                               (not bram_1_A_input_sel(1) and     bram_1_A_input_sel(0)) or
	                               (not bram_1_B_input_sel(1) and     bram_1_B_input_sel(0)) );

	k2_being_served <= REQ_2 and ( (    bram_0_A_input_sel(1) and not bram_0_A_input_sel(0)) or
	                               (    bram_0_B_input_sel(1) and not bram_0_B_input_sel(0)) or
	                               (    bram_1_A_input_sel(1) and not bram_1_A_input_sel(0)) or
	                               (    bram_1_B_input_sel(1) and not bram_1_B_input_sel(0)) );

	k3_being_served <= REQ_3 and ( (    bram_0_A_input_sel(1) and     bram_0_A_input_sel(0)) or
	                               (    bram_0_B_input_sel(1) and     bram_0_B_input_sel(0)) or
	                               (    bram_1_A_input_sel(1) and     bram_1_A_input_sel(0)) or
	                               (    bram_1_B_input_sel(1) and     bram_1_B_input_sel(0)) );


	--
	-- The higher bits of the output selection signal represent the BRAM
	-- which may be being used and, therefore, are the higher input port
	-- address bits.
	--
	k0_output_sel(1 downto 1) <= to_bitvector(ADDR_0(9 downto 9));
	k1_output_sel(1 downto 1) <= to_bitvector(ADDR_1(9 downto 9));
	k2_output_sel(1 downto 1) <= to_bitvector(ADDR_2(9 downto 9));
	k3_output_sel(1 downto 1) <= to_bitvector(ADDR_3(9 downto 9));


	--
	-- The lower bit of the output selection signal represent the BRAM
	-- port that may be being used:
	--
	--   kX_output_sel(0) = (ADDR_0(8 downto 0) == addr_0_b) or (ADDR_0(8 downto 0) == addr_1_b)
	--
	k0_output_sel(0) <= ( ( to_bit(ADDR_0(0)) xnor to_bit(addr_0_b(0)) ) and
	                      ( to_bit(ADDR_0(1)) xnor to_bit(addr_0_b(1)) ) and
	                      ( to_bit(ADDR_0(2)) xnor to_bit(addr_0_b(2)) ) and
	                      ( to_bit(ADDR_0(3)) xnor to_bit(addr_0_b(3)) ) and
	                      ( to_bit(ADDR_0(4)) xnor to_bit(addr_0_b(4)) ) and
	                      ( to_bit(ADDR_0(5)) xnor to_bit(addr_0_b(5)) ) and
	                      ( to_bit(ADDR_0(6)) xnor to_bit(addr_0_b(6)) ) and
	                      ( to_bit(ADDR_0(7)) xnor to_bit(addr_0_b(7)) ) and
	                      ( to_bit(ADDR_0(8)) xnor to_bit(addr_0_b(8)) ) )
	                    or
	                    ( ( to_bit(ADDR_0(0)) xnor to_bit(addr_1_b(0)) ) and
	                      ( to_bit(ADDR_0(1)) xnor to_bit(addr_1_b(1)) ) and
	                      ( to_bit(ADDR_0(2)) xnor to_bit(addr_1_b(2)) ) and
	                      ( to_bit(ADDR_0(3)) xnor to_bit(addr_1_b(3)) ) and
	                      ( to_bit(ADDR_0(4)) xnor to_bit(addr_1_b(4)) ) and
	                      ( to_bit(ADDR_0(5)) xnor to_bit(addr_1_b(5)) ) and
	                      ( to_bit(ADDR_0(6)) xnor to_bit(addr_1_b(6)) ) and
	                      ( to_bit(ADDR_0(7)) xnor to_bit(addr_1_b(7)) ) and
	                      ( to_bit(ADDR_0(8)) xnor to_bit(addr_1_b(8)) ) );

	k1_output_sel(0) <= ( ( to_bit(ADDR_1(0)) xnor to_bit(addr_0_b(0)) ) and
	                      ( to_bit(ADDR_1(1)) xnor to_bit(addr_0_b(1)) ) and
	                      ( to_bit(ADDR_1(2)) xnor to_bit(addr_0_b(2)) ) and
	                      ( to_bit(ADDR_1(3)) xnor to_bit(addr_0_b(3)) ) and
	                      ( to_bit(ADDR_1(4)) xnor to_bit(addr_0_b(4)) ) and
	                      ( to_bit(ADDR_1(5)) xnor to_bit(addr_0_b(5)) ) and
	                      ( to_bit(ADDR_1(6)) xnor to_bit(addr_0_b(6)) ) and
	                      ( to_bit(ADDR_1(7)) xnor to_bit(addr_0_b(7)) ) and
	                      ( to_bit(ADDR_1(8)) xnor to_bit(addr_0_b(8)) ) )
	                    or
	                    ( ( to_bit(ADDR_1(0)) xnor to_bit(addr_1_b(0)) ) and
	                      ( to_bit(ADDR_1(1)) xnor to_bit(addr_1_b(1)) ) and
	                      ( to_bit(ADDR_1(2)) xnor to_bit(addr_1_b(2)) ) and
	                      ( to_bit(ADDR_1(3)) xnor to_bit(addr_1_b(3)) ) and
	                      ( to_bit(ADDR_1(4)) xnor to_bit(addr_1_b(4)) ) and
	                      ( to_bit(ADDR_1(5)) xnor to_bit(addr_1_b(5)) ) and
	                      ( to_bit(ADDR_1(6)) xnor to_bit(addr_1_b(6)) ) and
	                      ( to_bit(ADDR_1(7)) xnor to_bit(addr_1_b(7)) ) and
	                      ( to_bit(ADDR_1(8)) xnor to_bit(addr_1_b(8)) ) );

	k2_output_sel(0) <= ( ( to_bit(ADDR_2(0)) xnor to_bit(addr_0_b(0)) ) and
	                      ( to_bit(ADDR_2(1)) xnor to_bit(addr_0_b(1)) ) and
	                      ( to_bit(ADDR_2(2)) xnor to_bit(addr_0_b(2)) ) and
	                      ( to_bit(ADDR_2(3)) xnor to_bit(addr_0_b(3)) ) and
	                      ( to_bit(ADDR_2(4)) xnor to_bit(addr_0_b(4)) ) and
	                      ( to_bit(ADDR_2(5)) xnor to_bit(addr_0_b(5)) ) and
	                      ( to_bit(ADDR_2(6)) xnor to_bit(addr_0_b(6)) ) and
	                      ( to_bit(ADDR_2(7)) xnor to_bit(addr_0_b(7)) ) and
	                      ( to_bit(ADDR_2(8)) xnor to_bit(addr_0_b(8)) ) )
	                    or
	                    ( ( to_bit(ADDR_2(0)) xnor to_bit(addr_1_b(0)) ) and
	                      ( to_bit(ADDR_2(1)) xnor to_bit(addr_1_b(1)) ) and
	                      ( to_bit(ADDR_2(2)) xnor to_bit(addr_1_b(2)) ) and
	                      ( to_bit(ADDR_2(3)) xnor to_bit(addr_1_b(3)) ) and
	                      ( to_bit(ADDR_2(4)) xnor to_bit(addr_1_b(4)) ) and
	                      ( to_bit(ADDR_2(5)) xnor to_bit(addr_1_b(5)) ) and
	                      ( to_bit(ADDR_2(6)) xnor to_bit(addr_1_b(6)) ) and
	                      ( to_bit(ADDR_2(7)) xnor to_bit(addr_1_b(7)) ) and
	                      ( to_bit(ADDR_2(8)) xnor to_bit(addr_1_b(8)) ) );

	k3_output_sel(0) <= ( ( to_bit(ADDR_3(0)) xnor to_bit(addr_0_b(0)) ) and
	                      ( to_bit(ADDR_3(1)) xnor to_bit(addr_0_b(1)) ) and
	                      ( to_bit(ADDR_3(2)) xnor to_bit(addr_0_b(2)) ) and
	                      ( to_bit(ADDR_3(3)) xnor to_bit(addr_0_b(3)) ) and
	                      ( to_bit(ADDR_3(4)) xnor to_bit(addr_0_b(4)) ) and
	                      ( to_bit(ADDR_3(5)) xnor to_bit(addr_0_b(5)) ) and
	                      ( to_bit(ADDR_3(6)) xnor to_bit(addr_0_b(6)) ) and
	                      ( to_bit(ADDR_3(7)) xnor to_bit(addr_0_b(7)) ) and
	                      ( to_bit(ADDR_3(8)) xnor to_bit(addr_0_b(8)) ) )
	                    or
	                    ( ( to_bit(ADDR_3(0)) xnor to_bit(addr_1_b(0)) ) and
	                      ( to_bit(ADDR_3(1)) xnor to_bit(addr_1_b(1)) ) and
	                      ( to_bit(ADDR_3(2)) xnor to_bit(addr_1_b(2)) ) and
	                      ( to_bit(ADDR_3(3)) xnor to_bit(addr_1_b(3)) ) and
	                      ( to_bit(ADDR_3(4)) xnor to_bit(addr_1_b(4)) ) and
	                      ( to_bit(ADDR_3(5)) xnor to_bit(addr_1_b(5)) ) and
	                      ( to_bit(ADDR_3(6)) xnor to_bit(addr_1_b(6)) ) and
	                      ( to_bit(ADDR_3(7)) xnor to_bit(addr_1_b(7)) ) and
	                      ( to_bit(ADDR_3(8)) xnor to_bit(addr_1_b(8)) ) );


	input_controller_0 : block begin
		with bram_0_A_input_sel select
			di_0_a    <=  DI_0 when "00",
			              DI_1 when "01",
			              DI_2 when "10",
			              DI_3 when "11";
		with bram_0_A_input_sel select
			addr_0_a  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_0_A_input_sel select
			we_0_a    <=  WE_0 when "00",
			              WE_1 when "01",
			              WE_2 when "10",
			              WE_3 when "11";
	end block input_controller_0;

	input_controller_1 : block begin
		with bram_0_B_input_sel select
			di_0_b    <=  DI_0 when "00",
			              DI_1 when "01",
			              DI_2 when "10",
			              DI_3 when "11";
		with bram_0_B_input_sel select
			addr_0_b  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_0_B_input_sel select
			we_0_b    <=  WE_0 when "00",
			              WE_1 when "01",
			              WE_2 when "10",
			              WE_3 when "11";
	end block input_controller_1;

	input_controller_2 : block begin
		with bram_1_A_input_sel select
			di_1_a    <=  DI_0 when "00",
			              DI_1 when "01",
			              DI_2 when "10",
			              DI_3 when "11";
		with bram_1_A_input_sel select
			addr_1_a  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_1_A_input_sel select
			we_1_a    <=  WE_0 when "00",
			              WE_1 when "01",
			              WE_2 when "10",
			              WE_3 when "11";
	end block input_controller_2;

	input_controller_3 : block begin
		with bram_1_B_input_sel select
			di_1_b    <=  DI_0 when "00",
			              DI_1 when "01",
			              DI_2 when "10",
			              DI_3 when "11";
		with bram_1_B_input_sel select
			addr_1_b  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_1_B_input_sel select
			we_1_b    <=  WE_0 when "00",
			              WE_1 when "01",
			              WE_2 when "10",
			              WE_3 when "11";
	end block input_controller_3;


	output_controller_0 : block begin
		with k0_output_sel select
			DO_0 <= do_0_a when "00",
			        do_0_b when "01",
			        do_1_a when "10",
			        do_1_b when "11";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO_1 <= do_0_a when "00",
			        do_0_b when "01",
			        do_1_a when "10",
			        do_1_b when "11";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO_2 <= do_0_a when "00",
			        do_0_b when "01",
			        do_1_a when "10",
			        do_1_b when "11";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO_3 <= do_0_a when "00",
			        do_0_b when "01",
			        do_1_a when "10",
			        do_1_b when "11";
	end block output_controller_3;


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

		DOA                  => do_0_a,              -- Output port-A data
		DOB                  => do_0_b,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => di_0_a,              -- Input port-A data
		DIB                  => di_0_b,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => addr_0_a,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => addr_0_b,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => en_0_a,              -- Input port-A enable
		ENB                  => en_0_b,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => we_0_a,              -- Input port-A write enable
		WEB                  => we_0_b               -- Input port-B write enable

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

		DOA                  => do_1_a,              -- Output port-A data
		DOB                  => do_1_b,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => di_1_a,              -- Input port-A data
		DIB                  => di_1_b,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => addr_1_a,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => addr_1_b,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => en_1_a,              -- Input port-A enable
		ENB                  => en_1_b,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => we_1_a,              -- Input port-A write enable
		WEB                  => we_1_b               -- Input port-B write enable

	);


end smem_arch;
