#
# Run a process task.
#
# See the Development System Reference Guide for a complete list of all
# the process tasks.
#
# param[in] task The process task you want to run.
# return True in case of success; false otherwise.
#

proc run_task { task } {

	puts "Running '$task'"

	set result [ process run "$task" ]
	set status [ process get $task status ]

	if { (($status != "up_to_date") && ($status != "warnings")) || !$result } {
		return false
	}

	return true

}
