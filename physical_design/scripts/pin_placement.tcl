# ============================================================
# 64-bit Synchronous ALU
# SKY130A - I/O Pin Placement
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/post_place/alu64_post_place_opt.odb"
set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/pin_placement"

file mkdir $results_dir

# Verify required inputs.
foreach f [list $liberty $input_db $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts "============================================================"
puts "64-BIT ALU: I/O PIN PLACEMENT"
puts "============================================================"

# Load the post-placement optimized design.
read_db $input_db
read_liberty $liberty
read_sdc $sdc

# Set provisional RC estimates for timing analysis.
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met5

# Automatically place I/O pins around the die boundary.
# Horizontal edges: met3
# Vertical edges:   met2
place_pins \
    -hor_layers met3 \
    -ver_layers met2 \
    -corner_avoidance 5 \
    -min_distance 2 \
    -write_pin_placement "$results_dir/alu64_pin_placement.tcl"

# Save the design with its I/O pin locations.
write_db "$results_dir/alu64_pin_placed.odb"
write_def "$results_dir/alu64_pin_placed.def"

puts "============================================================"
puts "PIN PLACEMENT SCRIPT FINISHED"
puts "Database: $results_dir/alu64_pin_placed.odb"
puts "DEF:      $results_dir/alu64_pin_placed.def"
puts "============================================================"
