proc open_project {} {

   global myScript
   global myProject

   if { ! [ file exists ${myProject}.xise ] } {
      ## project file isn't there, rebuild it.
      puts "Project $myProject not found. Use project_rebuild to recreate it."
      return false
   }

   project open $myProject

   return true

}
