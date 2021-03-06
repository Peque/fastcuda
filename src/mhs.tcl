#
#  mhs.tcl
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

#
# TODO: seek for the latest IP cores available instead of using a specific
#       version (get rid of warnings due to superseded cores).
#



#
# Set pcores versions
#
proc get_latest_pcore_version { pcore } {
	global XILINX_DIR
	global FASTCUDA_DIR
	set XILINX_PCORES_DIR $XILINX_DIR/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores
	return [ exec $FASTCUDA_DIR/src/lib/get_latest_pcore_version.sh $XILINX_PCORES_DIR $pcore ]
}

set microblaze_version        [ get_latest_pcore_version microblaze ]
set lmb_v10_version           [ get_latest_pcore_version lmb_v10 ]
set lmb_bram_if_cntlr_version [ get_latest_pcore_version lmb_bram_if_cntlr ]
set bram_block_version        [ get_latest_pcore_version bram_block ]
set proc_sys_reset_version    [ get_latest_pcore_version proc_sys_reset ]
set clock_generator_version   [ get_latest_pcore_version clock_generator ]
set axi_interconnect_version  [ get_latest_pcore_version axi_interconnect ]
set axi_s6_ddrx_version       [ get_latest_pcore_version axi_s6_ddrx ]
set mdm_version               [ get_latest_pcore_version mdm ]
set chipscope_ila_version     [ get_latest_pcore_version chipscope_ila ]
set chipscope_icon_version    [ get_latest_pcore_version chipscope_icon ]
set registers_version           2.00.a
set master_version              1.00.a


#
# Create hadle variables for the original and merged microprocessor hardware specification (MHS) files:
#
set mhs_handle [xget_handle mhs]
set merged_mhs_handle [xget_handle merged_mhs]


#
# Top level ports
#
xadd_hw_ipinst_port $mhs_handle zio "zio, DIR = IO"
xadd_hw_ipinst_port $mhs_handle rzq "rzq, DIR = IO"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_we_n "mcbx_dram_we_n, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_udqs_n "mcbx_dram_udqs_n, DIR = IO"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_udqs "mcbx_dram_udqs, DIR = IO"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_udm "mcbx_dram_udm, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_ras_n "mcbx_dram_ras_n, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_odt "mcbx_dram_odt, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_ldm "mcbx_dram_ldm, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_dqs_n "mcbx_dram_dqs_n, DIR = IO"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_dqs "mcbx_dram_dqs, DIR = IO"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_dq "mcbx_dram_dq, DIR = IO, VEC = \[15:0\]"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_clk_n "mcbx_dram_clk_n, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_clk "mcbx_dram_clk, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_cke "mcbx_dram_cke, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_cas_n "mcbx_dram_cas_n, DIR = O"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_ba "mcbx_dram_ba, DIR = O, VEC = \[2:0\]"
xadd_hw_ipinst_port $mhs_handle mcbx_dram_addr "mcbx_dram_addr, DIR = O, VEC = \[12:0\]"
xadd_hw_ipinst_port $mhs_handle RESET "RESET, DIR = I, SIGIS = RST, RST_POLARITY = 0"
xadd_hw_ipinst_port $mhs_handle GCLK "GCLK, DIR = I, SIGIS = CLK, CLK_FREQ = 100000000"

# Add a MicroBlaze (MB_0) v8.20.a IP with the instance name mblaze_0 to the MHS:
set mblaze_0_handle [xadd_hw_ipinst $mhs_handle mblaze_0 microblaze $microblaze_version]

# Add a Local Memory Bus v2.00.b for the MB_0 instructions cache:
set mblaze_0_ilmb_handle [xadd_hw_ipinst $mhs_handle mblaze_0_ilmb lmb_v10 $lmb_v10_version]

# Add a LMB v2.00.b for the MB_0 data cache:
set mblaze_0_dlmb_handle [xadd_hw_ipinst $mhs_handle mblaze_0_dlmb lmb_v10 $lmb_v10_version]

# Add a LMB BRAM interface controller (IC) for the MB_0 intructions cache:
set mblaze_0_i_bram_cntlr_handle [xadd_hw_ipinst $mhs_handle mblaze_0_i_bram_cntlr lmb_bram_if_cntlr $lmb_bram_if_cntlr_version]

