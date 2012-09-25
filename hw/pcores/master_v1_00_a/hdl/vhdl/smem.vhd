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

		DO_0, DO_1, DO_2, DO_3, DO_4, DO_5, DO_6, DO_7                     : out std_logic_vector(31 downto 0);    -- Data output ports
		DI_0, DI_1, DI_2, DI_3, DI_4, DI_5, DI_6, DI_7                     : in  std_logic_vector(31 downto 0);    -- Data input ports
		ADDR_0, ADDR_1, ADDR_2, ADDR_3, ADDR_4, ADDR_5, ADDR_6, ADDR_7     : in  std_logic_vector(10 downto 0);    -- Address input ports
		WE_0, WE_1, WE_2, WE_3, WE_4, WE_5, WE_6, WE_7                     : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports
		BRAM_CLK, TRIG_CLK, RST                                            : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3, REQ_4, REQ_5, REQ_6, REQ_7             : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3, RDY_4, RDY_5, RDY_6, RDY_7             : out std_logic                         -- Ready output port

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

	signal k0_output_sel       : bit_vector(2 downto 0) := "000";
	signal k1_output_sel       : bit_vector(2 downto 0) := "000";
	signal k2_output_sel       : bit_vector(2 downto 0) := "000";
	signal k3_output_sel       : bit_vector(2 downto 0) := "000";
	signal k4_output_sel       : bit_vector(2 downto 0) := "000";
	signal k5_output_sel       : bit_vector(2 downto 0) := "000";
	signal k6_output_sel       : bit_vector(2 downto 0) := "000";
	signal k7_output_sel       : bit_vector(2 downto 0) := "000";

	signal k0_being_served     : bit := '0';
	signal k1_being_served     : bit := '0';
	signal k2_being_served     : bit := '0';
	signal k3_being_served     : bit := '0';
	signal k4_being_served     : bit := '0';
	signal k5_being_served     : bit := '0';
	signal k6_being_served     : bit := '0';
	signal k7_being_served     : bit := '0';

	signal k0_needs_attention  : bit := '0';
	signal k1_needs_attention  : bit := '0';
	signal k2_needs_attention  : bit := '0';
	signal k3_needs_attention  : bit := '0';
	signal k4_needs_attention  : bit := '0';
	signal k5_needs_attention  : bit := '0';
	signal k6_needs_attention  : bit := '0';
	signal k7_needs_attention  : bit := '0';

	signal addr_0_eq_addr_1    : bit := '0';
	signal addr_0_eq_addr_2    : bit := '0';
	signal addr_0_eq_addr_3    : bit := '0';
	signal addr_0_eq_addr_4    : bit := '0';
	signal addr_0_eq_addr_5    : bit := '0';
	signal addr_0_eq_addr_6    : bit := '0';
	signal addr_0_eq_addr_7    : bit := '0';
	signal addr_1_eq_addr_2    : bit := '0';
	signal addr_1_eq_addr_3    : bit := '0';
	signal addr_1_eq_addr_4    : bit := '0';
	signal addr_1_eq_addr_5    : bit := '0';
	signal addr_1_eq_addr_6    : bit := '0';
	signal addr_1_eq_addr_7    : bit := '0';
	signal addr_2_eq_addr_3    : bit := '0';
	signal addr_2_eq_addr_4    : bit := '0';
	signal addr_2_eq_addr_5    : bit := '0';
	signal addr_2_eq_addr_6    : bit := '0';
	signal addr_2_eq_addr_7    : bit := '0';
	signal addr_3_eq_addr_4    : bit := '0';
	signal addr_3_eq_addr_5    : bit := '0';
	signal addr_3_eq_addr_6    : bit := '0';
	signal addr_3_eq_addr_7    : bit := '0';
	signal addr_4_eq_addr_5    : bit := '0';
	signal addr_4_eq_addr_6    : bit := '0';
	signal addr_4_eq_addr_7    : bit := '0';
	signal addr_5_eq_addr_6    : bit := '0';
	signal addr_5_eq_addr_7    : bit := '0';
	signal addr_6_eq_addr_7    : bit := '0';

	signal we_0_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_1_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_2_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_3_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_4_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_5_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_6_safe           : std_logic_vector(3 downto 0) := "0000";
	signal we_7_safe           : std_logic_vector(3 downto 0) := "0000";

	signal bram_0_A_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_0_B_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_1_A_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_1_B_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_2_A_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_2_B_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_3_A_input_sel  : bit_vector(2 downto 0) := "000";
	signal bram_3_B_input_sel  : bit_vector(2 downto 0) := "000";

	signal k0_needs_bram_0     : bit := '0';
	signal k0_needs_bram_1     : bit := '0';
	signal k0_needs_bram_2     : bit := '0';
	signal k0_needs_bram_3     : bit := '0';
	signal k1_needs_bram_0     : bit := '0';
	signal k1_needs_bram_1     : bit := '0';
	signal k1_needs_bram_2     : bit := '0';
	signal k1_needs_bram_3     : bit := '0';
	signal k2_needs_bram_0     : bit := '0';
	signal k2_needs_bram_1     : bit := '0';
	signal k2_needs_bram_2     : bit := '0';
	signal k2_needs_bram_3     : bit := '0';
	signal k3_needs_bram_0     : bit := '0';
	signal k3_needs_bram_1     : bit := '0';
	signal k3_needs_bram_2     : bit := '0';
	signal k3_needs_bram_3     : bit := '0';
	signal k4_needs_bram_0     : bit := '0';
	signal k4_needs_bram_1     : bit := '0';
	signal k4_needs_bram_2     : bit := '0';
	signal k4_needs_bram_3     : bit := '0';
	signal k5_needs_bram_0     : bit := '0';
	signal k5_needs_bram_1     : bit := '0';
	signal k5_needs_bram_2     : bit := '0';
	signal k5_needs_bram_3     : bit := '0';
	signal k6_needs_bram_0     : bit := '0';
	signal k6_needs_bram_1     : bit := '0';
	signal k6_needs_bram_2     : bit := '0';
	signal k6_needs_bram_3     : bit := '0';
	signal k7_needs_bram_0     : bit := '0';
	signal k7_needs_bram_1     : bit := '0';
	signal k7_needs_bram_2     : bit := '0';
	signal k7_needs_bram_3     : bit := '0';

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

	signal do_2_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal do_2_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_2_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_2_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal addr_2_a            : std_logic_vector(8 downto 0) := "000000000";
	signal addr_2_b            : std_logic_vector(8 downto 0) := "000000000";
	signal we_2_a              : std_logic_vector(3 downto 0) := "0000";
	signal we_2_b              : std_logic_vector(3 downto 0) := "0000";
	signal en_2_a              : std_logic := '0';
	signal en_2_b              : std_logic := '0';

	signal do_3_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal do_3_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_3_a              : std_logic_vector(31 downto 0) := X"00000000";
	signal di_3_b              : std_logic_vector(31 downto 0) := X"00000000";
	signal addr_3_a            : std_logic_vector(8 downto 0) := "000000000";
	signal addr_3_b            : std_logic_vector(8 downto 0) := "000000000";
	signal we_3_a              : std_logic_vector(3 downto 0) := "0000";
	signal we_3_b              : std_logic_vector(3 downto 0) := "0000";
	signal en_3_a              : std_logic := '0';
	signal en_3_b              : std_logic := '0';


