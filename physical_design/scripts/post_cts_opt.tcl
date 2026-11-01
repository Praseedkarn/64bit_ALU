# ============================================================
# 64-bit Synchronous ALU
# SKY130A - Post-CTS Optimization
# OpenROAD v2.x
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/cts/alu64_cts.odb"
set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/post_cts_opt"
set reports_dir "$project_dir/physical_design/reports/post_cts_opt"

file mkdir $results_dir
file mkdir $reports_dir

foreach f [list $tech_lef $cell_lef $liberty $input_db $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts "============================================================"
puts "64-BIT ALU: POST-CTS OPTIMIZATION"
puts "============================================================"

# Load the physical design libraries and CTS database.
read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty
read_db $input_db
read_sdc $sdc

# Use provisional placement-based RC estimates.
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met5
set_propagated_clock [all_clocks]
estimate_parasitics -placement

# ------------------------------------------------------------
# 1. Baseline timing before optimization
# ------------------------------------------------------------

report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/setup_before.rpt"

report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/hold_before.rpt"

report_design_area > "$reports_dir/area_before.rpt"

# ------------------------------------------------------------
# 2. Repair electrical design issues
# ------------------------------------------------------------

puts "INFO: Running post-CTS electrical repair..."
repair_design

# ------------------------------------------------------------
# 3. Repair setup timing
# ------------------------------------------------------------

estimate_parasitics -placement

puts "INFO: Running post-CTS setup timing repair..."
repair_timing -setup

# Legalize cells after repair.
detailed_placement

# ------------------------------------------------------------
# 4. Repair hold timing
# ------------------------------------------------------------

estimate_parasitics -placement

puts "INFO: Running post-CTS hold timing repair..."
repair_timing -hold

# Legalize any cells changed by timing repair.
detailed_placement

# ------------------------------------------------------------
# 5. Final checks and reports
# ------------------------------------------------------------

estimate_parasitics -placement

check_placement \
    -verbose \
    -report_file_name "$reports_dir/placement_check.rpt"

report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/setup_after.rpt"

report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/hold_after.rpt"

report_design_area > "$reports_dir/area_after.rpt"

# Preserve the original CTS checkpoint.
write_db "$results_dir/alu64_post_cts_opt.odb"
write_def "$results_dir/alu64_post_cts_opt.def"

puts "============================================================"
puts "POST-CTS OPTIMIZATION FINISHED"
puts "Database: $results_dir/alu64_post_cts_opt.odb"
puts "DEF:      $results_dir/alu64_post_cts_opt.def"
puts "Reports:  $reports_dir"
puts "============================================================"
