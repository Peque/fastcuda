#
# set_project_props
#
# This procedure sets the project properties as they were set in the project
# at the time this script was generated.
#

proc set_project_props {} {

	if { ! [ open_project ] } {
		return false
	}

	puts "Setting project properties..."

	project set family "Spartan6"
	project set device "xc6slx45"
	project set package "csg324"
	project set speed "-3"
	project set top_level_module_type "HDL"
	project set synthesis_tool "XST (VHDL/Verilog)"
	project set simulator "ISim (VHDL/Verilog)"
	project set "Preferred Language" "VHDL"
	project set "Enable Message Filtering" "false"

	puts "Project property values set."

}
