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

		N_PORTS         : integer := 16;
		N_BRAMS         : integer := 8;
		LOG2_N_PORTS    : integer := 4  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code

	);

	port (

		DO                     : out std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data output ports
		DI                     : in  std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data input ports
		ADDR_0, ADDR_1, ADDR_2, ADDR_3, ADDR_4, ADDR_5, ADDR_6, ADDR_7, ADDR_8, ADDR_9, ADDR_10, ADDR_11, ADDR_12, ADDR_13, ADDR_14, ADDR_15     : in  std_logic_vector(11 downto 0);    -- Address input ports
		WE_0, WE_1, WE_2, WE_3, WE_4, WE_5, WE_6, WE_7, WE_8, WE_9, WE_10, WE_11, WE_12, WE_13, WE_14, WE_15                     : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
		BRAM_CLK, TRIG_CLK, RST                                            : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3, REQ_4, REQ_5, REQ_6, REQ_7, REQ_8, REQ_9, REQ_10, REQ_11, REQ_12, REQ_13, REQ_14, REQ_15             : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3, RDY_4, RDY_5, RDY_6, RDY_7, RDY_8, RDY_9, RDY_10, RDY_11, RDY_12, RDY_13, RDY_14, RDY_15             : out std_logic                         -- Ready output port

	);

end smem;



