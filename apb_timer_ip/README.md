# APB Timer IP Design & Verification

## 1. Overview

This project implements the RTL design and a verification environment for a 64-bit APB-based Timer IP. The IP is customized from the Core-Local Interruptor (CLINT) timer of industrial RISC-V architectures.

The verification environment tests APB protocol behavior (including wrong-protocol cases), register access rules, the 64-bit prescaled counter, hardware auto-clear, debug halt mode, error responses (`tim_pslverr`), and the level-triggered interrupt lifecycle with Write-1-to-Clear (RW1C) status handling.

All 15 directed testcases pass in regression, and DUT code coverage is closed to 100% with a small, documented set of exclusions (see Section 6).

## 2. DUT Specifications

| Parameter / Feature | Description |
| :--- | :--- |
| **Bus Interface** | APB Slave with 12-bit address bus (`tim_paddr[11:0]`) and 32-bit data bus |
| **Data Transfer** | 32-bit APB transfers with 4-bit byte-enable write strobes (`tim_pstrb[3:0]`) |
| **Wait States** | Every transfer has one wait state: `tim_pready` is Low in the first `tim_penable` cycle and High in the next |
| **Error Handling** | Error response (`tim_pslverr`) on illegal configuration attempts |
| **Reserved Area** | RAZ/WI (Read-As-Zero, Write-Ignored) on reserved offsets |
| **Counter Architecture** | 64-bit count-up timer (`TDR0` lower 32 bits, `TDR1` upper 32 bits) |
| **Prescaler Modes** | Default mode (system clock speed) and Control mode (divided up to 256) |
| **Auto-Clear** | Hardware clears `TDR0`/`TDR1` to `0` when `timer_en` falls (H -> L) |
| **Debug Mode** | Freezes counting when `dbg_mode = 1` and `THCSR.halt_req = 1`, acknowledged by `THCSR.halt_ack = 1` |
| **Interrupt System** | Maskable level interrupt (`tim_int`) set when the 64-bit counter equals `{TCMP1, TCMP0}`, cleared with RW1C |
| **Reset** | Active-low asynchronous reset (`rst_n`) |

## 3. Design Architecture

![Block Diagram](docs/block_diagram.png)

The top-level module (`apb_timer_ip`) consists of four functional blocks:

- **APB Slave:** A 3-state FSM (IDLE -> SETUP -> ACCESS). It turns APB transfers into one-cycle read/write strobes (`wr_en`, `rd_en`), asserts `tim_pready` in the ACCESS cycle (one wait state per transfer), and forwards `reg_err` to `tim_pslverr`. `wr_en`, `rd_en` and `tim_pready` are only active when `PSEL` and `PENABLE` are both High.
- **Register:** Decodes 12-bit addresses, stores configuration registers (`TCR`, `TCMP0/1`, `TIER`, `TISR`, `THCSR`), implements RAZ/WI for reserved space, handles RW1C clearing, checks illegal configuration writes to generate `reg_err`, and compares the counter with `{TCMP1, TCMP0}` to set the interrupt status and drive `tim_int`.
- **Counter Control:** Runs the internal 8-bit prescaler counter based on `div_val` and `div_en`, generates the count enable (`cnt_en`), detects the falling edge of `timer_en` (`timer_en_fall`), and handles the debug halt request/acknowledge handshake.
- **Counter:** Holds the 64-bit counter (`TDR0`, `TDR1`) with the update priority: Hardware Auto-Clear > APB byte-strobe write > Count Increment.

## 4. Verification Architecture & Scenarios

The environment is a task-driven testbench (`test_bench.v`) that runs one testcase from `testcases/` per simulation.

- **APB Master Tasks:** `test_bench.write()` and `test_bench.read()` generate protocol-compliant APB transfers (setup phase, access phase held until `tim_pready`) with byte strobes.
- **Golden Reference Model:** `mod_golden_cnt` tracks the expected 64-bit counter value in parallel with the DUT, following the TCR, TDR and THCSR writes seen on the bus.
- **Self-Checking:** Each testcase compares read data, flags and error responses against expected values, prints `[PASSED]`/`[FAILED]` per check, and reports a final verdict.
- **Testcase Suite:** 15 independent testcase files, listed in `sim/pat.list` and run in sequence by `run.csh`; `report.csh` summarizes the results.

