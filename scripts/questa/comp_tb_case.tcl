#!/usr/bin/tclsh

if { $argc > 3 } {
    puts "Error: Invalid number of arguments"
    puts {Usage: ./comp_tb_case.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP <tb_case> [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] || [string match [lindex $argv 1] "-help"] || [string match [lindex $argv 2] "-help"] || [string match [lindex $argv 3] "-help"] } {
    puts "User must select SETUP_KBAXI4LITE AXI4lite BFM or SETUP_MENTOR_AXI4_QVIP AXI4lite BFM (license required)."
    puts {Usage: ./comp_tb_case.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP <tb_case> | -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 0] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts "User must select target ZEDBOARD."
    puts {Usage: ./comp_tb_case.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP <tb_case> [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 1] "SETUP_KBAXI4LITE"] && ![string match [lindex $argv 1] "SETUP_MENTOR_AXI4_QVIP"] } {
    puts "Error; invalid argument: [lindex $argv 1]"
    puts "User must select SETUP_KBAXI4LITE AXI4lite BFM or SETUP_MENTOR_AXI4_QVIP AXI4lite BFM (license required)."
    puts {Usage: ./comp_tb_case.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP [-help]}
    puts {       <target>: ZEDBOARD} 
    exit 0
} 

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log


set sim_case [lindex $argv 2]

regsub {^case_} $sim_case {} sim_name
set sim_name_pkg ${sim_name}_pkg.sv

if {! [file isdirectory $repo_path/top/svsim/$sim_case]} {
    puts "Directory $repo_path/top/svsim/$sim_case does not exist"
    exit 0
} elseif {! [file isfile $repo_path/top/svsim/$sim_case/$sim_name_pkg]} {
    puts "Required simulation case package file $repo_path/top/svsim/$sim_case/$sim_name_pkg does not exist"
    exit 0
}

set modelsimini $scripts_path/modelsim.ini

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

#create scripts/logs if not exists
file mkdir $log_path

set logfilename "comp_tb_case_log.txt"
set fileid [open $log_path/$logfilename "w"]

puts "------- comp_tb_case_tb.tcl -------"
puts $fileid "------- comp_tb_case_tb.tcl -------"

# Sourcing /scripts/toolsetup.tcl
set toolsetupfile "$repo_path/scripts/toolsetup.tcl"
# Defines global variable target used in ./toolsetup.tcl script.
set ::target [lindex $argv 0]
puts "Reading toolsetupfile file: $toolsetupfile."
puts $fileid "Reading toolsetupfile file: $toolsetupfile."
source $toolsetupfile

#create lib if not exists
file mkdir $lib_path
    
#Libs to be created
set lib_list "tb_mla_lib"

#Create libs
foreach lib $lib_list { 
    if {! [file isdirectory $lib_path/$lib]} {
        puts "Creating library: $lib"
        puts $fileid "Creating library: $lib"
        eval exec vlib $lib_path/$lib
    } else {
        puts "Library $lib already exists"
        puts $fileid "Library $lib already exists"
    }
}

set tb_work_lib $lib_path/tb_mla_lib
set vlog "vlog -timescale 1ns/1ps -L unisim -L unimacro -linedebug -assertdebug +acc=npr +cover -work $tb_work_lib"

set result [eval exec $vlog $repo_path/top/svsim/$sim_case/$sim_name_pkg   +incdir+$repo_path/top/svsim/$sim_case]
puts $result
puts $fileid $result

close $fileid



