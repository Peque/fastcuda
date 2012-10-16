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

		N_PORTS         : integer := 4;
		N_BRAMS         : integer := 2;
		LOG2_N_PORTS    : integer := 2  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code

	);

	port (

		DO                     : out std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data output ports
		DI                     : in  std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data input ports
		ADDR_0, ADDR_1, ADDR_2, ADDR_3     : in  std_logic_vector(9 downto 0);    -- Address input ports
		WE_0, WE_1, WE_2, WE_3                     : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
		BRAM_CLK, TRIG_CLK, RST                                            : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3             : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3             : out std_logic                         -- Ready output port

	);

end smem;



architecture smem_arch of smem is


	constant DIP_value         : std_logic_vector(3 downto 0) := "0000";
	constant LOWADDR_value     : std_logic_vector(4 downto 0) := "00000";
	constant REGCE_value       : std_logic := '0';
	constant EN_value          : std_logic := '1';

	signal k0_output_sel       : bit_vector(1 downto 0) := "00";
	signal k1_output_sel       : bit_vector(1 downto 0) := "00";
	signal k2_output_sel       : bit_vector(1 downto 0) := "00";
	signal k3_output_sel       : bit_vector(1 downto 0) := "00";

	signal k0_being_served     : bit := '0';
	signal k1_being_served     : bit := '0';
	signal k2_being_served     : bit := '0';
	signal k3_being_served     : bit := '0';

	signal we_0_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_1_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_2_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_3_safe           : std_logic_vector(3 downto 0) := "0000";

	signal bram_0_input_sel    : bit_vector(1 downto 0) := "00";
	signal bram_1_input_sel    : bit_vector(1 downto 0) := "00";
	signal bram_2_input_sel    : bit_vector(1 downto 0) := "00";
	signal bram_3_input_sel    : bit_vector(1 downto 0) := "00";

	signal k0_needs_bram_0     : bit := '0';
	signal k0_needs_bram_1     : bit := '0';
	signal k1_needs_bram_0     : bit := '0';
	signal k1_needs_bram_1     : bit := '0';
	signal k2_needs_bram_0     : bit := '0';
	signal k2_needs_bram_1     : bit := '0';
	signal k3_needs_bram_0     : bit := '0';
	signal k3_needs_bram_1     : bit := '0';

	signal bram_do             : std_logic_vector(N_PORTS * 32 - 1 downto 0);
	signal bram_di             : std_logic_vector(N_PORTS * 32 - 1 downto 0);
	signal bram_addr           : std_logic_vector(N_PORTS * 9  - 1 downto 0);
	signal bram_we             : std_logic_vector(N_PORTS * 4  - 1 downto 0);
	signal bram_en             : std_logic_vector(N_PORTS * 1  - 1 downto 0);


