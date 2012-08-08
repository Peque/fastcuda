#
#  main.tcl
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
# Get self information:
#
set main_script [file normalize [info script]]
set main_script_dir [file dirname $main_script]
set main_script_name [file tail $main_script]


#
# Load configuration variables:
#
source ~/.fastcuda/config_build.tcl


#
# Generate hardware architecture:
#

xload new test.xmp


# Project settings:
xset arch spartan6
xset dev xc6slx45
xset package csg324
xset hdl vhdl
xset intstyle default
xset sdk_export_dir SDK/SDK_Export
xset sdk_export_bmm_bit 1
xset searchpath ~/.fastcuda/Atlys_AXI_BSB_Support/lib
xset speedgrade -3
xset ucf_file data/test.ucf
xset parallel_synthesis yes
xset enable_par_timing_error 0


# MHS file creation:
source $main_script_dir/mhs.tcl


# Create UCF file
set ucf_descriptor [open ./data/test.ucf a]
puts $ucf_descriptor "#"
puts $ucf_descriptor "# pin constraints"
puts $ucf_descriptor "#"
puts $ucf_descriptor "NET GCLK LOC = \"L15\"  |  IOSTANDARD = \"LVCMOS33\";"
puts $ucf_descriptor "NET RESET LOC = \"T15\"  |  IOSTANDARD = \"LVCMOS33\"  |  TIG;"
puts $ucf_descriptor "NET rzq IOSTANDARD = \"LVCMOS18_JEDEC\";"
puts $ucf_descriptor "NET zio IOSTANDARD = \"LVCMOS18_JEDEC\";"
puts $ucf_descriptor "#"
puts $ucf_descriptor "# additional constraints"
puts $ucf_descriptor "#"
puts $ucf_descriptor "NET \"GCLK\" TNM_NET = sys_clk_pin;"
puts $ucf_descriptor "TIMESPEC TS_sys_clk_pin = PERIOD sys_clk_pin 100000 kHz;"
close $ucf_descriptor


#
# Copy master and registers IPs to pcores/ directory
#
# TODO: remove this! (use CIP command line mode instead of copying the IP files)
#
puts "Finished 	MHS file"
puts "Copying pcores from $FASTCUDA_DIR/pcores"
exec cp -r $FASTCUDA_DIR/hw/pcores ./
puts "pcores copied"

#
# Save project
#
save proj

#
# Run the Xilinx implementation tools flow and generate the bitstream
#
run bits

#
# Process finished
#
exit
