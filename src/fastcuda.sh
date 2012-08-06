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
source $XILINX_DIR/ISE_DS/settings$SYSTEM.sh


#
# Create configuration file for the TCL script
#
echo "set FASTCUDA_DIR \"$FASTCUDA_DIR\"">> $CONFIG_DIR/config_build.tcl
echo "set FASTCUDA_PROJ_NAME \"$1\"">> $CONFIG_DIR/config_build.tcl


#
# Creating project's folder
#
if [ -d ./fastcuda_$1 ]; then
	echo "A folder containing a project with this name already exists."
	read -p "Would you like to override it? (y/n): "
	if [ ${REPLY} != "y" ]; then
		echo "Please, choose a different project name and try again..."
		exit
	fi
	rm -rf fastcuda_$1
fi

mkdir fastcuda_$1
cd fastcuda_$1


#
# Run the target TCL file using XPS
#
xps -nw -scr $FASTCUDA_DIR/src/main.tcl


#
# Remove configuration file for the TCL script
#
rm $CONFIG_DIR/config_build.tcl
