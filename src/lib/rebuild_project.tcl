#
# rebuild_project
#
# This procedure renames the project file (if it exists) and recreates the project.
# It then sets project properties and adds project sources as specified by the
# set_project_props and add_source_files support procs. It recreates VHDL Libraries
# as they existed at the time this script was generated.
#
# It then calls run_process to set process properties and run selected processes.
#
proc rebuild_project {} {

	global myScript
	global myProject

	project close
	## put out a 'heartbeat' - so we know something's happening.
	puts "\n$myScript: Rebuilding ($myProject)...\n"

	set proj_exts [ list ise xise gise ]
	foreach ext $proj_exts {
		set proj_name "${myProject}.$ext"
		if { [ file exists $proj_name ] } {
			file delete $proj_name
		}
	}

	project new $myProject
	set_project_props
	add_source_files
	create_libraries
	puts "$myScript: project rebuild completed."

	run_process

}
