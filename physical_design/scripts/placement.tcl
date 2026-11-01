# ============================================================
# Project      : 64-bit Synchronous ALU
# Technology   : SKY130A
# Standard Cell: SKY130 HD
# Tool         : OpenROAD
# Stage        : Standard-Cell Placement
# ============================================================

# ------------------------------------------------------------
# 1. Project paths
# ------------------------------------------------------------

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/pdn/alu64_pdn.odb"

set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/placement"
set logs_dir "$project_dir/physical_design/logs/placement"
set reports_dir "$project_dir/physical_design/reports"

file mkdir $results_dir
file mkdir $logs_dir
file mkdir "$reports_dir/timing"
file mkdir "$reports_dir/design_checks"

# ------------------------------------------------------------
# 2. Validate input files
# ------------------------------------------------------------

foreach f [list $liberty $input_db $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts ""
puts "============================================================"
puts "       64-BIT ALU STANDARD-CELL PLACEMENT"
puts "============================================================"

# ------------------------------------------------------------
# 3. Load the PDN database and timing library
# ------------------------------------------------------------

read_db $input_db
read_liberty $liberty

puts "INFO: PDN database loaded."
puts "INFO: SKY130 HD timing library loaded."

# ------------------------------------------------------------
# 4. Load timing constraints
# ------------------------------------------------------------

read_sdc $sdc

puts "INFO: Timing constraints loaded."

# ------------------------------------------------------------
# 5. Global placement
# ------------------------------------------------------------

# Initial target placement density: 35%.
# This is an initial setting, not an optimized value.

puts "INFO: Starting global placement."

global_placement -density 0.40

puts "INFO: Global placement completed."

# ------------------------------------------------------------
# 6. Detailed placement
# ------------------------------------------------------------

# Legalize cell positions and check placement legality.

puts "INFO: Starting detailed placement."

detailed_placement \
    -report_file_name "$reports_dir/design_checks/placement.rpt"

puts "INFO: Detailed placement completed."

# ------------------------------------------------------------
# 7. Check placement legality
# ------------------------------------------------------------

puts "INFO: Checking placement legality."

check_placement -verbose

# ------------------------------------------------------------
# 8. Estimate placement-stage parasitics
# ------------------------------------------------------------

# These are placement-based estimates, not routed parasitics.

estimate_parasitics -placement

# ------------------------------------------------------------
# 9. Generate a preliminary timing report
# ------------------------------------------------------------

puts "INFO: Generating preliminary timing report."

report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/timing/placement_timing.rpt"

puts "INFO: Timing report saved."

# ------------------------------------------------------------
# 10. Save placement results
# ------------------------------------------------------------

write_db "$results_dir/alu64_placed.odb"
write_def "$results_dir/alu64_placed.def"

puts ""
puts "============================================================"
puts "       PLACEMENT STAGE FINISHED"
puts "============================================================"
puts "Database: $results_dir/alu64_placed.odb"
puts "DEF:      $results_dir/alu64_placed.def"
puts "Timing:   $reports_dir/timing/placement_timing.rpt"
puts "============================================================"