# Add a LMB BRAM IC for the MB_0 data cache:
set mblaze_0_d_bram_cntlr_handle [xadd_hw_ipinst $mhs_handle mblaze_0_d_bram_cntlr lmb_bram_if_cntlr $lmb_bram_if_cntlr_version]

# Add a BRAM for the MB_0 instructions and data caches:
set mblaze_0_bram_handle [xadd_hw_ipinst $mhs_handle mblaze_0_bram bram_block $bram_block_version]

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
set psys_reset_0_handle [xadd_hw_ipinst $mhs_handle psys_reset_0 proc_sys_reset $proc_sys_reset_version]
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
set clock_generator_0_handle [xadd_hw_ipinst $mhs_handle clock_generator_0 clock_generator $clock_generator_version]
#   Reset: active low
xadd_hw_ipinst_parameter $clock_generator_0_handle C_EXT_RESET_HIGH 0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKIN_FREQ 100000000
xadd_hw_ipinst_port $clock_generator_0_handle RST RESET
xadd_hw_ipinst_port $clock_generator_0_handle CLKIN GCLK
xadd_hw_ipinst_port $clock_generator_0_handle LOCKED psys_reset_0_Dcm_locked
#   Clock 0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_FREQ 600000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT0_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT0 clk_600_0000MHz_PLL0_nobuf
#   Clock 1
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_FREQ 600000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_PHASE 180
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT1_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT1 clk_600_0000MHz_180_PLL0_nobuf
#   Clock 2
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT2_FREQ 100000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT2_GROUP PLL0
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT2 clk_100_0000MHz_PLL0
#   Clock 3
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT3_FREQ 100000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT3_PHASE 90
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT3_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT3_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT3 clk_100_0000MHz_90_PLL0_nobuf
#   Clock 4
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT4_FREQ 100000000
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT4_GROUP PLL0
xadd_hw_ipinst_parameter $clock_generator_0_handle C_CLKOUT4_BUF FALSE
xadd_hw_ipinst_port $clock_generator_0_handle CLKOUT4 clk_100_0000MHz_PLL0_nobuf

# Connect MB_0 instructions and data LMBs to reset and clock signals:
xadd_hw_ipinst_port $mblaze_0_ilmb_handle SYS_RST psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $mblaze_0_ilmb_handle LMB_CLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $mblaze_0_dlmb_handle SYS_RST psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $mblaze_0_dlmb_handle LMB_CLK clk_100_0000MHz_PLL0

# Set MB_0 LMBs and BRAM parameters (number of slaves and memory size):
xadd_hw_ipinst_parameter $mblaze_0_ilmb_handle C_LMB_NUM_SLAVES 1
xadd_hw_ipinst_parameter $mblaze_0_dlmb_handle C_LMB_NUM_SLAVES 1
xadd_hw_ipinst_parameter $mblaze_0_bram_handle C_MEMSIZE 0x2000

# Connect MB_0 to reset and clock signals:
xadd_hw_ipinst_port $mblaze_0_handle MB_RESET psys_reset_0_MB_Reset
xadd_hw_ipinst_port $mblaze_0_handle CLK clk_100_0000MHz_PLL0

# Set other MB_0 parameters:
xadd_hw_ipinst_parameter $mblaze_0_handle C_INTERCONNECT 2
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_BARREL 1
xadd_hw_ipinst_parameter $mblaze_0_handle C_USE_FPU 0
xadd_hw_ipinst_parameter $mblaze_0_handle C_ENDIANNESS 1
xadd_hw_ipinst_parameter $mblaze_0_handle C_ICACHE_USE_FSL 0
xadd_hw_ipinst_parameter $mblaze_0_handle C_DCACHE_USE_FSL 0

# MB_0 AXI bus interfaces:
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_DP axi4lite_0
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_DC axi4_0
xadd_hw_ipinst_busif $mblaze_0_handle M_AXI_IC axi4_0

