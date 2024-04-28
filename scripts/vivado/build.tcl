#!/usr/bin/tclsh

if { $argc > 4 } {
    puts "Error: Invalid number of arguments"
    puts {Usage: ./build.tcl <target> | <psmodule> | -help [-version version]}
    puts {       <target>: ZEDBOARD } 
    puts {       <psmodule>: SIMPLE | FACERECON } 
    exit 0
} elseif { [string match [lindex $argv 0] "-help"] || [string match [lindex $argv 1] "-help"] || [string match [lindex $argv 2] "-help"] || [string match [lindex $argv 3] "-help"]} {
    puts "User select ZEDBOARD design"
    puts {Usage: ./build.tcl <target> | <psmodule> | -help [-version version]}
    puts {       <target>: ZEDBOARD } 
    puts {       <psmodule>: SIMPLE | FACERECON } 
    exit 0
} elseif { !([string match [lindex $argv 0] "ZEDBOARD"]) } {
    puts "Error; invalid argument: [lindex $argv 0]"
    puts {Usage: ./build.tcl <target> | <psmodule> | -help [-version version]}
    puts {       <target>: ZEDBOARD } 
    puts {       <psmodule>: SIMPLE | FACERECON } 
    exit 0
} elseif { !([string match [lindex $argv 1] "SIMPLE"] || [string match [lindex $argv 1] "FACERECON"]) } {
    puts "Error; invalid argument: [lindex $argv 1]"
    puts {Usage: ./build.tcl <target> | <psmodule> | -help [-version version]}
    puts {       <target>: ZEDBOARD } 
    puts {       <psmodule>: SIMPLE | FACERECON } 
    exit 0
} elseif { ![string match [lindex $argv 2] "-version"] } {
    puts "Warning; Missing build version. Build version suppressed."
    set build_version "default"
} elseif { [string match [lindex $argv 2] "-version"] && [expr $argc < 4] } {
    puts "Warning; Missing build version name. Build version suppressed."
    set build_version "default"
} else {
    set build_version [lindex $argv 3]
}

puts "MLA building started."

set repo_path $::env(MLA_DESIGN)

# Set tool setup path /scripts/toolsetup.tcl
set toolsetupfile "$repo_path/scripts/toolsetup.tcl"

# Defines global variables used in ./toolsetup.tcl and sources.tcl scripts.
set ::target [lindex $argv 0]
set ::psmodule [lindex $argv 1]

puts "Reading toolsetupfile file: $toolsetupfile."
source $toolsetupfile

# Build script for MLA
if {$argc > 0} {
    if {[lindex $argv 0] == "ZEDBOARD"} {

        puts "Building started for ZEDBOARD board."

        set pr_dir "$repo_path/top/pr/non_project_mode/zedboard"
        file mkdir $pr_dir

        set logfilename zedboard_build.log

        cd $pr_dir
        if { [string match $build_version "default"] } {
          set output_dir $pr_dir/zedboard_build
        } else {
          set output_dir $pr_dir/zedboard_build_$build_version
        }
        file mkdir $output_dir
        set build_log_dir "$output_dir/build_logs"
        file mkdir $build_log_dir
        set fileid [open $build_log_dir/$logfilename w]
        puts $fileid "Reading toolsetupfile file: $toolsetupfile."

        puts "Building ZEDBOARD in directory: $output_dir"
        puts "Vivado vivado.log and vivado.jou files in: $build_log_dir"
        puts "Log file in: $build_log_dir/$logfilename"
        # Using -stack 2000 option to avoid segmentation error; see Xilinx AR#64434
        set result [eval exec vivado -stack 2000 -log $build_log_dir/vivado.log -journal $build_log_dir/vivado.jou -mode batch -source $repo_path/scripts/vivado/build_zedboard.tcl -tclargs $output_dir $target $psmodule]
        puts $fileid $result
        close $fileid

    } else {
 
       puts "Only ZEDBOARD currently allowed!"

    }    

} 

puts "Finished Building."
