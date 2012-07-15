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
