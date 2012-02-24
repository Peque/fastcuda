#
# create_libraries
#
# This procedure defines VHDL libraries and associates files with those libraries.
# It is expected to be used when recreating the project. Any libraries defined
# when this script was generated are recreated by this procedure.
#
proc create_libraries {} {

	if { ! [ open_project ] } {
		return false
	}

	puts "Creating libraries..."

	# must close the project or library definitions aren't saved.
	project save

}
