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
		BRAM_CLK                                            : in  std_logic;                        -- Clock and reset input ports
		REQ_0, REQ_1, REQ_2, REQ_3             : in  std_logic;                        -- Request input ports
		RDY_0, RDY_1, RDY_2, RDY_3             : out std_logic;                         -- Ready output port

		BRAM_DI_PORT        : out std_logic_vector(N_PORTS * 32 - 1 downto 0);
		BRAM_ADDR_PORT      : out std_logic_vector(N_PORTS * 9  - 1 downto 0);
		BRAM_WE_PORT        : out std_logic_vector(N_PORTS * 4  - 1 downto 0)
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

	signal k0_needs_attention  : bit := '0';
	signal k1_needs_attention  : bit := '0';
	signal k2_needs_attention  : bit := '0';
	signal k3_needs_attention  : bit := '0';

	signal addr_0_eq_addr_1    : bit := '0';
	signal addr_0_eq_addr_2    : bit := '0';
	signal addr_0_eq_addr_3    : bit := '0';
	signal addr_1_eq_addr_2    : bit := '0';
	signal addr_1_eq_addr_3    : bit := '0';
	signal addr_2_eq_addr_3    : bit := '0';

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

	signal DO_fake             : std_logic_vector(N_PORTS * 32 - 1 downto 0);
	signal bram_clk_signal     : std_logic;


