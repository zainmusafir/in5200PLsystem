#!/usr/bin/tclsh
   
# Only Zedboard targets are currently defined.
if { ![string match [lindex $target] "ZEDBOARD"] } {
    puts "Error; invalid argument: [lindex $target]"
    puts "User must select target ZEDBOARD."
    puts {Usage: ./toolsetup.tcl <target>}
    puts {       <target>: ZEDBOARD} 
    exit 0
}

# set env(TCL_LIBRARY) "/usr/share/tcl8.5:"


if {[string match [lindex $target] "ZEDBOARD"] } {
#  set VivadoVersion "2018.3"
#  set QuestaVersion "2019_2020/Questa"
  set VivadoVersion "2020.2"
  set QuestaVersion "2020_2021/QuestaCore"
  # Path to xilinx_library
  set env(XILINX_SIMULATION_LIB) "/projects/robin/CADlib/sim-lib/questa_2020.2_vivado_2020.2"
}  

# Set Xilinx Vivado variable and path
set VivadoPath "/projects/robin/programs"
set env(XILINX_VIVADO) "$VivadoPath/Vivado/$VivadoVersion"
set env(PATH) "$VivadoPath/Vivado/$VivadoVersion/bin:$env(PATH)"
set env(PATH) "$VivadoPath/Vivado_HLS/$VivadoVersion/bin:$env(PATH)"
set env(PATH) "$VivadoPath/DocNav/bin:$env(PATH)"
set env(PATH) "$VivadoPath/SDK/$VivadoVersion/bin:$env(PATH)"

# Set Questa version and path
set QuestaPath "/projects/nanus/eda/Mentor"
set env(PLATFORM) "lin"
set env(QUESTA_TOOL) "$QuestaPath"
set env(QUESTA_HOME) "$QuestaPath/$QuestaVersion/questasim/linux_x86_64"  
set env(PATH) "$QuestaPath/$QuestaVersion/questasim//linux_x86_64:$env(PATH)"
set env(PATH) "$QuestaPath/$QuestaVersion/questasim/RUVM_2020.4:$env(PATH)"

# View environment variables set
#puts "Setting Questa and Vivado environment variables:
#puts "Questa version: $QuestaVersion"
#puts "Questa_TOOL variable: $env(QUESTA_TOOL)"
#puts "Questa_TOOL variable: $env(QUESTA_HOME)"
#puts "Vivado version: $VivadoVersion" 
#puts "XILINX_VIVADO environment variable: $env(XILINX_VIVADO)" 
#puts "Path to Xilinx simulation libraries: $env(XILINX_SIMULATION_LIB)"
#puts "PATH environment variable: $env(PATH)"
