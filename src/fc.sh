#!/bin/bash

#
#  fc.sh
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

SYSTEM=lin
if [ `uname -m | grep x86_64` ]; then
	SYSTEM=${SYSTEM}64  # lin64 for 64 bits systems
fi

XILINX_DIR_TOKEN=/ISE/bin/$SYSTEM/xtclsh
FASTCUDA_DIR_TOKEN=/src/lib/run_task.tcl


# Check if the configuration file exists. If it doesn't exist, create
# the configuration directory and a new configuration file
if [ ! -d $CONFIG_DIR ]; then

	echo "No configuration folder found, creating a new one..."

	mkdir $CONFIG_DIR
	touch $CONFIG_DIR/config

	echo "Trying to find Xilinx in your /opt and user directories..."
	XILINX_FOUND_OPT=$(find /opt -name '.?*' -prune -o -print | grep $XILINX_DIR_TOKEN)
	XILINX_FOUND_HOME=$(find ~ -name '.?*' -prune -o -print | grep $XILINX_DIR_TOKEN)


	if [[ -z "$XILINX_FOUND_OPT" && -z "$XILINX_FOUND_HOME" ]]; then
		echo "Couldn't find Xilinx in your system."
		echo "Please, introduce path for the Xilinx installation directory,"
		read -p "(i.e.: /opt/Xilinx/13.3/ISE_DS): "
		while [ ! `readlink -e ${REPLY}${XILINX_DIR_TOKEN}` ]; do
			echo "Incorrect path. Please try again with an absolute path with no trailing '/',"
			read -p "(i.e.: /opt/Xilinx/13.3/ISE_DS): "
		done
		echo XILINX_DIR=$REPLY>> $CONFIG_DIR/config
	else
		if [[ ! -z "$XILINX_FOUND_OPT" ]]; then
			echo "Found Xilinx installation in /opt."
			# Make use of parameter expansion:
			echo XILINX_DIR=${XILINX_FOUND_OPT%%"$XILINX_DIR_TOKEN"*}>> $CONFIG_DIR/config
		else
			echo "Found Xilinx installation in your user directory."
			# Make use of parameter expansion:
			echo XILINX_DIR=${XILINX_FOUND_HOME%%"$XILINX_DIR_TOKEN"*}>> $CONFIG_DIR/config
		fi
	fi


	echo "Trying to find FASTCUDA in your /opt and user directories..."
	FASTCUDA_FOUND_OPT=$(find /opt -name '.?*' -prune -o -print | grep $FASTCUDA_DIR_TOKEN)
	FASTCUDA_FOUND_HOME=$(find ~ -name '.?*' -prune -o -print | grep $FASTCUDA_DIR_TOKEN)

	if [[ -z "$FASTCUDA_FOUND_OPT" && -z "$FASTCUDA_FOUND_HOME" ]]; then
		echo "Couldn't find FASTCUDA in your system."
		echo "Please, introduce path for the FASTCUDA installation directory,"
		read -p "(i.e.: /opt/fastcuda): "
		while [ ! `readlink -e ${REPLY}${FASTCUDA_DIR_TOKEN}` ]; do
			echo "Incorrect path. Please try again with an absolute path with no trailing '/',"
			read -p "(i.e.: /opt/fastcuda): "
		done
		echo FASTCUDA_DIR=$REPLY>> $CONFIG_DIR/config
	else
		if [[ ! -z "$FASTCUDA_FOUND_OPT" ]]; then
			echo "Found FASTCUDA installation in /opt."
			# Make use of parameter expansion:
			echo FASTCUDA_DIR=${FASTCUDA_FOUND_OPT%%"$FASTCUDA_DIR_TOKEN"*}>> $CONFIG_DIR/config
		else
			echo "Found FASTCUDA installation in your user directory."
			# Make use of parameter expansion:
			echo FASTCUDA_DIR=${FASTCUDA_FOUND_HOME%%"$FASTCUDA_DIR_TOKEN"*}>> $CONFIG_DIR/config
		fi
	fi

	echo "Configuration file created."
fi


# Get information from the configuration file:
echo "Reading configuration file..."
source $CONFIG_DIR/config
echo "Loaded data from the configuration file."


# Find Xilinx's TCL native interpreter (depends on the system's
# architecture):
XTCLSH_DIR=$XILINX_DIR/ISE/bin/$SYSTEM


# Run the target TCL file using Xilinx's tclsh
$XTCLSH_DIR/xtclsh $FASTCUDA_DIR/src/main.tcl $1