begin


	en_0_a <= '1';
	en_0_b <= '1';
	en_1_a <= '1';
	en_1_b <= '1';
	en_2_a <= '1';
	en_2_b <= '1';
	en_3_a <= '1';
	en_3_b <= '1';


	we_0_safe(3) <= WE_0(3) and to_stdulogic(k0_needs_attention);
	we_0_safe(2) <= WE_0(2) and to_stdulogic(k0_needs_attention);
	we_0_safe(1) <= WE_0(1) and to_stdulogic(k0_needs_attention);
	we_0_safe(0) <= WE_0(0) and to_stdulogic(k0_needs_attention);

	we_1_safe(3) <= WE_1(3) and to_stdulogic(k1_needs_attention);
	we_1_safe(2) <= WE_1(2) and to_stdulogic(k1_needs_attention);
	we_1_safe(1) <= WE_1(1) and to_stdulogic(k1_needs_attention);
	we_1_safe(0) <= WE_1(0) and to_stdulogic(k1_needs_attention);

	we_2_safe(3) <= WE_2(3) and to_stdulogic(k2_needs_attention);
	we_2_safe(2) <= WE_2(2) and to_stdulogic(k2_needs_attention);
	we_2_safe(1) <= WE_2(1) and to_stdulogic(k2_needs_attention);
	we_2_safe(0) <= WE_2(0) and to_stdulogic(k2_needs_attention);

	we_3_safe(3) <= WE_3(3) and to_stdulogic(k3_needs_attention);
	we_3_safe(2) <= WE_3(2) and to_stdulogic(k3_needs_attention);
	we_3_safe(1) <= WE_3(1) and to_stdulogic(k3_needs_attention);
	we_3_safe(0) <= WE_3(0) and to_stdulogic(k3_needs_attention);

	we_4_safe(3) <= WE_4(3) and to_stdulogic(k4_needs_attention);
	we_4_safe(2) <= WE_4(2) and to_stdulogic(k4_needs_attention);
	we_4_safe(1) <= WE_4(1) and to_stdulogic(k4_needs_attention);
	we_4_safe(0) <= WE_4(0) and to_stdulogic(k4_needs_attention);

	we_5_safe(3) <= WE_5(3) and to_stdulogic(k5_needs_attention);
	we_5_safe(2) <= WE_5(2) and to_stdulogic(k5_needs_attention);
	we_5_safe(1) <= WE_5(1) and to_stdulogic(k5_needs_attention);
	we_5_safe(0) <= WE_5(0) and to_stdulogic(k5_needs_attention);

	we_6_safe(3) <= WE_6(3) and to_stdulogic(k6_needs_attention);
	we_6_safe(2) <= WE_6(2) and to_stdulogic(k6_needs_attention);
	we_6_safe(1) <= WE_6(1) and to_stdulogic(k6_needs_attention);
	we_6_safe(0) <= WE_6(0) and to_stdulogic(k6_needs_attention);

	we_7_safe(3) <= WE_7(3) and to_stdulogic(k7_needs_attention);
	we_7_safe(2) <= WE_7(2) and to_stdulogic(k7_needs_attention);
	we_7_safe(1) <= WE_7(1) and to_stdulogic(k7_needs_attention);
	we_7_safe(0) <= WE_7(0) and to_stdulogic(k7_needs_attention);


	RDY_0 <= to_stdulogic(k0_being_served);
	RDY_1 <= to_stdulogic(k1_being_served);
	RDY_2 <= to_stdulogic(k2_being_served);
	RDY_3 <= to_stdulogic(k3_being_served);
	RDY_4 <= to_stdulogic(k4_being_served);
	RDY_5 <= to_stdulogic(k5_being_served);
	RDY_6 <= to_stdulogic(k6_being_served);
	RDY_7 <= to_stdulogic(k7_being_served);


	k0_needs_attention <= to_bit(REQ_0);

	k1_needs_attention <= to_bit(REQ_1) and (not (addr_0_eq_addr_1 and k0_needs_attention));

	k2_needs_attention <= to_bit(REQ_2) and (not (addr_0_eq_addr_2 and k0_needs_attention)) and (not (addr_1_eq_addr_2 and k1_needs_attention));

	k3_needs_attention <= to_bit(REQ_3) and (not (addr_0_eq_addr_3 and k0_needs_attention)) and (not (addr_1_eq_addr_3 and k1_needs_attention)) and (not (addr_2_eq_addr_3 and k2_needs_attention));

	k4_needs_attention <= to_bit(REQ_4) and (not (addr_0_eq_addr_4 and k0_needs_attention)) and (not (addr_1_eq_addr_4 and k1_needs_attention)) and (not (addr_2_eq_addr_4 and k2_needs_attention)) and (not (addr_3_eq_addr_4 and k3_needs_attention));

	k5_needs_attention <= to_bit(REQ_5) and (not (addr_0_eq_addr_5 and k0_needs_attention)) and (not (addr_1_eq_addr_5 and k1_needs_attention)) and (not (addr_2_eq_addr_5 and k2_needs_attention)) and (not (addr_3_eq_addr_5 and k3_needs_attention)) and (not (addr_4_eq_addr_5 and k4_needs_attention));

	k6_needs_attention <= to_bit(REQ_6) and (not (addr_0_eq_addr_6 and k0_needs_attention)) and (not (addr_1_eq_addr_6 and k1_needs_attention)) and (not (addr_2_eq_addr_6 and k2_needs_attention)) and (not (addr_3_eq_addr_6 and k3_needs_attention)) and (not (addr_4_eq_addr_6 and k4_needs_attention)) and (not (addr_5_eq_addr_6 and k5_needs_attention));

	k7_needs_attention <= to_bit(REQ_7) and (not (addr_0_eq_addr_7 and k0_needs_attention)) and (not (addr_1_eq_addr_7 and k1_needs_attention)) and (not (addr_2_eq_addr_7 and k2_needs_attention)) and (not (addr_3_eq_addr_7 and k3_needs_attention)) and (not (addr_4_eq_addr_7 and k4_needs_attention)) and (not (addr_5_eq_addr_7 and k5_needs_attention)) and (not (addr_6_eq_addr_7 and k6_needs_attention));


	k0_needs_bram_0 <= k0_needs_attention and not to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_1 <= k0_needs_attention and not to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));
	k0_needs_bram_2 <= k0_needs_attention and     to_bit(ADDR_0(10)) and not to_bit(ADDR_0(9));
	k0_needs_bram_3 <= k0_needs_attention and     to_bit(ADDR_0(10)) and     to_bit(ADDR_0(9));

	k1_needs_bram_0 <= k1_needs_attention and not to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_1 <= k1_needs_attention and not to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));
	k1_needs_bram_2 <= k1_needs_attention and     to_bit(ADDR_1(10)) and not to_bit(ADDR_1(9));
	k1_needs_bram_3 <= k1_needs_attention and     to_bit(ADDR_1(10)) and     to_bit(ADDR_1(9));

	k2_needs_bram_0 <= k2_needs_attention and not to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_1 <= k2_needs_attention and not to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));
	k2_needs_bram_2 <= k2_needs_attention and     to_bit(ADDR_2(10)) and not to_bit(ADDR_2(9));
	k2_needs_bram_3 <= k2_needs_attention and     to_bit(ADDR_2(10)) and     to_bit(ADDR_2(9));

	k3_needs_bram_0 <= k3_needs_attention and not to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_1 <= k3_needs_attention and not to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));
	k3_needs_bram_2 <= k3_needs_attention and     to_bit(ADDR_3(10)) and not to_bit(ADDR_3(9));
	k3_needs_bram_3 <= k3_needs_attention and     to_bit(ADDR_3(10)) and     to_bit(ADDR_3(9));

	k4_needs_bram_0 <= k4_needs_attention and not to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_1 <= k4_needs_attention and not to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));
	k4_needs_bram_2 <= k4_needs_attention and     to_bit(ADDR_4(10)) and not to_bit(ADDR_4(9));
	k4_needs_bram_3 <= k4_needs_attention and     to_bit(ADDR_4(10)) and     to_bit(ADDR_4(9));

	k5_needs_bram_0 <= k5_needs_attention and not to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_1 <= k5_needs_attention and not to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));
	k5_needs_bram_2 <= k5_needs_attention and     to_bit(ADDR_5(10)) and not to_bit(ADDR_5(9));
	k5_needs_bram_3 <= k5_needs_attention and     to_bit(ADDR_5(10)) and     to_bit(ADDR_5(9));

	k6_needs_bram_0 <= k6_needs_attention and not to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_1 <= k6_needs_attention and not to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));
	k6_needs_bram_2 <= k6_needs_attention and     to_bit(ADDR_6(10)) and not to_bit(ADDR_6(9));
	k6_needs_bram_3 <= k6_needs_attention and     to_bit(ADDR_6(10)) and     to_bit(ADDR_6(9));

	-- NEVER USED! --k7_needs_bram_0 <= k7_needs_attention and not to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	-- NEVER USED! --k7_needs_bram_1 <= k7_needs_attention and not to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));
	-- NEVER USED! --k7_needs_bram_2 <= k7_needs_attention and     to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	-- NEVER USED! --k7_needs_bram_3 <= k7_needs_attention and     to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));


	bram_0_A_input_sel(2) <= not (k0_needs_bram_0 or k1_needs_bram_0 or k2_needs_bram_0 or k3_needs_bram_0);
	bram_1_A_input_sel(2) <= not (k0_needs_bram_1 or k1_needs_bram_1 or k2_needs_bram_1 or k3_needs_bram_1);
	bram_2_A_input_sel(2) <= not (k0_needs_bram_2 or k1_needs_bram_2 or k2_needs_bram_2 or k3_needs_bram_2);
	bram_3_A_input_sel(2) <= not (k0_needs_bram_3 or k1_needs_bram_3 or k2_needs_bram_3 or k3_needs_bram_3);

	bram_0_A_input_sel(1) <= not (k0_needs_bram_0 or k1_needs_bram_0 or ((k4_needs_bram_0 or k5_needs_bram_0) and (not k3_needs_bram_0) and (not k2_needs_bram_0)));
	bram_1_A_input_sel(1) <= not (k0_needs_bram_1 or k1_needs_bram_1 or ((k4_needs_bram_1 or k5_needs_bram_1) and (not k3_needs_bram_1) and (not k2_needs_bram_1)));
	bram_2_A_input_sel(1) <= not (k0_needs_bram_2 or k1_needs_bram_2 or ((k4_needs_bram_2 or k5_needs_bram_2) and (not k3_needs_bram_2) and (not k2_needs_bram_2)));
	bram_3_A_input_sel(1) <= not (k0_needs_bram_3 or k1_needs_bram_3 or ((k4_needs_bram_3 or k5_needs_bram_3) and (not k3_needs_bram_3) and (not k2_needs_bram_3)));

	bram_0_A_input_sel(0) <= not (k0_needs_bram_0 or (k2_needs_bram_0 and not k1_needs_bram_0) or (k4_needs_bram_0 and not k3_needs_bram_0 and not k1_needs_bram_0) or (k6_needs_bram_0 and not k5_needs_bram_0 and not k3_needs_bram_0 and not k1_needs_bram_0));
	bram_1_A_input_sel(0) <= not (k0_needs_bram_1 or (k2_needs_bram_1 and not k1_needs_bram_1) or (k4_needs_bram_1 and not k3_needs_bram_1 and not k1_needs_bram_1) or (k6_needs_bram_1 and not k5_needs_bram_1 and not k3_needs_bram_1 and not k1_needs_bram_1));
	bram_2_A_input_sel(0) <= not (k0_needs_bram_2 or (k2_needs_bram_2 and not k1_needs_bram_2) or (k4_needs_bram_2 and not k3_needs_bram_2 and not k1_needs_bram_2) or (k6_needs_bram_2 and not k5_needs_bram_2 and not k3_needs_bram_2 and not k1_needs_bram_2));
	bram_3_A_input_sel(0) <= not (k0_needs_bram_3 or (k2_needs_bram_3 and not k1_needs_bram_3) or (k4_needs_bram_3 and not k3_needs_bram_3 and not k1_needs_bram_3) or (k6_needs_bram_3 and not k5_needs_bram_3 and not k3_needs_bram_3 and not k1_needs_bram_3));


