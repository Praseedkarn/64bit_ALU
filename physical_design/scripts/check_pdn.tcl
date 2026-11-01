# ============================================================
# PDN Connectivity Diagnostic
# Project: 64-bit Synchronous ALU
# Technology: SKY130A
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/pdn/alu64_pdn.odb"
set report_dir "$project_dir/physical_design/reports/design_checks"

file mkdir $report_dir

read_db $input_db
read_liberty $liberty

puts "Checking VDD power-grid connectivity..."

check_power_grid \
    -net VDD \
    -floorplanning \
    -error_file "$report_dir/vdd_pdn_errors.rpt"

puts "Checking VSS power-grid connectivity..."

check_power_grid \
    -net VSS \
    -floorplanning \
    -error_file "$report_dir/vss_pdn_errors.rpt"

puts "PDN connectivity checks completed."
