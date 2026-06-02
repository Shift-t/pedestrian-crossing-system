# FPGA-Based Smart Pedestrian Crossing System

A complete digital hardware system that models and implements a three-road smart traffic light controller with a prioritized pedestrian crossing signal. The design is implemented in Verilog HDL and configured for the **Nexys-A7-100T FPGA board** (Xilinx Artix-7).

---

## Project Overview

This project implements a smart traffic intersection manager designed for university-level Digital Logic Laboratories. The system prioritizes Road 1 traffic and includes a button-activated pedestrian crossing. The design features:
*   **Modular Control Path (FSM):** A state machine managing transitions between three roads and the pedestrian state.
*   **Data Path Countdown Timers:** Custom countdown timer counting down state durations at exactly 1Hz frequency.
*   **Hardware Debouncers:** Mechanical noise filtration modules for push buttons.
*   **Multiplexed 7-Segment Display Controller:** Scans through active-low anodes to display the remaining time of the active green light on a multi-digit display.

---

## System Architecture

The project is structured modularly. The top-level wrapper module connects the components:

```text
================================================================================
                               TOP-LEVEL SYSTEM WRAPPER
                             (traffic_system_test.v)
================================================================================

              clk (100MHz) -------------------------------+--------------+
                                                          |              |
  reset -----------------> [ debounce (d1) ]              |              |
                                |                         |              |
                                | cln_reset               |              |
                                v                         |              |
  enable --------------------------------+                |              |
                                         |                |              |
  ped_btn ---------------> [ debounce (d2) ]              |              |
                                |                         |              |
                                | cln_ped                 |              |
                                v                         v              |
             +--------------------------------------+     |              |
             |      pedestrian_crossing (test)      |     |              |
             |            (Control Unit)            |     |              |
             +------------------+-------------------+     |              |
             |                  |                   |     |              |
             |  clk (100MHz)    | reset, enable,    |     |              |
             |  (to my_clock)   | cln_ped           |     |              |
             |       |          |                   |     |              |
             |       v          |                   |     |              |
             |  [ clk1hz ]      |                   |     |              |
             |       |          v                   |     |              |
             |       | clk_1Hz  +-----> [ timer ]   |     |              |
             |       +---------------------> |      |     |              |
             |                               v      |     |              |
             |                        remaining_time|     |              |
             +-------------------------------+------+     |              |
                                             |            |              |
                                             | [s1..s3]   |              |
                                             | ped_signal |              |
                                             |            |              |
                                             v            v              |
                      (Display mux logic: D0, D2, D4, D6)                |
                                             |                           |
                                             v                           v
                                     +---------------------------------------+
                                     |           DISP7SEG (display)          |
                                     |            (Display Driver)           |
                                     +-------------------+-------------------+
                                                         |
                                                         v
  ------------------------------------------------------------------------------
  FPGA PINS:      [r1..r3, s1..s3]          [seg7:seg0]             [an7:an0]
                    Green/Red LEDs         7-Segment Cathodes      Digit Anodes
  ------------------------------------------------------------------------------
```

---

## FSM State Machine & Logic

The system is modeled as a Finite State Machine with four primary states:
1.  **S1 (Road 1 Green):** Priority road, Green for **9 seconds**.
2.  **S2 (Road 2 Green):** Secondary road, Green for **5 seconds**.
3.  **S3 (Road 3 Green):** Secondary road, Green for **5 seconds**.
4.  **PED (Pedestrian Crossing):** All traffic signals are Red, Pedestrian signal is Green for **6 seconds**.

### State Transition Table

The logic for transitions and outputs is summarized below:

