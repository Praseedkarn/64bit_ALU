
# ============================================================
# 64-BIT SYNCHRONOUS ALU
# SKY130A - POST ROUTE PARASITIC EXTRACTION
# Tool: OpenROAD v2.x
# ============================================================

# 1. Project configuration

set project_dir "$env(HOME)/64bit_ALU"

set sky130_root "$env(HOME)/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A"

set tech_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"

set cell_lef "$sky130_root/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"

set liberty "$sky130_root/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

set rc_rules "$sky130_root/libs.tech/librelane/rules.openrcx.sky130A.nom.spef_extractor"

set input_db "$project_dir/physical_design/results/routing/alu64_routed.odb"

set sdc "$project_dir/constraints/alu64.sdc"

set results_dir "$project_dir/physical_design/results/extraction"

set reports_dir "$project_dir/physical_design/reports/extraction"

set logs_dir "$project_dir/physical_design/logs/extraction"

file mkdir $results_dir
file mkdir $reports_dir
file mkdir $logs_dir

# 2. Validate inputs

foreach f [list $tech_lef $cell_lef $liberty $rc_rules $input_db $sdc] {
    if {![file exists $f]} {
        error "Required file not found: $f"
    }
}

puts "============================================================"
puts "64-BIT ALU: POST ROUTE PARASITIC EXTRACTION"
puts "============================================================"

# 3. Load technology

read_lef $tech_lef
read_lef $cell_lef
read_liberty $liberty

# 4. Load routed database and constraints

read_db $input_db
read_sdc $sdc

set_propagated_clock [all_clocks]

puts "INFO: Routed database loaded."

# 5. Extract routed parasitics

puts "INFO: Starting nominal RC extraction..."

extract_parasitics \
    -ext_model_file $rc_rules \
    -corner_cnt 1

puts "INFO: Parasitic extraction completed."

# 6. Export SPEF

write_spef "$results_dir/alu64_nom.spef"

puts "INFO: SPEF generated."

# 7. Post-route setup timing

report_checks \
    -path_delay max \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/post_route_setup.rpt"

# 8. Post-route hold timing

report_checks \
    -path_delay min \
    -format full_clock_expanded \
    -fields {slew cap input_pin net fanout} \
    > "$reports_dir/post_route_hold.rpt"

# 9. Area report

report_design_area > "$reports_dir/post_route_area.rpt"

# 10. Save extracted database

write_db "$results_dir/alu64_extracted.odb"

puts "============================================================"
puts "POST ROUTE EXTRACTION COMPLETED"
puts "============================================================"
puts "SPEF: $results_dir/alu64_nom.spef"
puts "ODB:  $results_dir/alu64_extracted.odb"
puts "Reports: $reports_dir"
puts "============================================================"

