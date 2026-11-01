
set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set netlist "$env(HOME)/64bit_ALU/synthesis/alu64_sky130.v"
set sdc "$env(HOME)/64bit_ALU/constraints/alu64.sdc"

foreach f [list $tech_lef $cell_lef $liberty $netlist $sdc] {
    if {![file exists $f]} {
        error "Missing required file: $f"
    }
}

read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty

read_verilog $netlist
link_design alu64

read_sdc $sdc

puts "========== SDC VALIDATION =========="
puts "Design: alu64"
puts "Clock:"
report_clock_properties [get_clocks clk]

puts "Timing constraints loaded successfully."

puts "\n========== TIMING CHECKS =========="

report_checks -path_delay max -format full_clock_expanded

puts "\n========== UNCONSTRAINED PATH CHECK =========="

report_checks -unconstrained -format full_clock_expanded

puts "========== END TIMING CHECKS =========="

puts "========== END VALIDATION =========="

