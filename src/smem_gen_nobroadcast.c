/*
 * smem_gen.c
 *
 * Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */


#include <stdio.h>
#include <math.h>
#include <string.h>


int N;


void print_license()
{
	printf("--\n");
	printf("-- smem.vhd\n");
	printf("--\n");
	printf("-- Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>\n");
	printf("--\n");
	printf("-- This program is free software; you can redistribute it and/or modify\n");
	printf("-- it under the terms of the GNU General Public License as published by\n");
	printf("-- the Free Software Foundation; either version 2 of the License, or\n");
	printf("-- (at your option) any later version.\n");
	printf("--\n");
	printf("-- This program is distributed in the hope that it will be useful,\n");
	printf("-- but WITHOUT ANY WARRANTY; without even the implied warranty of\n");
	printf("-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n");
	printf("-- GNU General Public License for more details.\n");
	printf("--\n");
	printf("-- You should have received a copy of the GNU General Public License\n");
	printf("-- along with this program; if not, write to the Free Software\n");
	printf("-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,\n");
	printf("-- MA 02110-1301, USA.\n");
	printf("--\n");
	printf("--\n");
}

void print_libraries()
{
	printf("library ieee;\n");
	printf("use ieee.std_logic_1164.all;\n");
	printf("\n");
	printf("library unisim;\n");
	printf("use unisim.vcomponents.all;\n");
	printf("\n");
	printf("library unimacro;\n");
	printf("use unimacro.vcomponents.all;\n");
}

void print_entity()
{
	int i;

	printf("entity smem is\n");
	printf("\n");
	printf("	generic (\n");
	printf("\n");
	printf("		N_PORTS         : integer := %d;\n", N);
	printf("		N_BRAMS         : integer := %d;\n", N / 2);
	printf("		LOG2_N_PORTS    : integer := %d  -- TODO: should be calculated from N_PORTS and then used only to generate the VHDL code\n", (int) log2(N));
	printf("\n");
	printf("	);\n");
	printf("\n");
	printf("	port (\n");
	printf("\n");
	printf("		DO                     : out std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data output ports\n");
	printf("		DI                     : in  std_logic_vector(32 * N_PORTS - 1 downto 0);    -- Data input ports\n");
	printf("		");
	for (i=0; i<N; i++) {
		printf("ADDR_%d", i);
		if (i<N-1) printf(", ");
	}
	printf("     : in  std_logic_vector(%d downto 0);    -- Address input ports\n", 8 + (int)log2(N) - 1);

	printf("		");
	for (i=0; i<N; i++) {
		printf("WE_%d", i);
		if (i<N-1) printf(", ");
	}
	printf("                     : in  std_logic_vector(3 downto 0);     -- Byte write enable input ports\n");
	printf("		BRAM_CLK, TRIG_CLK, RST                                            : in  std_logic;                        -- Clock and reset input ports\n");
	printf("		");
	for (i=0; i<N; i++) {
		printf("REQ_%d", i);
		if (i<N-1) printf(", ");
	}
	printf("             : in  std_logic;                        -- Request input ports\n");
	printf("		");
	for (i=0; i<N; i++) {
		printf("RDY_%d", i);
		if (i<N-1) printf(", ");
	}
	printf("             : out std_logic                         -- Ready output port\n");
	printf("\n");
	printf("	);\n");
	printf("\n");
	printf("end smem;");
}

void print_bram_en()
{
	int i;

	for (i=0;i<N;i++) {
		printf("	bram_en(%d) <= '1';\n", i);
	}
}

void print_we_safe()
{
	int i, j;

	for (i=0;i<N;i++) {
		for (j=3;j>=0;j--) {
			printf("	we_%d_safe(%d) <= WE_%d(%d) and to_stdulogic(to_bit(REQ_%d));\n", i, j, i, j, i);
		}
		printf("\n");
	}
}

void print_ready()
{
	int i;

	for (i=0;i<N;i++) {
		printf("	RDY_%d <= to_stdulogic(k%d_being_served);\n", i, i);
	}
}

const char *byte_to_binary(int x)
{
	static char b[11];
	b[0] = '\0';

	do {
		if (x % 2) strcat(b, "1");
		else strcat(b, "0");
		x /= 2;
	} while (x > 0);

	int i;
	i = 10 - strlen(b);

	while (i--) strcat(b, "0");

	return b;
}

