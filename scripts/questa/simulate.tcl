#!/usr/bin/tclsh

if { $argc > 11 } {
    puts "Error: Invalid number of arguments"
    #  Argument number             0           1          2        3      4        4       3 eller 5       4 eller 6                                                                  3/5/7    4/6/8   3/5/7/9  0-10      
    puts {Usage: ./simulate.tcl <target> <test case> <sequence> [-seed <value> | random] [-verbosity UVM_NONE | UVM_LOW | UVM_MEDIUM (default) | UVM_HIGH | UVM_FULL | UVM_DEBUG] [-hlsmodule <value>] [-gui] [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] || [string match [lindex $argv 1] "-help"] || [string match [lindex $argv 2] "-help"] || [string match [lindex $argv 3] "-help"] || [string match [lindex $argv 4] "-help"] || [string match [lindex $argv 5] "-help"] || [string match [lindex $argv 6] "-help"] || [string match [lindex $argv 7] "-help"] || [string match [lindex $argv 8] "-help"] || [string match [lindex $argv 9] "-help"] || [string match [lindex $argv 10] "-help"] } {
    puts "User must select target equal ZEDBOARD and test case with sequence."
    puts {Usage: ./simulate.tcl <target> <test case> <sequence> [-seed <value> | random] [-verbosity [-verbosity UVM_NONE | UVM_LOW | UVM_MEDIUM (default) | UVM_HIGH | UVM_FULL | UVM_DEBUG]] [-hlsmodule <value>] [-gui] [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 0] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts "User must select target ZEDBOARD"
    puts {Usage: ./simulate.tcl <target> <test case> <sequence> [-seed <value> | random] [-verbosity [-verbosity UVM_NONE | UVM_LOW | UVM_MEDIUM (default) | UVM_HIGH | UVM_FULL | UVM_DEBUG]] [-hlsmodule <value>] [-gui] [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
}

#Paths
set repo_path $::env(MLA_DESIGN)
set sim_path "$repo_path/top/svsim"
set scripts_questa_path "$repo_path/scripts/questa"

set toolsetupfile "$repo_path/scripts/toolsetup.tcl"
# Defines global variable target used in ./toolsetup.tcl script.
set ::target [lindex $argv 0]
# puts "Reading toolsetupfile file: $toolsetupfile."
source $toolsetupfile 

set simcase [lindex $argv 1]
set testseq [lindex $argv 2]

if {[string match [lindex $argv 3] "-seed"]} {
    set seed_value [lindex $argv 4]
} elseif {[string match [lindex $argv 5] "-seed"]} {
    set seed_value [lindex $argv 6]
} else {
    set seed_value 42
}

if {[string match [lindex $argv 3] "-verbosity"]} {
  if {[string match [lindex $argv 4] "UVM_NONE"] || [string match [lindex $argv 4] "UVM_LOW"] || [string match [lindex $argv 4] "UVM_MEDIUM"] || [string match [lindex $argv 4] "UVM_HIGH"] || [string match [lindex $argv 4] "UVM_FULL"] || [string match [lindex $argv 4] "UVM_DEBUG"]} {
    set uvm_verbosity_value [lindex $argv 4]
  } else {
    puts "Error: Invalid -verbosity argument: [lindex $argv 4]"
    puts {Usage: ./simulate.tcl <module> <target> <test case> <sequence> [-seed <value> | random] [-verbosity [-verbosity UVM_NONE | UVM_LOW | UVM_MEDIUM (default) | UVM_HIGH | UVM_FULL | UVM_DEBUG]] [-hlsmodule <value>] [-gui] [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0   
  } 
} elseif {[string match [lindex $argv 5] "-verbosity"]} {
  if {[string match [lindex $argv 6] "UVM_NONE"] || [string match [lindex $argv 6] "UVM_LOW"] || [string match [lindex $argv 6] "UVM_MEDIUM"] || [string match [lindex $argv 6] "UVM_HIGH"] || [string match [lindex $argv 6] "UVM_FULL"] || [string match [lindex $argv 6] "UVM_DEBUG"]} {
    set uvm_verbosity_value [lindex $argv 6]
  } else {
    puts "Error: Invalid -verbosity argument: [lindex $argv 6]"
    puts {Usage: ./simulate.tcl <module> <target> <test case> <sequence> [-seed <value> | random] [-verbosity [-verbosity UVM_NONE | UVM_LOW | UVM_MEDIUM (default) | UVM_HIGH | UVM_FULL | UVM_DEBUG]] [-hlsmodule <value>] [-gui] [-help]}
    puts {       <module>: TOP or DTI_SPI} 
    puts {       <target>: ZEDBOARD} 
    exit 0   
  } 
} else {
    set uvm_verbosity_value UVM_MEDIUM
}

if {[string match [lindex $argv 3] "-hlsmodule"] || [string match [lindex $argv 5] "-hlsmodule"] || [string match [lindex $argv 7] "-hlsmodule"]} {
    if {[string match [lindex $argv 3] "-hlsmodule"]} {
      set hlsmodule_value [lindex $argv 4]
    } elseif {[string match [lindex $argv 5] "-hlsmodule"]} {
      set hlsmodule_value [lindex $argv 6]
    } elseif {[string match [lindex $argv 7] "-hlsmodule"]} { 
      set hlsmodule_value [lindex $argv 8]
    } else {
      # Default value set til AES128
      set hlsmodule_value AES128  
    }
} else {
  # Default value set til AES128
  set hlsmodule_value AES128
}


set dofile "run.do"
set dofile_gui "run_gui.do" ; # Runs the simulator 0 ns to build the UVM testbench in GUI mode
 
# Note: Remember to update scripts/questa/run.do file if vsim options list is changed 
#       due to code coverage reporting in .sim directory
set vsim "vsim -lib tb_mla_lib \
               -L unisim \
               -L unimacro \
               -L mla_lib \
               -autoexclusionsdisable=fsm \
               -fsmdebug \
               -assertdebug \
               +notimingchecks \
               -printsimstats \
               -msgmode both \
               -modelsimini $repo_path/scripts/questa/modelsim.ini \
               -coverage \
               -t ps \
               -classdebug \
               -uvmcontrol=all,certe \
               +UVM_MAX_QUIT_COUNT=11 \
               -scdpidebug \
               -G HLSMODULE=$hlsmodule_value \
               -G TARGET=[lindex $argv 0]"

# Must be added to vsim command above for Aurora IP simulation
#               -L xpm \
#               -L gtwizard_ultrascale_v1_7_9 \
#               -L xil_defaultlib \


#Log file for questa output
eval file delete -force -- $sim_path/$simcase/$testseq.sim
file mkdir $sim_path/$simcase/$testseq.sim
set logfilename "questa_transcript.log"
set fileid [open $sim_path/$simcase/$testseq.sim/$logfilename "w"]

# Set simulation directory
cd $sim_path/$simcase/$testseq.sim

if {[string match [lindex $argv 3] "-gui"] || [string match [lindex $argv 5] "-gui"] || [string match [lindex $argv 7] "-gui"] || [string match [lindex $argv 9] "-gui"]} {
  puts "Simulating case: $simcase with test sequence: $testseq"
  puts $fileid "Simulating case: $simcase with test sequence: $testseq"
  puts "----- Simulation started in GUI mode -----"
  puts "Simulation script log file: $sim_path/$simcase/$testseq.sim/$logfilename"
  puts $fileid "Simulation script log file: $sim_path/$simcase/$testseq.sim/$logfilename"
  set log [eval exec $vsim -onfinish stop -sv_seed $seed_value +UVM_VERBOSITY=$uvm_verbosity_value -voptargs="+acc=v" +uvm_set_action="*,_ALL_,UVM_ERROR,UVM_DISPLAY|UVM_STOP" -gui +UVM_TESTNAME=$testseq -do $scripts_questa_path/$dofile_gui tb_top &]
#  puts $log
  puts $fileid $log
 
} else {

  puts "Batch mode simulation case: $simcase with test sequence: $testseq"
  puts $fileid "Batch mode simulation case: $simcase with test sequence: $testseq"
  puts "Simulation script log file: $sim_path/$simcase/$testseq.sim/$logfilename"
  puts $fileid "Simulation script log file: $sim_path/$simcase/$testseq.sim/$logfilename"
  if { [file exist $sim_path/$simcase/$testseq.sim/$dofile] } {
    set log [eval exec $vsim -onfinish stop -sv_seed $seed_value +UVM_VERBOSITY=$uvm_verbosity_value -voptargs="+acc=v" +uvm_set_action="*,_ALL_,UVM_ERROR,UVM_DISPLAY|UVM_STOP" +UVM_TESTNAME=$testseq -c -do $sim_path/$simcase/$testseq.sim/$dofile tb_top]
    puts "Simulation of $testseq done"
  } else {
    set log [eval exec $vsim -onfinish stop -sv_seed $seed_value +UVM_VERBOSITY=$uvm_verbosity_value -voptargs="+acc=v" +uvm_set_action="*,_ALL_,UVM_ERROR,UVM_DISPLAY|UVM_STOP" +UVM_TESTNAME=$testseq -c -do $scripts_questa_path/$dofile tb_top]
    puts "Simulation of $testseq done"
  }
  #  puts $log
  puts $fileid $log 

  if { [file exist $sim_path/$simcase/$testseq.sim/$testseq\_error.log] } {

    set fileid_errorlog [open $sim_path/$simcase/$testseq.sim/$testseq\_error.log "r"]
    set errorlog_filesize [file size $sim_path/$simcase/$testseq.sim/$testseq\_error.log]  
    close $fileid_errorlog

    if {$errorlog_filesize == 0} {
      puts "Simulation case: $simcase with test sequence: $testseq FINISHED SUCCESSFULLY."
      puts $fileid "Simulation case: $simcase with test sequence: $testseq FINISHED SUCCESSFULLY."
      puts "Simulation log file: $sim_path/$simcase/$testseq.sim/$testseq.log"
      puts $fileid "Simulation log file: $sim_path/$simcase/$testseq.sim/$testseq.log"
    } else {
      puts "ERROR: Simulation case: $simcase with test sequence: $testseq error log file is not empty. PLEASE CHECK ERROR LOG FILE."
      puts $fileid "ERROR: Simulation case: $simcase with test sequence: $testseq error log file is not empty. PLEASE CHECK ERROR LOG FILE."
      puts "Simulation log file without errors: $sim_path/$simcase/$testseq.sim/$testseq.log"
      puts $fileid "Simulation log file without errors: $sim_path/$simcase/$testseq.sim/$testseq.log"
      puts "ERROR log file: $sim_path/$simcase/$testseq.sim/$testseq\_error.log"
      puts $fileid "ERROR log file: $sim_path/$simcase/$testseq.sim/$testseq\_error.log"
    }
  } else {
    puts "Missing log file: $sim_path/$simcase/$testseq.sim/$testseq\_error.log; PLEASE CHECK SIMULATION!"
    puts $fileid "Missing log file: $sim_path/$simcase/$testseq.sim/$testseq\_error.log; PLEASE CHECK SIMULATION!"
  }
}

close $fileid




