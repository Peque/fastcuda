#
# Main (top-level) routines
#
# run_process
# This procedure is used to run processes on an existing project. You may comment or
# uncomment lines to control which processes are run. This routine is set up to run
# the Implement Design and Generate Programming File processes by default. This proc
# also sets process properties as specified in the "set_process_props" proc. Only
# those properties which have values different from their current settings in the project
# file will be modified in the project.
#

proc run_process {} {

	puts "\nRunning project...\n"

	if { ! [ open_project ] } {
		return false
	}

	set_process_props

	#
	# Remove the comment characters (#'s) to enable the following commands
	# process run "Synthesize"
	# process run "Translate"
	# process run "Map"
	# process run "Place & Route"
	#

	set task "Implement Design"

	if { ! [run_task $task] } {
		puts "$task run failed, check run output for details."
		project close
		return
	}

	set task "Generate Programming File"

	if { ! [run_task $task] } {
		puts "$task run failed, check run output for details."
		project close
		return
	}

	puts "Run completed (successfully)."

	project close

}
