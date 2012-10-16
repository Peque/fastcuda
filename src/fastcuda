#!/bin/bash

#
#  fastcuda.sh
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



CONFIG_DIR=~/.fastcuda
FASTCUDA_PROJ_NAME=$1

SYSTEM=32  # 32 bits systems
if [ `uname -m | grep x86_64` ]; then
	SYSTEM=64  # 64 bits systems
fi


if [ ! -d $CONFIG_DIR ]; then
	echo "No configuration folder found. Please run ./install first..."
	exit
fi

#
# Get information from the configuration file:
#
echo "Reading configuration file..."
source $CONFIG_DIR/config
echo "Loaded data from the configuration file."


#
# Load Xilinx settings for our system
#
SETTINGS_FILE=.settings$SYSTEM.sh
XIL_SCRIPT_LOC="$XILINX_DIR/ISE_DS"
xlnxInstLocList=""
xlnxInstLocList="${xlnxInstLocList} common"
xlnxInstLocList="${xlnxInstLocList} EDK"
xlnxInstLocList="${xlnxInstLocList} common/CodeSourcery"
xlnxInstLocList="${xlnxInstLocList} PlanAhead"
xlnxInstLocList="${xlnxInstLocList} ../../Vivado/2012.1"
xlnxInstLocList="${xlnxInstLocList} ISE"
xlnxInstLocList="${xlnxInstLocList} SysGen"
XIL_SCRIPT_LOC_TMP_UNI=${XIL_SCRIPT_LOC}
for i in $xlnxInstLocList
do
	d="${XIL_SCRIPT_LOC_TMP_UNI}/$i"
	sfn="$d/$SETTINGS_FILE"
	if [ -e  "$sfn" ]; then
		echo . "$sfn" "$d"
		. "$sfn" "$d"
	fi
done


#
# Create configuration file for the TCL script
#
# TODO: parse each line in the bash configuration file and automatically
#       translate all of it.
#
echo "set FASTCUDA_DIR \"$FASTCUDA_DIR\"">> $CONFIG_DIR/config_build.tcl
echo "set FASTCUDA_PROJ_NAME \"$FASTCUDA_PROJ_NAME\"">> $CONFIG_DIR/config_build.tcl
echo "set XILINX_DIR \"$XILINX_DIR\"">> $CONFIG_DIR/config_build.tcl


#
# Creating project's folder
#
if [ -d ./fcbuild_$FASTCUDA_PROJ_NAME ]; then
	echo "A folder containing a project with this name already exists."
	read -p "Would you like to override it? (y/n): "
	if [ ${REPLY} != "y" ]; then
		echo "Please, choose a different project name and try again..."
		exit
	fi
	rm -rf fcbuild_$FASTCUDA_PROJ_NAME
fi

mkdir fcbuild_$FASTCUDA_PROJ_NAME
cd fcbuild_$FASTCUDA_PROJ_NAME


#
# Run the target TCL file using XPS
#
xps -nw -scr $FASTCUDA_DIR/src/main.tcl


#
# Run the Xilinx implementation tools flow and generate the bitstream
#
make -f ./$FASTCUDA_PROJ_NAME.make bits


#
# Export to SDK
#
make -f ./$FASTCUDA_PROJ_NAME.make exporttosdk


#
# Remove configuration file for the TCL script
#
rm $CONFIG_DIR/config_build.tcl
