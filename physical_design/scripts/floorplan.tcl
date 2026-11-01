
# ============================================================
# Project      : 64-bit Synchronous ALU
# Technology   : SKY130A
# Standard Cell: SKY130 HD
# Tool         : OpenROAD
# Stage        : Initial Floorplanning
# ============================================================

# ------------------------------------------------------------
# 1. Project and technology paths
# ------------------------------------------------------------

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set netlist "$project_dir/synthesis/alu64_sky130.v"
set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/floorplan"
set logs_dir "$project_dir/physical_design/logs/floorplan"

# ------------------------------------------------------------
# 2. Create output directories
# ------------------------------------------------------------

file mkdir $results_dir
file mkdir $logs_dir

# ------------------------------------------------------------
# 3. Validate required input files
# ------------------------------------------------------------

foreach f [list $tech_lef $cell_lef $liberty $netlist $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts ""
puts "============================================================"
puts "          64-BIT ALU FLOORPLANNING"
puts "============================================================"
puts "Project directory: $project_dir"
puts "Technology: SKY130A"
puts "Standard-cell library: SKY130 HD"
puts "INFO: All required input files exist."

# ------------------------------------------------------------
# 4. Load technology and standard-cell libraries
# ------------------------------------------------------------

read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty

puts "INFO: Technology LEF loaded."
puts "INFO: Standard-cell LEF loaded."
puts "INFO: Liberty timing library loaded."

# ------------------------------------------------------------
# 5. Load synthesized netlist
# ------------------------------------------------------------

read_verilog $netlist
link_design alu64

puts "INFO: Synthesized ALU netlist loaded and linked."

# ------------------------------------------------------------
# 6. Load timing constraints
# ------------------------------------------------------------

read_sdc $sdc

puts "INFO: Timing constraints loaded."

# ------------------------------------------------------------
# 7. Initialize the floorplan
# ------------------------------------------------------------

# Initial target utilization: 35%
# Aspect ratio: 1.0 (approximately square)
# Core-to-die margin: 10 microns
#
# Verify that "unithd" matches the placement site defined
# in the installed SKY130 HD LEF.

initialize_floorplan \
    -utilization 35 \
    -aspect_ratio 1.0 \
    -core_space 10 \
    -site unithd

puts "INFO: Initial floorplan created."

# ------------------------------------------------------------
# 8. Save floorplan database and DEF
# ------------------------------------------------------------

write_db "$results_dir/alu64_floorplan.odb"
write_def "$results_dir/alu64_floorplan.def"

puts "INFO: OpenROAD database saved."
puts "INFO: Floorplan DEF saved."

# ------------------------------------------------------------
# 9. Completion summary
# ------------------------------------------------------------

puts ""
puts "============================================================"
puts "         FLOORPLANNING COMPLETED SUCCESSFULLY"
puts "============================================================"
puts "Database: $results_dir/alu64_floorplan.odb"
puts "DEF file: $results_dir/alu64_floorplan.def"
puts "============================================================"
