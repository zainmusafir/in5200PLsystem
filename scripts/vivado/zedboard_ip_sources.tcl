#!/usr/bin/tclsh

puts stdout "Reading MLA ZEDBOARD Zynq 7020 IPs, Block Design (BD) design files and constraint files ..."

#Path to repo
set repo_path $::env(MLA_DESIGN)

# Set VHDL as default for IP generation
set_property target_language VHDL [current_project]

# Read Xilinx IPs as Out-Of-Context design files
set xilinx_ip_path $repo_path/ip/zedboard_xc7z020/
set xilinx_ip_list "clk_wiz_0/clk_wiz_0.xci \
                    fifo_512x32bit/fifo_512x32bit.xci \
                    fifo_512x16bit/fifo_512x16bit.xci \
                    fifo_512x8bit/fifo_512x8bit.xci \
                    bram_truedualport_512x32bit/bram_truedualport_512x32bit.xci"


# Read Zynq PS as Global Block Design (i.e. .bd file)

if {$::psmodule=="SIMPLE"} {
  # Simple processor
  set bd_path_simple $repo_path/ip/processor_system/zedboard/processor_system/processor_system.srcs/sources_1/bd/processor_system/
  set bd_list_simple "processor_system.bd"
} else {
  # Facerecon processor system
  set bd_path_facerecon $repo_path/ip/facerecon/adv7511_zed/adv7511_zed.srcs/sources_1/bd/system/
  set bd_list_facerecon "system.bd"
}


set constraint_path $repo_path/scripts/constraints/

if {$::psmodule=="SIMPLE"} {
  # Read constraints for Simple
  set constraint_list "zedboard_contraints.xdc"
} else {
  # Read constraints for Facerecon
  set constraint_list "zedboard_contraints.xdc \
                       facerecon_timing.xdc"
}

###########################################################
## Read HDL design files, IPs, BD design and constraints ##
###########################################################

foreach xilinx_ip_sourcefile $xilinx_ip_list {
    read_ip $xilinx_ip_path$xilinx_ip_sourcefile
    # Generate IP with .xci files
    set ipname [lindex [split $xilinx_ip_sourcefile /] end]
    puts $ipname

    # Performs Global IP generation
    set_property generate_synth_checkpoint FALSE [get_files [lindex $ipname end]]
    generate_target -force all [get_files [lindex $ipname end]]
}

if {$::psmodule=="SIMPLE"} {
  foreach bd_sourcefile $bd_list_simple {
    read_bd $bd_path_simple$bd_sourcefile
    set ipname [lindex [split $bd_sourcefile /] end]
    puts $ipname
    # Performs GLOBAL Block Design (BD) generation; this will result in resynth of BD design every P&R,
    #   but eases generation/use of the BD module in P&R.
    # The Block Design may also be read as Out-Of-Context (OOC) per Block Design .bd file or as a premade synthesized .dcp file.
    set_property synth_checkpoint_mode none [get_files [lindex $ipname end]]
    generate_target {synthesis implementation} [get_files [lindex $ipname end]]
 }
} else {
  foreach bd_sourcefile $bd_list_facerecon {
    read_bd $bd_path_facerecon$bd_sourcefile
    set ipname [lindex [split $bd_sourcefile /] end]
    puts $ipname
    # Performs GLOBAL Block Design (BD) generation; this will result in resynth of BD design every P&R,
    #   but eases generation/use of the BD module in P&R.
    # The Block Design may also be read as Out-Of-Context (OOC) per Block Design .bd file or as a premade synthesized .dcp file.
    set_property synth_checkpoint_mode none [get_files [lindex $ipname end]]
    generate_target {synthesis implementation} [get_files [lindex $ipname end]]
  }
}

foreach constraints_sourcefile $constraint_list {
    read_xdc $constraint_path$constraints_sourcefile
}

# Report IP status
report_ip_status

puts stdout "Reading MLA ZEDBOARD Zynq 7020 IP and Block Design (BD) design files done."

