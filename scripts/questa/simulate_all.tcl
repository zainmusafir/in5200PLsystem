#!/usr/bin/tclsh

if { $argc > 2 } {
    puts "Error: Invalid number of arguments"
    puts {Usage: ./simulate_all.tcl <target> [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] || [string match [lindex $argv 1] "-help"]} {
    puts "User must select target equal ZEDBOARD."
    puts {Usage: ./simulate_all.tcl <target> [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 0] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts "User must select target ZEDBOARD."
    puts {Usage: ./simulate_all.tcl <target> [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
}

set case_sim_errors 0

#Paths
set repo_path $::env(MLA_DESIGN)
set sim_path "$repo_path/top/svsim"
set scripts_questa_path "$repo_path/scripts/questa"

set toolsetupfile "$repo_path/scripts/toolsetup.tcl"
# Defines global variable target used in ./toolsetup.tcl script.
set ::target [lindex $argv 0]
set simscript "$scripts_questa_path/simulate.tcl $target"

# puts "Reading toolsetupfile file: $toolsetupfile."
source $toolsetupfile 

#Log file for questa output
set logfilename "questa_all_transcript.log"
set logfileid [open $sim_path/$logfilename "w"]


# Make a list of all simulation test cases.
# Syntax: $simscript <case> <test>
lappend runlist "$simscript case_psif_reg  psif_reg_test"
lappend runlist "$simscript case_psif_ram  psif_ram_test"
lappend runlist "$simscript case_psif_odi_spi  psif_odi_spi_test -hlsmodule AES128"
# Add the test case when lab3 task 3 is complete
#lappend runlist "$simscript TOP ZEDBOARD case_psif_scu psif_scu_test"
# Add these simulation cases after completing the ZU FSM module architecture.
#lappend runlist "$simscript case_psif_zu psif_zu_test -hlsmodule AES128"
#lappend runlist "$simscript case_psif_zu_csim psif_zu_csim_test -hlsmodule AES128"
# Add this simulation for DTI case
# lappend runlist "$simscript case_psif_dti_spi  psif_dti_spi_test -hlsmodule AES128"
# lappend runlist "$simscript case_psif_dti_spi_module  psif_dti_spi_module_test -hlsmodule AES128"
# more simulations ....

# Run all simulations in batch mode
puts "Simulation script log file: $sim_path/$logfilename"
foreach runsim $runlist {
  puts "Run Questa sim: $runsim ........"
  set log [eval exec $runsim]
  puts "Completed Questa sim: $runsim"
  puts $log
  puts $logfileid $log
}

close $logfileid

#Check if successful
set fileid [open $sim_path/$logfilename "r"]
set filedata [read $fileid]
close $fileid

set test [regexp "ERROR:" $filedata]

if {$test == 1} {
    puts "********** ERROR: Testcases finished with errors. **********"
    puts "**********        See log file: $sim_path/$logfilename **********"
} else {
    puts "********** ALL TESTCASES FINISHED SUCCESSFULLY. **********"
}
