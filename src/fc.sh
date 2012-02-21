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

# Check if the configuration file exists. If it doesn't exist, create
# the configuration directory and a new configuration file
if [ ! -d $CONFIG_DIR ]; then
	mkdir $CONFIG_DIR
	cd $CONFIG_DIR
	touch config

	echo "Please, introduce path to Xilinx installation (i.e.: /opt/Xilinx/13.3/ISE_DS/):"
	read
	while [ ! `readlink -e $REPLY` ]; do
		echo "Please try again (i.e.: /opt/Xilinx/13.3/ISE_DS/):"
		read
	done
	echo XTCLSH_DIR=$REPLY>> config

	echo "Please, introduce path to FASTCUDA installation (i.e.: /opt/fastcuda/):"
	read
	while [ ! `readlink -e $REPLY` ]; do
		echo "Please try again (i.e.: /opt/fastcuda/):"
		read
	done
	echo FC_DIR=$REPLY>> config
fi


# TODO: this paths should be taken from the configuration file
xtclsh_dir=/media/Data/Programs/Xilinx/13.3/ISE_DS/ISE/bin/lin64
fc_dir=/media/Data/Development/fastcuda


# Go to fastcuda/src/
cd "$fc_dir/src"


# Run the target TCL file using Xilinx's tclsh
$xtclsh_dir/xtclsh ./main.tcl $1

