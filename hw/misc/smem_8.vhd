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

		N_PORTS         : integer := 8;
		N_BRAMS         : integer := 4;
		LOG2_N_PORTS    : integer := 3  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code

	);

	port (

		DO                     : out std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data output ports
		DI                     : in  std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data input ports
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

	signal bram_0_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_1_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_2_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_3_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_4_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_5_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_6_input_sel    : bit_vector(2 downto 0) := "000";
	signal bram_7_input_sel    : bit_vector(2 downto 0) := "000";

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

	k7_needs_bram_0 <= k7_needs_attention and not to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_1 <= k7_needs_attention and not to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));
	k7_needs_bram_2 <= k7_needs_attention and     to_bit(ADDR_7(10)) and not to_bit(ADDR_7(9));
	k7_needs_bram_3 <= k7_needs_attention and     to_bit(ADDR_7(10)) and     to_bit(ADDR_7(9));


	bram_0_input_sel(2) <= not ((k0_needs_bram_0 or k1_needs_bram_0 or k2_needs_bram_0 or k3_needs_bram_0));
	bram_2_input_sel(2) <= not ((k0_needs_bram_1 or k1_needs_bram_1 or k2_needs_bram_1 or k3_needs_bram_1));
	bram_4_input_sel(2) <= not ((k0_needs_bram_2 or k1_needs_bram_2 or k2_needs_bram_2 or k3_needs_bram_2));
	bram_6_input_sel(2) <= not ((k0_needs_bram_3 or k1_needs_bram_3 or k2_needs_bram_3 or k3_needs_bram_3));

	bram_0_input_sel(1) <= not ((k0_needs_bram_0 or k1_needs_bram_0) or ((k4_needs_bram_0 or k5_needs_bram_0) and (not k3_needs_bram_0) and (not k2_needs_bram_0)));
	bram_2_input_sel(1) <= not ((k0_needs_bram_1 or k1_needs_bram_1) or ((k4_needs_bram_1 or k5_needs_bram_1) and (not k3_needs_bram_1) and (not k2_needs_bram_1)));
	bram_4_input_sel(1) <= not ((k0_needs_bram_2 or k1_needs_bram_2) or ((k4_needs_bram_2 or k5_needs_bram_2) and (not k3_needs_bram_2) and (not k2_needs_bram_2)));
	bram_6_input_sel(1) <= not ((k0_needs_bram_3 or k1_needs_bram_3) or ((k4_needs_bram_3 or k5_needs_bram_3) and (not k3_needs_bram_3) and (not k2_needs_bram_3)));

	bram_0_input_sel(0) <= not ((k0_needs_bram_0) or ((k2_needs_bram_0) and (not k1_needs_bram_0)) or ((k4_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0)) or ((k6_needs_bram_0) and (not k1_needs_bram_0) and (not k3_needs_bram_0) and (not k5_needs_bram_0)));
	bram_2_input_sel(0) <= not ((k0_needs_bram_1) or ((k2_needs_bram_1) and (not k1_needs_bram_1)) or ((k4_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1)) or ((k6_needs_bram_1) and (not k1_needs_bram_1) and (not k3_needs_bram_1) and (not k5_needs_bram_1)));
	bram_4_input_sel(0) <= not ((k0_needs_bram_2) or ((k2_needs_bram_2) and (not k1_needs_bram_2)) or ((k4_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2)) or ((k6_needs_bram_2) and (not k1_needs_bram_2) and (not k3_needs_bram_2) and (not k5_needs_bram_2)));
	bram_6_input_sel(0) <= not ((k0_needs_bram_3) or ((k2_needs_bram_3) and (not k1_needs_bram_3)) or ((k4_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3)) or ((k6_needs_bram_3) and (not k1_needs_bram_3) and (not k3_needs_bram_3) and (not k5_needs_bram_3)));


	bram_1_input_sel(2) <= (k7_needs_bram_0 or k6_needs_bram_0 or k5_needs_bram_0 or k4_needs_bram_0);
	bram_3_input_sel(2) <= (k7_needs_bram_1 or k6_needs_bram_1 or k5_needs_bram_1 or k4_needs_bram_1);
	bram_5_input_sel(2) <= (k7_needs_bram_2 or k6_needs_bram_2 or k5_needs_bram_2 or k4_needs_bram_2);
	bram_7_input_sel(2) <= (k7_needs_bram_3 or k6_needs_bram_3 or k5_needs_bram_3 or k4_needs_bram_3);

	bram_1_input_sel(1) <= (k7_needs_bram_0 or k6_needs_bram_0) or ((k3_needs_bram_0 or k2_needs_bram_0) and (not k4_needs_bram_0) and (not k5_needs_bram_0));
	bram_3_input_sel(1) <= (k7_needs_bram_1 or k6_needs_bram_1) or ((k3_needs_bram_1 or k2_needs_bram_1) and (not k4_needs_bram_1) and (not k5_needs_bram_1));
	bram_5_input_sel(1) <= (k7_needs_bram_2 or k6_needs_bram_2) or ((k3_needs_bram_2 or k2_needs_bram_2) and (not k4_needs_bram_2) and (not k5_needs_bram_2));
	bram_7_input_sel(1) <= (k7_needs_bram_3 or k6_needs_bram_3) or ((k3_needs_bram_3 or k2_needs_bram_3) and (not k4_needs_bram_3) and (not k5_needs_bram_3));

	bram_1_input_sel(0) <= (k7_needs_bram_0) or ((k5_needs_bram_0) and (not k6_needs_bram_0)) or ((k3_needs_bram_0) and (not k6_needs_bram_0) and (not k4_needs_bram_0)) or ((k1_needs_bram_0) and (not k6_needs_bram_0) and (not k4_needs_bram_0) and (not k2_needs_bram_0));
	bram_3_input_sel(0) <= (k7_needs_bram_1) or ((k5_needs_bram_1) and (not k6_needs_bram_1)) or ((k3_needs_bram_1) and (not k6_needs_bram_1) and (not k4_needs_bram_1)) or ((k1_needs_bram_1) and (not k6_needs_bram_1) and (not k4_needs_bram_1) and (not k2_needs_bram_1));
	bram_5_input_sel(0) <= (k7_needs_bram_2) or ((k5_needs_bram_2) and (not k6_needs_bram_2)) or ((k3_needs_bram_2) and (not k6_needs_bram_2) and (not k4_needs_bram_2)) or ((k1_needs_bram_2) and (not k6_needs_bram_2) and (not k4_needs_bram_2) and (not k2_needs_bram_2));
	bram_7_input_sel(0) <= (k7_needs_bram_3) or ((k5_needs_bram_3) and (not k6_needs_bram_3)) or ((k3_needs_bram_3) and (not k6_needs_bram_3) and (not k4_needs_bram_3)) or ((k1_needs_bram_3) and (not k6_needs_bram_3) and (not k4_needs_bram_3) and (not k2_needs_bram_3));


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

	k1_being_served <= to_bit(REQ_1) and (
	                       ( not k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(1) and not k1_output_sel(0) and ( ( not bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(1) and     k1_output_sel(0) and ( ( not bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (not k1_needs_attention) );

	k2_being_served <= to_bit(REQ_2) and (
	                       ( not k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(1) and not k2_output_sel(0) and ( ( not bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(1) and     k2_output_sel(0) and ( ( not bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (not k2_needs_attention) );

	k3_being_served <= to_bit(REQ_3) and (
	                       ( not k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_0_input_sel(2) and     bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(2) and     bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_2_input_sel(2) and     bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(2) and     bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(1) and not k3_output_sel(0) and ( ( not bram_4_input_sel(2) and     bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             ( not bram_5_input_sel(2) and     bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       (     k3_output_sel(1) and     k3_output_sel(0) and ( ( not bram_6_input_sel(2) and     bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             ( not bram_7_input_sel(2) and     bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (not k3_needs_attention) );

	k4_being_served <= to_bit(REQ_4) and (
	                       ( not k4_output_sel(1) and not k4_output_sel(0) and ( (     bram_0_input_sel(2) and not bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(2) and not bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k4_output_sel(1) and     k4_output_sel(0) and ( (     bram_2_input_sel(2) and not bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(2) and not bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(1) and not k4_output_sel(0) and ( (     bram_4_input_sel(2) and not bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(2) and not bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       (     k4_output_sel(1) and     k4_output_sel(0) and ( (     bram_6_input_sel(2) and not bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(2) and not bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (not k4_needs_attention) );

	k5_being_served <= to_bit(REQ_5) and (
	                       ( not k5_output_sel(1) and not k5_output_sel(0) and ( (     bram_0_input_sel(2) and not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(2) and not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       ( not k5_output_sel(1) and     k5_output_sel(0) and ( (     bram_2_input_sel(2) and not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(2) and not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(1) and not k5_output_sel(0) and ( (     bram_4_input_sel(2) and not bram_4_input_sel(1) and     bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(2) and not bram_5_input_sel(1) and     bram_5_input_sel(0)) ) )
	                       or
	                       (     k5_output_sel(1) and     k5_output_sel(0) and ( (     bram_6_input_sel(2) and not bram_6_input_sel(1) and     bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(2) and not bram_7_input_sel(1) and     bram_7_input_sel(0)) ) )
	                       or
	                       (not k5_needs_attention) );

	k6_being_served <= to_bit(REQ_6) and (
	                       ( not k6_output_sel(1) and not k6_output_sel(0) and ( (     bram_0_input_sel(2) and     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(2) and     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       ( not k6_output_sel(1) and     k6_output_sel(0) and ( (     bram_2_input_sel(2) and     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(2) and     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(1) and not k6_output_sel(0) and ( (     bram_4_input_sel(2) and     bram_4_input_sel(1) and not bram_4_input_sel(0)) or
	                                                                             (     bram_5_input_sel(2) and     bram_5_input_sel(1) and not bram_5_input_sel(0)) ) )
	                       or
	                       (     k6_output_sel(1) and     k6_output_sel(0) and ( (     bram_6_input_sel(2) and     bram_6_input_sel(1) and not bram_6_input_sel(0)) or
	                                                                             (     bram_7_input_sel(2) and     bram_7_input_sel(1) and not bram_7_input_sel(0)) ) )
	                       or
	                       (not k6_needs_attention) );

	k7_being_served <= to_bit(REQ_7);


	k0_output_sel(2 downto 1) <= to_bitvector(ADDR_0(10 downto 9));
	k1_output_sel(2 downto 1) <= to_bitvector(ADDR_1(10 downto 9));
	k2_output_sel(2 downto 1) <= to_bitvector(ADDR_2(10 downto 9));
	k3_output_sel(2 downto 1) <= to_bitvector(ADDR_3(10 downto 9));
	k4_output_sel(2 downto 1) <= to_bitvector(ADDR_4(10 downto 9));
	k5_output_sel(2 downto 1) <= to_bitvector(ADDR_5(10 downto 9));
	k6_output_sel(2 downto 1) <= to_bitvector(ADDR_6(10 downto 9));
	k7_output_sel(2 downto 1) <= to_bitvector(ADDR_7(10 downto 9));


	k0_output_sel(0) <= ( not k0_output_sel(2) and not k0_output_sel(1) and ( not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k0_output_sel(2) and     k0_output_sel(1) and ( not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    (     k0_output_sel(2) and not k0_output_sel(1) and ( not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    (     k0_output_sel(2) and     k0_output_sel(1) and ( not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) );

	k1_output_sel(0) <= ( not k1_output_sel(2) and not k1_output_sel(1) and ( not bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k1_output_sel(2) and     k1_output_sel(1) and ( not bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    (     k1_output_sel(2) and not k1_output_sel(1) and ( not bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    (     k1_output_sel(2) and     k1_output_sel(1) and ( not bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) );

	k2_output_sel(0) <= ( not k2_output_sel(2) and not k2_output_sel(1) and ( not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k2_output_sel(2) and     k2_output_sel(1) and ( not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    (     k2_output_sel(2) and not k2_output_sel(1) and ( not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    (     k2_output_sel(2) and     k2_output_sel(1) and ( not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) );

	k3_output_sel(0) <= ( not k3_output_sel(2) and not k3_output_sel(1) and ( not bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k3_output_sel(2) and     k3_output_sel(1) and ( not bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    (     k3_output_sel(2) and not k3_output_sel(1) and ( not bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    (     k3_output_sel(2) and     k3_output_sel(1) and ( not bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) );

	k4_output_sel(0) <= ( not k4_output_sel(2) and not k4_output_sel(1) and (     bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k4_output_sel(2) and     k4_output_sel(1) and (     bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    (     k4_output_sel(2) and not k4_output_sel(1) and (     bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    (     k4_output_sel(2) and     k4_output_sel(1) and (     bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) );

	k5_output_sel(0) <= ( not k5_output_sel(2) and not k5_output_sel(1) and (     bram_1_input_sel(2) and
	                                                                          not bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k5_output_sel(2) and     k5_output_sel(1) and (     bram_3_input_sel(2) and
	                                                                          not bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    (     k5_output_sel(2) and not k5_output_sel(1) and (     bram_5_input_sel(2) and
	                                                                          not bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    (     k5_output_sel(2) and     k5_output_sel(1) and (     bram_7_input_sel(2) and
	                                                                          not bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) );

	k6_output_sel(0) <= ( not k6_output_sel(2) and not k6_output_sel(1) and (     bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                          not bram_1_input_sel(0)) )
	                    or
	                    ( not k6_output_sel(2) and     k6_output_sel(1) and (     bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                          not bram_3_input_sel(0)) )
	                    or
	                    (     k6_output_sel(2) and not k6_output_sel(1) and (     bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                          not bram_5_input_sel(0)) )
	                    or
	                    (     k6_output_sel(2) and     k6_output_sel(1) and (     bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                          not bram_7_input_sel(0)) );

	k7_output_sel(0) <= ( not k7_output_sel(2) and not k7_output_sel(1) and (     bram_1_input_sel(2) and
	                                                                              bram_1_input_sel(1) and
	                                                                              bram_1_input_sel(0)) )
	                    or
	                    ( not k7_output_sel(2) and     k7_output_sel(1) and (     bram_3_input_sel(2) and
	                                                                              bram_3_input_sel(1) and
	                                                                              bram_3_input_sel(0)) )
	                    or
	                    (     k7_output_sel(2) and not k7_output_sel(1) and (     bram_5_input_sel(2) and
	                                                                              bram_5_input_sel(1) and
	                                                                              bram_5_input_sel(0)) )
	                    or
	                    (     k7_output_sel(2) and     k7_output_sel(1) and (     bram_7_input_sel(2) and
	                                                                              bram_7_input_sel(1) and
	                                                                              bram_7_input_sel(0)) );


	input_controller_0 : block begin
		with bram_0_input_sel select
			bram_di(1 * 32 - 1 downto 0 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_0_input_sel select
			bram_addr(1 * 9 - 1 downto 0 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_0_input_sel select
			bram_we(1 * 4 - 1 downto 0 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_0;

	input_controller_1 : block begin
		with bram_1_input_sel select
			bram_di(2 * 32 - 1 downto 1 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_1_input_sel select
			bram_addr(2 * 9 - 1 downto 1 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_1_input_sel select
			bram_we(2 * 4 - 1 downto 1 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_1;

	input_controller_2 : block begin
		with bram_2_input_sel select
			bram_di(3 * 32 - 1 downto 2 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_2_input_sel select
			bram_addr(3 * 9 - 1 downto 2 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_2_input_sel select
			bram_we(3 * 4 - 1 downto 2 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_2;

	input_controller_3 : block begin
		with bram_3_input_sel select
			bram_di(4 * 32 - 1 downto 3 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_3_input_sel select
			bram_addr(4 * 9 - 1 downto 3 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_3_input_sel select
			bram_we(4 * 4 - 1 downto 3 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_3;

	input_controller_4 : block begin
		with bram_4_input_sel select
			bram_di(5 * 32 - 1 downto 4 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_4_input_sel select
			bram_addr(5 * 9 - 1 downto 4 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_4_input_sel select
			bram_we(5 * 4 - 1 downto 4 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_4;

	input_controller_5 : block begin
		with bram_5_input_sel select
			bram_di(6 * 32 - 1 downto 5 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_5_input_sel select
			bram_addr(6 * 9 - 1 downto 5 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_5_input_sel select
			bram_we(6 * 4 - 1 downto 5 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_5;

	input_controller_6 : block begin
		with bram_6_input_sel select
			bram_di(7 * 32 - 1 downto 6 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_6_input_sel select
			bram_addr(7 * 9 - 1 downto 6 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_6_input_sel select
			bram_we(7 * 4 - 1 downto 6 * 4)    <=  we_0_safe when "000",
			              we_1_safe when "001",
			              we_2_safe when "010",
			              we_3_safe when "011",
			              we_4_safe when "100",
			              we_5_safe when "101",
			              we_6_safe when "110",
			              we_7_safe when "111";
	end block input_controller_6;

	input_controller_7 : block begin
		with bram_7_input_sel select
			bram_di(8 * 32 - 1 downto 7 * 32)    <=  DI(32 * 1 - 1 downto 32 * 0) when "000",
			              DI(32 * 2 - 1 downto 32 * 1) when "001",
			              DI(32 * 3 - 1 downto 32 * 2) when "010",
			              DI(32 * 4 - 1 downto 32 * 3) when "011",
			              DI(32 * 5 - 1 downto 32 * 4) when "100",
			              DI(32 * 6 - 1 downto 32 * 5) when "101",
			              DI(32 * 7 - 1 downto 32 * 6) when "110",
			              DI(32 * 8 - 1 downto 32 * 7) when "111";
		with bram_7_input_sel select
			bram_addr(8 * 9 - 1 downto 7 * 9)  <=  ADDR_0(8 downto 0) when "000",
			              ADDR_1(8 downto 0) when "001",
			              ADDR_2(8 downto 0) when "010",
			              ADDR_3(8 downto 0) when "011",
			              ADDR_4(8 downto 0) when "100",
			              ADDR_5(8 downto 0) when "101",
			              ADDR_6(8 downto 0) when "110",
			              ADDR_7(8 downto 0) when "111";
		with bram_7_input_sel select
			bram_we(8 * 4 - 1 downto 7 * 4)    <=  we_0_safe when "000",
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
			DO(32 * 1 - 1 downto 32 * 0) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO(32 * 2 - 1 downto 32 * 1) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO(32 * 3 - 1 downto 32 * 2) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO(32 * 4 - 1 downto 32 * 3) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_3;

	output_controller_4 : block begin
		with k4_output_sel select
			DO(32 * 5 - 1 downto 32 * 4) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_4;

	output_controller_5 : block begin
		with k5_output_sel select
			DO(32 * 6 - 1 downto 32 * 5) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_5;

	output_controller_6 : block begin
		with k6_output_sel select
			DO(32 * 7 - 1 downto 32 * 6) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_6;

	output_controller_7 : block begin
		with k7_output_sel select
			DO(32 * 8 - 1 downto 32 * 7) <= bram_do(1 * 32 - 1 downto 0 * 32) when "000",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "001",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "010",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "011",
			        bram_do(5 * 32 - 1 downto 4 * 32) when "100",
			        bram_do(6 * 32 - 1 downto 5 * 32) when "101",
			        bram_do(7 * 32 - 1 downto 6 * 32) when "110",
			        bram_do(8 * 32 - 1 downto 7 * 32) when "111";
	end block output_controller_7;


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
