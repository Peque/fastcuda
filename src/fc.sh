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
	SYSTEM=${XTCLSH_DIR}64  # lin64 for 64 bits systems
fi


# Check if the configuration file exists. If it doesn't exist, create
# the configuration directory and a new configuration file
if [ ! -d $CONFIG_DIR ]; then

	echo "No configuration folder found, creating a new one..."

	mkdir $CONFIG_DIR
	touch ${CONFIG_DIR}/config

	# ls -R is faster than find for this purpose, and automatically
	# excludes hidden folders.
	echo "Trying to find Xilinx in your /opt and user directories..."
	# TODO: testing paths! replace them with the correspondins /opt and ~.
	XILINX_FOUND_OPT=$(ls -R /media/Data/Programs | grep ISE/bin/lin)
	XILINX_FOUND_HOME=$(ls -R /media/Data/Development | grep ISE/bin/lin)

	if [[ -z "$XILINX_FOUND_OPT" && -z "$XILINX_FOUND_HOME" ]]; then
		echo "Couldn't find Xilinx in your system."
		echo "Please, introduce path for the Xilinx installation directory,"
		read -p "(i.e.: /opt/Xilinx/13.3/ISE_DS): "
		while [ ! `readlink -e ${REPLY}/ISE` ]; do
			echo "Incorrect path. Please try again with an absolute path with no trailing '/',"
			read -p "(i.e.: /opt/Xilinx/13.3/ISE_DS): "
		done
		echo XILINX_DIR=$REPLY>> ${CONFIG_DIR}/config
	else
		if [[ ! -z "$XILINX_FOUND_OPT" ]]; then
			echo "Found Xilinx installation in /opt."
			# TODO: write the corresponding path in the config file
		else
			echo "Found Xilinx installation in your user directory."
			# TODO: write the corresponding path in the config file
		fi
	fi

	# TODO: use same procedure as for Xilinx installation path (see above).
	echo "Please, introduce path for the FASTCUDA installation directory (i.e.: /opt/fastcuda):"
	read
	while [ ! `readlink -e ${REPLY}/src` ]; do
		echo "Incorrect path. Please try again with an absolute path with no trailing '/' (i.e.: /opt/fastcuda):"
		read
	done
	echo FC_DIR=$REPLY>> ${CONFIG_DIR}/config
fi


# Get information from the configuration file:
echo "Reading configuration file..."
source ${CONFIG_DIR}/config


# Find Xilinx's TCL native interpreter (depends on the system's
# architecture):
XTCLSH_DIR=${XILINX_DIR}/ISE/bin/lin
if [ `uname -m | grep x86_64` ]; then
	XTCLSH_DIR=${XTCLSH_DIR}64  # lin64 for 64 bits systems
fi


# Run the target TCL file using Xilinx's tclsh
${XTCLSH_DIR}/xtclsh ${FC_DIR}/src/main.tcl $1

