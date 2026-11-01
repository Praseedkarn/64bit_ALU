
# ============================================================
# 64-BIT ALU - ANTENNA VERIFICATION
# Technology: SKY130A
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"

set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/extraction/alu64_extracted.odb"

set reports_dir "$project_dir/physical_design/reports/antenna"

file mkdir $reports_dir

foreach f [list $tech_lef $cell_lef $liberty $input_db] {
    if {![file exists $f]} {
        error "Required file not found: $f"
    }
}

puts "============================================================"
puts "64-BIT ALU: ANTENNA VERIFICATION"
puts "============================================================"

# Load technology and routed design.

read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty
read_db $input_db

puts "INFO: Routed database loaded."

# Check antenna violations.

check_antennas \
    -verbose \
    -report_violating_nets \
    -report_file "$reports_dir/antenna_violations.rpt"

puts "============================================================"
puts "ANTENNA CHECK COMPLETED"
puts "Report: $reports_dir/antenna_violations.rpt"
puts "============================================================"

