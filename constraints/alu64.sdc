# ============================================================
# Design: 64-bit Synchronous ALU
# Technology: SKY130A
# File: constraints/alu64.sdc
# ============================================================

# ------------------------------------------------------------
# 1. Clock constraints
# ------------------------------------------------------------

create_clock -name clk -period 20.000 [get_ports clk]

set_clock_uncertainty 0.200 [get_clocks clk]

set_clock_transition 0.100 [get_clocks clk]


# ------------------------------------------------------------
# 2. Input timing constraints
# ------------------------------------------------------------

# Illustrative external input arrival times (ns).
# Replace with the actual upstream interface requirements.

set_input_delay 2.000 -clock clk \
    [get_ports {A[*] B[*] opcode[*]}]

# Reset is not a data input to the ALU combinational datapath.
# Its timing must be specified according to the reset strategy.
# For this preliminary setup, apply an explicit input delay.

set_input_delay 2.000 -clock clk [get_ports rst]


# ------------------------------------------------------------
# 3. Output timing constraints
# ------------------------------------------------------------

# Illustrative downstream setup requirements (ns).
# Replace with the actual receiving-interface requirements.

set_output_delay 2.000 -clock clk \
    [get_ports {result[*] zero carry overflow negative}]


# ------------------------------------------------------------
# 4. Output load constraints
# ------------------------------------------------------------

# Preliminary load assumption.
# The value is in the Liberty capacitance units, typically pF
# for the SKY130 Liberty library. Verify the library units.

set_load 0.010 \
    [get_ports {result[*] zero carry overflow negative}]


# ------------------------------------------------------------
# End of SDC
# ------------------------------------------------------------
