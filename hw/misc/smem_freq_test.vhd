--
-- smem_freq_test.vhd
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



entity smem_freq_test is

	generic (

		N_PORTS           : integer := 2;
		N_BRAMS           : integer := 1;
		LOG2_N_PORTS      : integer := 1  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code

	);

	port (

		DO                : out std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data output ports
		DI                : in  std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data input ports
		ADDR              : in  std_logic_vector(9 * N_PORTS - 1 downto 0);    -- Address input ports
		WE                : in  std_logic_vector(4 * N_PORTS - 1 downto 0);    -- Byte write enable input ports
		REQ               : in  std_logic_vector(N_PORTS - 1 downto 0);        -- Request input ports
		RDY               : out std_logic_vector(N_PORTS - 1 downto 0);        -- Ready output port
		BRAM_CLK          : in  std_logic;                                     -- Clock input port
		TRIG_CLK          : in  std_logic;                                     -- Clock input port
		RST               : in  std_logic                                      -- Reset input port

	);

end smem_freq_test;



architecture smem_freq_test_arch of smem_freq_test is


	signal DO_smem        : std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data output ports
	signal DI_smem        : std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data input ports
	signal ADDR_smem      : std_logic_vector(9 * N_PORTS - 1 downto 0);    -- Address input ports
	signal WE_smem        : std_logic_vector(4 * N_PORTS - 1 downto 0);    -- Byte write enable input ports
	signal REQ_smem       : std_logic_vector(N_PORTS - 1 downto 0);        -- Request input ports
	signal RDY_smem       : std_logic_vector(N_PORTS - 1 downto 0);        -- Ready output port

	component smem

		port (

			DO                : out std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data output ports
			DI                : in  std_logic_vector(32 * N_PORTS - 1 downto 0);   -- Data input ports
			ADDR_0            : in  std_logic_vector(8 downto 0);                  -- Address input ports
			ADDR_1            : in  std_logic_vector(8 downto 0);                  -- Address input ports
			WE_0              : in  std_logic_vector(3 downto 0);                  -- Byte write enable input ports
			WE_1              : in  std_logic_vector(3 downto 0);                  -- Byte write enable input ports
			REQ_0             : in  std_logic;                                     -- Request input ports
			REQ_1             : in  std_logic;                                     -- Request input ports
			RDY_0             : out std_logic;                                     -- Ready output port
			RDY_1             : out std_logic;                                     -- Ready output port
			BRAM_CLK          : in  std_logic;                                     -- Clock and reset input ports
			TRIG_CLK          : in  std_logic;                                     -- Clock input port
			RST               : in  std_logic                                      -- Reset input port

		);

	end component;


begin


	smem_inst : smem port map (

		DO        => DO_smem,
		DI        => DI_smem,

		ADDR_0    => ADDR_smem(9 * 1 - 1 downto 9 * 0),
		ADDR_1    => ADDR_smem(9 * 2 - 1 downto 9 * 1),

		WE_0      => WE_smem(4 * 1 - 1 downto 4 * 0),
		WE_1      => WE_smem(4 * 2 - 1 downto 4 * 1),

		REQ_0     => REQ_smem(0),
		REQ_1     => REQ_smem(1),

		RDY_0     => RDY_smem(0),
		RDY_1     => RDY_smem(1),

		BRAM_CLK  => BRAM_CLK,
		TRIG_CLK  => TRIG_CLK,
		RST       => RST

	);


	clock_rise : process (BRAM_CLK) is begin
		if (BRAM_CLK'event and BRAM_CLK='1') then
			DO <= DO_smem;
			DI_smem <= DI;
			ADDR_smem <= ADDR;
			WE_smem <= WE;
			REQ_smem <= REQ;
			RDY <= RDY_smem;
		end if;
	end process clock_rise;


end smem_freq_test_arch;
