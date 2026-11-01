transcript file simulation/transcript

if {![file exists work]} {
    vlib work
}

vlog rtl/alu64.v
vlog tb/tb_alu64.v

vsim -voptargs=+acc work.tb_alu64

vcd file simulation/alu64.vcd
vcd add -r /tb_alu64/*

run -all

vcd flush

quit -f