| Test Scenario | Testcase File (`Pat name`) | Verification Objective |
| :--- | :--- | :--- |
| **Register Reset Values** | `reg_init_chk.v` | Verify reset default values of all registers. |
| **Register Read / Write** | `reg_rw_chk.v` | Exercise read and write operations on all register fields. |
| **Byte Access** | `reg_byte_access.v` | Verify byte writes using `tim_pstrb[3:0]` without corrupting adjacent bytes. |
| **Reserved Space** | `reg_reserved_chk.v` | Verify RAZ/WI behavior on reserved register addresses. |
| **One-Hot Pattern** | `reg_1hot_chk.v` | Write one-hot patterns to detect bit-coupling between register fields. |
| **Counter Basic Operation** | `cnt_counting_chk.v` | Verify counting, carry from `TDR0` to `TDR1`, updating `TDR0/1` while counting, and clear on disable/resume. |
| **Prescaler Control** | `cnt_ctrl_chk.v` | Verify counting speed for `div_en` / `div_val` settings and counting after `timer_en` 1 -> 0 -> 1. |
| **Counter Behavior** | `cnt_behavior_chk.v` | Verify hardware auto-clear vs APB write, and APB write vs hardware increment (APB write wins). |
| **Debug Halted Mode** | `cnt_halt_chk.v` | Verify counter freeze and `halt_ack` with `dbg_mode = 1`, and no halt with `dbg_mode = 0`. |
| **APB Protocol** | `apb_protocol_chk.v` | Normal transfer, and wrong-protocol cases (only `PENABLE`, only `PSEL`) that must not change registers. |
| **APB Wait State** | `apb_rw_chk.v` | Check the 1-cycle wait state (`tim_pready`) on write and read transfers. |
| **Error Response Handling** | `apb_pslverr_chk.v` | Verify `tim_pslverr` on illegal `div_val` writes and on config changes while the timer is running. |
| **Multiple Bus Access** | `apb_multiple_access.v` | Back-to-back transfers (write-write then read-read, and write-read pairs) with data checks. |
| **Unaligned Address Access** | `apb_unaligned_chk.v` | Issue unaligned address requests and verify aligned register values are preserved. |
| **Interrupt Lifecycle** | `interrupt_chk.v` | Verify `tim_int` set on match, `TIER` masking, RW1C clear, sticky behavior and clear priority. |

## 5. Register Specification

| Address | Abbreviation | Register Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `0x00` | **TCR** | Timer Control Register | R/W | `0x0000_0100` | Timer enable (`bit 0`), prescaler enable (`bit 1`), and division factor `DIV_VAL` (`bits 11:8`). |
| `0x04` | **TDR0** | Timer Data Register 0 | R/W | `0x0000_0000` | Lower 32-bit counter value. Auto-clears to `0` when `timer_en` falls. |
| `0x08` | **TDR1** | Timer Data Register 1 | R/W | `0x0000_0000` | Upper 32-bit counter value. Auto-clears to `0` when `timer_en` falls. |
| `0x0C` | **TCMP0** | Timer Compare Register 0 | R/W | `0xFFFF_FFFF` | Lower 32-bit compare value for the interrupt. |
| `0x10` | **TCMP1** | Timer Compare Register 1 | R/W | `0xFFFF_FFFF` | Upper 32-bit compare value for the interrupt. |
| `0x14` | **TIER** | Timer Interrupt Enable Register | R/W | `0x0000_0000` | Interrupt enable mask (`bit 0`). |
| `0x18` | **TISR** | Timer Interrupt Status Register | RW1C | `0x0000_0000` | Interrupt pending status (`bit 0`). Write 1 to clear. |
| `0x1C` | **THCSR** | Timer Halt Control Status Register | R/W | `0x0000_0000` | Debug halt request (`bit 0`, RW) and halt acknowledge (`bit 1`, RO). |

## 6. Code Coverage

Code coverage was collected with **QuestaSim / ModelSim Intel Starter 2024.3** using `+cover=bcesft` (branch, condition, expression, statement, FSM, toggle).

- **Statement / Branch / FSM / Toggle:** 100% on the DUT modules (`apb_slave`, `register`, `counter_control`, `counter`) after exclusions.
- **Condition / Expression (FEC):** 100% after exclusions.
- **Exclusions (`sim/exclude.do`):**
  - Reserved `TCR` bits (toggle), which are not implemented.
  - FEC rows in `apb_slave.v` lines 46-48 that are decided only by `PSEL` or `PENABLE` in the ACCESS state. They need a master that drops `PSEL`/`PENABLE` inside the ACCESS cycle, which is an APB protocol violation and is outside the verification plan.