#
# Create AXI 4 and AXI 4-Lite interconnect cores:
#
set axi4lite_0_handle [xadd_hw_ipinst $mhs_handle axi4lite_0 axi_interconnect $axi_interconnect_version]
set axi4_0_handle [xadd_hw_ipinst $mhs_handle axi4_0 axi_interconnect $axi_interconnect_version]
set axi4_1_handle [xadd_hw_ipinst $mhs_handle axi4_1 axi_interconnect $axi_interconnect_version]
# Reset and clock ports:
xadd_hw_ipinst_port $axi4lite_0_handle INTERCONNECT_ARESETN psys_reset_0_Interconnect_aresetn
xadd_hw_ipinst_port $axi4lite_0_handle INTERCONNECT_ACLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $axi4_0_handle INTERCONNECT_ARESETN psys_reset_0_Interconnect_aresetn
xadd_hw_ipinst_port $axi4_0_handle INTERCONNECT_ACLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $axi4_1_handle INTERCONNECT_ARESETN psys_reset_0_Interconnect_aresetn
xadd_hw_ipinst_port $axi4_1_handle INTERCONNECT_ACLK clk_100_0000MHz_PLL0
# Define axi4lite_0 architecture as "shared access" (area optimized)
xadd_hw_ipinst_parameter $axi4lite_0_handle C_INTERCONNECT_CONNECTIVITY_MODE 0
# Define AXI interconnect base family:
xadd_hw_ipinst_parameter $axi4lite_0_handle C_BASEFAMILY spartan6
xadd_hw_ipinst_parameter $axi4_0_handle C_BASEFAMILY spartan6
xadd_hw_ipinst_parameter $axi4_1_handle C_BASEFAMILY spartan6

#
# Spartan 6 memory interface:
#
set MCB_DDR2_handle [xadd_hw_ipinst $mhs_handle MCB_DDR2 axi_s6_ddrx $axi_s6_ddrx_version]
#   Parameters
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MCB_RZQ_LOC L6
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MCB_ZIO_LOC C2
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MEM_TYPE DDR2
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MEM_PARTNO EDE1116AXXX-8E
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MEM_BANKADDR_WIDTH 3
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MEM_NUM_COL_BITS 10
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_MEM_DDR2_RTT 50OHMS
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_SKIP_IN_TERM_CAL 0
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_MASTERS "mblaze_0.M_AXI_DC & mblaze_0.M_AXI_IC"
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_AW_REGISTER 8
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_AR_REGISTER 8
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_W_REGISTER 8
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_R_REGISTER 8
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S0_AXI_B_REGISTER 8
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S0_AXI_ENABLE 1
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S0_AXI_STRICT_COHERENCY 0
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S0_AXI_BASEADDR 0xc0000000
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S0_AXI_HIGHADDR 0xc7ffffff
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_INTERCONNECT_S1_AXI_MASTERS "master_0.M_AXI"
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S1_AXI_ENABLE 1
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S1_AXI_STRICT_COHERENCY 0
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S1_AXI_BASEADDR 0xc0000000
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_S1_AXI_HIGHADDR 0xc7ffffff
xadd_hw_ipinst_parameter $MCB_DDR2_handle C_SYS_RST_PRESENT 1
#   Bus interfaces
xadd_hw_ipinst_busif $MCB_DDR2_handle S0_AXI axi4_0
xadd_hw_ipinst_busif $MCB_DDR2_handle S1_AXI axi4_1
#   Ports
xadd_hw_ipinst_port $MCB_DDR2_handle zio zio
xadd_hw_ipinst_port $MCB_DDR2_handle rzq rzq
xadd_hw_ipinst_port $MCB_DDR2_handle s0_axi_aclk clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $MCB_DDR2_handle s1_axi_aclk clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $MCB_DDR2_handle ui_clk clk_100_0000MHz_PLL0
#     Memory signals (mcbx_dram_*)
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_we_n mcbx_dram_we_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_udqs_n mcbx_dram_udqs_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_udqs mcbx_dram_udqs
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_udm mcbx_dram_udm
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_ras_n mcbx_dram_ras_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_odt mcbx_dram_odt
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_ldm mcbx_dram_ldm
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_dqs_n mcbx_dram_dqs_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_dqs mcbx_dram_dqs
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_dq mcbx_dram_dq
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_clk_n mcbx_dram_clk_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_clk mcbx_dram_clk
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_cke mcbx_dram_cke
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_cas_n mcbx_dram_cas_n
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_ba mcbx_dram_ba
xadd_hw_ipinst_port $MCB_DDR2_handle mcbx_dram_addr mcbx_dram_addr
xadd_hw_ipinst_port $MCB_DDR2_handle sysclk_2x clk_600_0000MHz_PLL0_nobuf
xadd_hw_ipinst_port $MCB_DDR2_handle sysclk_2x_180 clk_600_0000MHz_180_PLL0_nobuf
xadd_hw_ipinst_port $MCB_DDR2_handle SYS_RST psys_reset_0_BUS_STRUCT_RESET
xadd_hw_ipinst_port $MCB_DDR2_handle PLL_LOCK psys_reset_0_Dcm_locked