void invert_string(char *s)
{
	char a[11];
	int i, j;

	j = 0;
	i = strlen(s);
	s += i;

	while (i--) a[j++] = *(--s);

	a[j] = '\0';

	strcpy(s, a);
}


void print_needs_bram()
{
	int i, j, k;
	char bram_port[(int)log2(N) + 1];

	for (i=0;i<N;i++) {
		for (j=0;j<N/2;j++) {
			printf("	k%d_needs_bram_%d <= to_bit(REQ_%d)", i, j, i);
			sprintf(bram_port, "%s", byte_to_binary(j));
			for (k=(int)log2(N)-1-1;k>=0;k--) {
				printf(" and");
				if (bram_port[k] == '0') printf(" not ");
				else printf("     ");
				printf("to_bit(ADDR_%d(%d))", i, 9 + k);
			}
			printf(";\n");
		}
		printf("\n");
	}
}

void print_bram_input_sel()
{
	int i, j, a , b, c, d;

	for (j=(int)log2(N)-1;j>=0;j--) {
		for (i=0;i<N/2;i++) {
			printf("	bram_%d_input_sel(%d) <= not (", 2*i, j);


			for (a=0;a<N/((int)exp2(j+1));a++) {
				printf("(");
				for (b=0;b<N/((int)exp2((int)log2(N)-j));b++) {
					printf("k%d_needs_bram_%d", (int)exp2(j+1)*a+b, i);
					if (b < N/((int)exp2((int)log2(N)-j)) - 1) printf(" or ");
				}
				printf(")");
				if ((a < N/((int)exp2(j+1)) - 1) && (c>=a)) printf(" or (");
				for (c=0;c<a;c++) {
					for (d=0;d<N/((int)exp2(log2(N)-j));d++) {
						printf(" and (not k%d_needs_bram_%d)", (int)exp2(j+1)*c-d+1+2*(b-1), i);
					}
					if ((a < N/((int)exp2(j+1)) - 1) && (c == a-1)) printf(") or (");
					else if (c==a-1) printf(")");
				}
			}
			printf(");\n");
		}
		printf("\n");
	}
	printf("\n");

	for (j=(int)log2(N)-1;j>=0;j--) {
		for (i=0;i<N/2;i++) {
			printf("	bram_%d_input_sel(%d) <= ", 2*i+1, j);


			for (a=0;a<N/((int)exp2(j+1));a++) {
				printf("(");
				for (b=0;b<N/((int)exp2((int)log2(N)-j));b++) {
					printf("k%d_needs_bram_%d", N - 1 - ((int)exp2(j+1)*a+b), i);
					if (b < N/((int)exp2((int)log2(N)-j)) - 1) printf(" or ");
				}
				printf(")");
				if ((a < N/((int)exp2(j+1)) - 1) && (c>=a)) printf(" or (");
				for (c=0;c<a;c++) {
					for (d=0;d<N/((int)exp2(log2(N)-j));d++) {
						printf(" and (not k%d_needs_bram_%d)", N - 1 - ((int)exp2(j+1)*c-d+1+2*(b-1)), i);
					}
					if ((a < N/((int)exp2(j+1)) - 1) && (c == a-1)) printf(") or (");
					else if (c==a-1) printf(")");
				}
			}
			printf(";\n");
		}
		printf("\n");
	}
	printf("\n");
}

void print_being_served()
{
	int i, j, k;
	char bit_string[(int)log2(N) + 1];

	for (i=0; i<N; i++) {
		printf("	k%d_being_served <= to_bit(REQ_%d)", i, i);
		if (i != 0 && i != N - 1) {
			printf(" and (\n");
			for (j=0;j<N/2;j++) {
				printf("	                       (");
				sprintf(bit_string, "%s", byte_to_binary(j));
				for (k=(int)log2(N)-1-1;k>=0;k--) {
					if (bit_string[k] == '0') printf(" not ");
					else printf("     ");
					printf("k%d_output_sel(%d) and", i, k);
				}
				printf(" ( (");
				sprintf(bit_string, "%s", byte_to_binary(i));
				for (k=(int)log2(N)-1;k>=0;k--) {
					if (bit_string[k] == '0') printf(" not ");
					else printf("     ");
					printf("bram_%d_input_sel(%d)", 2*j, k);
					if (k>0) printf(" and");
				}
				printf(") or\n	                                                                             (");
				for (k=(int)log2(N)-1;k>=0;k--) {
					if (bit_string[k] == '0') printf(" not ");
					else printf("     ");
					printf("bram_%d_input_sel(%d)", 2*j+1, k);
					if (k>0) printf(" and");
				}
				printf(") ) )\n	                       or\n");
			}
			printf("	                       (not to_bit(REQ_%d)) )", i);
		}
		printf(";\n\n");
	}
}

