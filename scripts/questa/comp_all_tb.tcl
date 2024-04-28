#!/usr/bin/tclsh

if { $argc > 3 } {
    puts "Error: Invalid number of arguments"
    puts {Usage: ./comp_all_tb.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP | -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] || [string match [lindex $argv 1] "-help"] || [string match [lindex $argv 2] "-help"] || [string match [lindex $argv 3] "-help"]} {
    puts "User must select SETUP_KBAXI4LITE AXI4lite BFM or SETUP_MENTOR_AXI4_QVIP AXI4lite BFM (license required)."
    puts {Usage: ./comp_all_tb.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP | -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 0] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts "User must select target ZEDBOARD."
    puts {Usage: ./comp_all_tb.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP | -help}
    puts {       <target>: ZEDBOARD} 
    exit 0
} elseif { ![string match [lindex $argv 1] "SETUP_KBAXI4LITE"] && ![string match [lindex $argv 1] "SETUP_MENTOR_AXI4_QVIP"] } {
    puts "Error; invalid argument: [lindex $argv 1]"
    puts "User must select SETUP_KBAXI4LITE AXI4lite BFM or SETUP_MENTOR_AXI4_QVIP AXI4lite BFM (license required)."
    puts {Usage: ./comp_all_tb.tcl <target> SETUP_KBAXI4LITE | SETUP_MENTOR_AXI4_QVIP | -help}
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

set logfilename "comp_all_tb_log.txt"
set fileid [open $log_path/$logfilename "w"]

puts "------- comp_all_tb_tb.tcl -------"
puts $fileid "------- comp_all_tb_tb.tcl -------"

# Sourcing /scripts/toolsetup.tcl
set toolsetupfile "$repo_path/scripts/toolsetup.tcl"
# Defines global variable target used in ./toolsetup.tcl script.
set ::target [lindex $argv 0]
puts "Reading toolsetupfile file: $toolsetupfile."
puts $fileid "Reading toolsetupfile file: $toolsetupfile."
source $toolsetupfile

#create lib directory if not exists
file mkdir $lib_path
# Define Aurora lib directory if not exists
file mkdir $lib_path/questa_lib
    

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

close $fileid

source $scripts_path/comp_wizgen_if.tcl
# Defines global variable used in comp_tb.tcl and comp_tbseq.tcl scripts.
set ::setup_value [lindex $argv 1]
# source $scripts_path/aurora_compile.tcl
source $scripts_path/comp_tb.tcl
source $scripts_path/comp_tbseq.tcl



