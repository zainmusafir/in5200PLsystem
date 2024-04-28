onerror {quit -f}

# The log command will generate a vsim.wlf file ...
#log -r /*

# Coverage exclude during simulation not used due to done in coverage.tcl script!!
# # Including coverage exclude command file.
# if {[file exists "[pwd]/coverage_exclude.do"]} {
#    do coverage_exclude.do
#    puts "Info: Executed coverage_exclude.do file in [pwd]"  
# } else {
#    puts "Warning: coverage_exclude.do file does not exist in [pwd]"
# }

run -all

# Get sequence name. The selected sequence is argument 37 to the vsim command!
set sequence_name [lindex [split [split [lindex $argv 37] /] =] 1]
puts $sequence_name

puts "Info: Writing coverage data for $sequence_name"
coverage attribute -name TESTNAME -value $sequence_name
coverage save -assert -directive -cvg -codeAll -onexit "$sequence_name.ucdb"
puts "Info: Module coverage data generation complete"
coverage report -file "$sequence_name.rep"
puts "Info: Module coverage report written to $sequence_name.rep"
coverage report -html -htmldir "$sequence_name\_html"
puts "Info: Module coverage report written to $sequence_name\_html"

exit -f