------------------------------------------------------------------------------------------------------------------
-- EXPAND !!
------------------------------------------------------------------------------------------------------------------
	-- TODO: find the proper logic functions for B ports
	bram_0_B_input_sel(2) <= bram_0_A_input_sel(1);
	bram_0_B_input_sel(1) <= bram_0_A_input_sel(1) or bram_0_A_input_sel(0) or not k1_needs_bram_0;
	bram_0_B_input_sel(0) <= not (k2_needs_bram_0 and ((k0_needs_bram_0 and not k1_needs_bram_0) or
	                                                   (k1_needs_bram_0 and not k0_needs_bram_0)));
	bram_1_B_input_sel(2) <= bram_1_A_input_sel(1);
	bram_1_B_input_sel(1) <= bram_1_A_input_sel(1) or bram_1_A_input_sel(0) or not k1_needs_bram_1;
	bram_1_B_input_sel(0) <= not (k2_needs_bram_1 and ((k0_needs_bram_1 and not k1_needs_bram_1) or
	                                                   (k1_needs_bram_1 and not k0_needs_bram_1)));
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------


	addr_0_eq_addr_1 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_1(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_1(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_1(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_1(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_1(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_1(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_1(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_1(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_1(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_1(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_1(0))) );

	addr_0_eq_addr_2 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_2(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_2(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_2(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_2(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_2(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_2(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_2(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_2(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_2(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_2(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_2(0))) );

	addr_0_eq_addr_3 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_3(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_3(0))) );

	addr_0_eq_addr_4 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_4(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_4(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_4(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_4(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_4(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_4(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_4(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_4(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_4(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_4(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_4(0))) );

	addr_0_eq_addr_5 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_5(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_5(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_5(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_5(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_5(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_5(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_5(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_5(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_5(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_5(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_5(0))) );

	addr_0_eq_addr_6 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_6(0))) );

	addr_0_eq_addr_7 <= ( (to_bit(ADDR_0(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_0(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_7(0))) );

	addr_1_eq_addr_2 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_2(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_2(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_2(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_2(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_2(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_2(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_2(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_2(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_2(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_2(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_2(0))) );

	addr_1_eq_addr_3 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_3(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_3(0))) );

	addr_1_eq_addr_4 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_4(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_4(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_4(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_4(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_4(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_4(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_4(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_4(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_4(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_4(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_4(0))) );

	addr_1_eq_addr_5 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_5(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_5(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_5(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_5(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_5(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_5(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_5(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_5(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_5(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_5(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_5(0))) );

	addr_1_eq_addr_6 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_6(0))) );

	addr_1_eq_addr_7 <= ( (to_bit(ADDR_1(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_1(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_7(0))) );

	addr_2_eq_addr_3 <= ( (to_bit(ADDR_2(10)) xnor to_bit(ADDR_3(10))) and
	                      (to_bit(ADDR_2(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_3(0))) );

	addr_2_eq_addr_4 <= ( (to_bit(ADDR_2(10)) xnor to_bit(ADDR_4(10))) and
	                      (to_bit(ADDR_2(9)) xnor to_bit(ADDR_4(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_4(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_4(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_4(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_4(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_4(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_4(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_4(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_4(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_4(0))) );

	addr_2_eq_addr_5 <= ( (to_bit(ADDR_2(10)) xnor to_bit(ADDR_5(10))) and
	                      (to_bit(ADDR_2(9)) xnor to_bit(ADDR_5(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_5(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_5(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_5(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_5(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_5(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_5(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_5(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_5(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_5(0))) );

	addr_2_eq_addr_6 <= ( (to_bit(ADDR_2(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_2(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_6(0))) );

	addr_2_eq_addr_7 <= ( (to_bit(ADDR_2(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_2(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_7(0))) );

	addr_3_eq_addr_4 <= ( (to_bit(ADDR_3(10)) xnor to_bit(ADDR_4(10))) and
	                      (to_bit(ADDR_3(9)) xnor to_bit(ADDR_4(9))) and
	                      (to_bit(ADDR_3(8)) xnor to_bit(ADDR_4(8))) and
	                      (to_bit(ADDR_3(7)) xnor to_bit(ADDR_4(7))) and
	                      (to_bit(ADDR_3(6)) xnor to_bit(ADDR_4(6))) and
	                      (to_bit(ADDR_3(5)) xnor to_bit(ADDR_4(5))) and
	                      (to_bit(ADDR_3(4)) xnor to_bit(ADDR_4(4))) and
	                      (to_bit(ADDR_3(3)) xnor to_bit(ADDR_4(3))) and
	                      (to_bit(ADDR_3(2)) xnor to_bit(ADDR_4(2))) and
	                      (to_bit(ADDR_3(1)) xnor to_bit(ADDR_4(1))) and
	                      (to_bit(ADDR_3(0)) xnor to_bit(ADDR_4(0))) );

	addr_3_eq_addr_5 <= ( (to_bit(ADDR_3(10)) xnor to_bit(ADDR_5(10))) and
	                      (to_bit(ADDR_3(9)) xnor to_bit(ADDR_5(9))) and
	                      (to_bit(ADDR_3(8)) xnor to_bit(ADDR_5(8))) and
	                      (to_bit(ADDR_3(7)) xnor to_bit(ADDR_5(7))) and
	                      (to_bit(ADDR_3(6)) xnor to_bit(ADDR_5(6))) and
	                      (to_bit(ADDR_3(5)) xnor to_bit(ADDR_5(5))) and
	                      (to_bit(ADDR_3(4)) xnor to_bit(ADDR_5(4))) and
	                      (to_bit(ADDR_3(3)) xnor to_bit(ADDR_5(3))) and
	                      (to_bit(ADDR_3(2)) xnor to_bit(ADDR_5(2))) and
	                      (to_bit(ADDR_3(1)) xnor to_bit(ADDR_5(1))) and
	                      (to_bit(ADDR_3(0)) xnor to_bit(ADDR_5(0))) );

	addr_3_eq_addr_6 <= ( (to_bit(ADDR_3(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_3(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_3(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_3(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_3(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_3(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_3(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_3(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_3(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_3(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_3(0)) xnor to_bit(ADDR_6(0))) );

	addr_3_eq_addr_7 <= ( (to_bit(ADDR_3(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_3(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_3(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_3(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_3(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_3(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_3(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_3(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_3(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_3(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_3(0)) xnor to_bit(ADDR_7(0))) );

	addr_4_eq_addr_5 <= ( (to_bit(ADDR_4(10)) xnor to_bit(ADDR_5(10))) and
	                      (to_bit(ADDR_4(9)) xnor to_bit(ADDR_5(9))) and
	                      (to_bit(ADDR_4(8)) xnor to_bit(ADDR_5(8))) and
	                      (to_bit(ADDR_4(7)) xnor to_bit(ADDR_5(7))) and
	                      (to_bit(ADDR_4(6)) xnor to_bit(ADDR_5(6))) and
	                      (to_bit(ADDR_4(5)) xnor to_bit(ADDR_5(5))) and
	                      (to_bit(ADDR_4(4)) xnor to_bit(ADDR_5(4))) and
	                      (to_bit(ADDR_4(3)) xnor to_bit(ADDR_5(3))) and
	                      (to_bit(ADDR_4(2)) xnor to_bit(ADDR_5(2))) and
	                      (to_bit(ADDR_4(1)) xnor to_bit(ADDR_5(1))) and
	                      (to_bit(ADDR_4(0)) xnor to_bit(ADDR_5(0))) );

	addr_4_eq_addr_6 <= ( (to_bit(ADDR_4(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_4(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_4(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_4(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_4(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_4(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_4(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_4(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_4(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_4(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_4(0)) xnor to_bit(ADDR_6(0))) );

	addr_4_eq_addr_7 <= ( (to_bit(ADDR_4(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_4(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_4(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_4(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_4(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_4(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_4(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_4(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_4(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_4(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_4(0)) xnor to_bit(ADDR_7(0))) );

	addr_5_eq_addr_6 <= ( (to_bit(ADDR_5(10)) xnor to_bit(ADDR_6(10))) and
	                      (to_bit(ADDR_5(9)) xnor to_bit(ADDR_6(9))) and
	                      (to_bit(ADDR_5(8)) xnor to_bit(ADDR_6(8))) and
	                      (to_bit(ADDR_5(7)) xnor to_bit(ADDR_6(7))) and
	                      (to_bit(ADDR_5(6)) xnor to_bit(ADDR_6(6))) and
	                      (to_bit(ADDR_5(5)) xnor to_bit(ADDR_6(5))) and
	                      (to_bit(ADDR_5(4)) xnor to_bit(ADDR_6(4))) and
	                      (to_bit(ADDR_5(3)) xnor to_bit(ADDR_6(3))) and
	                      (to_bit(ADDR_5(2)) xnor to_bit(ADDR_6(2))) and
	                      (to_bit(ADDR_5(1)) xnor to_bit(ADDR_6(1))) and
	                      (to_bit(ADDR_5(0)) xnor to_bit(ADDR_6(0))) );

	addr_5_eq_addr_7 <= ( (to_bit(ADDR_5(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_5(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_5(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_5(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_5(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_5(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_5(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_5(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_5(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_5(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_5(0)) xnor to_bit(ADDR_7(0))) );

	addr_6_eq_addr_7 <= ( (to_bit(ADDR_6(10)) xnor to_bit(ADDR_7(10))) and
	                      (to_bit(ADDR_6(9)) xnor to_bit(ADDR_7(9))) and
	                      (to_bit(ADDR_6(8)) xnor to_bit(ADDR_7(8))) and
	                      (to_bit(ADDR_6(7)) xnor to_bit(ADDR_7(7))) and
	                      (to_bit(ADDR_6(6)) xnor to_bit(ADDR_7(6))) and
	                      (to_bit(ADDR_6(5)) xnor to_bit(ADDR_7(5))) and
	                      (to_bit(ADDR_6(4)) xnor to_bit(ADDR_7(4))) and
	                      (to_bit(ADDR_6(3)) xnor to_bit(ADDR_7(3))) and
	                      (to_bit(ADDR_6(2)) xnor to_bit(ADDR_7(2))) and
	                      (to_bit(ADDR_6(1)) xnor to_bit(ADDR_7(1))) and
	                      (to_bit(ADDR_6(0)) xnor to_bit(ADDR_7(0))) );


	k0_being_served <= to_bit(REQ_0);

	k1_being_served <= to_bit(REQ_1);

	k2_being_served <= to_bit(REQ_2) and (
	                       ( not k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_0_A_input_sel(2) and     bram_0_A_input_sel(1) and not bram_0_A_input_sel(0)) or
	                                                                             ( not bram_0_B_input_sel(2) and     bram_0_B_input_sel(1) and not bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_1_A_input_sel(2) and     bram_1_A_input_sel(1) and not bram_1_A_input_sel(0)) or
	                                                                             ( not bram_1_B_input_sel(2) and     bram_1_B_input_sel(1) and not bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_2_A_input_sel(2) and     bram_2_A_input_sel(1) and not bram_2_A_input_sel(0)) or
	                                                                             ( not bram_2_B_input_sel(2) and     bram_2_B_input_sel(1) and not bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_3_A_input_sel(2) and     bram_3_A_input_sel(1) and not bram_3_A_input_sel(0)) or
	                                                                             ( not bram_3_B_input_sel(2) and     bram_3_B_input_sel(1) and not bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k2_needs_attention) );

	k3_being_served <= to_bit(REQ_3) and (
	                       ( not k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_0_A_input_sel(2) and     bram_0_A_input_sel(1) and     bram_0_A_input_sel(0)) or
	                                                                             ( not bram_0_B_input_sel(2) and     bram_0_B_input_sel(1) and     bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_1_A_input_sel(2) and     bram_1_A_input_sel(1) and     bram_1_A_input_sel(0)) or
	                                                                             ( not bram_1_B_input_sel(2) and     bram_1_B_input_sel(1) and     bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_2_A_input_sel(2) and     bram_2_A_input_sel(1) and     bram_2_A_input_sel(0)) or
	                                                                             ( not bram_2_B_input_sel(2) and     bram_2_B_input_sel(1) and     bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_3_A_input_sel(2) and     bram_3_A_input_sel(1) and     bram_3_A_input_sel(0)) or
	                                                                             ( not bram_3_B_input_sel(2) and     bram_3_B_input_sel(1) and     bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k3_needs_attention) );

	k4_being_served <= to_bit(REQ_4) and (
	                       ( not k4_output_sel(1) and not k4_output_sel(0) and ( (     bram_0_A_input_sel(2) and not bram_0_A_input_sel(1) and not bram_0_A_input_sel(0)) or
	                                                                             (     bram_0_B_input_sel(2) and not bram_0_B_input_sel(1) and not bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k4_output_sel(1) and     k4_output_sel(0) and ( (     bram_1_A_input_sel(2) and not bram_1_A_input_sel(1) and not bram_1_A_input_sel(0)) or
	                                                                             (     bram_1_B_input_sel(2) and not bram_1_B_input_sel(1) and not bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(1) and not k4_output_sel(0) and ( (     bram_2_A_input_sel(2) and not bram_2_A_input_sel(1) and not bram_2_A_input_sel(0)) or
	                                                                             (     bram_2_B_input_sel(2) and not bram_2_B_input_sel(1) and not bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(1) and     k4_output_sel(0) and ( (     bram_3_A_input_sel(2) and not bram_3_A_input_sel(1) and not bram_3_A_input_sel(0)) or
	                                                                             (     bram_3_B_input_sel(2) and not bram_3_B_input_sel(1) and not bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k4_needs_attention) );

	k5_being_served <= to_bit(REQ_5) and (
	                       ( not k5_output_sel(1) and not k5_output_sel(0) and ( (     bram_0_A_input_sel(2) and not bram_0_A_input_sel(1) and     bram_0_A_input_sel(0)) or
	                                                                             (     bram_0_B_input_sel(2) and not bram_0_B_input_sel(1) and     bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k5_output_sel(1) and     k5_output_sel(0) and ( (     bram_1_A_input_sel(2) and not bram_1_A_input_sel(1) and     bram_1_A_input_sel(0)) or
	                                                                             (     bram_1_B_input_sel(2) and not bram_1_B_input_sel(1) and     bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(1) and not k5_output_sel(0) and ( (     bram_2_A_input_sel(2) and not bram_2_A_input_sel(1) and     bram_2_A_input_sel(0)) or
	                                                                             (     bram_2_B_input_sel(2) and not bram_2_B_input_sel(1) and     bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(1) and     k5_output_sel(0) and ( (     bram_3_A_input_sel(2) and not bram_3_A_input_sel(1) and     bram_3_A_input_sel(0)) or
	                                                                             (     bram_3_B_input_sel(2) and not bram_3_B_input_sel(1) and     bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k5_needs_attention) );

	k6_being_served <= to_bit(REQ_6) and (
	                       ( not k6_output_sel(1) and not k6_output_sel(0) and ( (     bram_0_A_input_sel(2) and     bram_0_A_input_sel(1) and not bram_0_A_input_sel(0)) or
	                                                                             (     bram_0_B_input_sel(2) and     bram_0_B_input_sel(1) and not bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k6_output_sel(1) and     k6_output_sel(0) and ( (     bram_1_A_input_sel(2) and     bram_1_A_input_sel(1) and not bram_1_A_input_sel(0)) or
	                                                                             (     bram_1_B_input_sel(2) and     bram_1_B_input_sel(1) and not bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(1) and not k6_output_sel(0) and ( (     bram_2_A_input_sel(2) and     bram_2_A_input_sel(1) and not bram_2_A_input_sel(0)) or
	                                                                             (     bram_2_B_input_sel(2) and     bram_2_B_input_sel(1) and not bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(1) and     k6_output_sel(0) and ( (     bram_3_A_input_sel(2) and     bram_3_A_input_sel(1) and not bram_3_A_input_sel(0)) or
	                                                                             (     bram_3_B_input_sel(2) and     bram_3_B_input_sel(1) and not bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k6_needs_attention) );

	k7_being_served <= to_bit(REQ_7) and (
	                       ( not k7_output_sel(1) and not k7_output_sel(0) and ( (     bram_0_A_input_sel(2) and     bram_0_A_input_sel(1) and     bram_0_A_input_sel(0)) or
	                                                                             (     bram_0_B_input_sel(2) and     bram_0_B_input_sel(1) and     bram_0_B_input_sel(0)) ) )
	                       or
	                       ( not k7_output_sel(1) and     k7_output_sel(0) and ( (     bram_1_A_input_sel(2) and     bram_1_A_input_sel(1) and     bram_1_A_input_sel(0)) or
	                                                                             (     bram_1_B_input_sel(2) and     bram_1_B_input_sel(1) and     bram_1_B_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(1) and not k7_output_sel(0) and ( (     bram_2_A_input_sel(2) and     bram_2_A_input_sel(1) and     bram_2_A_input_sel(0)) or
	                                                                             (     bram_2_B_input_sel(2) and     bram_2_B_input_sel(1) and     bram_2_B_input_sel(0)) ) )
	                       or
	                       (     k7_output_sel(1) and     k7_output_sel(0) and ( (     bram_3_A_input_sel(2) and     bram_3_A_input_sel(1) and     bram_3_A_input_sel(0)) or
	                                                                             (     bram_3_B_input_sel(2) and     bram_3_B_input_sel(1) and     bram_3_B_input_sel(0)) ) )
	                       or
	                       (not k7_needs_attention) );


	--
	-- The higher bits of the output selection signal represent the BRAM
	-- which may be being used and, therefore, are the higher input port
	-- address bits.
	--
	k0_output_sel(2 downto 1) <= to_bitvector(ADDR_0(10 downto 9));
	k1_output_sel(2 downto 1) <= to_bitvector(ADDR_1(10 downto 9));
	k2_output_sel(2 downto 1) <= to_bitvector(ADDR_2(10 downto 9));
	k3_output_sel(2 downto 1) <= to_bitvector(ADDR_3(10 downto 9));
	k4_output_sel(2 downto 1) <= to_bitvector(ADDR_4(10 downto 9));
	k5_output_sel(2 downto 1) <= to_bitvector(ADDR_5(10 downto 9));
	k6_output_sel(2 downto 1) <= to_bitvector(ADDR_6(10 downto 9));
	k7_output_sel(2 downto 1) <= to_bitvector(ADDR_7(10 downto 9));


	k0_output_sel(0) <= ( not k0_output_sel(2) and not k0_output_sel(1) and ( not bram_0_B_input_sel(2) and
	                                                                          not bram_0_B_input_sel(1) and
	                                                                          not bram_0_B_input_sel(0)) )
	                    or
	                    ( not k0_output_sel(2) and     k0_output_sel(1) and ( not bram_1_B_input_sel(2) and
	                                                                          not bram_1_B_input_sel(1) and
	                                                                          not bram_1_B_input_sel(0)) )
	                    or
	                    (     k0_output_sel(2) and not k0_output_sel(1) and ( not bram_2_B_input_sel(2) and
	                                                                          not bram_2_B_input_sel(1) and
	                                                                          not bram_2_B_input_sel(0)) )
	                    or
	                    (     k0_output_sel(2) and     k0_output_sel(1) and ( not bram_3_B_input_sel(2) and
	                                                                          not bram_3_B_input_sel(1) and
	                                                                          not bram_3_B_input_sel(0)) );

	k1_output_sel(0) <= ( not k1_output_sel(2) and not k1_output_sel(1) and ( not bram_0_B_input_sel(2) and
	                                                                          not bram_0_B_input_sel(1) and
	                                                                              bram_0_B_input_sel(0)) )
	                    or
	                    ( not k1_output_sel(2) and     k1_output_sel(1) and ( not bram_1_B_input_sel(2) and
	                                                                          not bram_1_B_input_sel(1) and
	                                                                              bram_1_B_input_sel(0)) )
	                    or
	                    (     k1_output_sel(2) and not k1_output_sel(1) and ( not bram_2_B_input_sel(2) and
	                                                                          not bram_2_B_input_sel(1) and
	                                                                              bram_2_B_input_sel(0)) )
	                    or
	                    (     k1_output_sel(2) and     k1_output_sel(1) and ( not bram_3_B_input_sel(2) and
	                                                                          not bram_3_B_input_sel(1) and
	                                                                              bram_3_B_input_sel(0)) );

	k2_output_sel(0) <= ( not k2_output_sel(2) and not k2_output_sel(1) and ( not bram_0_B_input_sel(2) and
	                                                                              bram_0_B_input_sel(1) and
	                                                                          not bram_0_B_input_sel(0)) )
	                    or
	                    ( not k2_output_sel(2) and     k2_output_sel(1) and ( not bram_1_B_input_sel(2) and
	                                                                              bram_1_B_input_sel(1) and
	                                                                          not bram_1_B_input_sel(0)) )
	                    or
	                    (     k2_output_sel(2) and not k2_output_sel(1) and ( not bram_2_B_input_sel(2) and
	                                                                              bram_2_B_input_sel(1) and
	                                                                          not bram_2_B_input_sel(0)) )
	                    or
	                    (     k2_output_sel(2) and     k2_output_sel(1) and ( not bram_3_B_input_sel(2) and
	                                                                              bram_3_B_input_sel(1) and
	                                                                          not bram_3_B_input_sel(0)) );

	k3_output_sel(0) <= ( not k3_output_sel(2) and not k3_output_sel(1) and ( not bram_0_B_input_sel(2) and
	                                                                              bram_0_B_input_sel(1) and
	                                                                              bram_0_B_input_sel(0)) )
	                    or
	                    ( not k3_output_sel(2) and     k3_output_sel(1) and ( not bram_1_B_input_sel(2) and
	                                                                              bram_1_B_input_sel(1) and
	                                                                              bram_1_B_input_sel(0)) )
	                    or
	                    (     k3_output_sel(2) and not k3_output_sel(1) and ( not bram_2_B_input_sel(2) and
	                                                                              bram_2_B_input_sel(1) and
	                                                                              bram_2_B_input_sel(0)) )
	                    or
	                    (     k3_output_sel(2) and     k3_output_sel(1) and ( not bram_3_B_input_sel(2) and
	                                                                              bram_3_B_input_sel(1) and
	                                                                              bram_3_B_input_sel(0)) );

	k4_output_sel(0) <= ( not k4_output_sel(2) and not k4_output_sel(1) and (     bram_0_B_input_sel(2) and
	                                                                          not bram_0_B_input_sel(1) and
	                                                                          not bram_0_B_input_sel(0)) )
	                    or
	                    ( not k4_output_sel(2) and     k4_output_sel(1) and (     bram_1_B_input_sel(2) and
	                                                                          not bram_1_B_input_sel(1) and
	                                                                          not bram_1_B_input_sel(0)) )
	                    or
	                    (     k4_output_sel(2) and not k4_output_sel(1) and (     bram_2_B_input_sel(2) and
	                                                                          not bram_2_B_input_sel(1) and
	                                                                          not bram_2_B_input_sel(0)) )
	                    or
	                    (     k4_output_sel(2) and     k4_output_sel(1) and (     bram_3_B_input_sel(2) and
	                                                                          not bram_3_B_input_sel(1) and
	                                                                          not bram_3_B_input_sel(0)) );

	k5_output_sel(0) <= ( not k5_output_sel(2) and not k5_output_sel(1) and (     bram_0_B_input_sel(2) and
	                                                                          not bram_0_B_input_sel(1) and
	                                                                              bram_0_B_input_sel(0)) )
	                    or
	                    ( not k5_output_sel(2) and     k5_output_sel(1) and (     bram_1_B_input_sel(2) and
	                                                                          not bram_1_B_input_sel(1) and
	                                                                              bram_1_B_input_sel(0)) )
	                    or
	                    (     k5_output_sel(2) and not k5_output_sel(1) and (     bram_2_B_input_sel(2) and
	                                                                          not bram_2_B_input_sel(1) and
	                                                                              bram_2_B_input_sel(0)) )
	                    or
	                    (     k5_output_sel(2) and     k5_output_sel(1) and (     bram_3_B_input_sel(2) and
	                                                                          not bram_3_B_input_sel(1) and
	                                                                              bram_3_B_input_sel(0)) );

	k6_output_sel(0) <= ( not k6_output_sel(2) and not k6_output_sel(1) and (     bram_0_B_input_sel(2) and
	                                                                              bram_0_B_input_sel(1) and
	                                                                          not bram_0_B_input_sel(0)) )
	                    or
	                    ( not k6_output_sel(2) and     k6_output_sel(1) and (     bram_1_B_input_sel(2) and
	                                                                              bram_1_B_input_sel(1) and
	                                                                          not bram_1_B_input_sel(0)) )
	                    or
	                    (     k6_output_sel(2) and not k6_output_sel(1) and (     bram_2_B_input_sel(2) and
	                                                                              bram_2_B_input_sel(1) and
	                                                                          not bram_2_B_input_sel(0)) )
	                    or
	                    (     k6_output_sel(2) and     k6_output_sel(1) and (     bram_3_B_input_sel(2) and
	                                                                              bram_3_B_input_sel(1) and
	                                                                          not bram_3_B_input_sel(0)) );

	k7_output_sel(0) <= ( not k7_output_sel(2) and not k7_output_sel(1) and (     bram_0_B_input_sel(2) and
	                                                                              bram_0_B_input_sel(1) and
	                                                                              bram_0_B_input_sel(0)) )
	                    or
	                    ( not k7_output_sel(2) and     k7_output_sel(1) and (     bram_1_B_input_sel(2) and
	                                                                              bram_1_B_input_sel(1) and
	                                                                              bram_1_B_input_sel(0)) )
	                    or
	                    (     k7_output_sel(2) and not k7_output_sel(1) and (     bram_2_B_input_sel(2) and
	                                                                              bram_2_B_input_sel(1) and
	                                                                              bram_2_B_input_sel(0)) )
	                    or
	                    (     k7_output_sel(2) and     k7_output_sel(1) and (     bram_3_B_input_sel(2) and
	                                                                              bram_3_B_input_sel(1) and
	                                                                              bram_3_B_input_sel(0)) );


	--
	-- A process implementation alternative for the output controller
	-- which could be used to update output signals only on BRAM_CLK
	-- events or TRIG_CLK events:
	--
	-- TODO: decide whether using a process implementation could be better.
	--
	--k0_output_sel_controller : process (BRAM_CLK) begin
		--if (BRAM_CLK'event and BRAM_CLK = '0') then
			--if (ADDR_0(9 downto 9) = "0") then
				--k0_output_sel(1 downto 1) <= "0";
				--if (bram_0_B_input_sel = "00") then
					--k0_output_sel(0) <= '1';
				--else
					--k0_output_sel(0) <= '0';
				--end if;
			--else
				--k0_output_sel(1 downto 1) <= "1";
				--if (bram_1_B_input_sel = "00") then
					--k0_output_sel(0) <= '1';
				--else
					--k0_output_sel(0) <= '0';
				--end if;
			--end if;
		--end if;
	--end process k0_output_sel_controller;


	input_controller_0 : block begin
		with bram_0_A_input_sel select
			di_0_a    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_0_A_input_sel select
			addr_0_a  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_0_A_input_sel select
			we_0_a    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_0;

	input_controller_1 : block begin
		with bram_0_B_input_sel select
			di_0_b    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_0_B_input_sel select
			addr_0_b  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_0_B_input_sel select
			we_0_b    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_1;

	input_controller_2 : block begin
		with bram_1_A_input_sel select
			di_1_a    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_1_A_input_sel select
			addr_1_a  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_1_A_input_sel select
			we_1_a    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_2;

	input_controller_3 : block begin
		with bram_1_B_input_sel select
			di_1_b    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_1_B_input_sel select
			addr_1_b  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_1_B_input_sel select
			we_1_b    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_3;

	input_controller_4 : block begin
		with bram_2_A_input_sel select
			di_2_a    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_2_A_input_sel select
			addr_2_a  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_2_A_input_sel select
			we_2_a    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_4;

	input_controller_5 : block begin
		with bram_2_B_input_sel select
			di_2_b    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_2_B_input_sel select
			addr_2_b  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_2_B_input_sel select
			we_2_b    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_5;

	input_controller_6 : block begin
		with bram_3_A_input_sel select
			di_3_a    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_3_A_input_sel select
			addr_3_a  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_3_A_input_sel select
			we_3_a    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_6;

	input_controller_7 : block begin
		with bram_3_B_input_sel select
			di_3_b    <=  DI_0 when "000",
			              DI_1 when "001",
			              DI_2 when "010",
			              DI_3 when "011",
			              DI_4 when "100",
			              DI_5 when "101",
			              DI_6 when "110",
			              DI_7 when "111";
		with bram_3_B_input_sel select
			addr_3_b  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_3_B_input_sel select
			we_3_b    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_7;


	output_controller_0 : block begin
		with k0_output_sel select
			DO_0 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO_1 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO_2 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO_3 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_3;

	output_controller_4 : block begin
		with k0_output_sel select
			DO_0 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_4;

	output_controller_5 : block begin
		with k1_output_sel select
			DO_1 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_5;

	output_controller_6 : block begin
		with k2_output_sel select
			DO_2 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_6;

	output_controller_7 : block begin
		with k3_output_sel select
			DO_3 <= do_0_a when "000",
			        do_0_b when "001",
			        do_1_a when "010",
			        do_1_b when "011",
			        do_2_a when "100",
			        do_2_b when "101",
			        do_3_a when "110",
			        do_3_b when "111";
	end block output_controller_7;


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


	RAMB16BWER_2 : RAMB16BWER

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

		DOA                  => do_2_a,              -- Output port-A data
		DOB                  => do_2_b,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => di_2_a,              -- Input port-A data
		DIB                  => di_2_b,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => addr_2_a,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => addr_2_b,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => en_2_a,              -- Input port-A enable
		ENB                  => en_2_b,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => we_2_a,              -- Input port-A write enable
		WEB                  => we_2_b               -- Input port-B write enable

	);


	RAMB16BWER_3 : RAMB16BWER

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

		DOA                  => do_3_a,              -- Output port-A data
		DOB                  => do_3_b,              -- Output port-B data
		DOPA                 => open,                -- We are not using parity bits
		DOPB                 => open,                -- We are not using parity bits
		DIA                  => di_3_a,              -- Input port-A data
		DIB                  => di_3_b,              -- Input port-B data
		DIPA                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		DIPB                 => DIP_value,           -- Input parity bits always set to 0 (not using them)
		ADDRA(13 downto 5)   => addr_3_a,            -- Input port-A address
		ADDRA(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		ADDRB(13 downto 5)   => addr_3_b,            -- Input port-B address
		ADDRB(4 downto 0)    => LOWADDR_value,       -- Set low adress bits to 0
		CLKA                 => BRAM_CLK,            -- Input port-A clock
		CLKB                 => BRAM_CLK,            -- Input port-B clock
		ENA                  => en_3_a,              -- Input port-A enable
		ENB                  => en_3_b,              -- Input port-B enable
		REGCEA               => REGCE_value,         -- Input port-A output register enable
		REGCEB               => REGCE_value,         -- Input port-B output register enable
		RSTA                 => RST,                 -- Input port-A reset
		RSTB                 => RST,                 -- Input port-B reset
		WEA                  => we_3_a,              -- Input port-A write enable
		WEB                  => we_3_b               -- Input port-B write enable

	);


end smem_arch;
