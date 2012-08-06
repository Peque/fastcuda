#!/bin/bash

#
#  install.sh
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


XILINX_DIR_TOKEN=/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores
FASTCUDA_DIR_TOKEN=/src/fastcuda.sh


#
# Remove old configuration if it existed and create a new one
#
rm -rf ~/.fastcuda
mkdir $CONFIG_DIR
touch $CONFIG_DIR/config


#
# Find Xilinx installation
#
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
	echo XILINX_DIR=\"$REPLY\">> $CONFIG_DIR/config
else
	if [[ ! -z "$XILINX_FOUND_OPT" ]]; then
		echo "Found Xilinx installation in /opt."
		echo XILINX_DIR=\"${XILINX_FOUND_OPT%%"$XILINX_DIR_TOKEN"*}\">> $CONFIG_DIR/config
	else
		echo "Found Xilinx installation in your user directory."
		echo XILINX_DIR=\"${XILINX_FOUND_HOME%%"$XILINX_DIR_TOKEN"*}\">> $CONFIG_DIR/config
	fi
fi


#
# Find FASTCUDA installation
#
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
	echo FASTCUDA_DIR=\"$REPLY\">> $CONFIG_DIR/config
else
	if [[ ! -z "$FASTCUDA_FOUND_OPT" ]]; then
		echo "Found FASTCUDA installation in /opt."
		echo FASTCUDA_DIR=\"${FASTCUDA_FOUND_OPT%%"$FASTCUDA_DIR_TOKEN"*}\">> $CONFIG_DIR/config
	else
		echo "Found FASTCUDA installation in your user directory."
		echo FASTCUDA_DIR=\"${FASTCUDA_FOUND_HOME%%"$FASTCUDA_DIR_TOKEN"*}\">> $CONFIG_DIR/config
	fi
fi

echo "Configuration file created."


#
# Atlys AXI BSB Support
#
echo "Downloading Atlys AXI BSB Support..."
wget -P $CONFIG_DIR https://www.digilentinc.com/Data/Products/ATLYS/Atlys_BSB_Support_v_3_4.zip
echo "Extracting Atlys BSB Support..."
unzip -d $CONFIG_DIR $CONFIG_DIR/Atlys_BSB_Support_v_3_4.zip
echo "Saving Atlys BSB Support..."
mv $CONFIG_DIR/Atlys_BSB_Support_v_3_4/Atlys_AXI_BSB_Support/ $CONFIG_DIR
echo "Cleaning files..."
rm -rf $CONFIG_DIR/Atlys_BSB_Support_v_3_4/
rm $CONFIG_DIR/Atlys_BSB_Support_v_3_4.zip

#
# Installation complete
#
echo "Installation complete!"
