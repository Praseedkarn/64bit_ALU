# ============================================================
# Project      : 64-bit Synchronous ALU
# Technology   : SKY130A
# Standard Cell: SKY130 HD
# Tool         : OpenROAD
# Stage        : Power Distribution Network
# ============================================================

# ------------------------------------------------------------
# 1. Project paths
# ------------------------------------------------------------

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root \
    "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set liberty \
    "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db \
    "$project_dir/physical_design/results/floorplan/alu64_floorplan.odb"

set results_dir "$project_dir/physical_design/results/pdn"
set logs_dir "$project_dir/physical_design/logs/pdn"

file mkdir $results_dir
file mkdir $logs_dir

# ------------------------------------------------------------
# 2. Validate inputs
# ------------------------------------------------------------

foreach f [list $liberty $input_db] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts "INFO: Input files verified."

# ------------------------------------------------------------
# 3. Load the floorplanned database
# ------------------------------------------------------------

read_db $input_db
read_liberty $liberty

puts "INFO: Floorplan database loaded."

# ------------------------------------------------------------
# 4. Connect standard-cell power and ground pins
# ------------------------------------------------------------

add_global_connection \
    -net VDD \
    -inst_pattern {.*} \
    -pin_pattern {^VPWR$} \
    -power

add_global_connection \
    -net VDD \
    -inst_pattern {.*} \
    -pin_pattern {^VPB$}

add_global_connection \
    -net VSS \
    -inst_pattern {.*} \
    -pin_pattern {^VGND$} \
    -ground

add_global_connection \
    -net VSS \
    -inst_pattern {.*} \
    -pin_pattern {^VNB$}

global_connect

puts "INFO: Global power connections configured."

# ------------------------------------------------------------
# 5. Define the core voltage domain
# ------------------------------------------------------------

set_voltage_domain \
    -name CORE \
    -power VDD \
    -ground VSS

# ------------------------------------------------------------
# 6. Define the standard-cell power grid
# ------------------------------------------------------------

define_pdn_grid \
    -name grid \
    -voltage_domains {CORE}

# ------------------------------------------------------------
# 7. Standard-cell power rails on met1
# ------------------------------------------------------------

# Follow the standard-cell power-pin geometry.
# SKY130 HD platform configuration.

add_pdn_stripe \
    -grid grid \
    -layer met1 \
    -width 0.48 \
    -pitch 5.44 \
    -offset 0 \
    -followpins

# ------------------------------------------------------------
# 8. Vertical power straps on met4
# ------------------------------------------------------------

add_pdn_stripe \
    -grid grid \
    -layer met4 \
    -width 1.600 \
    -pitch 27.140 \
    -offset 13.570

# ------------------------------------------------------------
# 9. Horizontal power straps on met5
# ------------------------------------------------------------

add_pdn_stripe \
    -grid grid \
    -layer met5 \
    -width 1.600 \
    -pitch 27.200 \
    -offset 13.600

# ------------------------------------------------------------
# 10. Connect the power-grid layers
# ------------------------------------------------------------

# OpenROAD constructs via stacks for the selected layers
# using compatible technology via definitions/rules.

add_pdn_connect \
    -grid grid \
    -layers {met1 met4}

add_pdn_connect \
    -grid grid \
    -layers {met4 met5}

# ------------------------------------------------------------
# 11. Generate the power distribution network
# ------------------------------------------------------------

puts "INFO: Generating SKY130 HD PDN."

pdngen \
    -failed_via_report "$results_dir/failed_vias.rpt"

# ------------------------------------------------------------
# 12. Save outputs
# ------------------------------------------------------------

write_db "$results_dir/alu64_pdn.odb"
write_def "$results_dir/alu64_pdn.def"

puts ""
puts "============================================================"
puts "       ALU PDN GENERATION FINISHED"
puts "============================================================"
puts "Database: $results_dir/alu64_pdn.odb"
puts "DEF:      $results_dir/alu64_pdn.def"
puts "============================================================"