architecture smem_arch of smem is


	constant DIP_value         : std_logic_vector(3 downto 0) := "0000";
	constant LOWADDR_value     : std_logic_vector(4 downto 0) := "00000";
	constant REGCE_value       : std_logic := '0';
	constant EN_value          : std_logic := '1';

	signal k0_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k1_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k2_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k3_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k4_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k5_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k6_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k7_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k8_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k9_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k10_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k11_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k12_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k13_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k14_output_sel       : bit_vector(3 downto 0) := "0000";
	signal k15_output_sel       : bit_vector(3 downto 0) := "0000";

	signal k0_being_served     : bit := '0';
	signal k1_being_served     : bit := '0';
	signal k2_being_served     : bit := '0';
	signal k3_being_served     : bit := '0';
	signal k4_being_served     : bit := '0';
	signal k5_being_served     : bit := '0';
	signal k6_being_served     : bit := '0';
	signal k7_being_served     : bit := '0';
	signal k8_being_served     : bit := '0';
	signal k9_being_served     : bit := '0';
	signal k10_being_served     : bit := '0';
	signal k11_being_served     : bit := '0';
	signal k12_being_served     : bit := '0';
	signal k13_being_served     : bit := '0';
	signal k14_being_served     : bit := '0';
	signal k15_being_served     : bit := '0';

	signal we_0_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_1_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_2_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_3_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_4_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_5_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_6_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_7_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_8_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_9_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_10_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_11_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_12_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_13_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_14_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_15_safe           : std_logic_vector(3 downto 0) := "0000";

	signal bram_0_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_1_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_2_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_3_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_4_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_5_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_6_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_7_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_8_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_9_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_10_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_11_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_12_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_13_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_14_input_sel    : bit_vector(3 downto 0) := "0000";
	signal bram_15_input_sel    : bit_vector(3 downto 0) := "0000";

	signal k0_needs_bram_0     : bit := '0';
	signal k0_needs_bram_1     : bit := '0';
	signal k0_needs_bram_2     : bit := '0';
	signal k0_needs_bram_3     : bit := '0';
	signal k0_needs_bram_4     : bit := '0';
	signal k0_needs_bram_5     : bit := '0';
	signal k0_needs_bram_6     : bit := '0';
	signal k0_needs_bram_7     : bit := '0';
	signal k1_needs_bram_0     : bit := '0';
	signal k1_needs_bram_1     : bit := '0';
	signal k1_needs_bram_2     : bit := '0';
	signal k1_needs_bram_3     : bit := '0';
	signal k1_needs_bram_4     : bit := '0';
	signal k1_needs_bram_5     : bit := '0';
	signal k1_needs_bram_6     : bit := '0';
	signal k1_needs_bram_7     : bit := '0';
	signal k2_needs_bram_0     : bit := '0';
	signal k2_needs_bram_1     : bit := '0';
	signal k2_needs_bram_2     : bit := '0';
	signal k2_needs_bram_3     : bit := '0';
	signal k2_needs_bram_4     : bit := '0';
	signal k2_needs_bram_5     : bit := '0';
	signal k2_needs_bram_6     : bit := '0';
	signal k2_needs_bram_7     : bit := '0';
	signal k3_needs_bram_0     : bit := '0';
	signal k3_needs_bram_1     : bit := '0';
	signal k3_needs_bram_2     : bit := '0';
	signal k3_needs_bram_3     : bit := '0';
	signal k3_needs_bram_4     : bit := '0';
	signal k3_needs_bram_5     : bit := '0';
	signal k3_needs_bram_6     : bit := '0';
	signal k3_needs_bram_7     : bit := '0';
	signal k4_needs_bram_0     : bit := '0';
	signal k4_needs_bram_1     : bit := '0';
	signal k4_needs_bram_2     : bit := '0';
	signal k4_needs_bram_3     : bit := '0';
	signal k4_needs_bram_4     : bit := '0';
	signal k4_needs_bram_5     : bit := '0';
	signal k4_needs_bram_6     : bit := '0';
	signal k4_needs_bram_7     : bit := '0';
	signal k5_needs_bram_0     : bit := '0';
	signal k5_needs_bram_1     : bit := '0';
	signal k5_needs_bram_2     : bit := '0';
	signal k5_needs_bram_3     : bit := '0';
	signal k5_needs_bram_4     : bit := '0';
	signal k5_needs_bram_5     : bit := '0';
	signal k5_needs_bram_6     : bit := '0';
	signal k5_needs_bram_7     : bit := '0';
	signal k6_needs_bram_0     : bit := '0';
	signal k6_needs_bram_1     : bit := '0';
	signal k6_needs_bram_2     : bit := '0';
	signal k6_needs_bram_3     : bit := '0';
	signal k6_needs_bram_4     : bit := '0';
	signal k6_needs_bram_5     : bit := '0';
	signal k6_needs_bram_6     : bit := '0';
	signal k6_needs_bram_7     : bit := '0';
	signal k7_needs_bram_0     : bit := '0';
	signal k7_needs_bram_1     : bit := '0';
	signal k7_needs_bram_2     : bit := '0';
	signal k7_needs_bram_3     : bit := '0';
	signal k7_needs_bram_4     : bit := '0';
	signal k7_needs_bram_5     : bit := '0';
	signal k7_needs_bram_6     : bit := '0';
	signal k7_needs_bram_7     : bit := '0';
	signal k8_needs_bram_0     : bit := '0';
	signal k8_needs_bram_1     : bit := '0';
	signal k8_needs_bram_2     : bit := '0';
	signal k8_needs_bram_3     : bit := '0';
	signal k8_needs_bram_4     : bit := '0';
	signal k8_needs_bram_5     : bit := '0';
	signal k8_needs_bram_6     : bit := '0';
	signal k8_needs_bram_7     : bit := '0';
	signal k9_needs_bram_0     : bit := '0';
	signal k9_needs_bram_1     : bit := '0';
	signal k9_needs_bram_2     : bit := '0';
	signal k9_needs_bram_3     : bit := '0';
	signal k9_needs_bram_4     : bit := '0';
	signal k9_needs_bram_5     : bit := '0';
	signal k9_needs_bram_6     : bit := '0';
	signal k9_needs_bram_7     : bit := '0';
	signal k10_needs_bram_0     : bit := '0';
	signal k10_needs_bram_1     : bit := '0';
	signal k10_needs_bram_2     : bit := '0';
	signal k10_needs_bram_3     : bit := '0';
	signal k10_needs_bram_4     : bit := '0';
	signal k10_needs_bram_5     : bit := '0';
	signal k10_needs_bram_6     : bit := '0';
	signal k10_needs_bram_7     : bit := '0';
	signal k11_needs_bram_0     : bit := '0';
	signal k11_needs_bram_1     : bit := '0';
	signal k11_needs_bram_2     : bit := '0';
	signal k11_needs_bram_3     : bit := '0';
	signal k11_needs_bram_4     : bit := '0';
	signal k11_needs_bram_5     : bit := '0';
	signal k11_needs_bram_6     : bit := '0';
	signal k11_needs_bram_7     : bit := '0';
	signal k12_needs_bram_0     : bit := '0';
	signal k12_needs_bram_1     : bit := '0';
	signal k12_needs_bram_2     : bit := '0';
	signal k12_needs_bram_3     : bit := '0';
	signal k12_needs_bram_4     : bit := '0';
	signal k12_needs_bram_5     : bit := '0';
	signal k12_needs_bram_6     : bit := '0';
	signal k12_needs_bram_7     : bit := '0';
	signal k13_needs_bram_0     : bit := '0';
	signal k13_needs_bram_1     : bit := '0';
	signal k13_needs_bram_2     : bit := '0';
	signal k13_needs_bram_3     : bit := '0';
	signal k13_needs_bram_4     : bit := '0';
	signal k13_needs_bram_5     : bit := '0';
	signal k13_needs_bram_6     : bit := '0';
	signal k13_needs_bram_7     : bit := '0';
	signal k14_needs_bram_0     : bit := '0';
	signal k14_needs_bram_1     : bit := '0';
	signal k14_needs_bram_2     : bit := '0';
	signal k14_needs_bram_3     : bit := '0';
	signal k14_needs_bram_4     : bit := '0';
	signal k14_needs_bram_5     : bit := '0';
	signal k14_needs_bram_6     : bit := '0';
	signal k14_needs_bram_7     : bit := '0';
	signal k15_needs_bram_0     : bit := '0';
	signal k15_needs_bram_1     : bit := '0';
	signal k15_needs_bram_2     : bit := '0';
	signal k15_needs_bram_3     : bit := '0';
	signal k15_needs_bram_4     : bit := '0';
	signal k15_needs_bram_5     : bit := '0';
	signal k15_needs_bram_6     : bit := '0';
	signal k15_needs_bram_7     : bit := '0';

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
	bram_en(4) <= '1';
	bram_en(5) <= '1';
	bram_en(6) <= '1';
	bram_en(7) <= '1';
	bram_en(8) <= '1';
	bram_en(9) <= '1';
	bram_en(10) <= '1';
	bram_en(11) <= '1';
	bram_en(12) <= '1';
	bram_en(13) <= '1';
	bram_en(14) <= '1';
	bram_en(15) <= '1';


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

	we_4_safe(3) <= WE_4(3) and to_stdulogic(to_bit(REQ_4));
	we_4_safe(2) <= WE_4(2) and to_stdulogic(to_bit(REQ_4));
	we_4_safe(1) <= WE_4(1) and to_stdulogic(to_bit(REQ_4));
	we_4_safe(0) <= WE_4(0) and to_stdulogic(to_bit(REQ_4));

	we_5_safe(3) <= WE_5(3) and to_stdulogic(to_bit(REQ_5));
	we_5_safe(2) <= WE_5(2) and to_stdulogic(to_bit(REQ_5));
	we_5_safe(1) <= WE_5(1) and to_stdulogic(to_bit(REQ_5));
	we_5_safe(0) <= WE_5(0) and to_stdulogic(to_bit(REQ_5));

	we_6_safe(3) <= WE_6(3) and to_stdulogic(to_bit(REQ_6));
	we_6_safe(2) <= WE_6(2) and to_stdulogic(to_bit(REQ_6));
	we_6_safe(1) <= WE_6(1) and to_stdulogic(to_bit(REQ_6));
	we_6_safe(0) <= WE_6(0) and to_stdulogic(to_bit(REQ_6));

	we_7_safe(3) <= WE_7(3) and to_stdulogic(to_bit(REQ_7));
	we_7_safe(2) <= WE_7(2) and to_stdulogic(to_bit(REQ_7));
	we_7_safe(1) <= WE_7(1) and to_stdulogic(to_bit(REQ_7));
	we_7_safe(0) <= WE_7(0) and to_stdulogic(to_bit(REQ_7));

	we_8_safe(3) <= WE_8(3) and to_stdulogic(to_bit(REQ_8));
	we_8_safe(2) <= WE_8(2) and to_stdulogic(to_bit(REQ_8));
	we_8_safe(1) <= WE_8(1) and to_stdulogic(to_bit(REQ_8));
	we_8_safe(0) <= WE_8(0) and to_stdulogic(to_bit(REQ_8));

	we_9_safe(3) <= WE_9(3) and to_stdulogic(to_bit(REQ_9));
	we_9_safe(2) <= WE_9(2) and to_stdulogic(to_bit(REQ_9));
	we_9_safe(1) <= WE_9(1) and to_stdulogic(to_bit(REQ_9));
	we_9_safe(0) <= WE_9(0) and to_stdulogic(to_bit(REQ_9));

	we_10_safe(3) <= WE_10(3) and to_stdulogic(to_bit(REQ_10));
	we_10_safe(2) <= WE_10(2) and to_stdulogic(to_bit(REQ_10));
	we_10_safe(1) <= WE_10(1) and to_stdulogic(to_bit(REQ_10));
	we_10_safe(0) <= WE_10(0) and to_stdulogic(to_bit(REQ_10));

	we_11_safe(3) <= WE_11(3) and to_stdulogic(to_bit(REQ_11));
	we_11_safe(2) <= WE_11(2) and to_stdulogic(to_bit(REQ_11));
	we_11_safe(1) <= WE_11(1) and to_stdulogic(to_bit(REQ_11));
	we_11_safe(0) <= WE_11(0) and to_stdulogic(to_bit(REQ_11));

	we_12_safe(3) <= WE_12(3) and to_stdulogic(to_bit(REQ_12));
	we_12_safe(2) <= WE_12(2) and to_stdulogic(to_bit(REQ_12));
	we_12_safe(1) <= WE_12(1) and to_stdulogic(to_bit(REQ_12));
	we_12_safe(0) <= WE_12(0) and to_stdulogic(to_bit(REQ_12));

	we_13_safe(3) <= WE_13(3) and to_stdulogic(to_bit(REQ_13));
	we_13_safe(2) <= WE_13(2) and to_stdulogic(to_bit(REQ_13));
	we_13_safe(1) <= WE_13(1) and to_stdulogic(to_bit(REQ_13));
	we_13_safe(0) <= WE_13(0) and to_stdulogic(to_bit(REQ_13));

	we_14_safe(3) <= WE_14(3) and to_stdulogic(to_bit(REQ_14));
	we_14_safe(2) <= WE_14(2) and to_stdulogic(to_bit(REQ_14));
	we_14_safe(1) <= WE_14(1) and to_stdulogic(to_bit(REQ_14));
	we_14_safe(0) <= WE_14(0) and to_stdulogic(to_bit(REQ_14));

	we_15_safe(3) <= WE_15(3) and to_stdulogic(to_bit(REQ_15));
	we_15_safe(2) <= WE_15(2) and to_stdulogic(to_bit(REQ_15));
	we_15_safe(1) <= WE_15(1) and to_stdulogic(to_bit(REQ_15));
	we_15_safe(0) <= WE_15(0) and to_stdulogic(to_bit(REQ_15));


	RDY_0 <= to_stdulogic(k0_being_served);
	RDY_1 <= to_stdulogic(k1_being_served);
	RDY_2 <= to_stdulogic(k2_being_served);
	RDY_3 <= to_stdulogic(k3_being_served);
	RDY_4 <= to_stdulogic(k4_being_served);
	RDY_5 <= to_stdulogic(k5_being_served);
	RDY_6 <= to_stdulogic(k6_being_served);
	RDY_7 <= to_stdulogic(k7_being_served);
	RDY_8 <= to_stdulogic(k8_being_served);
	RDY_9 <= to_stdulogic(k9_being_served);
	RDY_10 <= to_stdulogic(k10_being_served);
	RDY_11 <= to_stdulogic(k11_being_served);
	RDY_12 <= to_stdulogic(k12_being_served);
	RDY_13 <= to_stdulogic(k13_being_served);
	RDY_14 <= to_stdulogic(k14_being_served);
	RDY_15 <= to_stdulogic(k15_being_served);

	k0_needs_bram_0 <= to_bit(REQ_0) and not to_bit(ADDR_0(11)) and not to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_1 <= to_bit(REQ_0) and not to_bit(ADDR_0(11)) and not to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));
	k0_needs_bram_2 <= to_bit(REQ_0) and not to_bit(ADDR_0(11)) and     to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_3 <= to_bit(REQ_0) and not to_bit(ADDR_0(11)) and     to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));
	k0_needs_bram_4 <= to_bit(REQ_0) and     to_bit(ADDR_0(11)) and not to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_5 <= to_bit(REQ_0) and     to_bit(ADDR_0(11)) and not to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));
	k0_needs_bram_6 <= to_bit(REQ_0) and     to_bit(ADDR_0(11)) and     to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_7 <= to_bit(REQ_0) and     to_bit(ADDR_0(11)) and     to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));

	k1_needs_bram_0 <= to_bit(REQ_1) and not to_bit(ADDR_1(11)) and not to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_1 <= to_bit(REQ_1) and not to_bit(ADDR_1(11)) and not to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));
	k1_needs_bram_2 <= to_bit(REQ_1) and not to_bit(ADDR_1(11)) and     to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_3 <= to_bit(REQ_1) and not to_bit(ADDR_1(11)) and     to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));
	k1_needs_bram_4 <= to_bit(REQ_1) and     to_bit(ADDR_1(11)) and not to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_5 <= to_bit(REQ_1) and     to_bit(ADDR_1(11)) and not to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));
	k1_needs_bram_6 <= to_bit(REQ_1) and     to_bit(ADDR_1(11)) and     to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_7 <= to_bit(REQ_1) and     to_bit(ADDR_1(11)) and     to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));

	k2_needs_bram_0 <= to_bit(REQ_2) and not to_bit(ADDR_2(11)) and not to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_1 <= to_bit(REQ_2) and not to_bit(ADDR_2(11)) and not to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));
	k2_needs_bram_2 <= to_bit(REQ_2) and not to_bit(ADDR_2(11)) and     to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_3 <= to_bit(REQ_2) and not to_bit(ADDR_2(11)) and     to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));
	k2_needs_bram_4 <= to_bit(REQ_2) and     to_bit(ADDR_2(11)) and not to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_5 <= to_bit(REQ_2) and     to_bit(ADDR_2(11)) and not to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));
	k2_needs_bram_6 <= to_bit(REQ_2) and     to_bit(ADDR_2(11)) and     to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_7 <= to_bit(REQ_2) and     to_bit(ADDR_2(11)) and     to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));

	k3_needs_bram_0 <= to_bit(REQ_3) and not to_bit(ADDR_3(11)) and not to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_1 <= to_bit(REQ_3) and not to_bit(ADDR_3(11)) and not to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));
	k3_needs_bram_2 <= to_bit(REQ_3) and not to_bit(ADDR_3(11)) and     to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_3 <= to_bit(REQ_3) and not to_bit(ADDR_3(11)) and     to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));
	k3_needs_bram_4 <= to_bit(REQ_3) and     to_bit(ADDR_3(11)) and not to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_5 <= to_bit(REQ_3) and     to_bit(ADDR_3(11)) and not to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));
	k3_needs_bram_6 <= to_bit(REQ_3) and     to_bit(ADDR_3(11)) and     to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_7 <= to_bit(REQ_3) and     to_bit(ADDR_3(11)) and     to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));

	k4_needs_bram_0 <= to_bit(REQ_4) and not to_bit(ADDR_4(11)) and not to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_1 <= to_bit(REQ_4) and not to_bit(ADDR_4(11)) and not to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));
	k4_needs_bram_2 <= to_bit(REQ_4) and not to_bit(ADDR_4(11)) and     to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_3 <= to_bit(REQ_4) and not to_bit(ADDR_4(11)) and     to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));
	k4_needs_bram_4 <= to_bit(REQ_4) and     to_bit(ADDR_4(11)) and not to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_5 <= to_bit(REQ_4) and     to_bit(ADDR_4(11)) and not to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));
	k4_needs_bram_6 <= to_bit(REQ_4) and     to_bit(ADDR_4(11)) and     to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_7 <= to_bit(REQ_4) and     to_bit(ADDR_4(11)) and     to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));

	k5_needs_bram_0 <= to_bit(REQ_5) and not to_bit(ADDR_5(11)) and not to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_1 <= to_bit(REQ_5) and not to_bit(ADDR_5(11)) and not to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));
	k5_needs_bram_2 <= to_bit(REQ_5) and not to_bit(ADDR_5(11)) and     to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_3 <= to_bit(REQ_5) and not to_bit(ADDR_5(11)) and     to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));
	k5_needs_bram_4 <= to_bit(REQ_5) and     to_bit(ADDR_5(11)) and not to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_5 <= to_bit(REQ_5) and     to_bit(ADDR_5(11)) and not to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));
	k5_needs_bram_6 <= to_bit(REQ_5) and     to_bit(ADDR_5(11)) and     to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_7 <= to_bit(REQ_5) and     to_bit(ADDR_5(11)) and     to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));

	k6_needs_bram_0 <= to_bit(REQ_6) and not to_bit(ADDR_6(11)) and not to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_1 <= to_bit(REQ_6) and not to_bit(ADDR_6(11)) and not to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));
	k6_needs_bram_2 <= to_bit(REQ_6) and not to_bit(ADDR_6(11)) and     to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_3 <= to_bit(REQ_6) and not to_bit(ADDR_6(11)) and     to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));
	k6_needs_bram_4 <= to_bit(REQ_6) and     to_bit(ADDR_6(11)) and not to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_5 <= to_bit(REQ_6) and     to_bit(ADDR_6(11)) and not to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));
	k6_needs_bram_6 <= to_bit(REQ_6) and     to_bit(ADDR_6(11)) and     to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_7 <= to_bit(REQ_6) and     to_bit(ADDR_6(11)) and     to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));

	k7_needs_bram_0 <= to_bit(REQ_7) and not to_bit(ADDR_7(11)) and not to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_1 <= to_bit(REQ_7) and not to_bit(ADDR_7(11)) and not to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));
	k7_needs_bram_2 <= to_bit(REQ_7) and not to_bit(ADDR_7(11)) and     to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_3 <= to_bit(REQ_7) and not to_bit(ADDR_7(11)) and     to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));
	k7_needs_bram_4 <= to_bit(REQ_7) and     to_bit(ADDR_7(11)) and not to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_5 <= to_bit(REQ_7) and     to_bit(ADDR_7(11)) and not to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));
	k7_needs_bram_6 <= to_bit(REQ_7) and     to_bit(ADDR_7(11)) and     to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_7 <= to_bit(REQ_7) and     to_bit(ADDR_7(11)) and     to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));

	k8_needs_bram_0 <= to_bit(REQ_8) and not to_bit(ADDR_8(11)) and not to_bit(ADDR_8(10)) and not to_bit(ADDR_8(9));
	k8_needs_bram_1 <= to_bit(REQ_8) and not to_bit(ADDR_8(11)) and not to_bit(ADDR_8(10)) and     to_bit(ADDR_8(9));
	k8_needs_bram_2 <= to_bit(REQ_8) and not to_bit(ADDR_8(11)) and     to_bit(ADDR_8(10)) and not to_bit(ADDR_8(9));
	k8_needs_bram_3 <= to_bit(REQ_8) and not to_bit(ADDR_8(11)) and     to_bit(ADDR_8(10)) and     to_bit(ADDR_8(9));
	k8_needs_bram_4 <= to_bit(REQ_8) and     to_bit(ADDR_8(11)) and not to_bit(ADDR_8(10)) and not to_bit(ADDR_8(9));
	k8_needs_bram_5 <= to_bit(REQ_8) and     to_bit(ADDR_8(11)) and not to_bit(ADDR_8(10)) and     to_bit(ADDR_8(9));
	k8_needs_bram_6 <= to_bit(REQ_8) and     to_bit(ADDR_8(11)) and     to_bit(ADDR_8(10)) and not to_bit(ADDR_8(9));
	k8_needs_bram_7 <= to_bit(REQ_8) and     to_bit(ADDR_8(11)) and     to_bit(ADDR_8(10)) and     to_bit(ADDR_8(9));

	k9_needs_bram_0 <= to_bit(REQ_9) and not to_bit(ADDR_9(11)) and not to_bit(ADDR_9(10)) and not to_bit(ADDR_9(9));
	k9_needs_bram_1 <= to_bit(REQ_9) and not to_bit(ADDR_9(11)) and not to_bit(ADDR_9(10)) and     to_bit(ADDR_9(9));
	k9_needs_bram_2 <= to_bit(REQ_9) and not to_bit(ADDR_9(11)) and     to_bit(ADDR_9(10)) and not to_bit(ADDR_9(9));
	k9_needs_bram_3 <= to_bit(REQ_9) and not to_bit(ADDR_9(11)) and     to_bit(ADDR_9(10)) and     to_bit(ADDR_9(9));
	k9_needs_bram_4 <= to_bit(REQ_9) and     to_bit(ADDR_9(11)) and not to_bit(ADDR_9(10)) and not to_bit(ADDR_9(9));
	k9_needs_bram_5 <= to_bit(REQ_9) and     to_bit(ADDR_9(11)) and not to_bit(ADDR_9(10)) and     to_bit(ADDR_9(9));
	k9_needs_bram_6 <= to_bit(REQ_9) and     to_bit(ADDR_9(11)) and     to_bit(ADDR_9(10)) and not to_bit(ADDR_9(9));
	k9_needs_bram_7 <= to_bit(REQ_9) and     to_bit(ADDR_9(11)) and     to_bit(ADDR_9(10)) and     to_bit(ADDR_9(9));

	k10_needs_bram_0 <= to_bit(REQ_10) and not to_bit(ADDR_10(11)) and not to_bit(ADDR_10(10)) and not to_bit(ADDR_10(9));
	k10_needs_bram_1 <= to_bit(REQ_10) and not to_bit(ADDR_10(11)) and not to_bit(ADDR_10(10)) and     to_bit(ADDR_10(9));
	k10_needs_bram_2 <= to_bit(REQ_10) and not to_bit(ADDR_10(11)) and     to_bit(ADDR_10(10)) and not to_bit(ADDR_10(9));
	k10_needs_bram_3 <= to_bit(REQ_10) and not to_bit(ADDR_10(11)) and     to_bit(ADDR_10(10)) and     to_bit(ADDR_10(9));
	k10_needs_bram_4 <= to_bit(REQ_10) and     to_bit(ADDR_10(11)) and not to_bit(ADDR_10(10)) and not to_bit(ADDR_10(9));
	k10_needs_bram_5 <= to_bit(REQ_10) and     to_bit(ADDR_10(11)) and not to_bit(ADDR_10(10)) and     to_bit(ADDR_10(9));
	k10_needs_bram_6 <= to_bit(REQ_10) and     to_bit(ADDR_10(11)) and     to_bit(ADDR_10(10)) and not to_bit(ADDR_10(9));
	k10_needs_bram_7 <= to_bit(REQ_10) and     to_bit(ADDR_10(11)) and     to_bit(ADDR_10(10)) and     to_bit(ADDR_10(9));

	k11_needs_bram_0 <= to_bit(REQ_11) and not to_bit(ADDR_11(11)) and not to_bit(ADDR_11(10)) and not to_bit(ADDR_11(9));
	k11_needs_bram_1 <= to_bit(REQ_11) and not to_bit(ADDR_11(11)) and not to_bit(ADDR_11(10)) and     to_bit(ADDR_11(9));
	k11_needs_bram_2 <= to_bit(REQ_11) and not to_bit(ADDR_11(11)) and     to_bit(ADDR_11(10)) and not to_bit(ADDR_11(9));
	k11_needs_bram_3 <= to_bit(REQ_11) and not to_bit(ADDR_11(11)) and     to_bit(ADDR_11(10)) and     to_bit(ADDR_11(9));
	k11_needs_bram_4 <= to_bit(REQ_11) and     to_bit(ADDR_11(11)) and not to_bit(ADDR_11(10)) and not to_bit(ADDR_11(9));
	k11_needs_bram_5 <= to_bit(REQ_11) and     to_bit(ADDR_11(11)) and not to_bit(ADDR_11(10)) and     to_bit(ADDR_11(9));
	k11_needs_bram_6 <= to_bit(REQ_11) and     to_bit(ADDR_11(11)) and     to_bit(ADDR_11(10)) and not to_bit(ADDR_11(9));
	k11_needs_bram_7 <= to_bit(REQ_11) and     to_bit(ADDR_11(11)) and     to_bit(ADDR_11(10)) and     to_bit(ADDR_11(9));

	k12_needs_bram_0 <= to_bit(REQ_12) and not to_bit(ADDR_12(11)) and not to_bit(ADDR_12(10)) and not to_bit(ADDR_12(9));
	k12_needs_bram_1 <= to_bit(REQ_12) and not to_bit(ADDR_12(11)) and not to_bit(ADDR_12(10)) and     to_bit(ADDR_12(9));
	k12_needs_bram_2 <= to_bit(REQ_12) and not to_bit(ADDR_12(11)) and     to_bit(ADDR_12(10)) and not to_bit(ADDR_12(9));
	k12_needs_bram_3 <= to_bit(REQ_12) and not to_bit(ADDR_12(11)) and     to_bit(ADDR_12(10)) and     to_bit(ADDR_12(9));
	k12_needs_bram_4 <= to_bit(REQ_12) and     to_bit(ADDR_12(11)) and not to_bit(ADDR_12(10)) and not to_bit(ADDR_12(9));
	k12_needs_bram_5 <= to_bit(REQ_12) and     to_bit(ADDR_12(11)) and not to_bit(ADDR_12(10)) and     to_bit(ADDR_12(9));
	k12_needs_bram_6 <= to_bit(REQ_12) and     to_bit(ADDR_12(11)) and     to_bit(ADDR_12(10)) and not to_bit(ADDR_12(9));
	k12_needs_bram_7 <= to_bit(REQ_12) and     to_bit(ADDR_12(11)) and     to_bit(ADDR_12(10)) and     to_bit(ADDR_12(9));

	k13_needs_bram_0 <= to_bit(REQ_13) and not to_bit(ADDR_13(11)) and not to_bit(ADDR_13(10)) and not to_bit(ADDR_13(9));
	k13_needs_bram_1 <= to_bit(REQ_13) and not to_bit(ADDR_13(11)) and not to_bit(ADDR_13(10)) and     to_bit(ADDR_13(9));
	k13_needs_bram_2 <= to_bit(REQ_13) and not to_bit(ADDR_13(11)) and     to_bit(ADDR_13(10)) and not to_bit(ADDR_13(9));
	k13_needs_bram_3 <= to_bit(REQ_13) and not to_bit(ADDR_13(11)) and     to_bit(ADDR_13(10)) and     to_bit(ADDR_13(9));
	k13_needs_bram_4 <= to_bit(REQ_13) and     to_bit(ADDR_13(11)) and not to_bit(ADDR_13(10)) and not to_bit(ADDR_13(9));
	k13_needs_bram_5 <= to_bit(REQ_13) and     to_bit(ADDR_13(11)) and not to_bit(ADDR_13(10)) and     to_bit(ADDR_13(9));
	k13_needs_bram_6 <= to_bit(REQ_13) and     to_bit(ADDR_13(11)) and     to_bit(ADDR_13(10)) and not to_bit(ADDR_13(9));
	k13_needs_bram_7 <= to_bit(REQ_13) and     to_bit(ADDR_13(11)) and     to_bit(ADDR_13(10)) and     to_bit(ADDR_13(9));

	k14_needs_bram_0 <= to_bit(REQ_14) and not to_bit(ADDR_14(11)) and not to_bit(ADDR_14(10)) and not to_bit(ADDR_14(9));
	k14_needs_bram_1 <= to_bit(REQ_14) and not to_bit(ADDR_14(11)) and not to_bit(ADDR_14(10)) and     to_bit(ADDR_14(9));
	k14_needs_bram_2 <= to_bit(REQ_14) and not to_bit(ADDR_14(11)) and     to_bit(ADDR_14(10)) and not to_bit(ADDR_14(9));
	k14_needs_bram_3 <= to_bit(REQ_14) and not to_bit(ADDR_14(11)) and     to_bit(ADDR_14(10)) and     to_bit(ADDR_14(9));
	k14_needs_bram_4 <= to_bit(REQ_14) and     to_bit(ADDR_14(11)) and not to_bit(ADDR_14(10)) and not to_bit(ADDR_14(9));
	k14_needs_bram_5 <= to_bit(REQ_14) and     to_bit(ADDR_14(11)) and not to_bit(ADDR_14(10)) and     to_bit(ADDR_14(9));
	k14_needs_bram_6 <= to_bit(REQ_14) and     to_bit(ADDR_14(11)) and     to_bit(ADDR_14(10)) and not to_bit(ADDR_14(9));
	k14_needs_bram_7 <= to_bit(REQ_14) and     to_bit(ADDR_14(11)) and     to_bit(ADDR_14(10)) and     to_bit(ADDR_14(9));

	k15_needs_bram_0 <= to_bit(REQ_15) and not to_bit(ADDR_15(11)) and not to_bit(ADDR_15(10)) and not to_bit(ADDR_15(9));
	k15_needs_bram_1 <= to_bit(REQ_15) and not to_bit(ADDR_15(11)) and not to_bit(ADDR_15(10)) and     to_bit(ADDR_15(9));
	k15_needs_bram_2 <= to_bit(REQ_15) and not to_bit(ADDR_15(11)) and     to_bit(ADDR_15(10)) and not to_bit(ADDR_15(9));
	k15_needs_bram_3 <= to_bit(REQ_15) and not to_bit(ADDR_15(11)) and     to_bit(ADDR_15(10)) and     to_bit(ADDR_15(9));
	k15_needs_bram_4 <= to_bit(REQ_15) and     to_bit(ADDR_15(11)) and not to_bit(ADDR_15(10)) and not to_bit(ADDR_15(9));
	k15_needs_bram_5 <= to_bit(REQ_15) and     to_bit(ADDR_15(11)) and not to_bit(ADDR_15(10)) and     to_bit(ADDR_15(9));
	k15_needs_bram_6 <= to_bit(REQ_15) and     to_bit(ADDR_15(11)) and     to_bit(ADDR_15(10)) and not to_bit(ADDR_15(9));
	k15_needs_bram_7 <= to_bit(REQ_15) and     to_bit(ADDR_15(11)) and     to_bit(ADDR_15(10)) and     to_bit(ADDR_15(9));


	bram_0_input_sel(3) <= not ((k0_needs_bram_0 or k1_needs_bram_0 or k2_needs_bram_0 or k3_needs_bram_0 or k4_needs_bram_0 or k5_needs_bram_0 or k6_needs_bram_0 or k7_needs_bram_0));
	bram_2_input_sel(3) <= not ((k0_needs_bram_1 or k1_needs_bram_1 or k2_needs_bram_1 or k3_needs_bram_1 or k4_needs_bram_1 or k5_needs_bram_1 or k6_needs_bram_1 or k7_needs_bram_1));
	bram_4_input_sel(3) <= not ((k0_needs_bram_2 or k1_needs_bram_2 or k2_needs_bram_2 or k3_needs_bram_2 or k4_needs_bram_2 or k5_needs_bram_2 or k6_needs_bram_2 or k7_needs_bram_2));
	bram_6_input_sel(3) <= not ((k0_needs_bram_3 or k1_needs_bram_3 or k2_needs_bram_3 or k3_needs_bram_3 or k4_needs_bram_3 or k5_needs_bram_3 or k6_needs_bram_3 or k7_needs_bram_3));
	bram_8_input_sel(3) <= not ((k0_needs_bram_4 or k1_needs_bram_4 or k2_needs_bram_4 or k3_needs_bram_4 or k4_needs_bram_4 or k5_needs_bram_4 or k6_needs_bram_4 or k7_needs_bram_4));
	bram_10_input_sel(3) <= not ((k0_needs_bram_5 or k1_needs_bram_5 or k2_needs_bram_5 or k3_needs_bram_5 or k4_needs_bram_5 or k5_needs_bram_5 or k6_needs_bram_5 or k7_needs_bram_5));
	bram_12_input_sel(3) <= not ((k0_needs_bram_6 or k1_needs_bram_6 or k2_needs_bram_6 or k3_needs_bram_6 or k4_needs_bram_6 or k5_needs_bram_6 or k6_needs_bram_6 or k7_needs_bram_6));
	bram_14_input_sel(3) <= not ((k0_needs_bram_7 or k1_needs_bram_7 or k2_needs_bram_7 or k3_needs_bram_7 or k4_needs_bram_7 or k5_needs_bram_7 or k6_needs_bram_7 or k7_needs_bram_7));

	bram_0_input_sel(2) <= not ((k0_needs_bram_0 or k1_needs_bram_0 or k2_needs_bram_0 or k3_needs_bram_0) or ((k8_needs_bram_0 or k9_needs_bram_0 or k10_needs_bram_0 or k11_needs_bram_0) and (not k7_needs_bram_0) and (not k6_needs_bram_0) and (not k5_needs_bram_0) and (not k4_needs_bram_0)));
	bram_2_input_sel(2) <= not ((k0_needs_bram_1 or k1_needs_bram_1 or k2_needs_bram_1 or k3_needs_bram_1) or ((k8_needs_bram_1 or k9_needs_bram_1 or k10_needs_bram_1 or k11_needs_bram_1) and (not k7_needs_bram_1) and (not k6_needs_bram_1) and (not k5_needs_bram_1) and (not k4_needs_bram_1)));
	bram_4_input_sel(2) <= not ((k0_needs_bram_2 or k1_needs_bram_2 or k2_needs_bram_2 or k3_needs_bram_2) or ((k8_needs_bram_2 or k9_needs_bram_2 or k10_needs_bram_2 or k11_needs_bram_2) and (not k7_needs_bram_2) and (not k6_needs_bram_2) and (not k5_needs_bram_2) and (not k4_needs_bram_2)));
	bram_6_input_sel(2) <= not ((k0_needs_bram_3 or k1_needs_bram_3 or k2_needs_bram_3 or k3_needs_bram_3) or ((k8_needs_bram_3 or k9_needs_bram_3 or k10_needs_bram_3 or k11_needs_bram_3) and (not k7_needs_bram_3) and (not k6_needs_bram_3) and (not k5_needs_bram_3) and (not k4_needs_bram_3)));
	bram_8_input_sel(2) <= not ((k0_needs_bram_4 or k1_needs_bram_4 or k2_needs_bram_4 or k3_needs_bram_4) or ((k8_needs_bram_4 or k9_needs_bram_4 or k10_needs_bram_4 or k11_needs_bram_4) and (not k7_needs_bram_4) and (not k6_needs_bram_4) and (not k5_needs_bram_4) and (not k4_needs_bram_4)));
	bram_10_input_sel(2) <= not ((k0_needs_bram_5 or k1_needs_bram_5 or k2_needs_bram_5 or k3_needs_bram_5) or ((k8_needs_bram_5 or k9_needs_bram_5 or k10_needs_bram_5 or k11_needs_bram_5) and (not k7_needs_bram_5) and (not k6_needs_bram_5) and (not k5_needs_bram_5) and (not k4_needs_bram_5)));
	bram_12_input_sel(2) <= not ((k0_needs_bram_6 or k1_needs_bram_6 or k2_needs_bram_6 or k3_needs_bram_6) or ((k8_needs_bram_6 or k9_needs_bram_6 or k10_needs_bram_6 or k11_needs_bram_6) and (not k7_needs_bram_6) and (not k6_needs_bram_6) and (not k5_needs_bram_6) and (not k4_needs_bram_6)));
	bram_14_input_sel(2) <= not ((k0_needs_bram_7 or k1_needs_bram_7 or k2_needs_bram_7 or k3_needs_bram_7) or ((k8_needs_bram_7 or k9_needs_bram_7 or k10_needs_bram_7 or k11_needs_bram_7) and (not k7_needs_bram_7) and (not k6_needs_bram_7) and (not k5_needs_bram_7) and (not k4_needs_bram_7)));

	bram_0_input_sel(1) <= not ((k0_needs_bram_0 or k1_needs_bram_0) or ((k4_needs_bram_0 or k5_needs_bram_0) and (not k3_needs_bram_0) and (not k2_needs_bram_0)) or ((k8_needs_bram_0 or k9_needs_bram_0) and (not k3_needs_bram_0) and (not k2_needs_bram_0) and (not k7_needs_bram_0) and (not k6_needs_bram_0)) or ((k12_needs_bram_0 or k13_needs_bram_0) and (not k3_needs_bram_0) and (not k2_needs_bram_0) and (not k7_needs_bram_0) and (not k6_needs_bram_0) and (not k11_needs_bram_0) and (not k10_needs_bram_0)));
	bram_2_input_sel(1) <= not ((k0_needs_bram_1 or k1_needs_bram_1) or ((k4_needs_bram_1 or k5_needs_bram_1) and (not k3_needs_bram_1) and (not k2_needs_bram_1)) or ((k8_needs_bram_1 or k9_needs_bram_1) and (not k3_needs_bram_1) and (not k2_needs_bram_1) and (not k7_needs_bram_1) and (not k6_needs_bram_1)) or ((k12_needs_bram_1 or k13_needs_bram_1) and (not k3_needs_bram_1) and (not k2_needs_bram_1) and (not k7_needs_bram_1) and (not k6_needs_bram_1) and (not k11_needs_bram_1) and (not k10_needs_bram_1)));
	bram_4_input_sel(1) <= not ((k0_needs_bram_2 or k1_needs_bram_2) or ((k4_needs_bram_2 or k5_needs_bram_2) and (not k3_needs_bram_2) and (not k2_needs_bram_2)) or ((k8_needs_bram_2 or k9_needs_bram_2) and (not k3_needs_bram_2) and (not k2_needs_bram_2) and (not k7_needs_bram_2) and (not k6_needs_bram_2)) or ((k12_needs_bram_2 or k13_needs_bram_2) and (not k3_needs_bram_2) and (not k2_needs_bram_2) and (not k7_needs_bram_2) and (not k6_needs_bram_2) and (not k11_needs_bram_2) and (not k10_needs_bram_2)));
	bram_6_input_sel(1) <= not ((k0_needs_bram_3 or k1_needs_bram_3) or ((k4_needs_bram_3 or k5_needs_bram_3) and (not k3_needs_bram_3) and (not k2_needs_bram_3)) or ((k8_needs_bram_3 or k9_needs_bram_3) and (not k3_needs_bram_3) and (not k2_needs_bram_3) and (not k7_needs_bram_3) and (not k6_needs_bram_3)) or ((k12_needs_bram_3 or k13_needs_bram_3) and (not k3_needs_bram_3) and (not k2_needs_bram_3) and (not k7_needs_bram_3) and (not k6_needs_bram_3) and (not k11_needs_bram_3) and (not k10_needs_bram_3)));
	bram_8_input_sel(1) <= not ((k0_needs_bram_4 or k1_needs_bram_4) or ((k4_needs_bram_4 or k5_needs_bram_4) and (not k3_needs_bram_4) and (not k2_needs_bram_4)) or ((k8_needs_bram_4 or k9_needs_bram_4) and (not k3_needs_bram_4) and (not k2_needs_bram_4) and (not k7_needs_bram_4) and (not k6_needs_bram_4)) or ((k12_needs_bram_4 or k13_needs_bram_4) and (not k3_needs_bram_4) and (not k2_needs_bram_4) and (not k7_needs_bram_4) and (not k6_needs_bram_4) and (not k11_needs_bram_4) and (not k10_needs_bram_4)));
	bram_10_input_sel(1) <= not ((k0_needs_bram_5 or k1_needs_bram_5) or ((k4_needs_bram_5 or k5_needs_bram_5) and (not k3_needs_bram_5) and (not k2_needs_bram_5)) or ((k8_needs_bram_5 or k9_needs_bram_5) and (not k3_needs_bram_5) and (not k2_needs_bram_5) and (not k7_needs_bram_5) and (not k6_needs_bram_5)) or ((k12_needs_bram_5 or k13_needs_bram_5) and (not k3_needs_bram_5) and (not k2_needs_bram_5) and (not k7_needs_bram_5) and (not k6_needs_bram_5) and (not k11_needs_bram_5) and (not k10_needs_bram_5)));
	bram_12_input_sel(1) <= not ((k0_needs_bram_6 or k1_needs_bram_6) or ((k4_needs_bram_6 or k5_needs_bram_6) and (not k3_needs_bram_6) and (not k2_needs_bram_6)) or ((k8_needs_bram_6 or k9_needs_bram_6) and (not k3_needs_bram_6) and (not k2_needs_bram_6) and (not k7_needs_bram_6) and (not k6_needs_bram_6)) or ((k12_needs_bram_6 or k13_needs_bram_6) and (not k3_needs_bram_6) and (not k2_needs_bram_6) and (not k7_needs_bram_6) and (not k6_needs_bram_6) and (not k11_needs_bram_6) and (not k10_needs_bram_6)));
	bram_14_input_sel(1) <= not ((k0_needs_bram_7 or k1_needs_bram_7) or ((k4_needs_bram_7 or k5_needs_bram_7) and (not k3_needs_bram_7) and (not k2_needs_bram_7)) or ((k8_needs_bram_7 or k9_needs_bram_7) and (not k3_needs_bram_7) and (not k2_needs_bram_7) and (not k7_needs_bram_7) and (not k6_needs_bram_7)) or ((k12_needs_bram_7 or k13_needs_bram_7) and (not k3_needs_bram_7) and (not k2_needs_bram_7) and (not k7_needs_bram_7) and (not k6_needs_bram_7) and (not k11_needs_bram_7) and (not k10_needs_bram_7)));

	bram_0_input_sel(0) <= not ((k0_needs_bram_0) or ((k2_needs_bram_0) and (not k1_needs_bram_0)) or ((k4_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0)) or ((k6_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0)) or ((k8_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0) and (not k7_needs_bram_0)) or ((k10_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0) and (not k7_needs_bram_0) and (not k9_needs_bram_0)) or ((k12_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0) and (not k7_needs_bram_0) and (not k9_needs_bram_0) and (not k11_needs_bram_0)) or ((k14_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0) and (not k7_needs_bram_0) and (not k9_needs_bram_0) and (not k11_needs_bram_0) and (not k13_needs_bram_0)));
	bram_2_input_sel(0) <= not ((k0_needs_bram_1) or ((k2_needs_bram_1) and (not k1_needs_bram_1)) or ((k4_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1)) or ((k6_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1)) or ((k8_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1) and (not k7_needs_bram_1)) or ((k10_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1) and (not k7_needs_bram_1) and (not k9_needs_bram_1)) or ((k12_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1) and (not k7_needs_bram_1) and (not k9_needs_bram_1) and (not k11_needs_bram_1)) or ((k14_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1) and (not k7_needs_bram_1) and (not k9_needs_bram_1) and (not k11_needs_bram_1) and (not k13_needs_bram_1)));
	bram_4_input_sel(0) <= not ((k0_needs_bram_2) or ((k2_needs_bram_2) and (not k1_needs_bram_2)) or ((k4_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2)) or ((k6_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2)) or ((k8_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2) and (not k7_needs_bram_2)) or ((k10_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2) and (not k7_needs_bram_2) and (not k9_needs_bram_2)) or ((k12_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2) and (not k7_needs_bram_2) and (not k9_needs_bram_2) and (not k11_needs_bram_2)) or ((k14_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2) and (not k7_needs_bram_2) and (not k9_needs_bram_2) and (not k11_needs_bram_2) and (not k13_needs_bram_2)));
	bram_6_input_sel(0) <= not ((k0_needs_bram_3) or ((k2_needs_bram_3) and (not k1_needs_bram_3)) or ((k4_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3)) or ((k6_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3)) or ((k8_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3) and (not k7_needs_bram_3)) or ((k10_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3) and (not k7_needs_bram_3) and (not k9_needs_bram_3)) or ((k12_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3) and (not k7_needs_bram_3) and (not k9_needs_bram_3) and (not k11_needs_bram_3)) or ((k14_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3) and (not k7_needs_bram_3) and (not k9_needs_bram_3) and (not k11_needs_bram_3) and (not k13_needs_bram_3)));
	bram_8_input_sel(0) <= not ((k0_needs_bram_4) or ((k2_needs_bram_4) and (not k1_needs_bram_4)) or ((k4_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4)) or ((k6_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4) and (not k5_needs_bram_4)) or ((k8_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4) and (not k5_needs_bram_4) and (not k7_needs_bram_4)) or ((k10_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4) and (not k5_needs_bram_4) and (not k7_needs_bram_4) and (not k9_needs_bram_4)) or ((k12_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4) and (not k5_needs_bram_4) and (not k7_needs_bram_4) and (not k9_needs_bram_4) and (not k11_needs_bram_4)) or ((k14_needs_bram_4) and (not k1_needs_bram_4) and (not k3_needs_bram_4) and (not k5_needs_bram_4) and (not k7_needs_bram_4) and (not k9_needs_bram_4) and (not k11_needs_bram_4) and (not k13_needs_bram_4)));
	bram_10_input_sel(0) <= not ((k0_needs_bram_5) or ((k2_needs_bram_5) and (not k1_needs_bram_5)) or ((k4_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5)) or ((k6_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5) and (not k5_needs_bram_5)) or ((k8_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5) and (not k5_needs_bram_5) and (not k7_needs_bram_5)) or ((k10_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5) and (not k5_needs_bram_5) and (not k7_needs_bram_5) and (not k9_needs_bram_5)) or ((k12_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5) and (not k5_needs_bram_5) and (not k7_needs_bram_5) and (not k9_needs_bram_5) and (not k11_needs_bram_5)) or ((k14_needs_bram_5) and (not k1_needs_bram_5) and (not k3_needs_bram_5) and (not k5_needs_bram_5) and (not k7_needs_bram_5) and (not k9_needs_bram_5) and (not k11_needs_bram_5) and (not k13_needs_bram_5)));
	bram_12_input_sel(0) <= not ((k0_needs_bram_6) or ((k2_needs_bram_6) and (not k1_needs_bram_6)) or ((k4_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6)) or ((k6_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6) and (not k5_needs_bram_6)) or ((k8_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6) and (not k5_needs_bram_6) and (not k7_needs_bram_6)) or ((k10_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6) and (not k5_needs_bram_6) and (not k7_needs_bram_6) and (not k9_needs_bram_6)) or ((k12_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6) and (not k5_needs_bram_6) and (not k7_needs_bram_6) and (not k9_needs_bram_6) and (not k11_needs_bram_6)) or ((k14_needs_bram_6) and (not k1_needs_bram_6) and (not k3_needs_bram_6) and (not k5_needs_bram_6) and (not k7_needs_bram_6) and (not k9_needs_bram_6) and (not k11_needs_bram_6) and (not k13_needs_bram_6)));
	bram_14_input_sel(0) <= not ((k0_needs_bram_7) or ((k2_needs_bram_7) and (not k1_needs_bram_7)) or ((k4_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7)) or ((k6_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7) and (not k5_needs_bram_7)) or ((k8_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7) and (not k5_needs_bram_7) and (not k7_needs_bram_7)) or ((k10_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7) and (not k5_needs_bram_7) and (not k7_needs_bram_7) and (not k9_needs_bram_7)) or ((k12_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7) and (not k5_needs_bram_7) and (not k7_needs_bram_7) and (not k9_needs_bram_7) and (not k11_needs_bram_7)) or ((k14_needs_bram_7) and (not k1_needs_bram_7) and (not k3_needs_bram_7) and (not k5_needs_bram_7) and (not k7_needs_bram_7) and (not k9_needs_bram_7) and (not k11_needs_bram_7) and (not k13_needs_bram_7)));


	bram_1_input_sel(3) <= (k15_needs_bram_0 or k14_needs_bram_0 or k13_needs_bram_0 or k12_needs_bram_0 or k11_needs_bram_0 or k10_needs_bram_0 or k9_needs_bram_0 or k8_needs_bram_0);
	bram_3_input_sel(3) <= (k15_needs_bram_1 or k14_needs_bram_1 or k13_needs_bram_1 or k12_needs_bram_1 or k11_needs_bram_1 or k10_needs_bram_1 or k9_needs_bram_1 or k8_needs_bram_1);
	bram_5_input_sel(3) <= (k15_needs_bram_2 or k14_needs_bram_2 or k13_needs_bram_2 or k12_needs_bram_2 or k11_needs_bram_2 or k10_needs_bram_2 or k9_needs_bram_2 or k8_needs_bram_2);
	bram_7_input_sel(3) <= (k15_needs_bram_3 or k14_needs_bram_3 or k13_needs_bram_3 or k12_needs_bram_3 or k11_needs_bram_3 or k10_needs_bram_3 or k9_needs_bram_3 or k8_needs_bram_3);
	bram_9_input_sel(3) <= (k15_needs_bram_4 or k14_needs_bram_4 or k13_needs_bram_4 or k12_needs_bram_4 or k11_needs_bram_4 or k10_needs_bram_4 or k9_needs_bram_4 or k8_needs_bram_4);
	bram_11_input_sel(3) <= (k15_needs_bram_5 or k14_needs_bram_5 or k13_needs_bram_5 or k12_needs_bram_5 or k11_needs_bram_5 or k10_needs_bram_5 or k9_needs_bram_5 or k8_needs_bram_5);
	bram_13_input_sel(3) <= (k15_needs_bram_6 or k14_needs_bram_6 or k13_needs_bram_6 or k12_needs_bram_6 or k11_needs_bram_6 or k10_needs_bram_6 or k9_needs_bram_6 or k8_needs_bram_6);
	bram_15_input_sel(3) <= (k15_needs_bram_7 or k14_needs_bram_7 or k13_needs_bram_7 or k12_needs_bram_7 or k11_needs_bram_7 or k10_needs_bram_7 or k9_needs_bram_7 or k8_needs_bram_7);

	bram_1_input_sel(2) <= (k15_needs_bram_0 or k14_needs_bram_0 or k13_needs_bram_0 or k12_needs_bram_0) or ((k7_needs_bram_0 or k6_needs_bram_0 or k5_needs_bram_0 or k4_needs_bram_0) and (not k8_needs_bram_0) and (not k9_needs_bram_0) and (not k10_needs_bram_0) and (not k11_needs_bram_0));
	bram_3_input_sel(2) <= (k15_needs_bram_1 or k14_needs_bram_1 or k13_needs_bram_1 or k12_needs_bram_1) or ((k7_needs_bram_1 or k6_needs_bram_1 or k5_needs_bram_1 or k4_needs_bram_1) and (not k8_needs_bram_1) and (not k9_needs_bram_1) and (not k10_needs_bram_1) and (not k11_needs_bram_1));
	bram_5_input_sel(2) <= (k15_needs_bram_2 or k14_needs_bram_2 or k13_needs_bram_2 or k12_needs_bram_2) or ((k7_needs_bram_2 or k6_needs_bram_2 or k5_needs_bram_2 or k4_needs_bram_2) and (not k8_needs_bram_2) and (not k9_needs_bram_2) and (not k10_needs_bram_2) and (not k11_needs_bram_2));
	bram_7_input_sel(2) <= (k15_needs_bram_3 or k14_needs_bram_3 or k13_needs_bram_3 or k12_needs_bram_3) or ((k7_needs_bram_3 or k6_needs_bram_3 or k5_needs_bram_3 or k4_needs_bram_3) and (not k8_needs_bram_3) and (not k9_needs_bram_3) and (not k10_needs_bram_3) and (not k11_needs_bram_3));
	bram_9_input_sel(2) <= (k15_needs_bram_4 or k14_needs_bram_4 or k13_needs_bram_4 or k12_needs_bram_4) or ((k7_needs_bram_4 or k6_needs_bram_4 or k5_needs_bram_4 or k4_needs_bram_4) and (not k8_needs_bram_4) and (not k9_needs_bram_4) and (not k10_needs_bram_4) and (not k11_needs_bram_4));
	bram_11_input_sel(2) <= (k15_needs_bram_5 or k14_needs_bram_5 or k13_needs_bram_5 or k12_needs_bram_5) or ((k7_needs_bram_5 or k6_needs_bram_5 or k5_needs_bram_5 or k4_needs_bram_5) and (not k8_needs_bram_5) and (not k9_needs_bram_5) and (not k10_needs_bram_5) and (not k11_needs_bram_5));
	bram_13_input_sel(2) <= (k15_needs_bram_6 or k14_needs_bram_6 or k13_needs_bram_6 or k12_needs_bram_6) or ((k7_needs_bram_6 or k6_needs_bram_6 or k5_needs_bram_6 or k4_needs_bram_6) and (not k8_needs_bram_6) and (not k9_needs_bram_6) and (not k10_needs_bram_6) and (not k11_needs_bram_6));
	bram_15_input_sel(2) <= (k15_needs_bram_7 or k14_needs_bram_7 or k13_needs_bram_7 or k12_needs_bram_7) or ((k7_needs_bram_7 or k6_needs_bram_7 or k5_needs_bram_7 or k4_needs_bram_7) and (not k8_needs_bram_7) and (not k9_needs_bram_7) and (not k10_needs_bram_7) and (not k11_needs_bram_7));

	bram_1_input_sel(1) <= (k15_needs_bram_0 or k14_needs_bram_0) or ((k11_needs_bram_0 or k10_needs_bram_0) and (not k12_needs_bram_0) and (not k13_needs_bram_0)) or ((k7_needs_bram_0 or k6_needs_bram_0) and (not k12_needs_bram_0) and (not k13_needs_bram_0) and (not k8_needs_bram_0) and (not k9_needs_bram_0)) or ((k3_needs_bram_0 or k2_needs_bram_0) and (not k12_needs_bram_0) and (not k13_needs_bram_0) and (not k8_needs_bram_0) and (not k9_needs_bram_0) and (not k4_needs_bram_0) and (not k5_needs_bram_0));
	bram_3_input_sel(1) <= (k15_needs_bram_1 or k14_needs_bram_1) or ((k11_needs_bram_1 or k10_needs_bram_1) and (not k12_needs_bram_1) and (not k13_needs_bram_1)) or ((k7_needs_bram_1 or k6_needs_bram_1) and (not k12_needs_bram_1) and (not k13_needs_bram_1) and (not k8_needs_bram_1) and (not k9_needs_bram_1)) or ((k3_needs_bram_1 or k2_needs_bram_1) and (not k12_needs_bram_1) and (not k13_needs_bram_1) and (not k8_needs_bram_1) and (not k9_needs_bram_1) and (not k4_needs_bram_1) and (not k5_needs_bram_1));
	bram_5_input_sel(1) <= (k15_needs_bram_2 or k14_needs_bram_2) or ((k11_needs_bram_2 or k10_needs_bram_2) and (not k12_needs_bram_2) and (not k13_needs_bram_2)) or ((k7_needs_bram_2 or k6_needs_bram_2) and (not k12_needs_bram_2) and (not k13_needs_bram_2) and (not k8_needs_bram_2) and (not k9_needs_bram_2)) or ((k3_needs_bram_2 or k2_needs_bram_2) and (not k12_needs_bram_2) and (not k13_needs_bram_2) and (not k8_needs_bram_2) and (not k9_needs_bram_2) and (not k4_needs_bram_2) and (not k5_needs_bram_2));
	bram_7_input_sel(1) <= (k15_needs_bram_3 or k14_needs_bram_3) or ((k11_needs_bram_3 or k10_needs_bram_3) and (not k12_needs_bram_3) and (not k13_needs_bram_3)) or ((k7_needs_bram_3 or k6_needs_bram_3) and (not k12_needs_bram_3) and (not k13_needs_bram_3) and (not k8_needs_bram_3) and (not k9_needs_bram_3)) or ((k3_needs_bram_3 or k2_needs_bram_3) and (not k12_needs_bram_3) and (not k13_needs_bram_3) and (not k8_needs_bram_3) and (not k9_needs_bram_3) and (not k4_needs_bram_3) and (not k5_needs_bram_3));
	bram_9_input_sel(1) <= (k15_needs_bram_4 or k14_needs_bram_4) or ((k11_needs_bram_4 or k10_needs_bram_4) and (not k12_needs_bram_4) and (not k13_needs_bram_4)) or ((k7_needs_bram_4 or k6_needs_bram_4) and (not k12_needs_bram_4) and (not k13_needs_bram_4) and (not k8_needs_bram_4) and (not k9_needs_bram_4)) or ((k3_needs_bram_4 or k2_needs_bram_4) and (not k12_needs_bram_4) and (not k13_needs_bram_4) and (not k8_needs_bram_4) and (not k9_needs_bram_4) and (not k4_needs_bram_4) and (not k5_needs_bram_4));
	bram_11_input_sel(1) <= (k15_needs_bram_5 or k14_needs_bram_5) or ((k11_needs_bram_5 or k10_needs_bram_5) and (not k12_needs_bram_5) and (not k13_needs_bram_5)) or ((k7_needs_bram_5 or k6_needs_bram_5) and (not k12_needs_bram_5) and (not k13_needs_bram_5) and (not k8_needs_bram_5) and (not k9_needs_bram_5)) or ((k3_needs_bram_5 or k2_needs_bram_5) and (not k12_needs_bram_5) and (not k13_needs_bram_5) and (not k8_needs_bram_5) and (not k9_needs_bram_5) and (not k4_needs_bram_5) and (not k5_needs_bram_5));
	bram_13_input_sel(1) <= (k15_needs_bram_6 or k14_needs_bram_6) or ((k11_needs_bram_6 or k10_needs_bram_6) and (not k12_needs_bram_6) and (not k13_needs_bram_6)) or ((k7_needs_bram_6 or k6_needs_bram_6) and (not k12_needs_bram_6) and (not k13_needs_bram_6) and (not k8_needs_bram_6) and (not k9_needs_bram_6)) or ((k3_needs_bram_6 or k2_needs_bram_6) and (not k12_needs_bram_6) and (not k13_needs_bram_6) and (not k8_needs_bram_6) and (not k9_needs_bram_6) and (not k4_needs_bram_6) and (not k5_needs_bram_6));
	bram_15_input_sel(1) <= (k15_needs_bram_7 or k14_needs_bram_7) or ((k11_needs_bram_7 or k10_needs_bram_7) and (not k12_needs_bram_7) and (not k13_needs_bram_7)) or ((k7_needs_bram_7 or k6_needs_bram_7) and (not k12_needs_bram_7) and (not k13_needs_bram_7) and (not k8_needs_bram_7) and (not k9_needs_bram_7)) or ((k3_needs_bram_7 or k2_needs_bram_7) and (not k12_needs_bram_7) and (not k13_needs_bram_7) and (not k8_needs_bram_7) and (not k9_needs_bram_7) and (not k4_needs_bram_7) and (not k5_needs_bram_7));

	bram_1_input_sel(0) <= (k15_needs_bram_0) or ((k13_needs_bram_0) and (not k14_needs_bram_0)) or ((k11_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0)) or ((k9_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0) and (not k10_needs_bram_0)) or ((k7_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0) and (not k10_needs_bram_0) and (not k8_needs_bram_0)) or ((k5_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0) and (not k10_needs_bram_0) and (not k8_needs_bram_0) and (not k6_needs_bram_0)) or ((k3_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0) and (not k10_needs_bram_0) and (not k8_needs_bram_0) and (not k6_needs_bram_0) and (not k4_needs_bram_0)) or ((k1_needs_bram_0) and (not k14_needs_bram_0) and (not k12_needs_bram_0) and (not k10_needs_bram_0) and (not k8_needs_bram_0) and (not k6_needs_bram_0) and (not k4_needs_bram_0) and (not k2_needs_bram_0));
	bram_3_input_sel(0) <= (k15_needs_bram_1) or ((k13_needs_bram_1) and (not k14_needs_bram_1)) or ((k11_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1)) or ((k9_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1) and (not k10_needs_bram_1)) or ((k7_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1) and (not k10_needs_bram_1) and (not k8_needs_bram_1)) or ((k5_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1) and (not k10_needs_bram_1) and (not k8_needs_bram_1) and (not k6_needs_bram_1)) or ((k3_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1) and (not k10_needs_bram_1) and (not k8_needs_bram_1) and (not k6_needs_bram_1) and (not k4_needs_bram_1)) or ((k1_needs_bram_1) and (not k14_needs_bram_1) and (not k12_needs_bram_1) and (not k10_needs_bram_1) and (not k8_needs_bram_1) and (not k6_needs_bram_1) and (not k4_needs_bram_1) and (not k2_needs_bram_1));
	bram_5_input_sel(0) <= (k15_needs_bram_2) or ((k13_needs_bram_2) and (not k14_needs_bram_2)) or ((k11_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2)) or ((k9_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2) and (not k10_needs_bram_2)) or ((k7_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2) and (not k10_needs_bram_2) and (not k8_needs_bram_2)) or ((k5_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2) and (not k10_needs_bram_2) and (not k8_needs_bram_2) and (not k6_needs_bram_2)) or ((k3_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2) and (not k10_needs_bram_2) and (not k8_needs_bram_2) and (not k6_needs_bram_2) and (not k4_needs_bram_2)) or ((k1_needs_bram_2) and (not k14_needs_bram_2) and (not k12_needs_bram_2) and (not k10_needs_bram_2) and (not k8_needs_bram_2) and (not k6_needs_bram_2) and (not k4_needs_bram_2) and (not k2_needs_bram_2));
	bram_7_input_sel(0) <= (k15_needs_bram_3) or ((k13_needs_bram_3) and (not k14_needs_bram_3)) or ((k11_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3)) or ((k9_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3) and (not k10_needs_bram_3)) or ((k7_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3) and (not k10_needs_bram_3) and (not k8_needs_bram_3)) or ((k5_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3) and (not k10_needs_bram_3) and (not k8_needs_bram_3) and (not k6_needs_bram_3)) or ((k3_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3) and (not k10_needs_bram_3) and (not k8_needs_bram_3) and (not k6_needs_bram_3) and (not k4_needs_bram_3)) or ((k1_needs_bram_3) and (not k14_needs_bram_3) and (not k12_needs_bram_3) and (not k10_needs_bram_3) and (not k8_needs_bram_3) and (not k6_needs_bram_3) and (not k4_needs_bram_3) and (not k2_needs_bram_3));
	bram_9_input_sel(0) <= (k15_needs_bram_4) or ((k13_needs_bram_4) and (not k14_needs_bram_4)) or ((k11_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4)) or ((k9_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4) and (not k10_needs_bram_4)) or ((k7_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4) and (not k10_needs_bram_4) and (not k8_needs_bram_4)) or ((k5_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4) and (not k10_needs_bram_4) and (not k8_needs_bram_4) and (not k6_needs_bram_4)) or ((k3_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4) and (not k10_needs_bram_4) and (not k8_needs_bram_4) and (not k6_needs_bram_4) and (not k4_needs_bram_4)) or ((k1_needs_bram_4) and (not k14_needs_bram_4) and (not k12_needs_bram_4) and (not k10_needs_bram_4) and (not k8_needs_bram_4) and (not k6_needs_bram_4) and (not k4_needs_bram_4) and (not k2_needs_bram_4));
	bram_11_input_sel(0) <= (k15_needs_bram_5) or ((k13_needs_bram_5) and (not k14_needs_bram_5)) or ((k11_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5)) or ((k9_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5) and (not k10_needs_bram_5)) or ((k7_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5) and (not k10_needs_bram_5) and (not k8_needs_bram_5)) or ((k5_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5) and (not k10_needs_bram_5) and (not k8_needs_bram_5) and (not k6_needs_bram_5)) or ((k3_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5) and (not k10_needs_bram_5) and (not k8_needs_bram_5) and (not k6_needs_bram_5) and (not k4_needs_bram_5)) or ((k1_needs_bram_5) and (not k14_needs_bram_5) and (not k12_needs_bram_5) and (not k10_needs_bram_5) and (not k8_needs_bram_5) and (not k6_needs_bram_5) and (not k4_needs_bram_5) and (not k2_needs_bram_5));
	bram_13_input_sel(0) <= (k15_needs_bram_6) or ((k13_needs_bram_6) and (not k14_needs_bram_6)) or ((k11_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6)) or ((k9_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6) and (not k10_needs_bram_6)) or ((k7_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6) and (not k10_needs_bram_6) and (not k8_needs_bram_6)) or ((k5_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6) and (not k10_needs_bram_6) and (not k8_needs_bram_6) and (not k6_needs_bram_6)) or ((k3_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6) and (not k10_needs_bram_6) and (not k8_needs_bram_6) and (not k6_needs_bram_6) and (not k4_needs_bram_6)) or ((k1_needs_bram_6) and (not k14_needs_bram_6) and (not k12_needs_bram_6) and (not k10_needs_bram_6) and (not k8_needs_bram_6) and (not k6_needs_bram_6) and (not k4_needs_bram_6) and (not k2_needs_bram_6));
	bram_15_input_sel(0) <= (k15_needs_bram_7) or ((k13_needs_bram_7) and (not k14_needs_bram_7)) or ((k11_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7)) or ((k9_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7) and (not k10_needs_bram_7)) or ((k7_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7) and (not k10_needs_bram_7) and (not k8_needs_bram_7)) or ((k5_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7) and (not k10_needs_bram_7) and (not k8_needs_bram_7) and (not k6_needs_bram_7)) or ((k3_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7) and (not k10_needs_bram_7) and (not k8_needs_bram_7) and (not k6_needs_bram_7) and (not k4_needs_bram_7)) or ((k1_needs_bram_7) and (not k14_needs_bram_7) and (not k12_needs_bram_7) and (not k10_needs_bram_7) and (not k8_needs_bram_7) and (not k6_needs_bram_7) and (not k4_needs_bram_7) and (not k2_needs_bram_7));



	k0_being_served <= to_bit(REQ_0);

	k1_being_served <= to_bit(REQ_1) and (
	                       ( not k1_output_sel(2) and not k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_0_input_sel(3) and not bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and not bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k1_output_sel(2) and not k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_2_input_sel(3) and not bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and not bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k1_output_sel(2) and     k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_4_input_sel(3) and not bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and not bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k1_output_sel(2) and     k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_6_input_sel(3) and not bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and not bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(2) and not k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_8_input_sel(3) and not bram_8_input_sel(2) and not bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and not bram_9_input_sel(2) and not bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(2) and not k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_10_input_sel(3) and not bram_10_input_sel(2) and not bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and not bram_11_input_sel(2) and not bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(2) and     k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_12_input_sel(3) and not bram_12_input_sel(2) and not bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and not bram_13_input_sel(2) and not bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(2) and     k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_14_input_sel(3) and not bram_14_input_sel(2) and not bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and not bram_15_input_sel(2) and not bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_1)) );

	k2_being_served <= to_bit(REQ_2) and (
	                       ( not k2_output_sel(2) and not k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_0_input_sel(3) and not bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and not bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k2_output_sel(2) and not k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_2_input_sel(3) and not bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and not bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k2_output_sel(2) and     k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_4_input_sel(3) and not bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and not bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k2_output_sel(2) and     k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_6_input_sel(3) and not bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and not bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(2) and not k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_8_input_sel(3) and not bram_8_input_sel(2) and     bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and not bram_9_input_sel(2) and     bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(2) and not k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_10_input_sel(3) and not bram_10_input_sel(2) and     bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and not bram_11_input_sel(2) and     bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(2) and     k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_12_input_sel(3) and not bram_12_input_sel(2) and     bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and not bram_13_input_sel(2) and     bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(2) and     k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_14_input_sel(3) and not bram_14_input_sel(2) and     bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and not bram_15_input_sel(2) and     bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_2)) );

	k3_being_served <= to_bit(REQ_3) and (
	                       ( not k3_output_sel(2) and not k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_0_input_sel(3) and not bram_0_input_sel(2) and     bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and not bram_1_input_sel(2) and     bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k3_output_sel(2) and not k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_2_input_sel(3) and not bram_2_input_sel(2) and     bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and not bram_3_input_sel(2) and     bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k3_output_sel(2) and     k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_4_input_sel(3) and not bram_4_input_sel(2) and     bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and not bram_5_input_sel(2) and     bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k3_output_sel(2) and     k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_6_input_sel(3) and not bram_6_input_sel(2) and     bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and not bram_7_input_sel(2) and     bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(2) and not k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_8_input_sel(3) and not bram_8_input_sel(2) and     bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and not bram_9_input_sel(2) and     bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(2) and not k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_10_input_sel(3) and not bram_10_input_sel(2) and     bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and not bram_11_input_sel(2) and     bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(2) and     k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_12_input_sel(3) and not bram_12_input_sel(2) and     bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and not bram_13_input_sel(2) and     bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(2) and     k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_14_input_sel(3) and not bram_14_input_sel(2) and     bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and not bram_15_input_sel(2) and     bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_3)) );

	k4_being_served <= to_bit(REQ_4) and (
	                       ( not k4_output_sel(2) and not k4_output_sel(1) and not k4_output_sel(0) and ( ( not bram_0_input_sel(3) and     bram_0_input_sel(2) and not bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and     bram_1_input_sel(2) and not bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k4_output_sel(2) and not k4_output_sel(1) and     k4_output_sel(0) and ( ( not bram_2_input_sel(3) and     bram_2_input_sel(2) and not bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and     bram_3_input_sel(2) and not bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k4_output_sel(2) and     k4_output_sel(1) and not k4_output_sel(0) and ( ( not bram_4_input_sel(3) and     bram_4_input_sel(2) and not bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and     bram_5_input_sel(2) and not bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k4_output_sel(2) and     k4_output_sel(1) and     k4_output_sel(0) and ( ( not bram_6_input_sel(3) and     bram_6_input_sel(2) and not bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and     bram_7_input_sel(2) and not bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(2) and not k4_output_sel(1) and not k4_output_sel(0) and ( ( not bram_8_input_sel(3) and     bram_8_input_sel(2) and not bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and     bram_9_input_sel(2) and not bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(2) and not k4_output_sel(1) and     k4_output_sel(0) and ( ( not bram_10_input_sel(3) and     bram_10_input_sel(2) and not bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and     bram_11_input_sel(2) and not bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(2) and     k4_output_sel(1) and not k4_output_sel(0) and ( ( not bram_12_input_sel(3) and     bram_12_input_sel(2) and not bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and     bram_13_input_sel(2) and not bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(2) and     k4_output_sel(1) and     k4_output_sel(0) and ( ( not bram_14_input_sel(3) and     bram_14_input_sel(2) and not bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and     bram_15_input_sel(2) and not bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_4)) );

	k5_being_served <= to_bit(REQ_5) and (
	                       ( not k5_output_sel(2) and not k5_output_sel(1) and not k5_output_sel(0) and ( ( not bram_0_input_sel(3) and     bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and     bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k5_output_sel(2) and not k5_output_sel(1) and     k5_output_sel(0) and ( ( not bram_2_input_sel(3) and     bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and     bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k5_output_sel(2) and     k5_output_sel(1) and not k5_output_sel(0) and ( ( not bram_4_input_sel(3) and     bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and     bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k5_output_sel(2) and     k5_output_sel(1) and     k5_output_sel(0) and ( ( not bram_6_input_sel(3) and     bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and     bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(2) and not k5_output_sel(1) and not k5_output_sel(0) and ( ( not bram_8_input_sel(3) and     bram_8_input_sel(2) and not bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and     bram_9_input_sel(2) and not bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(2) and not k5_output_sel(1) and     k5_output_sel(0) and ( ( not bram_10_input_sel(3) and     bram_10_input_sel(2) and not bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and     bram_11_input_sel(2) and not bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(2) and     k5_output_sel(1) and not k5_output_sel(0) and ( ( not bram_12_input_sel(3) and     bram_12_input_sel(2) and not bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and     bram_13_input_sel(2) and not bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(2) and     k5_output_sel(1) and     k5_output_sel(0) and ( ( not bram_14_input_sel(3) and     bram_14_input_sel(2) and not bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and     bram_15_input_sel(2) and not bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_5)) );

	k6_being_served <= to_bit(REQ_6) and (
	                       ( not k6_output_sel(2) and not k6_output_sel(1) and not k6_output_sel(0) and ( ( not bram_0_input_sel(3) and     bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and     bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k6_output_sel(2) and not k6_output_sel(1) and     k6_output_sel(0) and ( ( not bram_2_input_sel(3) and     bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and     bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k6_output_sel(2) and     k6_output_sel(1) and not k6_output_sel(0) and ( ( not bram_4_input_sel(3) and     bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and     bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k6_output_sel(2) and     k6_output_sel(1) and     k6_output_sel(0) and ( ( not bram_6_input_sel(3) and     bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and     bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(2) and not k6_output_sel(1) and not k6_output_sel(0) and ( ( not bram_8_input_sel(3) and     bram_8_input_sel(2) and     bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and     bram_9_input_sel(2) and     bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(2) and not k6_output_sel(1) and     k6_output_sel(0) and ( ( not bram_10_input_sel(3) and     bram_10_input_sel(2) and     bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and     bram_11_input_sel(2) and     bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(2) and     k6_output_sel(1) and not k6_output_sel(0) and ( ( not bram_12_input_sel(3) and     bram_12_input_sel(2) and     bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and     bram_13_input_sel(2) and     bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(2) and     k6_output_sel(1) and     k6_output_sel(0) and ( ( not bram_14_input_sel(3) and     bram_14_input_sel(2) and     bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and     bram_15_input_sel(2) and     bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_6)) );

	k7_being_served <= to_bit(REQ_7) and (
	                       ( not k7_output_sel(2) and not k7_output_sel(1) and not k7_output_sel(0) and ( ( not bram_0_input_sel(3) and     bram_0_input_sel(2) and     bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(3) and     bram_1_input_sel(2) and     bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k7_output_sel(2) and not k7_output_sel(1) and     k7_output_sel(0) and ( ( not bram_2_input_sel(3) and     bram_2_input_sel(2) and     bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(3) and     bram_3_input_sel(2) and     bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k7_output_sel(2) and     k7_output_sel(1) and not k7_output_sel(0) and ( ( not bram_4_input_sel(3) and     bram_4_input_sel(2) and     bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(3) and     bram_5_input_sel(2) and     bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k7_output_sel(2) and     k7_output_sel(1) and     k7_output_sel(0) and ( ( not bram_6_input_sel(3) and     bram_6_input_sel(2) and     bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(3) and     bram_7_input_sel(2) and     bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(2) and not k7_output_sel(1) and not k7_output_sel(0) and ( ( not bram_8_input_sel(3) and     bram_8_input_sel(2) and     bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             ( not bram_9_input_sel(3) and     bram_9_input_sel(2) and     bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(2) and not k7_output_sel(1) and     k7_output_sel(0) and ( ( not bram_10_input_sel(3) and     bram_10_input_sel(2) and     bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             ( not bram_11_input_sel(3) and     bram_11_input_sel(2) and     bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(2) and     k7_output_sel(1) and not k7_output_sel(0) and ( ( not bram_12_input_sel(3) and     bram_12_input_sel(2) and     bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             ( not bram_13_input_sel(3) and     bram_13_input_sel(2) and     bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(2) and     k7_output_sel(1) and     k7_output_sel(0) and ( ( not bram_14_input_sel(3) and     bram_14_input_sel(2) and     bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             ( not bram_15_input_sel(3) and     bram_15_input_sel(2) and     bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_7)) );

	k8_being_served <= to_bit(REQ_8) and (
	                       ( not k8_output_sel(2) and not k8_output_sel(1) and not k8_output_sel(0) and ( (     bram_0_input_sel(3) and not bram_0_input_sel(2) and not bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and not bram_1_input_sel(2) and not bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k8_output_sel(2) and not k8_output_sel(1) and     k8_output_sel(0) and ( (     bram_2_input_sel(3) and not bram_2_input_sel(2) and not bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and not bram_3_input_sel(2) and not bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k8_output_sel(2) and     k8_output_sel(1) and not k8_output_sel(0) and ( (     bram_4_input_sel(3) and not bram_4_input_sel(2) and not bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and not bram_5_input_sel(2) and not bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k8_output_sel(2) and     k8_output_sel(1) and     k8_output_sel(0) and ( (     bram_6_input_sel(3) and not bram_6_input_sel(2) and not bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and not bram_7_input_sel(2) and not bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k8_output_sel(2) and not k8_output_sel(1) and not k8_output_sel(0) and ( (     bram_8_input_sel(3) and not bram_8_input_sel(2) and not bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and not bram_9_input_sel(2) and not bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k8_output_sel(2) and not k8_output_sel(1) and     k8_output_sel(0) and ( (     bram_10_input_sel(3) and not bram_10_input_sel(2) and not bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and not bram_11_input_sel(2) and not bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k8_output_sel(2) and     k8_output_sel(1) and not k8_output_sel(0) and ( (     bram_12_input_sel(3) and not bram_12_input_sel(2) and not bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and not bram_13_input_sel(2) and not bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k8_output_sel(2) and     k8_output_sel(1) and     k8_output_sel(0) and ( (     bram_14_input_sel(3) and not bram_14_input_sel(2) and not bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and not bram_15_input_sel(2) and not bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_8)) );

	k9_being_served <= to_bit(REQ_9) and (
	                       ( not k9_output_sel(2) and not k9_output_sel(1) and not k9_output_sel(0) and ( (     bram_0_input_sel(3) and not bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and not bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k9_output_sel(2) and not k9_output_sel(1) and     k9_output_sel(0) and ( (     bram_2_input_sel(3) and not bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and not bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k9_output_sel(2) and     k9_output_sel(1) and not k9_output_sel(0) and ( (     bram_4_input_sel(3) and not bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and not bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k9_output_sel(2) and     k9_output_sel(1) and     k9_output_sel(0) and ( (     bram_6_input_sel(3) and not bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and not bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k9_output_sel(2) and not k9_output_sel(1) and not k9_output_sel(0) and ( (     bram_8_input_sel(3) and not bram_8_input_sel(2) and not bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and not bram_9_input_sel(2) and not bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k9_output_sel(2) and not k9_output_sel(1) and     k9_output_sel(0) and ( (     bram_10_input_sel(3) and not bram_10_input_sel(2) and not bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and not bram_11_input_sel(2) and not bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k9_output_sel(2) and     k9_output_sel(1) and not k9_output_sel(0) and ( (     bram_12_input_sel(3) and not bram_12_input_sel(2) and not bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and not bram_13_input_sel(2) and not bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k9_output_sel(2) and     k9_output_sel(1) and     k9_output_sel(0) and ( (     bram_14_input_sel(3) and not bram_14_input_sel(2) and not bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and not bram_15_input_sel(2) and not bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_9)) );

	k10_being_served <= to_bit(REQ_10) and (
	                       ( not k10_output_sel(2) and not k10_output_sel(1) and not k10_output_sel(0) and ( (     bram_0_input_sel(3) and not bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and not bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k10_output_sel(2) and not k10_output_sel(1) and     k10_output_sel(0) and ( (     bram_2_input_sel(3) and not bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and not bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k10_output_sel(2) and     k10_output_sel(1) and not k10_output_sel(0) and ( (     bram_4_input_sel(3) and not bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and not bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k10_output_sel(2) and     k10_output_sel(1) and     k10_output_sel(0) and ( (     bram_6_input_sel(3) and not bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and not bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k10_output_sel(2) and not k10_output_sel(1) and not k10_output_sel(0) and ( (     bram_8_input_sel(3) and not bram_8_input_sel(2) and     bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and not bram_9_input_sel(2) and     bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k10_output_sel(2) and not k10_output_sel(1) and     k10_output_sel(0) and ( (     bram_10_input_sel(3) and not bram_10_input_sel(2) and     bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and not bram_11_input_sel(2) and     bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k10_output_sel(2) and     k10_output_sel(1) and not k10_output_sel(0) and ( (     bram_12_input_sel(3) and not bram_12_input_sel(2) and     bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and not bram_13_input_sel(2) and     bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k10_output_sel(2) and     k10_output_sel(1) and     k10_output_sel(0) and ( (     bram_14_input_sel(3) and not bram_14_input_sel(2) and     bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and not bram_15_input_sel(2) and     bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_10)) );

	k11_being_served <= to_bit(REQ_11) and (
	                       ( not k11_output_sel(2) and not k11_output_sel(1) and not k11_output_sel(0) and ( (     bram_0_input_sel(3) and not bram_0_input_sel(2) and     bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and not bram_1_input_sel(2) and     bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k11_output_sel(2) and not k11_output_sel(1) and     k11_output_sel(0) and ( (     bram_2_input_sel(3) and not bram_2_input_sel(2) and     bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and not bram_3_input_sel(2) and     bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k11_output_sel(2) and     k11_output_sel(1) and not k11_output_sel(0) and ( (     bram_4_input_sel(3) and not bram_4_input_sel(2) and     bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and not bram_5_input_sel(2) and     bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k11_output_sel(2) and     k11_output_sel(1) and     k11_output_sel(0) and ( (     bram_6_input_sel(3) and not bram_6_input_sel(2) and     bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and not bram_7_input_sel(2) and     bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k11_output_sel(2) and not k11_output_sel(1) and not k11_output_sel(0) and ( (     bram_8_input_sel(3) and not bram_8_input_sel(2) and     bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and not bram_9_input_sel(2) and     bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k11_output_sel(2) and not k11_output_sel(1) and     k11_output_sel(0) and ( (     bram_10_input_sel(3) and not bram_10_input_sel(2) and     bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and not bram_11_input_sel(2) and     bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k11_output_sel(2) and     k11_output_sel(1) and not k11_output_sel(0) and ( (     bram_12_input_sel(3) and not bram_12_input_sel(2) and     bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and not bram_13_input_sel(2) and     bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k11_output_sel(2) and     k11_output_sel(1) and     k11_output_sel(0) and ( (     bram_14_input_sel(3) and not bram_14_input_sel(2) and     bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and not bram_15_input_sel(2) and     bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_11)) );

	k12_being_served <= to_bit(REQ_12) and (
	                       ( not k12_output_sel(2) and not k12_output_sel(1) and not k12_output_sel(0) and ( (     bram_0_input_sel(3) and     bram_0_input_sel(2) and not bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and     bram_1_input_sel(2) and not bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k12_output_sel(2) and not k12_output_sel(1) and     k12_output_sel(0) and ( (     bram_2_input_sel(3) and     bram_2_input_sel(2) and not bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and     bram_3_input_sel(2) and not bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k12_output_sel(2) and     k12_output_sel(1) and not k12_output_sel(0) and ( (     bram_4_input_sel(3) and     bram_4_input_sel(2) and not bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and     bram_5_input_sel(2) and not bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k12_output_sel(2) and     k12_output_sel(1) and     k12_output_sel(0) and ( (     bram_6_input_sel(3) and     bram_6_input_sel(2) and not bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and     bram_7_input_sel(2) and not bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k12_output_sel(2) and not k12_output_sel(1) and not k12_output_sel(0) and ( (     bram_8_input_sel(3) and     bram_8_input_sel(2) and not bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and     bram_9_input_sel(2) and not bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k12_output_sel(2) and not k12_output_sel(1) and     k12_output_sel(0) and ( (     bram_10_input_sel(3) and     bram_10_input_sel(2) and not bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and     bram_11_input_sel(2) and not bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k12_output_sel(2) and     k12_output_sel(1) and not k12_output_sel(0) and ( (     bram_12_input_sel(3) and     bram_12_input_sel(2) and not bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and     bram_13_input_sel(2) and not bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k12_output_sel(2) and     k12_output_sel(1) and     k12_output_sel(0) and ( (     bram_14_input_sel(3) and     bram_14_input_sel(2) and not bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and     bram_15_input_sel(2) and not bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_12)) );

	k13_being_served <= to_bit(REQ_13) and (
	                       ( not k13_output_sel(2) and not k13_output_sel(1) and not k13_output_sel(0) and ( (     bram_0_input_sel(3) and     bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and     bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k13_output_sel(2) and not k13_output_sel(1) and     k13_output_sel(0) and ( (     bram_2_input_sel(3) and     bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and     bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       ( not k13_output_sel(2) and     k13_output_sel(1) and not k13_output_sel(0) and ( (     bram_4_input_sel(3) and     bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and     bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       ( not k13_output_sel(2) and     k13_output_sel(1) and     k13_output_sel(0) and ( (     bram_6_input_sel(3) and     bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and     bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (     k13_output_sel(2) and not k13_output_sel(1) and not k13_output_sel(0) and ( (     bram_8_input_sel(3) and     bram_8_input_sel(2) and not bram_8_input_sel(1) and     bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and     bram_9_input_sel(2) and not bram_9_input_sel(1) and     bram_9_input_sel(0)) ) )
	                       or
	                       (     k13_output_sel(2) and not k13_output_sel(1) and     k13_output_sel(0) and ( (     bram_10_input_sel(3) and     bram_10_input_sel(2) and not bram_10_input_sel(1) and     bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and     bram_11_input_sel(2) and not bram_11_input_sel(1) and     bram_11_input_sel(0)) ) )
	                       or
	                       (     k13_output_sel(2) and     k13_output_sel(1) and not k13_output_sel(0) and ( (     bram_12_input_sel(3) and     bram_12_input_sel(2) and not bram_12_input_sel(1) and     bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and     bram_13_input_sel(2) and not bram_13_input_sel(1) and     bram_13_input_sel(0)) ) )
	                       or
	                       (     k13_output_sel(2) and     k13_output_sel(1) and     k13_output_sel(0) and ( (     bram_14_input_sel(3) and     bram_14_input_sel(2) and not bram_14_input_sel(1) and     bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and     bram_15_input_sel(2) and not bram_15_input_sel(1) and     bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_13)) );

	k14_being_served <= to_bit(REQ_14) and (
	                       ( not k14_output_sel(2) and not k14_output_sel(1) and not k14_output_sel(0) and ( (     bram_0_input_sel(3) and     bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(3) and     bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k14_output_sel(2) and not k14_output_sel(1) and     k14_output_sel(0) and ( (     bram_2_input_sel(3) and     bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(3) and     bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       ( not k14_output_sel(2) and     k14_output_sel(1) and not k14_output_sel(0) and ( (     bram_4_input_sel(3) and     bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(3) and     bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       ( not k14_output_sel(2) and     k14_output_sel(1) and     k14_output_sel(0) and ( (     bram_6_input_sel(3) and     bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(3) and     bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (     k14_output_sel(2) and not k14_output_sel(1) and not k14_output_sel(0) and ( (     bram_8_input_sel(3) and     bram_8_input_sel(2) and     bram_8_input_sel(1) and not bram_8_input_sel(0)) or
	                                                                             (     bram_9_input_sel(3) and     bram_9_input_sel(2) and     bram_9_input_sel(1) and not bram_9_input_sel(0)) ) )
	                       or
	                       (     k14_output_sel(2) and not k14_output_sel(1) and     k14_output_sel(0) and ( (     bram_10_input_sel(3) and     bram_10_input_sel(2) and     bram_10_input_sel(1) and not bram_10_input_sel(0)) or
	                                                                             (     bram_11_input_sel(3) and     bram_11_input_sel(2) and     bram_11_input_sel(1) and not bram_11_input_sel(0)) ) )
	                       or
	                       (     k14_output_sel(2) and     k14_output_sel(1) and not k14_output_sel(0) and ( (     bram_12_input_sel(3) and     bram_12_input_sel(2) and     bram_12_input_sel(1) and not bram_12_input_sel(0)) or
	                                                                             (     bram_13_input_sel(3) and     bram_13_input_sel(2) and     bram_13_input_sel(1) and not bram_13_input_sel(0)) ) )
	                       or
	                       (     k14_output_sel(2) and     k14_output_sel(1) and     k14_output_sel(0) and ( (     bram_14_input_sel(3) and     bram_14_input_sel(2) and     bram_14_input_sel(1) and not bram_14_input_sel(0)) or
	                                                                             (     bram_15_input_sel(3) and     bram_15_input_sel(2) and     bram_15_input_sel(1) and not bram_15_input_sel(0)) ) )
	                       or
	                       (not to_bit(REQ_14)) );

	k15_being_served <= to_bit(REQ_15);


	k0_output_sel(3 downto 1) <= to_bitvector(ADDR_0(11 downto 9));
	k1_output_sel(3 downto 1) <= to_bitvector(ADDR_1(11 downto 9));
	k2_output_sel(3 downto 1) <= to_bitvector(ADDR_2(11 downto 9));
	k3_output_sel(3 downto 1) <= to_bitvector(ADDR_3(11 downto 9));
	k4_output_sel(3 downto 1) <= to_bitvector(ADDR_4(11 downto 9));
	k5_output_sel(3 downto 1) <= to_bitvector(ADDR_5(11 downto 9));
	k6_output_sel(3 downto 1) <= to_bitvector(ADDR_6(11 downto 9));
	k7_output_sel(3 downto 1) <= to_bitvector(ADDR_7(11 downto 9));
	k8_output_sel(3 downto 1) <= to_bitvector(ADDR_8(11 downto 9));
	k9_output_sel(3 downto 1) <= to_bitvector(ADDR_9(11 downto 9));
	k10_output_sel(3 downto 1) <= to_bitvector(ADDR_10(11 downto 9));
	k11_output_sel(3 downto 1) <= to_bitvector(ADDR_11(11 downto 9));
	k12_output_sel(3 downto 1) <= to_bitvector(ADDR_12(11 downto 9));
	k13_output_sel(3 downto 1) <= to_bitvector(ADDR_13(11 downto 9));
	k14_output_sel(3 downto 1) <= to_bitvector(ADDR_14(11 downto 9));
	k15_output_sel(3 downto 1) <= to_bitvector(ADDR_15(11 downto 9));


	k0_output_sel(0) <= ( not k0_output_sel(3) and not k0_output_sel(2) and not k0_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k0_output_sel(3) and not k0_output_sel(2) and     k0_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k0_output_sel(3) and     k0_output_sel(2) and not k0_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k0_output_sel(3) and     k0_output_sel(2) and     k0_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k0_output_sel(3) and not k0_output_sel(2) and not k0_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k0_output_sel(3) and not k0_output_sel(2) and     k0_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k0_output_sel(3) and     k0_output_sel(2) and not k0_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k0_output_sel(3) and     k0_output_sel(2) and     k0_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k1_output_sel(0) <= ( not k1_output_sel(3) and not k1_output_sel(2) and not k1_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k1_output_sel(3) and not k1_output_sel(2) and     k1_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k1_output_sel(3) and     k1_output_sel(2) and not k1_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k1_output_sel(3) and     k1_output_sel(2) and     k1_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k1_output_sel(3) and not k1_output_sel(2) and not k1_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k1_output_sel(3) and not k1_output_sel(2) and     k1_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k1_output_sel(3) and     k1_output_sel(2) and not k1_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k1_output_sel(3) and     k1_output_sel(2) and     k1_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k2_output_sel(0) <= ( not k2_output_sel(3) and not k2_output_sel(2) and not k2_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k2_output_sel(3) and not k2_output_sel(2) and     k2_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k2_output_sel(3) and     k2_output_sel(2) and not k2_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k2_output_sel(3) and     k2_output_sel(2) and     k2_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k2_output_sel(3) and not k2_output_sel(2) and not k2_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k2_output_sel(3) and not k2_output_sel(2) and     k2_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k2_output_sel(3) and     k2_output_sel(2) and not k2_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k2_output_sel(3) and     k2_output_sel(2) and     k2_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k3_output_sel(0) <= ( not k3_output_sel(3) and not k3_output_sel(2) and not k3_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k3_output_sel(3) and not k3_output_sel(2) and     k3_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k3_output_sel(3) and     k3_output_sel(2) and not k3_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k3_output_sel(3) and     k3_output_sel(2) and     k3_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k3_output_sel(3) and not k3_output_sel(2) and not k3_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k3_output_sel(3) and not k3_output_sel(2) and     k3_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k3_output_sel(3) and     k3_output_sel(2) and not k3_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k3_output_sel(3) and     k3_output_sel(2) and     k3_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k4_output_sel(0) <= ( not k4_output_sel(3) and not k4_output_sel(2) and not k4_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k4_output_sel(3) and not k4_output_sel(2) and     k4_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k4_output_sel(3) and     k4_output_sel(2) and not k4_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k4_output_sel(3) and     k4_output_sel(2) and     k4_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k4_output_sel(3) and not k4_output_sel(2) and not k4_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k4_output_sel(3) and not k4_output_sel(2) and     k4_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k4_output_sel(3) and     k4_output_sel(2) and not k4_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k4_output_sel(3) and     k4_output_sel(2) and     k4_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k5_output_sel(0) <= ( not k5_output_sel(3) and not k5_output_sel(2) and not k5_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k5_output_sel(3) and not k5_output_sel(2) and     k5_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k5_output_sel(3) and     k5_output_sel(2) and not k5_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k5_output_sel(3) and     k5_output_sel(2) and     k5_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k5_output_sel(3) and not k5_output_sel(2) and not k5_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k5_output_sel(3) and not k5_output_sel(2) and     k5_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k5_output_sel(3) and     k5_output_sel(2) and not k5_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k5_output_sel(3) and     k5_output_sel(2) and     k5_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k6_output_sel(0) <= ( not k6_output_sel(3) and not k6_output_sel(2) and not k6_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k6_output_sel(3) and not k6_output_sel(2) and     k6_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k6_output_sel(3) and     k6_output_sel(2) and not k6_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k6_output_sel(3) and     k6_output_sel(2) and     k6_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k6_output_sel(3) and not k6_output_sel(2) and not k6_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k6_output_sel(3) and not k6_output_sel(2) and     k6_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k6_output_sel(3) and     k6_output_sel(2) and not k6_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k6_output_sel(3) and     k6_output_sel(2) and     k6_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k7_output_sel(0) <= ( not k7_output_sel(3) and not k7_output_sel(2) and not k7_output_sel(1) and ( not bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k7_output_sel(3) and not k7_output_sel(2) and     k7_output_sel(1) and ( not bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k7_output_sel(3) and     k7_output_sel(2) and not k7_output_sel(1) and ( not bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k7_output_sel(3) and     k7_output_sel(2) and     k7_output_sel(1) and ( not bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k7_output_sel(3) and not k7_output_sel(2) and not k7_output_sel(1) and ( not bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k7_output_sel(3) and not k7_output_sel(2) and     k7_output_sel(1) and ( not bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k7_output_sel(3) and     k7_output_sel(2) and not k7_output_sel(1) and ( not bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k7_output_sel(3) and     k7_output_sel(2) and     k7_output_sel(1) and ( not bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k8_output_sel(0) <= ( not k8_output_sel(3) and not k8_output_sel(2) and not k8_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k8_output_sel(3) and not k8_output_sel(2) and     k8_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k8_output_sel(3) and     k8_output_sel(2) and not k8_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k8_output_sel(3) and     k8_output_sel(2) and     k8_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k8_output_sel(3) and not k8_output_sel(2) and not k8_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k8_output_sel(3) and not k8_output_sel(2) and     k8_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k8_output_sel(3) and     k8_output_sel(2) and not k8_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k8_output_sel(3) and     k8_output_sel(2) and     k8_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k9_output_sel(0) <= ( not k9_output_sel(3) and not k9_output_sel(2) and not k9_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k9_output_sel(3) and not k9_output_sel(2) and     k9_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k9_output_sel(3) and     k9_output_sel(2) and not k9_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k9_output_sel(3) and     k9_output_sel(2) and     k9_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k9_output_sel(3) and not k9_output_sel(2) and not k9_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k9_output_sel(3) and not k9_output_sel(2) and     k9_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k9_output_sel(3) and     k9_output_sel(2) and not k9_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k9_output_sel(3) and     k9_output_sel(2) and     k9_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k10_output_sel(0) <= ( not k10_output_sel(3) and not k10_output_sel(2) and not k10_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k10_output_sel(3) and not k10_output_sel(2) and     k10_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k10_output_sel(3) and     k10_output_sel(2) and not k10_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k10_output_sel(3) and     k10_output_sel(2) and     k10_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k10_output_sel(3) and not k10_output_sel(2) and not k10_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k10_output_sel(3) and not k10_output_sel(2) and     k10_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k10_output_sel(3) and     k10_output_sel(2) and not k10_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k10_output_sel(3) and     k10_output_sel(2) and     k10_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k11_output_sel(0) <= ( not k11_output_sel(3) and not k11_output_sel(2) and not k11_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                          not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k11_output_sel(3) and not k11_output_sel(2) and     k11_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                          not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k11_output_sel(3) and     k11_output_sel(2) and not k11_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                          not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k11_output_sel(3) and     k11_output_sel(2) and     k11_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                          not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k11_output_sel(3) and not k11_output_sel(2) and not k11_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                          not bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k11_output_sel(3) and not k11_output_sel(2) and     k11_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                          not bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k11_output_sel(3) and     k11_output_sel(2) and not k11_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                          not bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k11_output_sel(3) and     k11_output_sel(2) and     k11_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                          not bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k12_output_sel(0) <= ( not k12_output_sel(3) and not k12_output_sel(2) and not k12_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k12_output_sel(3) and not k12_output_sel(2) and     k12_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k12_output_sel(3) and     k12_output_sel(2) and not k12_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k12_output_sel(3) and     k12_output_sel(2) and     k12_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k12_output_sel(3) and not k12_output_sel(2) and not k12_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k12_output_sel(3) and not k12_output_sel(2) and     k12_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k12_output_sel(3) and     k12_output_sel(2) and not k12_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k12_output_sel(3) and     k12_output_sel(2) and     k12_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k13_output_sel(0) <= ( not k13_output_sel(3) and not k13_output_sel(2) and not k13_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k13_output_sel(3) and not k13_output_sel(2) and     k13_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k13_output_sel(3) and     k13_output_sel(2) and not k13_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k13_output_sel(3) and     k13_output_sel(2) and     k13_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k13_output_sel(3) and not k13_output_sel(2) and not k13_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                          not bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k13_output_sel(3) and not k13_output_sel(2) and     k13_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                          not bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k13_output_sel(3) and     k13_output_sel(2) and not k13_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                          not bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k13_output_sel(3) and     k13_output_sel(2) and     k13_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                          not bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );

	k14_output_sel(0) <= ( not k14_output_sel(3) and not k14_output_sel(2) and not k14_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k14_output_sel(3) and not k14_output_sel(2) and     k14_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    ( not k14_output_sel(3) and     k14_output_sel(2) and not k14_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    ( not k14_output_sel(3) and     k14_output_sel(2) and     k14_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) )
	                    or
	                    (     k14_output_sel(3) and not k14_output_sel(2) and not k14_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                          not bram_9_input_sel(0)) )
	                    or
	                    (     k14_output_sel(3) and not k14_output_sel(2) and     k14_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                          not bram_11_input_sel(0)) )
	                    or
	                    (     k14_output_sel(3) and     k14_output_sel(2) and not k14_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                          not bram_13_input_sel(0)) )
	                    or
	                    (     k14_output_sel(3) and     k14_output_sel(2) and     k14_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                          not bram_15_input_sel(0)) );

	k15_output_sel(0) <= ( not k15_output_sel(3) and not k15_output_sel(2) and not k15_output_sel(1) and (     bram_1_input_sel(3) and
	                                                                              bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k15_output_sel(3) and not k15_output_sel(2) and     k15_output_sel(1) and (     bram_3_input_sel(3) and
	                                                                              bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    ( not k15_output_sel(3) and     k15_output_sel(2) and not k15_output_sel(1) and (     bram_5_input_sel(3) and
	                                                                              bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    ( not k15_output_sel(3) and     k15_output_sel(2) and     k15_output_sel(1) and (     bram_7_input_sel(3) and
	                                                                              bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) )
	                    or
	                    (     k15_output_sel(3) and not k15_output_sel(2) and not k15_output_sel(1) and (     bram_9_input_sel(3) and
	                                                                              bram_9_input_sel(2) and
	                                                                              bram_9_input_sel(1) and
	                                                                              bram_9_input_sel(0)) )
	                    or
	                    (     k15_output_sel(3) and not k15_output_sel(2) and     k15_output_sel(1) and (     bram_11_input_sel(3) and
	                                                                              bram_11_input_sel(2) and
	                                                                              bram_11_input_sel(1) and
	                                                                              bram_11_input_sel(0)) )
	                    or
	                    (     k15_output_sel(3) and     k15_output_sel(2) and not k15_output_sel(1) and (     bram_13_input_sel(3) and
	                                                                              bram_13_input_sel(2) and
	                                                                              bram_13_input_sel(1) and
	                                                                              bram_13_input_sel(0)) )
	                    or
	                    (     k15_output_sel(3) and     k15_output_sel(2) and     k15_output_sel(1) and (     bram_15_input_sel(3) and
	                                                                              bram_15_input_sel(2) and
	                                                                              bram_15_input_sel(1) and
	                                                                              bram_15_input_sel(0)) );


	input_controller_0 : block begin
		with bram_0_input_sel select
			bram_di(1 * 32 - 1 downto 0 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_0_input_sel select
			bram_addr(1 * 9 - 1 downto 0 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_0_input_sel select
			bram_we(1 * 4 - 1 downto 0 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_0;

	input_controller_1 : block begin
		with bram_1_input_sel select
			bram_di(2 * 32 - 1 downto 1 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_1_input_sel select
			bram_addr(2 * 9 - 1 downto 1 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_1_input_sel select
			bram_we(2 * 4 - 1 downto 1 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_1;

	input_controller_2 : block begin
		with bram_2_input_sel select
			bram_di(3 * 32 - 1 downto 2 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_2_input_sel select
			bram_addr(3 * 9 - 1 downto 2 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_2_input_sel select
			bram_we(3 * 4 - 1 downto 2 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_2;

	input_controller_3 : block begin
		with bram_3_input_sel select
			bram_di(4 * 32 - 1 downto 3 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_3_input_sel select
			bram_addr(4 * 9 - 1 downto 3 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_3_input_sel select
			bram_we(4 * 4 - 1 downto 3 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_3;

	input_controller_4 : block begin
		with bram_4_input_sel select
			bram_di(5 * 32 - 1 downto 4 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_4_input_sel select
			bram_addr(5 * 9 - 1 downto 4 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_4_input_sel select
			bram_we(5 * 4 - 1 downto 4 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_4;

	input_controller_5 : block begin
		with bram_5_input_sel select
			bram_di(6 * 32 - 1 downto 5 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_5_input_sel select
			bram_addr(6 * 9 - 1 downto 5 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_5_input_sel select
			bram_we(6 * 4 - 1 downto 5 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_5;

	input_controller_6 : block begin
		with bram_6_input_sel select
			bram_di(7 * 32 - 1 downto 6 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_6_input_sel select
			bram_addr(7 * 9 - 1 downto 6 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_6_input_sel select
			bram_we(7 * 4 - 1 downto 6 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_6;

	input_controller_7 : block begin
		with bram_7_input_sel select
			bram_di(8 * 32 - 1 downto 7 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_7_input_sel select
			bram_addr(8 * 9 - 1 downto 7 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_7_input_sel select
			bram_we(8 * 4 - 1 downto 7 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_7;

	input_controller_8 : block begin
		with bram_8_input_sel select
			bram_di(9 * 32 - 1 downto 8 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_8_input_sel select
			bram_addr(9 * 9 - 1 downto 8 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_8_input_sel select
			bram_we(9 * 4 - 1 downto 8 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_8;

	input_controller_9 : block begin
		with bram_9_input_sel select
			bram_di(10 * 32 - 1 downto 9 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_9_input_sel select
			bram_addr(10 * 9 - 1 downto 9 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_9_input_sel select
			bram_we(10 * 4 - 1 downto 9 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_9;

	input_controller_10 : block begin
		with bram_10_input_sel select
			bram_di(11 * 32 - 1 downto 10 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_10_input_sel select
			bram_addr(11 * 9 - 1 downto 10 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_10_input_sel select
			bram_we(11 * 4 - 1 downto 10 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_10;

	input_controller_11 : block begin
		with bram_11_input_sel select
			bram_di(12 * 32 - 1 downto 11 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_11_input_sel select
			bram_addr(12 * 9 - 1 downto 11 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_11_input_sel select
			bram_we(12 * 4 - 1 downto 11 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_11;

	input_controller_12 : block begin
		with bram_12_input_sel select
			bram_di(13 * 32 - 1 downto 12 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_12_input_sel select
			bram_addr(13 * 9 - 1 downto 12 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_12_input_sel select
			bram_we(13 * 4 - 1 downto 12 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_12;

	input_controller_13 : block begin
		with bram_13_input_sel select
			bram_di(14 * 32 - 1 downto 13 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_13_input_sel select
			bram_addr(14 * 9 - 1 downto 13 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_13_input_sel select
			bram_we(14 * 4 - 1 downto 13 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_13;

	input_controller_14 : block begin
		with bram_14_input_sel select
			bram_di(15 * 32 - 1 downto 14 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_14_input_sel select
			bram_addr(15 * 9 - 1 downto 14 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_14_input_sel select
			bram_we(15 * 4 - 1 downto 14 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_14;

	input_controller_15 : block begin
		with bram_15_input_sel select
			bram_di(16 * 32 - 1 downto 15 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "0000",
			              DI(32 * 2 - 1 downto 32 * 1) when "0001",
			              DI(32 * 3 - 1 downto 32 * 2) when "0010",
			              DI(32 * 4 - 1 downto 32 * 3) when "0011",
			              DI(32 * 5 - 1 downto 32 * 4) when "0100",
			              DI(32 * 6 - 1 downto 32 * 5) when "0101",
			              DI(32 * 7 - 1 downto 32 * 6) when "0110",
			              DI(32 * 8 - 1 downto 32 * 7) when "0111",
			              DI(32 * 9 - 1 downto 32 * 8) when "1000",
			              DI(32 * 10 - 1 downto 32 * 9) when "1001",
			              DI(32 * 11 - 1 downto 32 * 10) when "1010",
			              DI(32 * 12 - 1 downto 32 * 11) when "1011",
			              DI(32 * 13 - 1 downto 32 * 12) when "1100",
			              DI(32 * 14 - 1 downto 32 * 13) when "1101",
			              DI(32 * 15 - 1 downto 32 * 14) when "1110",
			              DI(32 * 16 - 1 downto 32 * 15) when "1111";
		with bram_15_input_sel select
			bram_addr(16 * 9 - 1 downto 15 * 9)  <=  ADDR_0(8 downto 0) when "0000",
			              ADDR_1(8 downto 0) when "0001",
			              ADDR_2(8 downto 0) when "0010",
			              ADDR_3(8 downto 0) when "0011",
			              ADDR_4(8 downto 0) when "0100",
			              ADDR_5(8 downto 0) when "0101",
			              ADDR_6(8 downto 0) when "0110",
			              ADDR_7(8 downto 0) when "0111",
			              ADDR_8(8 downto 0) when "1000",
			              ADDR_9(8 downto 0) when "1001",
			              ADDR_10(8 downto 0) when "1010",
			              ADDR_11(8 downto 0) when "1011",
			              ADDR_12(8 downto 0) when "1100",
			              ADDR_13(8 downto 0) when "1101",
			              ADDR_14(8 downto 0) when "1110",
			              ADDR_15(8 downto 0) when "1111";
		with bram_15_input_sel select
			bram_we(16 * 4 - 1 downto 15 * 4)    <=  we_0_safe when "0000",
			              we_1_safe when "0001",
			              we_2_safe when "0010",
			              we_3_safe when "0011",
			              we_4_safe when "0100",
			              we_5_safe when "0101",
			              we_6_safe when "0110",
			              we_7_safe when "0111",
			              we_8_safe when "1000",
			              we_9_safe when "1001",
			              we_10_safe when "1010",
			              we_11_safe when "1011",
			              we_12_safe when "1100",
			              we_13_safe when "1101",
			              we_14_safe when "1110",
			              we_15_safe when "1111";
	end block input_controller_15;


	output_controller_0 : block begin
		with k0_output_sel select
			DO(32 * 1 - 1 downto 32 * 0) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO(32 * 2 - 1 downto 32 * 1) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO(32 * 3 - 1 downto 32 * 2) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO(32 * 4 - 1 downto 32 * 3) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_3;

	output_controller_4 : block begin
		with k4_output_sel select
			DO(32 * 5 - 1 downto 32 * 4) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_4;

	output_controller_5 : block begin
		with k5_output_sel select
			DO(32 * 6 - 1 downto 32 * 5) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_5;

	output_controller_6 : block begin
		with k6_output_sel select
			DO(32 * 7 - 1 downto 32 * 6) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_6;

	output_controller_7 : block begin
		with k7_output_sel select
			DO(32 * 8 - 1 downto 32 * 7) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_7;

	output_controller_8 : block begin
		with k8_output_sel select
			DO(32 * 9 - 1 downto 32 * 8) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_8;

	output_controller_9 : block begin
		with k9_output_sel select
			DO(32 * 10 - 1 downto 32 * 9) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_9;

	output_controller_10 : block begin
		with k10_output_sel select
			DO(32 * 11 - 1 downto 32 * 10) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_10;

	output_controller_11 : block begin
		with k11_output_sel select
			DO(32 * 12 - 1 downto 32 * 11) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_11;

	output_controller_12 : block begin
		with k12_output_sel select
			DO(32 * 13 - 1 downto 32 * 12) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_12;

	output_controller_13 : block begin
		with k13_output_sel select
			DO(32 * 14 - 1 downto 32 * 13) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_13;

	output_controller_14 : block begin
		with k14_output_sel select
			DO(32 * 15 - 1 downto 32 * 14) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_14;

	output_controller_15 : block begin
		with k15_output_sel select
			DO(32 * 16 - 1 downto 32 * 15) <= bram_do(1 * 32 - 1 downto 0 * 32) when "0000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "0001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "0010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "0011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "0100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "0101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "0110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "0111",
			        bram_do(9 * 32 - 1 downto 8 * 32) when "1000",
			        bram_do(10 * 32 - 1 downto 9 * 32) when "1001",
			        bram_do(11 * 32 - 1 downto 10 * 32) when "1010",
			        bram_do(12 * 32 - 1 downto 11 * 32) when "1011",
			        bram_do(13 * 32 - 1 downto 12 * 32) when "1100",
			        bram_do(14 * 32 - 1 downto 13 * 32) when "1101",
			        bram_do(15 * 32 - 1 downto 14 * 32) when "1110",
			        bram_do(16 * 32 - 1 downto 15 * 32) when "1111";
	end block output_controller_15;


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