void print_output_sel()
{
	int i, j, k;
	char bit_string[(int)log2(N) + 1];

	for (i=0;i<N;i++) {
		printf("	k%d_output_sel(%d downto %d) <= to_bitvector(ADDR_%d(%d downto %d));\n", i, (int)log2(N)-1, 1, i, 9 + (int)log2(N)-2, 9);
	}
	printf("\n\n");
	for (i=0;i<N;i++) {
		printf("	k%d_output_sel(0) <= (", i);
		for (j=0;j<N/2;j++) {
			sprintf(bit_string, "%s", byte_to_binary(j));
			for (k=(int)log2(N)-1;k>0;k--) {
				if (bit_string[k-1] == '0') printf(" not ");
				else printf("     ");
				printf("k%d_output_sel(%d) and", i, k);
			}
			printf(" ( ");
			sprintf(bit_string, "%s", byte_to_binary(i));
			for (k=(int)log2(N)-1;k>=0;k--) {
				if (bit_string[k] == '0') printf("not ");
				else printf("    ");
				printf("bram_%d_input_sel(%d)", 2*j+1, k);
				if (k>0) printf(" and\n	                                                                          ");
				else printf(") )");

			}
			if (j<N/2-1) printf("\n	                    or\n	                    (");
			else printf(";\n\n");
		}
	}
}

void print_input_controller()
{
	int i, j;
	char bit_string[(int)log2(N) + 1];

	for (i=0;i<N;i++) {
		printf("	input_controller_%d : block begin\n", i);
		printf("		with bram_%d_input_sel select\n", i);
		printf("			bram_di(%d * 32 - 1 downto %d * 32)    <=  ", i+1, i);
		for (j=0;j<N;j++) {
			sprintf(bit_string, "%s", byte_to_binary(j));
			bit_string[(int)log2(N)] = '\0';
			invert_string(bit_string);
			printf("DI(32 * %d - 1 downto 32 * %d) when \"%s\"", j+1, j, bit_string);
			if (j<N-1) printf(",\n			              ");
			else printf(";\n");
		}
		printf("		with bram_%d_input_sel select\n", i);
		printf("			bram_addr(%d * 9 - 1 downto %d * 9)  <=  ", i+1, i);
		for (j=0;j<N;j++) {
			sprintf(bit_string, "%s", byte_to_binary(j));
			bit_string[(int)log2(N)] = '\0';
			invert_string(bit_string);
			printf("ADDR_%d(8 downto 0) when \"%s\"", j, bit_string);
			if (j<N-1) printf(",\n			              ");
			else printf(";\n");
		}
		printf("		with bram_%d_input_sel select\n", i);
		printf("			bram_we(%d * 4 - 1 downto %d * 4)    <=  ", i+1, i);
		for (j=0;j<N;j++) {
			sprintf(bit_string, "%s", byte_to_binary(j));
			bit_string[(int)log2(N)] = '\0';
			invert_string(bit_string);
			printf("we_%d_safe when \"%s\"", j, bit_string);
			if (j<N-1) printf(",\n			              ");
			else printf(";\n");
		}
		printf("	end block input_controller_%d;\n", i);
		printf("\n");
	}
}

void print_output_controller()
{
	int i, j;
	char bit_string[(int)log2(N) + 1];

	for (i=0;i<N;i++) {
		printf("	output_controller_%d : block begin\n", i);
		printf("		with k%d_output_sel select\n", i);
		printf("			DO(32 * %d - 1 downto 32 * %d) <= ", i+1, i);
		for (j=0;j<N;j++) {
			sprintf(bit_string, "%s", byte_to_binary(j));
			bit_string[(int)log2(N)] = '\0';
			invert_string(bit_string);
			printf("bram_do(%d * 32 - 1 downto %d * 32) when \"%s\"", j+1, j, bit_string);
			if (j<N-1) printf(",\n			        ");
			else printf(";\n");
		}
		printf("	end block output_controller_%d;\n", i);
		printf("\n");
	}
}

