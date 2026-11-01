# 64-bit ALU | RTL Design & ASIC Physical Design

<p align="center">
  <b>Design • Verification • Synthesis • Physical Design • Timing Analysis</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog-blue" />
  <img src="https://img.shields.io/badge/Technology-SKY130A-orange" />
  <img src="https://img.shields.io/badge/Design-64--Bit-green" />
  <img src="https://img.shields.io/badge/Physical%20Design-OpenROAD-purple" />
  <img src="https://img.shields.io/badge/Verification-64%20PASS-brightgreen" />
</p>

## Overview

This project implements a **64-bit synchronous Arithmetic Logic Unit (ALU)** using Verilog HDL and takes the design through an ASIC RTL-to-Physical Design flow using the SkyWater 130nm (Sky130A) Process Design Kit.

The project covers the complete digital design workflow, starting from RTL development and functional verification to synthesis, floorplanning, placement, clock tree synthesis, routing, parasitic extraction and timing analysis.

The primary objective is to understand and implement the practical ASIC design flow using open-source Electronic Design Automation (EDA) tools.

## Project Specifications

| Parameter | Description |
|---|---|
| Design | 64-bit Synchronous ALU |
| HDL | Verilog |
| Data Width | 64 Bits |
| Technology | Sky130A |
| Standard Cell Library | Sky130 FD SC HD |
| Clock | 20 ns |
| Clock Frequency | 50 MHz |
| Simulation | Icarus Verilog / Questa |
| Synthesis | Yosys |
| Physical Design | OpenROAD |
| Layout Inspection | KLayout |
| Technology Node | 130 nm |

## Architecture

The ALU is designed to perform arithmetic and logical operations on two 64-bit input operands.

### Functional Blocks

- 64-bit input operand A
- 64-bit input operand B
- Opcode-based operation selection
- Arithmetic and logical datapath
- Synchronous control and reset
- 64-bit result output

### Block Diagram

```text
             +-------------------+
             |     Input A       |
             |      64-bit       |
             +---------+---------+
                       |
                       v
             +-------------------+
             |                   |
             |    64-bit ALU     |<---- Opcode
             |                   |
             +---------+---------+
                       ^
                       |
             +---------+---------+
             |     Input B       |
             |      64-bit       |
             +-------------------+
                       |
                       v
             +-------------------+
             |   Result Output   |
             |      64-bit       |
             +-------------------+
```

## ASIC RTL-to-Physical Design Flow

The design follows the standard ASIC implementation sequence:

```text
       RTL Development
              |
              v
       Functional Verification
              |
              v
          Synthesis
              |
              v
         Floorplanning
              |
              v
         Pin Placement
              |
              v
          Placement
              |
              v
     Power Distribution Network
              |
              v
     Clock Tree Synthesis (CTS)
              |
              v
       Timing Optimization
              |
              v
        Global Routing
              |
              v
       Detailed Routing
              |
              v
     Parasitic Extraction
              |
              v
      Post-Route STA
              |
              v
       Physical Verification
```

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Verilog | RTL design |
| Icarus Verilog | Functional simulation |
| Questa | Simulation and waveform analysis |
| GTKWave | Waveform visualization |
| Yosys | RTL synthesis |
| Sky130A PDK | Standard-cell technology |
| OpenROAD | ASIC physical design |
| OpenSTA | Static timing analysis |
| KLayout | Layout visualization and DRC |
| Magic | Layout verification |

## Verification Results

Functional verification was performed using a dedicated Verilog testbench.

**Simulation Summary:**

| Metric | Result |
|---|---:|
| Total Test Cases Passed | 64 |
| Total Test Cases Failed | 0 |
| Overall Status | PASS |

```text
========================================
          VERIFICATION SUMMARY
========================================
Total PASS: 64
Total FAIL: 0

ALL ALU TESTS PASSED
========================================
```

## Physical Design Results

The design successfully progressed through placement, CTS, routing and parasitic extraction.

### Routing

| Parameter | Result |
|---|---|
| Global Routing | Completed |
| Detailed Routing | Completed |
| Detailed Routing Violations | 0 |
| Routing Layers | met1 – met5 |
| Clock Routing Layers | met4 – met5 |

### Timing Analysis

Post-route timing analysis was performed using extracted parasitic information.

| Parameter | Post-Route Result |
|---|---:|
| Setup Slack | +7.26 ns |
| Hold Slack | +1.57 ns |
| Setup Timing | MET |
| Hold Timing | MET |

### Area Report

| Parameter | Result |
|---|---:|
| Design Area | 16,389 µm² |
| Reported Utilization | 40% |

*Values are from the current OpenROAD implementation reports.*

## Physical Verification Status

| Verification | Status |
|---|---|
| Functional Verification | PASS |
| Synthesis | Completed |
| Placement | Completed |
| Clock Tree Synthesis | Completed |
| Detailed Routing | 0 reported violations |
| Parasitic Extraction | Completed |
| Post-Route Setup Timing | MET |
| Post-Route Hold Timing | MET |
| Antenna Check | 1 violation pending |
| Full-Chip DRC | Pending |
| LVS | Pending |
| GDSII Stream-Out | Pending |

**Note:** Zero detailed-routing violations does not establish full foundry DRC signoff. Full physical verification and GDSII stream-out remain future work.

## Repository Structure

```text
64bit_ALU/
│
├── rtl/
│   └── alu64.v
│
├── tb/
│   └── tb_alu64.v
│
├── simulation/
│   ├── run_wave.do
│   └── simulation outputs
│
├── synthesis/
│   ├── Yosys scripts
│   ├── synthesis reports
│   └── mapped netlists
│
├── constraints/
│   └── alu64.sdc
│
├── physical_design/
│   ├── scripts/
│   │   ├── floorplan.tcl
│   │   ├── placement.tcl
│   │   ├── pdn.tcl
│   │   ├── cts.tcl
│   │   ├── routing.tcl
│   │   └── extraction.tcl
│   │
│   ├── results/
│   ├── reports/
│   └── logs/
│
├── .gitignore
└── README.md
```

## Key Learning Outcomes

Through this project, the following concepts were explored:

- RTL development using Verilog HDL.
- Functional verification and testbench development.
- Logic synthesis using Yosys.
- Standard-cell technology mapping.
- ASIC floorplanning and pin placement.
- Placement optimization and clock tree synthesis.
- Power distribution network implementation.
- Global and detailed routing.
- Parasitic extraction and SPEF generation.
- Post-route static timing analysis.
- Antenna verification and physical signoff concepts.

## Future Work

- Resolve the remaining antenna violation.
- Complete full-chip Sky130A DRC verification.
- Perform Layout Versus Schematic (LVS) verification.
- Complete GDSII stream-out.
- Perform final physical verification and signoff.

## Author

**Praseed Kumar**


- GitHub: [@Praseedkarn](https://github.com/Praseedkarn)

---

<p align="center">
  <b>64-bit ALU | RTL to Physical Design using Sky130A</b>
</p>