| Current State | Outputs (Green Lights Active) | Next State (`pedReq = 0`, `timer_done = 1`) | Next State (`pedReq = 1`, `timer_done = 1`) | Pedestrian Resumption State (`state_store`) |
|:---:|:---:|:---:|:---:|:---:|
| **S1** (Road 1) | `s1 = 1`, others = 0 | **S2** (Road 2) | **PED** | **S2** (Resumes at Road 2) |
| **S2** (Road 2) | `s2 = 1`, others = 0 | **S3** (Road 3) | **PED** | **S3** (Resumes at Road 3) |
| **S3** (Road 3) | `s3 = 1`, others = 0 | **S1** (Road 1) | **PED** | **S1** (Resumes at Road 1) |
| **PED** (Pedestrian)| `ped_signal = 1`, others = 0 | **state_store** | **state_store** | Resumes interrupted sequence |

*Note: If `timer_done = 0`, the FSM remains in its current state.*

---

## Pin Mapping (Nexys-A7 FPGA)

All signals are mapped to physical hardware on the Nexys-A7 board using the constraints file [DISP7SEG.ucf](DISP7SEG.ucf).

### Controls & Indicators

| Port Name | Board Component | FPGA Pin | I/O Standard | Description |
|:---|:---|:---:|:---:|:---|
| `clk` | System Oscillator | `E3` | LVCMOS18 | 100MHz internal clock |
| `reset` | CPU Reset Button (Red) | `M18` | LVCMOS18 | Active-high global reset |
| `enable` | Switch 0 | `J15` | LVCMOS18 | Active-high run enable |
| `ped_btn` | Button Down | `P18` | LVCMOS18 | Pedestrian crossing request |
| `s1` / `r1` | LED 0 / LED 1 | `H17` / `K15` | LVCMOS18 | Road 1 Green / Red signals |
| `s2` / `r2` | LED 2 / LED 3 | `R18` / `V17` | LVCMOS18 | Road 2 Green / Red signals |
| `s3` / `r3` | LED 4 / LED 5 | `V16` / `T15` | LVCMOS18 | Road 3 Green / Red signals |
| `ped_signal` / `r_ped_signal` | LED 6 / LED 7 | `V15` / `V14` | LVCMOS18 | Pedestrian Green / Red signals |

*Note: When the `enable` switch (Switch 0) is turned off (low), the countdown timer and Finite State Machine (FSM) will freeze in place, pausing all state transitions until `enable` is set high again.*

### 7-Segment Display

The 7-segment cathodes `seg[7:0]` and anodes `an[7:0]` are mapped to control digit scanning:
*   **Cathodes:** `seg[7]` (DP) to `seg[0]` (CA) mapped to `H15`, `L18`, `T11`, `P15`, `K13`, `K16`, `R10`, `T10`.
*   **Anodes:** Mapped to pins `U13`, `K2`, `T14`, `P14`, `J14`, `T9`, `J18`, `J17` (AN7 down to AN0).
*   **Mux Scanning Display Mapping:**
    *   **AN0 (Digit 0):** Displays remaining time for Road 1 (`S1`).
    *   **AN2 (Digit 2):** Displays remaining time for Road 2 (`S2`).
    *   **AN4 (Digit 4):** Displays remaining time for Road 3 (`S3`).
    *   **AN6 (Digit 6):** Displays remaining time for Pedestrian crossing (`PED`).
    *   *All other displays (AN1, AN3, AN5, AN7) are blanked.*

---

## Simulation & Synthesis

### Prerequisites
*   **Synthesis & Implementation:** Xilinx ISE Design Suite (version 14.7) or Vivado Design Suite configured for Artix-7.
*   **Simulation:** ISim, ModelSim, or Icarus Verilog.

### Synthesis Steps
1.  Open Xilinx Project Navigator.
2.  Select **Open Project** and choose the [pedestrian-crossing-system.xise](pedestrian-crossing-system.xise) project file.
3.  Ensure the top-level module is set to `traffic_system_test`.
4.  Run **Synthesize - XST** to compile the Verilog source code.
5.  Run **Implement Design** to translate, map, and place-and-route.
6.  Run **Generate Programming File** to create the `.bit` bitstream file for programming the FPGA.