#
# Registers:
#
set registers_0_handle [xadd_hw_ipinst $mhs_handle registers_0 registers $registers_version]
xadd_hw_ipinst_parameter $registers_0_handle C_BASEADDR 0x77c00000
xadd_hw_ipinst_parameter $registers_0_handle C_HIGHADDR 0x77c0ffff
xadd_hw_ipinst_busif $registers_0_handle S_AXI axi4lite_0
xadd_hw_ipinst_port $registers_0_handle S_AXI_ACLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $registers_0_handle address_out_0 master_0_address_in_0
xadd_hw_ipinst_port $registers_0_handle address_out_1 master_0_address_in_1
xadd_hw_ipinst_port $registers_0_handle address_out_2 master_0_address_in_2
xadd_hw_ipinst_port $registers_0_handle address_out_3 master_0_address_in_3
xadd_hw_ipinst_port $registers_0_handle go master_0_go
xadd_hw_ipinst_port $registers_0_handle ready master_0_ready
xadd_hw_ipinst_port $registers_0_handle DO_0 smem_DO_0
xadd_hw_ipinst_port $registers_0_handle DO_1 smem_DO_1
xadd_hw_ipinst_port $registers_0_handle DO_2 smem_DO_2
xadd_hw_ipinst_port $registers_0_handle DO_3 smem_DO_3
xadd_hw_ipinst_port $registers_0_handle DI_0 smem_DI_0
xadd_hw_ipinst_port $registers_0_handle DI_1 smem_DI_1
xadd_hw_ipinst_port $registers_0_handle DI_2 smem_DI_2
xadd_hw_ipinst_port $registers_0_handle DI_3 smem_DI_3
xadd_hw_ipinst_port $registers_0_handle ADDR_0_W smem_ADDR_0_W
xadd_hw_ipinst_port $registers_0_handle ADDR_1_W smem_ADDR_1_W
xadd_hw_ipinst_port $registers_0_handle ADDR_2_W smem_ADDR_2_W
xadd_hw_ipinst_port $registers_0_handle ADDR_3_W smem_ADDR_3_W
xadd_hw_ipinst_port $registers_0_handle ADDR_0_R smem_ADDR_0_R
xadd_hw_ipinst_port $registers_0_handle ADDR_1_R smem_ADDR_1_R
xadd_hw_ipinst_port $registers_0_handle ADDR_2_R smem_ADDR_2_R
xadd_hw_ipinst_port $registers_0_handle ADDR_3_R smem_ADDR_3_R
xadd_hw_ipinst_port $registers_0_handle RST smem_RST

