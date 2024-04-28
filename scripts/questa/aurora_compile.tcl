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

puts "\r\n------- aurora_compile.tcl -------"
puts $fileid "\r\n------- aurora_compile.tcl -------"

set vlog "vlog -timescale 1ns/1ps -L unisim -L unimacro -linedebug -assertdebug +acc=npr +cover"
set vcom "vcom -modelsimini $modelsimini -linedebug -assertdebug +acc=npr +cover"

set result [eval exec vlib $lib_path/questa_lib/work]
puts $result
puts $fileid $result

set result [eval exec vlib $lib_path/questa_lib/msim]
puts $result
puts $fileid $result

set result [eval exec vlib $lib_path/questa_lib/msim/xpm]
puts $result
puts $fileid $result
set result [eval exec vlib $lib_path/questa_lib/msim/gtwizard_ultrascale_v1_7_9]
puts $result
puts $fileid $result
set result [eval exec vlib $lib_path/questa_lib/msim/xil_defaultlib]
puts $result
puts $fileid $result

set result [eval exec vlog -work $lib_path/questa_lib/msim/xpm -64 -sv \
"/projects/robin/programs/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/projects/robin/programs/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv"]
puts $result
puts $fileid $result

set result [eval exec vcom -work $lib_path/questa_lib/msim/xpm -64 -93 \
"/projects/robin/programs/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd"]
puts $result
puts $fileid $result

set result [eval exec vlog -work $lib_path/questa_lib/msim/gtwizard_ultrascale_v1_7_9 -64 \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v"]
puts $result
puts $fileid $result

set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/ip_0/sim/gtwizard_ultrascale_v1_7_gthe4_channel.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/ip_0/sim/aurora_8b10b_0_gt_gthe4_channel_wrapper.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/ip_0/sim/aurora_8b10b_0_gt_gtwizard_gthe4.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/ip_0/sim/aurora_8b10b_0_gt_gtwizard_top.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/ip_0/sim/aurora_8b10b_0_gt.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_reset_logic.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0_core.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_support.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_support_reset_logic.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_clock_module.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_aurora_lane_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_axi_to_ll.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_channel_err_detect.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_channel_init_sm.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_chbond_count_dec_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_crc_top.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_err_detect_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_global_logic.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_hotplug.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_idle_and_ver_gen.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_lane_init_sm_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_left_align_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_left_align_mux.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_ll_to_axi.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_output_mux.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_output_switch_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_rx_ll.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_rx_ll_deframer.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_rx_ll_pdu_datapath.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_rxcrc.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_sideband_output.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_standard_cc_module.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_storage_ce_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_storage_count_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_storage_mux.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_storage_switch_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_sym_dec_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_sym_gen_4byte.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_cdc_sync.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/gt/aurora_8b10b_0_transceiver_wrapper.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_tx_ll.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_tx_ll_control.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_tx_ll_datapath.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_txcrc.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0/src/aurora_8b10b_0_valid_data_counter.v" \
"$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.gen/sources_1/ip/aurora_8b10b_0/aurora_8b10b_0.v"]
puts $result
puts $fileid $result

set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib "$repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/aurora_8b10b_0_ex.ip_user_files/sim_scripts/aurora_8b10b_0/questa/glbl.v"]
puts $result
puts $fileid $result

set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_axi_to_ll_exdes.v]
puts $result
puts $fileid $result
puts $result
puts $fileid $result
set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_ll_to_axi_exdes.v]
puts $result
puts $fileid $result
set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_cdc_sync_exdes.v]
puts $result
puts $fileid $result
set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_frame_gen.v]
puts $result
puts $fileid $result
set result [eval exec vlog -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_frame_check.v]
puts $result
puts $fileid $result
#set result [eval exec vlog +acc=npr -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/ip/zcu106_xczu7ev/aurora_8b10b_0_ex/imports/aurora_8b10b_0_tb.v]             
#puts $result
#puts $fileid $result

set result [eval exec vlog +acc=npr -work $lib_path/questa_lib/msim/xil_defaultlib -64 $repo_path/top/tb/aurora_8b10b_0_exdes_MODIFIED.v]
puts $result
puts $fileid $result
