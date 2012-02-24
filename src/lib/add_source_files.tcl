#
# add_source_files
#
# This procedure add the source files that were known to the project at the
# time this script was generated.
#
proc add_source_files {} {

	if { ! [ open_project ] } {
		return false
	}

	puts "Adding sources to project..."

	xfile add "../Desktop/uBlaze_DDR_por_pasos/Recien_creado/Prueba/system.xmp"
	xfile add "../Desktop/uBlaze_DDR_por_pasos/Recien_creado/Prueba/system_top.v"

	# Set the Top Module as well...
	project set top "system_top"

	puts "Project sources reloaded."

}
