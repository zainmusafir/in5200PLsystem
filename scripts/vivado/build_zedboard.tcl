# Vivado build script for MLA on ZEDBOARD testboard

puts "Setting up design"

#Path to repo
set repo_path $::env(MLA_DESIGN)

# Create output directories

# set output_dir
set output_dir [lindex $argv 0]
file mkdir $output_dir/reports
file mkdir $output_dir/checkpoints
file mkdir $output_dir/progfiles
file mkdir $output_dir/projects

# Defines global variable target used in sources.tcl and zedboard_ip_sources.tcl scripts.
set ::psmodule [lindex $argv 2]

set part_used xc7z020clg484-1
set board_used em.avnet.com:zed:part0:1.4
# set board_used em.avnet.com:zynq:zed:d

create_project -in_memory -part $part_used

# Set design parameters and create project
set_property PART $part_used [current_project]
set_property BOARD_PART $board_used [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]

# Checking board settings
report_property -all [current_project]

# Read all source files
source $repo_path/scripts/vivado/sources.tcl

# # Read all ZEDBOARD Xilinx IP, BD and constraints source files
source $repo_path/scripts/vivado/zedboard_ip_sources.tcl

# Run synthesis, write checkpoint and write post synth reports 
puts "Running synthesis and writing checkpoint and reports"
synth_design -generic TARGET=ZEDBOARD -top top -flatten rebuilt
# Write synthesis checkpoint
write_checkpoint -force $output_dir/checkpoints/post_synth_checkpoint.dcp
# Write synthesis reports
report_utilization -file $output_dir/reports/post_synth_utilization.rpt
report_timing -sort_by group -max_paths 5 -path_type summary -file $output_dir/reports/post_synth_timing.rpt
report_timing_summary -file $output_dir/reports/post_synth_timing_summary.rpt

# Write project
save_project_as -scan_for_includes -force mla_zedboard_synth $output_dir/projects

# Optimize, place design, write checkpoint and write post placement reports
puts "Running placement and writing checkpoint and reports"
opt_design
# power_opt_design; # Removed due to implementation area problems ...
place_ports
place_design -directive AltSpreadLogic_high
phys_opt_design -directive AggressiveExplore
# Write post place checkpoint
write_checkpoint -force $output_dir/checkpoints/post_place_checkpoint.dcp
# Write post place reports
report_utilization -file $output_dir/reports/post_place_utilization.rpt
report_timing -sort_by group -max_paths 5 -path_type summary -file $output_dir/reports/post_place_timing.rpt
report_timing_summary -file $output_dir/reports/post_place_timing_summary.rpt

# Route design, write checkpoint and write post routing reports 
puts "Running routing and writing checkpoint and reports"
route_design -directive AlternateCLBRouting ; # ONLY ULTRASCALE DEVICES??
# Write post route checkpoint
write_checkpoint -force $output_dir/checkpoints/post_route_checkpoint.dcp
# Write post route reports
report_utilization -file $output_dir/reports/post_route_utilization.rpt
report_timing -sort_by group -max_paths 5 -path_type summary -file $output_dir/reports/post_route_timing.rpt
report_timing_summary -warn_on_violation -file $output_dir/reports/post_route_timing_summary.rpt
report_clock_utilization -file $output_dir/reports/post_route_clock_utilization.rpt
report_drc -file $output_dir/reports/post_route_drc.rpt
report_power -file $output_dir/reports/post_route_power.rpt
report_clock_interaction -delay_type min_max -significant_digits 3 -name timing_2  -file $output_dir/reports/post_route_clock_interaction.rpt

# Write project
save_project_as -scan_for_includes -force mla_zedboard_routed $output_dir/projects

# Write the bitstream to file
puts "Writing bitstream."
write_bitstream -force $output_dir/progfiles/top_mla_zedboard.bit

# Write the ILA debug probes to file
puts "Writing ILA debug probes."
write_debug_probes -force $output_dir/progfiles/top_mla_zedboard_ila_debug_probes.ltx

# Write sysdef definition files
puts "Writing system definition. Closing design and opening routed checkpoint design."
close_design
open_checkpoint $output_dir/checkpoints/post_route_checkpoint.dcp 
write_hw_platform -fixed -force -include_bit $output_dir/progfiles/top_mla_zedboard.xsa

puts "Syntesis and P&R done."