void print_bram_inst()
{
	int i;

	printf("	bram_inst : for i in 0 to N_PORTS / 2 - 1 generate\n");
	printf("\n");
	printf("		RAMB16BWER_INST : RAMB16BWER\n");
	printf("\n");
	printf("		generic map (\n");
	printf("\n");
	printf("			-- Configurable data with for ports A and B\n");
	printf("			DATA_WIDTH_A => 36,\n");
	printf("			DATA_WIDTH_B => 36,\n");
	printf("\n");
	printf("			-- Enable RST capability\n");
	printf("			EN_RSTRAM_A => TRUE,\n");
	printf("			EN_RSTRAM_B => TRUE,\n");
	printf("\n");
	printf("			-- Reset type\n");
	printf("			RSTTYPE => \"SYNC\",\n");
	printf("\n");
	printf("			-- Optional port output register\n");
	printf("			DOA_REG => 0,\n");
	printf("			DOB_REG => 0,\n");
	printf("			-- Priority given to RAM RST over EN pin (when DO[A|B]_REG = 0)\n");
	printf("			RST_PRIORITY_A => \"SR\",\n");
	printf("			RST_PRIORITY_B => \"SR\",\n");
	printf("\n");
	printf("			-- Initial values on ports\n");
	printf("			INIT_A => X\"000000000\",\n");
	printf("			INIT_B => X\"000000000\",\n");
	printf("			INIT_FILE => \"NONE\",\n");
	printf("\n");
	printf("			-- Warning produced and affected outputs/memory location go unknown\n");
	printf("			SIM_COLLISION_CHECK => \"ALL\",\n");
	printf("\n");
	printf("			-- Simulation device (must be set to \"SPARTAN6\" for proper simulation behavior\n");
	printf("			SIM_DEVICE => \"SPARTAN6\",\n");
	printf("\n");
	printf("			-- Output value on the DO ports upon the assertion of the syncronous reset signal\n");
	printf("			SRVAL_A => X\"000000000\",\n");
	printf("			SRVAL_B => X\"000000000\",\n");
	printf("\n");
	printf("			-- NO_CHANGE mode: the output latches remain unchanged during a write operation\n");
	printf("			WRITE_MODE_A => \"READ_FIRST\",\n");
	printf("			WRITE_MODE_B => \"READ_FIRST\",\n");
	printf("\n");
	printf("			-- Initial contents of the RAM\n");
	for (i=0;i<64;i++) {
		printf("			INIT_%.2X => X\"0000000000000000000000000000000000000000000000000000000000000000\",\n", i);
	}
	printf("\n			-- Parity bits initialization\n");
	for (i=0;i<8;i++) {
		printf("			INITP_%.2X => X\"0000000000000000000000000000000000000000000000000000000000000000\"", i);
		if (i != 7) printf(",\n");
		else printf("\n");
	}
	printf("\n");
	printf("		) port map (\n");
	printf("\n");
	printf("			DOA                  => bram_do((2 * i + 1) * 32 - 1 downto (2 * i + 0) * 32),    -- Output port-A data\n");
	printf("			DOB                  => bram_do((2 * i + 2) * 32 - 1 downto (2 * i + 1) * 32),    -- Output port-B data\n");
	printf("			DOPA                 => open,                                                     -- We are not using parity bits\n");
	printf("			DOPB                 => open,                                                     -- We are not using parity bits\n");
	printf("			DIA                  => bram_di((2 * i + 1) * 32 - 1 downto (2 * i + 0) * 32),    -- Input port-A data\n");
	printf("			DIB                  => bram_di((2 * i + 2) * 32 - 1 downto (2 * i + 1) * 32),    -- Input port-B data\n");
	printf("			DIPA                 => DIP_value,                                                -- Input parity bits always set to 0 (not using them)\n");
	printf("			DIPB                 => DIP_value,                                                -- Input parity bits always set to 0 (not using them)\n");
	printf("			ADDRA(13 downto 5)   => bram_addr((2 * i + 1) * 9 - 1 downto (2 * i + 0) * 9),    -- Input port-A address\n");
	printf("			ADDRA(4 downto 0)    => LOWADDR_value,                                            -- Set low adress bits to 0\n");
	printf("			ADDRB(13 downto 5)   => bram_addr((2 * i + 2) * 9 - 1 downto (2 * i + 1) * 9),    -- Input port-B address\n");
	printf("			ADDRB(4 downto 0)    => LOWADDR_value,                                            -- Set low adress bits to 0\n");
	printf("			CLKA                 => BRAM_CLK,                                                 -- Input port-A clock\n");
	printf("			CLKB                 => BRAM_CLK,                                                 -- Input port-B clock\n");
	printf("			ENA                  => bram_en(2 * i),                                           -- Input port-A enable\n");
	printf("			ENB                  => bram_en(2 * i + 1),                                       -- Input port-B enable\n");
	printf("			REGCEA               => REGCE_value,                                              -- Input port-A output register enable\n");
	printf("			REGCEB               => REGCE_value,                                              -- Input port-B output register enable\n");
	printf("			RSTA                 => RST,                                                      -- Input port-A reset\n");
	printf("			RSTB                 => RST,                                                      -- Input port-B reset\n");
	printf("			WEA                  => bram_we((2 * i + 1) * 4 - 1 downto (2 * i + 0) * 4),      -- Input port-A write enable\n");
	printf("			WEB                  => bram_we((2 * i + 2) * 4 - 1 downto (2 * i + 1) * 4)       -- Input port-B write enable\n");
	printf("\n");
	printf("		);\n");
	printf("\n");
	printf("	end generate bram_inst;\n");
	printf("\n");
	printf("\n");
	printf("end smem_arch;\n");
}