## 7. Regression Results

The full regression was run with `./run.csh cov` and summarized with `./report.csh`.

| Metric | Result |
| :--- | :--- |
| **Total Testcases Run** | 15 |
| **Passed Testcases** | 15 |
| **Failed Testcases** | 0 |
| **Regression Status** | **PASSED (15/15/0)** |

### Simulation Evidence

**Regression Testsuite Results (`./report.csh`)**

![Regression Summary](docs/regression_result.png)

**QuestaSim Code Coverage Report**

![Coverage Report](docs/code_coverage_result.png)

**Simulation Waveform (last testcase of the regression)**

![Regression Waveform](docs/waveform_regression_test.png)

## 8. Tools and Technologies

- **Hardware Description Language:** Verilog
- **Simulation & EDA Tool:** QuestaSim / ModelSim 2024.3 (Intel Starter FPGA Edition)
- **Automation:** Make (`Makefile`), C-shell scripts (`run.csh`, `report.csh`), Tcl / DO script (`exclude.do`)
- **Version Control:** Git & GitHub

## 9. Repository Structure

```text
apb_timer_ip/
├── docs/
│   ├── Timer_Design_Spec.pdf          # IP design specification
│   ├── VPLAN_TIMER_IP.xlsx            # Verification plan
│   ├── block_diagram.png              # IP architecture block diagram
│   ├── apb_waveform.png               # APB transfer waveform
│   ├── regression_result.png          # Regression result screenshot
│   ├── code_coverage_result.png       # Coverage report screenshot
│   └── waveform_regression_test.png   # Simulation waveform screenshot
├── rtl/
│   ├── apb_slave.v                    # APB slave FSM and wait-state logic
│   ├── register.v                     # Address decoder, registers, interrupt logic
│   ├── counter_control.v              # Prescaler and debug halt logic
│   ├── counter.v                      # 64-bit counter
│   └── apb_timer_ip.v                 # Top-level wrapper
├── sim/
│   ├── compile.f                      # Compile options
│   ├── exclude.do                     # Coverage exclusions
│   ├── Makefile                       # Build / run / coverage targets
│   ├── pat.list                       # Testcase list for regression
│   ├── report.csh                     # Regression summary script
│   ├── rtl.f                          # RTL file list
│   ├── run.csh                        # Regression run script
│   └── tb.f                           # Testbench file list
├── tb/
│   └── test_bench.v                   # Verilog testbench (APB tasks, golden counter)
├── testcases/                         # 15 testcase files
│   ├── apb_multiple_access.v
│   ├── apb_protocol_chk.v
│   ├── apb_pslverr_chk.v
│   ├── apb_rw_chk.v
│   ├── apb_unaligned_chk.v
│   ├── cnt_behavior_chk.v
│   ├── cnt_counting_chk.v
│   ├── cnt_ctrl_chk.v
│   ├── cnt_halt_chk.v
│   ├── interrupt_chk.v
│   ├── reg_1hot_chk.v
│   ├── reg_byte_access.v
│   ├── reg_init_chk.v
│   ├── reg_reserved_chk.v
│   └── reg_rw_chk.v
├── .gitignore                         # Simulation output exclusion rules
└── README.md
```

## 10. Key Learning Outcomes

- **AMBA APB:** Implemented an APB slave with 32-bit transfers, byte strobes, one wait state per transfer and error signaling, and debugged a wait-state bug found through waveform analysis.
- **RTL Design:** Built a 64-bit counter with prescaling (up to divide-by-256), hardware auto-clear, and debug halt handshaking.
- **Interrupt Logic:** Built a maskable level interrupt from a 64-bit compare with RW1C status handling.
- **Verification Planning & Testbench:** Wrote a verification plan (Excel) mapped to testcases, and a task-driven self-checking testbench with a golden counter model.
- **Coverage Closure:** Analyzed statement, branch, FSM, toggle and expression coverage in QuestaSim, and justified each exclusion in `exclude.do`.
- **Regression Flow:** Used Makefile and C-shell scripts to run the testcase list and summarize results.

## 11. Documentation & References

- [Timer IP Design Specification (PDF)](docs/Timer_Design_Spec.pdf) - architecture, register map and timing diagrams.
- [Timer IP Verification Plan (Excel)](docs/VPLAN_TIMER_IP.xlsx) - verification scope and test scenario matrix.
