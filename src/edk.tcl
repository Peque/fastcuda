#
#  edk.tcl
#
#  Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

xload new test.xmp

# Create hadle variables for the original and merged microprocessor hardware specification (MHS) files:
set mhs_handle [xget_handle mhs]
set merged_mhs_handle [xget_handle merged_mhs]

# Add a MicroBlaze (MB_0) v8.20.a IP with the instance name mblaze_0 to the MHS:
set mblaze_0_handle [xadd_hw_ipinst $mhs_handle mblaze_0 microblaze 8.30.a]

# Add a Local Memory Bus v2.00.b for the MB_0 instructions cache:
set mblaze_0_ilmb_handle [xadd_hw_ipinst $mhs_handle mblaze_0_ilmb lmb_v10 2.00.b]

# Add a LMB v2.00.b for the MB_0 data cache:
set mblaze_0_dlmb_handle [xadd_hw_ipinst $mhs_handle mblaze_0_dlmb lmb_v10 2.00.b]

# Add a LMB BRAM interface controller (IC) for the MB_0 intructions cache:
set mblaze_0_i_bram_cntlr_handle [xadd_hw_ipinst $mhs_handle mblaze_0_i_bram_cntlr lmb_bram_if_cntlr 3.00.b]

# Add a LMB BRAM IC for the MB_0 data cache:
set mblaze_0_d_bram_cntlr_handle [xadd_hw_ipinst $mhs_handle mblaze_0_d_bram_cntlr lmb_bram_if_cntlr 3.00.b]

# Add a BRAM for the MB_0 instructions and data caches:
set mblaze_0_bram_handle [xadd_hw_ipinst $mhs_handle mblaze_0_bram bram_block 1.00.a]

# Set bus interfaces for MB_0 BRAM ports (connect A to i_bram_cntlr and B to d_bram_cntlr):
xadd_hw_ipinst_busif $mblaze_0_bram_handle PORTA mblaze_0_i_bram_cntlr2block
xadd_hw_ipinst_busif $mblaze_0_bram_handle PORTB mblaze_0_d_bram_cntlr2block

# Set bus interfaces for the MB_0 LMB BRAM ICs:
xadd_hw_ipinst_busif $mblaze_0_i_bram_cntlr_handle SLMB mblaze_0_ilmb
xadd_hw_ipinst_busif $mblaze_0_i_bram_cntlr_handle BRAM_PORT mblaze_0_i_bram_cntlr2block
xadd_hw_ipinst_busif $mblaze_0_d_bram_cntlr_handle SLMB mblaze_0_dlmb
xadd_hw_ipinst_busif $mblaze_0_d_bram_cntlr_handle BRAM_PORT mblaze_0_d_bram_cntlr2block

# Set memory size for the MB_0 LMB BRAM ICs:
xadd_hw_ipinst_parameter $mblaze_0_i_bram_cntlr_handle C_BASEADDR 0x00000000
xadd_hw_ipinst_parameter $mblaze_0_i_bram_cntlr_handle C_HIGHADDR 0x00001fff
xadd_hw_ipinst_parameter $mblaze_0_d_bram_cntlr_handle C_BASEADDR 0x00000000
xadd_hw_ipinst_parameter $mblaze_0_d_bram_cntlr_handle C_HIGHADDR 0x00001fff

# Make MB_0 LMB BRAM ICs accesible from MB_0:
xadd_hw_ipinst_busif $mblaze_0_handle ILMB mblaze_0_ilmb
xadd_hw_ipinst_busif $mblaze_0_handle DLMB mblaze_0_dlmb

# Configure MB_0 instructions and data caches:
#   Instructions cache
xadd_hw_ipinst_parameter $mblaze_0_handle C_ICACHE_BASEADDR 0xc0000000
xadd_hw_ipinst_parameter $mblaze_0_handle C_ICACHE_HIGHADDR 0xc7ffffff
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_ICACHE 1
xadd_hw_ipinst_parameter $mblaze_0_handle C_CACHE_BYTE_SIZE 8192
xadd_hw_ipinst_parameter $mblaze_0_handle C_ICACHE_ALWAYS_USED 1
#   Data cache
xadd_hw_ipinst_parameter $mblaze_0_handle C_DCACHE_BASEADDR 0xc0000000
xadd_hw_ipinst_parameter $mblaze_0_handle C_DCACHE_HIGHADDR 0xc7ffffff
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_DCACHE 1
xadd_hw_ipinst_parameter $mblaze_0_handle C_DCACHE_BYTE_SIZE 8192
xadd_hw_ipinst_parameter $mblaze_0_handle C_DCACHE_ALWAYS_USED 1


#
# Create and configure a processor system reset module:
#
set psys_reset_0_handle [xadd_hw_ipinst $mhs_handle psys_reset_0 proc_sys_reset 3.00.a]
# Reset generated when external reset = '0':
xadd_hw_ipinst_parameter $psys_reset_0_handle C_EXT_RESET_HIGH 0
xadd_hw_ipinst_port $psys_reset_0_handle Dcm_locked psys_reset_0_Dcm_locked
xadd_hw_ipinst_port $psys_reset_0_handle MB_Reset psys_reset_0_MB_Reset
xadd_hw_ipinst_port $psys_reset_0_handle BUS_STRUCT_RESET psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $psys_reset_0_handle Interconnect_aresetn psys_reset_0_Interconnect_aresetn
#   External reset and slowest sync (100 MHz) clock ports
xadd_hw_ipinst_port $psys_reset_0_handle Ext_Reset_In RESET
xadd_hw_ipinst_port $psys_reset_0_handle Slowest_sync_clk clk_100_0000MHz_PLL0


#
# Create and configure a clock generator:
#
set clock_generator_0_handle [xadd_hw_ipinst $mhs_handle clock_generator_0 clock_generator 4.03.a]
#   Reset: active low
xadd_hw_ipinst_parameter $clock_generator_0_handle C_EXT_RESET_HIGH 0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKIN_FREQ 100000000
xadd_hw_ipinst_port $clock_generator_0_handle RST RESET
xadd_hw_ipinst_port $clock_generator_0_handle CLKIN GCLK
xadd_hw_ipinst_port $clock_generator_0_handle LOCKED psys_reset_0_Dcm_locked
#   Clock 0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_FREQ 600000000
#     For phase alignment purposes:
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT0 clk_600_0000MHz_PLL0_nobuf
#   Clock 1
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_FREQ 600000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_PHASE 180
#     For phase alignment purposes:
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT1 clk_600_0000MHz_180_PLL0_nobuf
#   Clock 2
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT2_FREQ 100000000
#     For phase alignment purposes:
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT2_GROUP PLL0
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT2 clk_100_0000MHz_PLL0

# Connect MB_0 instructions and data LMBs to reset and clock signals:
xadd_hw_ipinst_port $mblaze_0_ilmb_handle SYS_RST psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $mblaze_0_ilmb_handle LMB_CLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $mblaze_0_dlmb_handle SYS_RST psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $mblaze_0_dlmb_handle LMB_CLK clk_100_0000MHz_PLL0

# Connect MB_0 to reset and clock signals:
xadd_hw_ipinst_port $mblaze_0_handle MB_RESET psys_reset_0_MB_Reset
xadd_hw_ipinst_port $mblaze_0_handle CLK clk_100_0000MHz_PLL0

# Set other MB_0 parameters:
xadd_hw_ipinst_parameter $mblaze_0_handle C_INTERCONNECT 2
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_BARREL 1
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_FPU 0

# MB_0 AXI bus interfaces:
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_DP axi4lite_0
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_DC axi4_0
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_IC axi4_0
