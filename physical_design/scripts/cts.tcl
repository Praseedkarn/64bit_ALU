# ============================================================
# 64-bit Synchronous ALU
# SKY130A - Clock Tree Synthesis
# ============================================================

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set input_db "$project_dir/physical_design/results/pin_placement/alu64_pin_placed.odb"
set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/cts"
set reports_dir "$project_dir/physical_design/reports/cts"

file mkdir $results_dir
file mkdir $reports_dir

# Check inputs.
foreach f [list $tech_lef $cell_lef $liberty $input_db $sdc] {
    if {![file exists $f]} {
        error "Required input file not found: $f"
    }
}

puts "============================================================"
puts "64-BIT ALU: CLOCK TREE SYNTHESIS"
puts "============================================================"

# Load technology and design.
read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty
read_db $input_db
read_sdc $sdc

# Provisional RC estimates for placement-based analysis.
set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met5

estimate_parasitics -placement

# Record pre-CTS timing.
report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/pre_cts_setup.rpt"

puts "INFO: Starting CTS on clock net clk."

# SKY130 HD clock buffers found in the installed Liberty.
set cts_buffers {
    sky130_fd_sc_hd__clkbuf_1
    sky130_fd_sc_hd__clkbuf_2
    sky130_fd_sc_hd__clkbuf_4
    sky130_fd_sc_hd__clkbuf_8
    sky130_fd_sc_hd__clkbuf_16
}

# Build the clock tree.
clock_tree_synthesis \
    -clk_nets clk \
    -buf_list $cts_buffers \
    -root_buf sky130_fd_sc_hd__clkbuf_16

# Use propagated clock timing after CTS.
set_propagated_clock [all_clocks]

# Estimate parasitics after clock-tree insertion.
estimate_parasitics -placement

# Report clock skew and post-CTS timing.
report_clock_skew \
    -setup \
    -clock clk \
    > "$reports_dir/post_cts_clock_skew.rpt"

report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/post_cts_setup.rpt"

report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/post_cts_hold.rpt"

# Save the CTS checkpoint.
write_db "$results_dir/alu64_cts.odb"
write_def "$results_dir/alu64_cts.def"

puts "============================================================"
puts "CTS SCRIPT FINISHED"
puts "Database: $results_dir/alu64_cts.odb"
puts "DEF:      $results_dir/alu64_cts.def"
puts "============================================================"
