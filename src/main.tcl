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
# Get self information, so we can properly load libraries:
#
set main_script [file normalize [info script]]
set main_script_dir [file dirname $main_script]
set main_script_name [file tail $main_script]

#
# Library path:
#
set lib_dir $main_script_dir/lib

#
# Includes:
#
source $lib_dir/run_task.tcl
source $lib_dir/run_process.tcl
source $lib_dir/set_project_props.tcl
source $lib_dir/set_process_props.tcl
source $lib_dir/create_libraries.tcl
source $lib_dir/rebuild_project.tcl
source $lib_dir/open_project.tcl
source $lib_dir/add_source_files.tcl
source $lib_dir/main.tcl

#
# Target file for building the project:
#
set target_project_dir [file normalize [lindex $::argv 0]]

#
# Avoid "not found" issues...
#
cd [file dirname $target_project_dir]

#
# Change argv for the following script, as we are using the source
# command which we can't use with any parameters except for the file
# itself...
#
# See lib/main.tcl for valid argv parameters.
#
set argv {rebuild_project}

set myProject "fastcuda_project"
set myScript "fastcuda_project.tcl"

#
# Running the target script:
#
if { [catch { main } result] } {
	puts "$myScript failed: $result."
}