begin


	bram_clk_signal <= BRAM_CLK;

	bram_en(0) <= '1';
	bram_en(1) <= '1';
	bram_en(2) <= '1';
	bram_en(3) <= '1';


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


	RDY_0 <= to_stdulogic(k0_being_served);
	RDY_1 <= to_stdulogic(k1_being_served);
	RDY_2 <= to_stdulogic(k2_being_served);
	RDY_3 <= to_stdulogic(k3_being_served);


	k0_needs_attention <= to_bit(REQ_0);

	k1_needs_attention <= to_bit(REQ_1) and (not (addr_0_eq_addr_1 and k0_needs_attention));

	k2_needs_attention <= to_bit(REQ_2) and (not (addr_0_eq_addr_2 and k0_needs_attention)) and (not (addr_1_eq_addr_2 and k1_needs_attention));

	k3_needs_attention <= to_bit(REQ_3) and (not (addr_0_eq_addr_3 and k0_needs_attention)) and (not (addr_1_eq_addr_3 and k1_needs_attention)) and (not (addr_2_eq_addr_3 and k2_needs_attention));


	k0_needs_bram_0 <= k0_needs_attention and not to_bit(ADDR_0(9));
	k0_needs_bram_1 <= k0_needs_attention and     to_bit(ADDR_0(9));

	k1_needs_bram_0 <= k1_needs_attention and not to_bit(ADDR_1(9));
	k1_needs_bram_1 <= k1_needs_attention and     to_bit(ADDR_1(9));

	k2_needs_bram_0 <= k2_needs_attention and not to_bit(ADDR_2(9));
	k2_needs_bram_1 <= k2_needs_attention and     to_bit(ADDR_2(9));

	k3_needs_bram_0 <= k3_needs_attention and not to_bit(ADDR_3(9));
	k3_needs_bram_1 <= k3_needs_attention and     to_bit(ADDR_3(9));


	bram_0_input_sel(1) <= not ((k0_needs_bram_0 or k1_needs_bram_0));
	bram_2_input_sel(1) <= not ((k0_needs_bram_1 or k1_needs_bram_1));

	bram_0_input_sel(0) <= not ((k0_needs_bram_0) or ((k2_needs_bram_0) and (not k1_needs_bram_0)));
	bram_2_input_sel(0) <= not ((k0_needs_bram_1) or ((k2_needs_bram_1) and (not k1_needs_bram_1)));


	bram_1_input_sel(1) <= (k3_needs_bram_0 or k2_needs_bram_0);
	bram_3_input_sel(1) <= (k3_needs_bram_1 or k2_needs_bram_1);

	bram_1_input_sel(0) <= (k3_needs_bram_0) or ((k1_needs_bram_0) and (not k2_needs_bram_0));
	bram_3_input_sel(0) <= (k3_needs_bram_1) or ((k1_needs_bram_1) and (not k2_needs_bram_1));


	addr_0_eq_addr_1 <= ( (to_bit(ADDR_0(9)) xnor to_bit(ADDR_1(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_1(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_1(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_1(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_1(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_1(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_1(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_1(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_1(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_1(0))) );

	addr_0_eq_addr_2 <= ( (to_bit(ADDR_0(9)) xnor to_bit(ADDR_2(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_2(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_2(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_2(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_2(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_2(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_2(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_2(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_2(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_2(0))) );

	addr_0_eq_addr_3 <= ( (to_bit(ADDR_0(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_0(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_0(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_0(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_0(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_0(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_0(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_0(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_0(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_0(0)) xnor to_bit(ADDR_3(0))) );

	addr_1_eq_addr_2 <= ( (to_bit(ADDR_1(9)) xnor to_bit(ADDR_2(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_2(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_2(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_2(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_2(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_2(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_2(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_2(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_2(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_2(0))) );

	addr_1_eq_addr_3 <= ( (to_bit(ADDR_1(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_1(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_1(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_1(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_1(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_1(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_1(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_1(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_1(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_1(0)) xnor to_bit(ADDR_3(0))) );

	addr_2_eq_addr_3 <= ( (to_bit(ADDR_2(9)) xnor to_bit(ADDR_3(9))) and
	                      (to_bit(ADDR_2(8)) xnor to_bit(ADDR_3(8))) and
	                      (to_bit(ADDR_2(7)) xnor to_bit(ADDR_3(7))) and
	                      (to_bit(ADDR_2(6)) xnor to_bit(ADDR_3(6))) and
	                      (to_bit(ADDR_2(5)) xnor to_bit(ADDR_3(5))) and
	                      (to_bit(ADDR_2(4)) xnor to_bit(ADDR_3(4))) and
	                      (to_bit(ADDR_2(3)) xnor to_bit(ADDR_3(3))) and
	                      (to_bit(ADDR_2(2)) xnor to_bit(ADDR_3(2))) and
	                      (to_bit(ADDR_2(1)) xnor to_bit(ADDR_3(1))) and
	                      (to_bit(ADDR_2(0)) xnor to_bit(ADDR_3(0))) );


	k0_being_served <= to_bit(REQ_0);

	k1_being_served <= to_bit(REQ_1) and (
	                       ( not k1_output_sel(0) and ( ( not bram_0_input_sel(1) and     bram_0_input_sel(0)) or
	                                                                             ( not bram_1_input_sel(1) and     bram_1_input_sel(0)) ) )
	                       or
	                       (     k1_output_sel(0) and ( ( not bram_2_input_sel(1) and     bram_2_input_sel(0)) or
	                                                                             ( not bram_3_input_sel(1) and     bram_3_input_sel(0)) ) )
	                       or
	                       (not k1_needs_attention) );

	k2_being_served <= to_bit(REQ_2) and (
	                       ( not k2_output_sel(0) and ( (     bram_0_input_sel(1) and not bram_0_input_sel(0)) or
	                                                                             (     bram_1_input_sel(1) and not bram_1_input_sel(0)) ) )
	                       or
	                       (     k2_output_sel(0) and ( (     bram_2_input_sel(1) and not bram_2_input_sel(0)) or
	                                                                             (     bram_3_input_sel(1) and not bram_3_input_sel(0)) ) )
	                       or
	                       (not k2_needs_attention) );

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
			DO_fake(32 * 1 - 1 downto 32 * 0) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_0;

	output_controller_1 : block begin
		with k1_output_sel select
			DO_fake(32 * 2 - 1 downto 32 * 1) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_1;

	output_controller_2 : block begin
		with k2_output_sel select
			DO_fake(32 * 3 - 1 downto 32 * 2) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_2;

	output_controller_3 : block begin
		with k3_output_sel select
			DO_fake(32 * 4 - 1 downto 32 * 3) <= bram_do(1 * 32 - 1 downto 0 * 32) when "00",
			        bram_do(2 * 32 - 1 downto 1 * 32) when "01",
			        bram_do(3 * 32 - 1 downto 2 * 32) when "10",
			        bram_do(4 * 32 - 1 downto 3 * 32) when "11";
	end block output_controller_3;


	bram_output_process : process (bram_clk_signal) begin
		if (bram_clk_signal'event and bram_clk_signal = '1') then
			DO <= DO_fake;
		end if;
	end process;

	bram_input_process : process (bram_clk_signal) begin
		if (bram_clk_signal'event and bram_clk_signal = '1') then
			bram_do         <= DI;
			BRAM_DI_PORT    <= bram_di;
			BRAM_ADDR_PORT  <= bram_addr;
			BRAM_WE_PORT    <= bram_we;
		end if;
	end process;


end smem_arch;
