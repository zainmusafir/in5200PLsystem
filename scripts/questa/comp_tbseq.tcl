#!/usr/bin/tclsh

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set modelsimini $scripts_path/modelsim.ini

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

set logfilename $log_path/comp_tbseq_log.txt
set fileid [open $logfilename "w"]

puts "\r\n------- comp_tbseq.tcl -------"
puts $fileid "\r\n------- comp_tbseq.tcl -------"

set tb_work_lib $lib_path/tb_mla_lib

set vlog "vlog -timescale 1ns/1ps -L unisim -L unimacro -linedebug -assertdebug +acc=npr +cover -work $tb_work_lib"

# Compile bind statement
# set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_core_odi_oled_ctrl_bind.sv -mfcu -cuname tb_top_core_odi_oled_ctrl_bind]
# puts $result
# puts $fileid $result

# Compile basic register, ram and interrupt handler test cases
set result [eval exec $vlog $repo_path/top/svsim/case_psif_reg/psif_reg_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_reg]
puts $result
puts $fileid $result

set result [eval exec $vlog $repo_path/top/svsim/case_psif_ram/psif_ram_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_ram]
puts $result
puts $fileid $result

# Compile functional test cases
set result [eval exec $vlog $repo_path/top/svsim/case_psif_odi_spi/psif_odi_spi_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_odi_spi]
puts $result
puts $fileid $result

 set result [eval exec $vlog $repo_path/top/svsim/case_psif_scu/psif_scu_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_scu]
 puts $result
 puts $fileid $result

set result [eval exec $vlog $repo_path/top/svsim/case_psif_dti_spi_loop/psif_dti_spi_loop_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_dti_spi_loop]
puts $result
puts $fileid $result

# set result [eval exec $vlog $repo_path/top/svsim/case_psif_dti_spi/psif_dti_spi_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_dti_spi]
# puts $result
# puts $fileid $result

# set result [eval exec $vlog $repo_path/top/svsim/case_psif_dti_spi_module/psif_dti_spi_module_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_dti_spi_module]
# puts $result
# puts $fileid $result

set result [eval exec $vlog $repo_path/top/svsim/case_psif_zu/psif_zu_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_zu]
puts $result
puts $fileid $result

set result [eval exec $vlog $repo_path/top/svsim/case_psif_zu_csim/psif_zu_csim_pkg.sv   +incdir+$repo_path/top/svsim/case_psif_zu_csim]
puts $result
puts $fileid $result

# Compile test benches; both tb_core and tb_top
set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_beh.sv   +incdir+$repo_path/top/tb]
puts $result
puts $fileid $result

close $fileid
