#!/usr/bin/tclsh

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set modelsimini $scripts_path/modelsim.ini

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

set logfilename $log_path/comp_tb_log.txt
set fileid [open $logfilename "w"]

puts "\r\n------- comp_tb.tcl -------"
puts $fileid "\r\n------- comp_tb.tcl -------"

set tb_work_lib $lib_path/tb_mla_lib
set vcom "vcom -modelsimini $modelsimini -linedebug -assertdebug +acc=npr +cover -work $tb_work_lib"
set vlog "vlog -timescale 1ns/1ps -L unisim -L unimacro -linedebug -assertdebug +acc=npr +cover -work $tb_work_lib"

# Local 
# set tb_ip_path $repo_path/ip/
# set tb_ip_vhdl_list "xxxxxxxx.vhd"

# foreach sourcefile $tb_ip_vhdl_list {
#     set result [eval exec $vcom $tb_ip_path$sourcefile]
#     puts $result
#     puts $fileid $result
# }

set tb_csv_path $repo_path/if/
set tb_csv_list "psif/tb/csvFiles/top_psif_vreguvm_pkg_uvm.sv \
                 psif/tb/csvFiles/top_psif_vreguvm_pkg_uvm_rw.sv"

foreach sourcefile $tb_csv_list {
    set result [eval exec $vlog $tb_csv_path$sourcefile]
    puts $result
    puts $fileid $result
}

# Compile reset agent interface
set tb_path $repo_path/
set tb_list "vip/reset_agent/reset_agent_if.sv"

foreach sourcefile $tb_list {
    set result [eval exec $vlog $tb_path$sourcefile]
    puts $result
    puts $fileid $result
}

# Compile reset agent
set result [eval exec $vlog $repo_path/vip/reset_agent/reset_agent_pkg.sv +incdir+$repo_path/vip/reset_agent]
puts $result
puts $fileid $result


set tb_path $repo_path/
# set tb_list "vip/interrupt_handler_agent/interrupt_if.sv"

# foreach sourcefile $tb_list {
#     set result [eval exec $vlog $tb_path$sourcefile]
#     puts $result
#     puts $fileid $result
# }

# # Compile interrupt handler
# set result [eval exec $vlog $repo_path/vip/interrupt_handler_agent/interrupt_handler_pkg.sv +incdir+$repo_path/vip/interrupt_handler_agent]
# puts $result
# puts $fileid $result


puts "--> Compiling SETUP_KBAXI4LITE  <--"
puts $fileid "--> Compiling SETUP_KBAXI4LITE  <--"

set result [eval exec $vlog $repo_path/vip/kb_axi4lite_agent/typedef_pkg.sv]
puts $result
puts $fileid $result
set result [eval exec $vlog $repo_path/vip/kb_axi4lite_agent/kb_axi4lite_agent_if.sv]
puts $result
puts $fileid $result
set result [eval exec $vlog $repo_path/vip/kb_axi4lite_agent/kb_axi4lite_agent_pkg.sv +incdir+$repo_path/vip/kb_axi4lite_agent]
puts $result
puts $fileid $result

puts "--> Compiling SETUP_KBAXI4STREAM  <--"
puts $fileid "--> Compiling SETUP_KBAXI4STREAM  <--"

set result [eval exec $vlog $repo_path/vip/kb_axi4stream_agent/kb_axi4stream_typedef_pkg.sv]
puts $result
puts $fileid $result
set result [eval exec $vlog $repo_path/vip/kb_axi4stream_agent/kb_axi4stream_agent_if.sv]
puts $result
puts $fileid $result
set result [eval exec $vlog $repo_path/vip/kb_axi4stream_agent/kb_axi4stream_agent_pkg.sv +incdir+$repo_path/vip/kb_axi4stream_agent]
puts $result
puts $fileid $result


# Compile oled_spi agent interface
set tb_path $repo_path/
set tb_list "vip/oled_spi_agent/oled_spi_agent_if.sv"

foreach sourcefile $tb_list {
    set result [eval exec $vlog $tb_path$sourcefile]
    puts $result
    puts $fileid $result
}

# Compile oled_spi agent
set result [eval exec $vlog $repo_path/vip/oled_spi_agent/oled_spi_agent_pkg.sv +incdir+$repo_path/vip/oled_spi_agent]
puts $result
puts $fileid $result

# Compile spi_4wire agent interface
# set tb_path $repo_path/
# set tb_list "vip/spi_4wire_agent/spi_4wire_agent_if.sv"

# foreach sourcefile $tb_list {
#     set result [eval exec $vlog $tb_path$sourcefile]
#     puts $result
#     puts $fileid $result
# }

# Compile spi_4wire agent
# set result [eval exec $vlog $repo_path/vip/spi_4wire_agent/spi_4wire_agent_pkg.sv +incdir+$repo_path/vip/spi_4wire_agent]
# puts $result
# puts $fileid $result


puts "--> Compiling testbench probes  <--"

set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/probe_pkg.sv      +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result

puts "--> Compiling testbench  <--"
puts $fileid "--> Compiling testbench  <--"

# Compile C functions
# set result [eval exec $vlog +define+$::setup_value $repo_path/ip/hls2/AES-vivado/src/aes.c -dpiheader $repo_path/ip/hls2/AES-vivado/src/aes.h]
# puts $result
# puts $fileid $result

# Compile bind statement
set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_core_odi_oled_ctrl_bind.sv -mfcu -cuname tb_top_core_odi_oled_ctrl_bind]
puts $result
puts $fileid $result
# set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_core_dti_dti_spi_bind.sv -mfcu -cuname tb_top_core_dti_dti_spi_bind]
# puts $result
# puts $fileid $result
# set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_core_dti_bind.sv -mfcu -cuname tb_top_core_dti_bind]
# puts $result
# puts $fileid $result
set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_top_core_zu_aes128_bind.sv -mfcu -cuname tb_top_core_zu_aes128_bind]
puts $result
puts $fileid $result

# Compile testbench environment and base packages
set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/axi4params_pkg.sv  +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result

set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/tb_env_base_pkg.sv  +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result

set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb/tb_env_pkg.sv         +incdir+$repo_path/top/tb]
puts $result
puts $fileid $result

set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/base_test_pkg.sv  +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result
set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/base_seq_pkg.sv   +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result

set result [eval exec $vlog +define+$::setup_value $repo_path/top/tb_base/probe_pkg.sv      +incdir+$repo_path/top/tb_base]
puts $result
puts $fileid $result

close $fileid
