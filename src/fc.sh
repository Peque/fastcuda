#!/bin/bash

# TODO: this path should be taken from a configuration file if not
# present in /opt/
xtclsh_dir="/media/Data/Programs/Xilinx/13.3/ISE_DS/ISE/bin/lin64"

# Go to fastcuda/src/
cd `dirname $0`

# Run the target TCL file using Xilinx's tclsh
$xtclsh_dir/xtclsh ./main.tcl $1

