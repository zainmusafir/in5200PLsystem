#!/usr/bin/tclsh

if { $argc == 0  || $argc > 2 } {
    puts "Error: Invalid number of arguments: $argc"
    puts {Usage: ./comp_all_design.tcl <target> -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] } {
    puts {Usage: ./comp_all_design.tcl <target> -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 0] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts "User must select target ZEDBOARD."
    puts {Usage: ./comp_all_design.tcl <target> -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { $argc == 2 && ![string match [lindex $argv 0] "-help"] } {
    puts "Error; invalid argument: [lindex $argv 1]"
    puts {Usage: ./comp_all_design.tcl <target> -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
}

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

#create scripts/logs if not exists
file mkdir $log_path

set logfilename "comp_all_design_log.txt"
set fileid [open $log_path/$logfilename "w"]

puts "------- comp_all_design.tcl -------"
puts $fileid "------- comp_all_design.tcl -------"

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
set lib_list "psif_lib
              mla_lib"

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

close $fileid

#Source compile scripts
source $scripts_path/comp_pck.tcl
source $scripts_path/comp_ip.tcl
source $scripts_path/comp_core.tcl