void print_arch()
{
	int i, j;

	printf("architecture smem_arch of smem is\n");
	printf("\n");
	printf("\n");
	printf("	constant DIP_value         : std_logic_vector(3 downto 0) := \"0000\";\n");
	printf("	constant LOWADDR_value     : std_logic_vector(4 downto 0) := \"00000\";\n");
	printf("	constant REGCE_value       : std_logic := '0';\n");
	printf("	constant EN_value          : std_logic := '1';\n");
	printf("\n");
	for (i=0;i<N;i++) {
		printf("	signal k%d_output_sel       : bit_vector(%d downto 0) := \"", i, (int) log2(N) - 1);
		for (j=0;j<log2(N);j++) {
			printf("0");
		}
		printf("\";\n");
	}
	printf("\n");
	for (i=0;i<N;i++) {
		printf("	signal k%d_being_served     : bit := '0';\n", i);
	}
	printf("\n");
	for (i=0;i<N;i++) {
		printf("	signal we_%d_safe           : std_logic_vector(3 downto 0) := \"0000\";\n", i);
	}
	printf("\n");
	for (i=0;i<N;i++) {
		printf("	signal bram_%d_input_sel    : bit_vector(%d downto 0) := \"", i, (int) log2(N) - 1);
		for (j=0;j<log2(N);j++) {
			printf("0");
		}
		printf("\";\n");
	}
	printf("\n");
	for (i=0;i<N;i++) {
		for (j=0;j<N/2;j++) {
			printf("	signal k%d_needs_bram_%d     : bit := '0';\n", i, j);
		}
	}
	printf("\n");
	printf("	signal bram_do             : std_logic_vector(N_PORTS * 32 - 1 downto 0);\n");
	printf("	signal bram_di             : std_logic_vector(N_PORTS * 32 - 1 downto 0);\n");
	printf("	signal bram_addr           : std_logic_vector(N_PORTS * 9  - 1 downto 0);\n");
	printf("	signal bram_we             : std_logic_vector(N_PORTS * 4  - 1 downto 0);\n");
	printf("	signal bram_en             : std_logic_vector(N_PORTS * 1  - 1 downto 0);\n");
	printf("\n");
	printf("\n");
	printf("begin\n");
	printf("\n");
	printf("\n");
	print_bram_en();
	printf("\n");
	printf("\n");
	print_we_safe();
	printf("\n");
	print_ready();
	printf("\n");
	print_needs_bram();
	printf("\n");
	print_bram_input_sel();
	printf("\n");
	print_being_served();
	printf("\n");
	print_output_sel();
	printf("\n");
	print_input_controller();
	printf("\n");
	print_output_controller();
	printf("\n");
	print_bram_inst();
}

int main(int argc, char **argv)
{
	sscanf(argv[1], "%d", &N);

	print_license();
	printf("\n");
	printf("\n");
	printf("\n");
	print_libraries();
	printf("\n");
	printf("\n");
	printf("\n");
	print_entity();
	printf("\n");
	printf("\n");
	printf("\n");
	printf("\n");
	print_arch();

	return 0;
}

