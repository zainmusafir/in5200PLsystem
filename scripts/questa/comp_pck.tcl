#!/usr/bin/tclsh

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

set modelsimini $scripts_path/modelsim.ini

set logfilename $log_path/comp_pck_log.txt
set fileid [open $logfilename "w"]

puts "\r\n------- comp_pck.tcl -------"
puts $fileid "\r\n------- comp_pck.tcl -------"

set mla_lib  $lib_path/mla_lib
set psif_lib $lib_path/psif_lib

set vcom "vcom -2008 -nologo -linedebug +acc=nprv -fsmdebug +cover"

set mla_zedboard_package_path $repo_path/packages/
set mla_zedboard_package_list "zedboard_target_pck.vhd"
# set mla_zedboard_package_list "zedboard_facerecon_target_pck.vhd"

set psif_package_path $repo_path/if/psif/packages/
set psif_package_list "psif_pck.vhd \
                       psif_odi_pck.vhd \
                       psif_dti_pck.vhd \
                       psif_zu_pck.vhd \
                       psif_scu_pck.vhd \
                       psif_aui_pck.vhd"


foreach sourcefile $mla_zedboard_package_list {
    set result [eval exec $vcom -modelsimini $modelsimini -work $mla_lib $mla_zedboard_package_path$sourcefile]
    puts $result
    puts $fileid $result
}

foreach sourcefile $psif_package_list {
    set result [eval exec $vcom -modelsimini $modelsimini -work $psif_lib $psif_package_path$sourcefile]
    puts $result
    puts $fileid $result
}

close $fileid
  