begin


	bram_en(0) <= '1';
	bram_en(1) <= '1';
	bram_en(2) <= '1';
	bram_en(3) <= '1';


	we_0_safe(3) <= WE_0(3) and to_stdulogic(to_bit(REQ_0));
	we_0_safe(2) <= WE_0(2) and to_stdulogic(to_bit(REQ_0));
	we_0_safe(1) <= WE_0(1) and to_stdulogic(to_bit(REQ_0));
	we_0_safe(0) <= WE_0(0) and to_stdulogic(to_bit(REQ_0));

	we_1_safe(3) <= WE_1(3) and to_stdulogic(to_bit(REQ_1));
	we_1_safe(2) <= WE_1(2) and to_stdulogic(to_bit(REQ_1));
	we_1_safe(1) <= WE_1(1) and to_stdulogic(to_bit(REQ_1));
	we_1_safe(0) <= WE_1(0) and to_stdulogic(to_bit(REQ_1));

	we_2_safe(3) <= WE_2(3) and to_stdulogic(to_bit(REQ_2));
	we_2_safe(2) <= WE_2(2) and to_stdulogic(to_bit(REQ_2));
	we_2_safe(1) <= WE_2(1) and to_stdulogic(to_bit(REQ_2));
	we_2_safe(0) <= WE_2(0) and to_stdulogic(to_bit(REQ_2));

	we_3_safe(3) <= WE_3(3) and to_stdulogic(to_bit(REQ_3));
	we_3_safe(2) <= WE_3(2) and to_stdulogic(to_bit(REQ_3));
	we_3_safe(1) <= WE_3(1) and to_stdulogic(to_bit(REQ_3));
	we_3_safe(0) <= WE_3(0) and to_stdulogic(to_bit(REQ_3));


	RDY_0 <= to_stdulogic(k0_being_served);
	RDY_1 <= to_stdulogic(k1_being_served);
	RDY_2 <= to_stdulogic(k2_being_served);
	RDY_3 <= to_stdulogic(k3_being_served);

	k0_needs_bram_0 <= to_bit(REQ_0) and not to_bit(ADDR_0(9));
	k0_needs_bram_1 <= to_bit(REQ_0) and     to_bit(ADDR_0(9));

	k1_needs_bram_0 <= to_bit(REQ_1) and not to_bit(ADDR_1(9));
	k1_needs_bram_1 <= to_bit(REQ_1) and     to_bit(ADDR_1(9));

	k2_needs_bram_0 <= to_bit(REQ_2) and not to_bit(ADDR_2(9));
	k2_needs_bram_1 <= to_bit(REQ_2) and     to_bit(ADDR_2(9));

	k3_needs_bram_0 <= to_bit(REQ_3) and not to_bit(ADDR_3(9));
	k3_needs_bram_1 <= to_bit(REQ_3) and     to_bit(ADDR_3(9));


	bram_0_input_sel(1) <= not ((k0_needs_bram_0 or k1_needs_bram_0));
	bram_2_input_sel(1) <= not ((k0_needs_bram_1 or k1_needs_bram_1));

	bram_0_input_sel(0) <= not ((k0_needs_bram_0) or ((k2_needs_bram_0) and (not k1_needs_bram_0)));
	bram_2_input_sel(0) <= not ((k0_needs_bram_1) or ((k2_needs_bram_1) and (not k1_needs_bram_1)));


	bram_1_input_sel(1) <= (k3_needs_bram_0 or k2_needs_bram_0);
	bram_3_input_sel(1) <= (k3_needs_bram_1 or k2_needs_bram_1);

	bram_1_input_sel(0) <= (k3_needs_bram_0) or ((k1_needs_bram_0) and (not k2_needs_bram_0));
	bram_3_input_sel(0) <= (k3_needs_bram_1) or ((k1_needs_bram_1) and (not k2_needs_bram_1));



	k0_being_served <= to_bit(REQ_0);

	k1_being_served <= to_bit(REQ_1) and (
	                       ( not k1_output_sel(0) and ( ( not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(0) and ( ( not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_1)) );

	k2_being_served <= to_bit(REQ_2) and (
	                       ( not k2_output_sel(0) and ( (     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(0) and ( (     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_2)) );

	k3_being_served <= to_bit(REQ_3);


	k0_output_sel(1 downto 1) <= to_bitvector(ADDR_0(9 downto 9));
	k1_output_sel(1 downto 1) <= to_bitvector(ADDR_1(9 downto 9));
	k2_output_sel(1 downto 1) <= to_bitvector(ADDR_2(9 downto 9));
	k3_output_sel(1 downto 1) <= to_bitvector(ADDR_3(9 downto 9));


	k0_output_sel(0) <= ( not k0_output_sel(1) and ( not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    (     k0_output_sel(1) and ( not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) );

	k1_output_sel(0) <= ( not k1_output_sel(1) and ( not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    (     k1_output_sel(1) and ( not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) );

	k2_output_sel(0) <= ( not k2_output_sel(1) and (     bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    (     k2_output_sel(1) and (     bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) );

	k3_output_sel(0) <= ( not k3_output_sel(1) and (     bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    (     k3_output_sel(1) and (     bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) );


	input_controller_0 : block begin
		with bram_0_input_sel select
			bram_di(1 * 32 - 1 downto 0 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "00",
			              DI(32 * 2 - 1 downto 32 * 1) when "01",
			              DI(32 * 3 - 1 downto 32 * 2) when "10",
			              DI(32 * 4 - 1 downto 32 * 3) when "11";
		with bram_0_input_sel select
			bram_addr(1 * 9 - 1 downto 0 * 9)  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_0_input_sel select
			bram_we(1 * 4 - 1 downto 0 * 4)    <=  we_0_safe when "00",
			              we_1_safe when "01",
			              we_2_safe when "10",
			              we_3_safe when "11";
	end block input_controller_0;

	input_controller_1 : block begin
		with bram_1_input_sel select
			bram_di(2 * 32 - 1 downto 1 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "00",
			              DI(32 * 2 - 1 downto 32 * 1) when "01",
			              DI(32 * 3 - 1 downto 32 * 2) when "10",
			              DI(32 * 4 - 1 downto 32 * 3) when "11";
		with bram_1_input_sel select
			bram_addr(2 * 9 - 1 downto 1 * 9)  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_1_input_sel select
			bram_we(2 * 4 - 1 downto 1 * 4)    <=  we_0_safe when "00",
			              we_1_safe when "01",
			              we_2_safe when "10",
			              we_3_safe when "11";
	end block input_controller_1;

	input_controller_2 : block begin
		with bram_2_input_sel select
			bram_di(3 * 32 - 1 downto 2 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "00",
			              DI(32 * 2 - 1 downto 32 * 1) when "01",
			              DI(32 * 3 - 1 downto 32 * 2) when "10",
			              DI(32 * 4 - 1 downto 32 * 3) when "11";
		with bram_2_input_sel select
			bram_addr(3 * 9 - 1 downto 2 * 9)  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_2_input_sel select
			bram_we(3 * 4 - 1 downto 2 * 4)    <=  we_0_safe when "00",
			              we_1_safe when "01",
			              we_2_safe when "10",
			              we_3_safe when "11";
	end block input_controller_2;

	input_controller_3 : block begin
		with bram_3_input_sel select
			bram_di(4 * 32 - 1 downto 3 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "00",
			              DI(32 * 2 - 1 downto 32 * 1) when "01",
			              DI(32 * 3 - 1 downto 32 * 2) when "10",
			              DI(32 * 4 - 1 downto 32 * 3) when "11";
		with bram_3_input_sel select
			bram_addr(4 * 9 - 1 downto 3 * 9)  <=  ADDR_0(8 downto 0) when "00",
			              ADDR_1(8 downto 0) when "01",
			              ADDR_2(8 downto 0) when "10",
			              ADDR_3(8 downto 0) when "11";
		with bram_3_input_sel select
			bram_we(4 * 4 - 1 downto 3 * 4)    <=  we_0_safe when "00",
			              we_1_safe when "01",
			              we_2_safe when "10",
			              we_3_safe when "11";
	end block input_controller_3;


	output_controller_0 : block begin
		with k0_output_sel select
			DO(32 * 1 - 1 downto 32 * 0) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO(32 * 2 - 1 downto 32 * 1) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO(32 * 3 - 1 downto 32 * 2) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO(32 * 4 - 1 downto 32 * 3) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_3;


	bram_inst : for i in 0 to N_PORTS / 2 - 1 generate

		RAMB16BWER_INST : RAMB16BWER

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

			DOA                  => bram_do((2 * i + 1) * 32 - 1 downto (2 * i + 0) * 32),    -- Output port-A data
			DOB                  => bram_do((2 * i + 2) * 32 - 1 downto (2 * i + 1) * 32),    -- Output port-B data
			DOPA                 => open,                                                     -- We are not using parity bits
			DOPB                 => open,                                                     -- We are not using parity bits
			DIA                  => bram_di((2 * i + 1) * 32 - 1 downto (2 * i + 0) * 32),    -- Input port-A data
			DIB                  => bram_di((2 * i + 2) * 32 - 1 downto (2 * i + 1) * 32),    -- Input port-B data
			DIPA                 => DIP_value,                                                -- Input parity bits always set to 0 (not using them)
			DIPB                 => DIP_value,                                                -- Input parity bits always set to 0 (not using them)
			ADDRA(13 downto 5)   => bram_addr((2 * i + 1) * 9 - 1 downto (2 * i + 0) * 9),    -- Input port-A address
			ADDRA(4 downto 0)    => LOWADDR_value,                                            -- Set low adress bits to 0
			ADDRB(13 downto 5)   => bram_addr((2 * i + 2) * 9 - 1 downto (2 * i + 1) * 9),    -- Input port-B address
			ADDRB(4 downto 0)    => LOWADDR_value,                                            -- Set low adress bits to 0
			CLKA                 => BRAM_CLK,                                                 -- Input port-A clock
			CLKB                 => BRAM_CLK,                                                 -- Input port-B clock
			ENA                  => bram_en(2 * i),                                           -- Input port-A enable
			ENB                  => bram_en(2 * i + 1),                                       -- Input port-B enable
			REGCEA               => REGCE_value,                                              -- Input port-A output register enable
			REGCEB               => REGCE_value,                                              -- Input port-B output register enable
			RSTA                 => RST,                                                      -- Input port-A reset
			RSTB                 => RST,                                                      -- Input port-B reset
			WEA                  => bram_we((2 * i + 1) * 4 - 1 downto (2 * i + 0) * 4),      -- Input port-A write enable
			WEB                  => bram_we((2 * i + 2) * 4 - 1 downto (2 * i + 1) * 4)       -- Input port-B write enable

		);

	end generate bram_inst;


end smem_arch;
