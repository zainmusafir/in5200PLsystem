#!/usr/bin/tclsh

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

set modelsimini $scripts_path/modelsim.ini

set logfilename $log_path/comp_core_log.txt
set fileid [open $logfilename "w"]

puts "\r\n------- comp_core.tcl -------"
puts $fileid "\r\n------- comp_core.tcl -------"

set work_lib $lib_path/mla_lib

set vcom "vcom -2008 -nologo -linedebug +acc=nprv -fsmdebug +cover"


# Set module design files
set modules_path $repo_path/
set module_list "core/cru/hdl/cru_ent.vhd \
                 core/cru/hdl/cru_rtl.vhd \
                 core/odi/hdl/ascii_rom.vhd \
                 core/odi/hdl/delay.vhd \
                 core/odi/hdl/oled_ctrl.vhd \
                 core/odi/hdl/oled_ex.vhd \
                 core/odi/hdl/oled_init.vhd \
                 core/odi/hdl/spi_ctrl.vhd \
                 core/odi/hdl/odi_ent.vhd \
                 core/odi/hdl/odi_str.vhd \
                 core/dti/hdl/dti_spi_ent.vhd \
                 core/dti/hdl/dti_spi_dmy.vhd \
                 core/dti/hdl/dti_ent.vhd \
                 core/dti/hdl/dti_str.vhd \
                 core/dti/hdl/spictrl_ent.vhd \
                 core/dti/hdl/spictrl_rtl.vhd \
                 core/zu/hdl/zu_fsm_ent.vhd \
                 core/zu/hdl/zu_fsm_dmy.vhd \
                 core/zu/hdl/zu_ent.vhd \
                 core/zu/hdl/zu_str.vhd \
                 core/scu/hdl/scu_fsm_ent.vhd \
                 core/scu/hdl/scu_fsm_rtl.vhd \
                 core/scu/hdl/scu_edge_regenerator_ent.vhd \
                 core/scu/hdl/scu_edge_regenerator_rtl.vhd \
                 core/scu/hdl/scu_ent.vhd \
                 core/scu/hdl/scu_str.vhd \
                 core/aui/hdl/aui_ent.vhd \
                 core/aui/hdl/aui_aurorarxctrl_ent.vhd \
                 core/aui/hdl/aui_aurorarxctrl_dmy.vhd \
                 core/aui/hdl/aui_auroratxctrl_ent.vhd \
                 core/aui/hdl/aui_auroratxctrl_dmy.vhd \
                 core/aui/hdl/aurora_8b10b_0_dmy.vhd \
                 core/aui/hdl/aui_str.vhd"



# Set core and top design files
# NOTE: Add the dummy processor model before the top design is compiled (i.e. before file top_str.vhd).

#added dummy processor 
set core_path $repo_path/
set core_list "ip/processor_system/zedboard/processor_system_dummy/processor_system_dmy.vhd\
               core/hdl/core_ent.vhd \
               core/hdl/core_str.vhd \
               top/hdl/top_ent.vhd \
               top/hdl/top_str.vhd"

# Compile module design files
foreach sourcefile $module_list {
    set result [eval exec $vcom -modelsimini $modelsimini -work $work_lib $modules_path$sourcefile]
    puts $result
    puts $fileid $result
}

# Compile Core design files
foreach sourcefile $core_list {
    set result [eval exec $vcom -modelsimini $modelsimini -work $work_lib $core_path$sourcefile]
    puts $result
    puts $fileid $result
}

close $fileid