#
# Master
#
set master_0_handle [xadd_hw_ipinst $mhs_handle master_0 master $master_version]
xadd_hw_ipinst_busif $master_0_handle M_AXI axi4_1
xadd_hw_ipinst_port $master_0_handle S_AXI_ACLK clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $master_0_handle S_AXI_ARESETN psys_reset_0_Interconnect_aresetn
xadd_hw_ipinst_port $master_0_handle chipscope_probe master_0_debug_signal
xadd_hw_ipinst_port $master_0_handle m_axi_aclk clk_100_0000MHz_PLL0
xadd_hw_ipinst_port $master_0_handle address_in_0 master_0_address_in_0
xadd_hw_ipinst_port $master_0_handle address_in_1 master_0_address_in_1
xadd_hw_ipinst_port $master_0_handle address_in_2 master_0_address_in_2
xadd_hw_ipinst_port $master_0_handle address_in_3 master_0_address_in_3
xadd_hw_ipinst_port $master_0_handle go master_0_go
xadd_hw_ipinst_port $master_0_handle ready master_0_ready
xadd_hw_ipinst_port $master_0_handle DO_0 smem_DO_0
xadd_hw_ipinst_port $master_0_handle DO_1 smem_DO_1
xadd_hw_ipinst_port $master_0_handle DO_2 smem_DO_2
xadd_hw_ipinst_port $master_0_handle DO_3 smem_DO_3
xadd_hw_ipinst_port $master_0_handle DI_0 smem_DI_0
xadd_hw_ipinst_port $master_0_handle DI_1 smem_DI_1
xadd_hw_ipinst_port $master_0_handle DI_2 smem_DI_2
xadd_hw_ipinst_port $master_0_handle DI_3 smem_DI_3
xadd_hw_ipinst_port $master_0_handle ADDR_0_W smem_ADDR_0_W
xadd_hw_ipinst_port $master_0_handle ADDR_1_W smem_ADDR_1_W
xadd_hw_ipinst_port $master_0_handle ADDR_2_W smem_ADDR_2_W
xadd_hw_ipinst_port $master_0_handle ADDR_3_W smem_ADDR_3_W
xadd_hw_ipinst_port $master_0_handle ADDR_0_R smem_ADDR_0_R
xadd_hw_ipinst_port $master_0_handle ADDR_1_R smem_ADDR_1_R
xadd_hw_ipinst_port $master_0_handle ADDR_2_R smem_ADDR_2_R
xadd_hw_ipinst_port $master_0_handle ADDR_3_R smem_ADDR_3_R
xadd_hw_ipinst_port $master_0_handle BRAM_CLK clk_100_0000MHz_PLL0_nobuf
xadd_hw_ipinst_port $master_0_handle TRIG_CLK clk_100_0000MHz_90_PLL0_nobuf
xadd_hw_ipinst_port $master_0_handle RST smem_RST

#
# MB_0 debug module
#
set mblaze_0_debug_module_handle [xadd_hw_ipinst $mhs_handle mblaze_0_debug_module mdm $mdm_version]
xadd_hw_ipinst_parameter $mblaze_0_debug_module_handle C_INTERCONNECT 2
xadd_hw_ipinst_parameter $mblaze_0_debug_module_handle C_USE_UART 1
xadd_hw_ipinst_parameter $mblaze_0_debug_module_handle C_BASEADDR 0x74800000
xadd_hw_ipinst_parameter $mblaze_0_debug_module_handle C_HIGHADDR 0x7480ffff
xadd_hw_ipinst_busif $mblaze_0_debug_module_handle S_AXI axi4lite_0
xadd_hw_ipinst_busif $mblaze_0_debug_module_handle MBDEBUG_0 mblaze_0_debug
xadd_hw_ipinst_port $mblaze_0_debug_module_handle Debug_SYS_Rst psys_reset_0_MB_Debug_Sys_Rst
xadd_hw_ipinst_port $mblaze_0_debug_module_handle S_AXI_ACLK clk_100_0000MHz_PLL0
# MB_0 bus interface and configuration:
xadd_hw_ipinst_parameter $mblaze_0_handle C_DEBUG_ENABLED 1
xadd_hw_ipinst_busif $mblaze_0_handle DEBUG mblaze_0_debug
# Reset port:
xadd_hw_ipinst_port $psys_reset_0_handle MB_Debug_Sys_Rst psys_reset_0_MB_Debug_Sys_Rst

#
# ChipScope integrated logic analyzer and controller
#
set chipscope_ila_handle [xadd_hw_ipinst $mhs_handle chipscope_ila_0 chipscope_ila $chipscope_ila_version]
xadd_hw_ipinst_parameter $chipscope_ila_handle C_TRIG0_UNITS 1
xadd_hw_ipinst_parameter $chipscope_ila_handle C_TRIG0_TRIGGER_IN_WIDTH 256
xadd_hw_ipinst_parameter $chipscope_ila_handle C_NUM_DATA_SAMPLES 1024
xadd_hw_ipinst_port $chipscope_ila_handle chipscope_ila_control chipscope_ila_0_control
xadd_hw_ipinst_port $chipscope_ila_handle TRIG0 master_0_debug_signal
xadd_hw_ipinst_port $chipscope_ila_handle CLK clk_100_0000MHz_PLL0

set chipscope_icon_handle [xadd_hw_ipinst $mhs_handle chipscope_icon_0 chipscope_icon $chipscope_icon_version]
xadd_hw_ipinst_parameter $chipscope_icon_handle C_NUM_CONTROL_PORTS 1
xadd_hw_ipinst_port $chipscope_icon_handle control0 chipscope_ila_0_control



