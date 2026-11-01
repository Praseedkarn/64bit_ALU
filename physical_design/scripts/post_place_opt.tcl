# ============================================================
# 64-bit Synchronous ALU
# SKY130A - Post-Placement Optimization
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/placement/alu64_placed.odb"
set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/post_place"
set reports_dir "$project_dir/physical_design/reports"

file mkdir $results_dir
file mkdir "$reports_dir/timing"
file mkdir "$reports_dir/design_checks"

foreach f [list $liberty $input_db $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts "============================================================"
puts "ALU POST-PLACEMENT OPTIMIZATION"
puts "============================================================"

# Load the original legal placement checkpoint.
read_db $input_db
read_liberty $liberty
read_sdc $sdc

# Provisional placement-based RC estimates.
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met5

estimate_parasitics -placement

# Record timing before repair.
report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/timing/post_place_before_opt.rpt"

# Repair electrical design issues.
repair_design

# Legalize cells after resizing and buffer insertion.
detailed_placement \
    -report_file_name "$reports_dir/design_checks/post_place_legalization.rpt"

# Check placement legality.
check_placement \
    -verbose \
    -report_file_name "$reports_dir/design_checks/post_place_check.rpt"

# Recalculate placement-based parasitics.
estimate_parasitics -placement

# Attempt setup repair after legalization.
repair_timing -setup

# Legalize again in case timing repair changed cell placement.
detailed_placement \
    -report_file_name "$reports_dir/design_checks/post_place_final_legalization.rpt"

# Save a placement legality report.
check_placement \
    -verbose \
    -report_file_name "$reports_dir/design_checks/post_place_final_check.rpt"

estimate_parasitics -placement

# Record final timing.
report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/timing/post_place_after_opt.rpt"

report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/timing/post_place_min_after_opt.rpt"

report_design_area \
    > "$reports_dir/design_checks/post_place_area.rpt"

# Save the checkpoint only after the checks above have run.
write_db "$results_dir/alu64_post_place_opt.odb"
write_def "$results_dir/alu64_post_place_opt.def"

puts "============================================================"
puts "POST-PLACEMENT OPTIMIZATION SCRIPT FINISHED"
puts "Database: $results_dir/alu64_post_place_opt.odb"
puts "DEF: $results_dir/alu64_post_place_opt.def"
puts "============================================================"