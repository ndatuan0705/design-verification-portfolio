# Synchronous FIFO Design Verification using SystemVerilog UVM

## 1. Overview
This project implements a SystemVerilog UVM-based verification environment for a synchronous FIFO (First-In, First-Out) design.
The testbench verifies FIFO behavior under normal operating conditions, boundary conditions, concurrent read/write operations, and reset scenarios. A reference queue is used as the expected data model, while the scoreboard checks the DUT outputs against the expected behavior.
The project focuses on reusable UVM components, self-checking verification, functional coverage, and regression testing.

## 2. DUT Specifications

| Parameter | Description |
| :--- | :--- |
| **Data width** | 8 bits |
| **FIFO depth** | 16 entries |
| **Clock** | Single synchronous clock (`clk`) |
| **Reset** | Active-low reset (`rst_n`) |
| **Inputs** | `clk`, `rst_n`, `wr_en`, `rd_en`, `data_in` |
| **Outputs** | `full`, `empty`, `data_out` |

## 3. Verification Architecture

![UVM Testbench Architecture](docs/uvm_sync_fifo_architecture.png)

The verification environment follows a modular UVM architecture:
*   **UVM Test:** Configures the environment and starts the selected sequences (`fifo_test.sv`).
*   **Sequences:** Generate stimulus for normal operations, overflow/underflow attempts, concurrent read/write operations, and reset scenarios (`fifo_sequence.sv`).
*   **Sequencer:** Manages the sequence items and passes them to the driver.
*   **Driver:** Converts sequence items into pin-level stimulus through the virtual interface.
*   **Monitor:** Samples DUT interface activity via `monitor_cb` and publishes observed transactions through an analysis port.
*   **Scoreboard:** Maintains a reference queue (`ref_q[$]`), checks FIFO status flags (`full`, `empty`), and compares actual output data against expected data.
*   **Functional Coverage:** Tracks FIFO state transitions and selected read/write scenarios via a `uvm_subscriber`.
*   **Interface:** Provides clocking blocks for coordinated signal driving and sampling, alongside concurrent SystemVerilog Assertions (SVA).
*   **DUT:** The synchronous FIFO RTL being verified.

The environment uses a configurable active agent, scoreboard, and coverage collector managed by `fifo_env_config.sv`.

## 4. Verification Scenarios

| Test Scenario | Sequence Name | Verification Objective |
| :--- | :--- | :--- |
| **Fill then empty** | `T_FILL_THEN_EMPTY_seq` | Write data until the FIFO is full (16 items), then read data until empty and check ordering. |
| **Overflow & Underflow attempt** | `T_OVERFLOW_UNDERFLOW_ATTEMPT_seq` | Attempt a write while the FIFO is full and check hold-full behavior. Attempt a read while the FIFO is empty and check hold-empty behavior. |
| **Concurrent read/write** | `T_CONCURRENT_RW_seq` | Exercise simultaneous read and write requests around boundary conditions. |
| **Reset during operation** | `T_RESET_ON_THE_FLY_seq` | Apply random reset during ongoing FIFO activity and check the resulting behavior and recovery. |
| **Regression** | `T_REGRESSION_seq` | Run all the above multiple scenarios sequentially through a master regression sequence. |

## 5. Scoreboard and Reference Model
The scoreboard (`fifo_scoreboard.sv`) uses a SystemVerilog queue (`ref_q[$]`) as a reference model to represent the expected FIFO contents.
Its main responsibilities include:
*   Updating the reference model according to accepted write (`wr_en=1, full=0`) and read (`rd_en=1, empty=0`) operations.
*   Checking the `full` and `empty` flags against the reference queue state (`ref_q.size()`).
*   Comparing the actual output data with the expected data popped from the queue.
*   Reporting mismatches to help identify functional bugs.

The reference model is used independently of the DUT's internal storage implementation.

## 6. Functional Coverage
The functional coverage model (`fifo_coverage.sv`) includes:
*   **Full transition coverage:** 0 → 1 and 1 → 0.
*   **Empty transition coverage:** 0 → 1 and 1 → 0.
*   **Write/read enable coverage:** Both control signals are exercised in their defined states.
*   **Overflow-attempt coverage:** Cross coverage for write requests while the FIFO is full (`cross_write_full`).
*   **Underflow-attempt coverage:** Cross coverage for read requests while the FIFO is empty (`cross_read_empty`).
*   **Concurrent read/write coverage:** Selected combinations of read enable, write enable, and FIFO status (`cross_wr_rd`).

## 7. Regression Results
The regression was executed using **Cadence Xcelium (v25.03)** with UVM 1.2.

| Metric | Result |
| :--- | :--- |
| **Regression Status** | PASSED |
| **Transactions Checked** | 214 successful |
| **Scoreboard Mismatches** | 0 reported errors |
| **Functional Coverage** | 100.00% |
| **SVA Violations** | 0 |

### Simulation Evidence
**UVM Log Summary:**

![Regression Summary](docs/regression_summary.png)

**Functional Coverage Report:**
![Coverage Report](docs/coverage_report.png)

**Regression Waveform:**
![Regression Waveform](docs/regression_waveform.png)

**Full/Empty Transitions Waveform:**
![Full Empty Waveform](docs/full_empty_waveform.png)

## 8. Tools and Technologies
*   SystemVerilog
*   Universal Verification Methodology (UVM 1.2)
*   Cadence Xcelium
*   Git and GitHub

## 9. Repository Structure
```text
sync-fifo-uvm-verification/
├── docs/
│   ├── uvm_sync_fifo_architecture.png
│   ├── coverage_report.png
│   ├── regression_summary.png
│   ├── regression_waveform.png
│   └── full_empty_waveform.png
├── rtl/
│   └── design.sv
├── tb/
│   ├── fifo_agent.sv
│   ├── fifo_coverage.sv
│   ├── fifo_driver.sv
│   ├── fifo_env_config.sv
│   ├── fifo_env.sv
│   ├── fifo_if.sv
│   ├── fifo_monitor.sv
│   ├── fifo_pkg.sv
│   ├── fifo_scoreboard.sv
│   ├── fifo_seq_item.sv
│   ├── fifo_sequence.sv
│   ├── fifo_sequencer.sv
│   ├── fifo_test.sv
│   └── testbench.sv
├── .gitignore
└── README.md
```

## 10. Key Learning Outcomes
Through this project, I practiced:
*   Building a modular UVM testbench from scratch.
*   Developing sequences, sequence items, drivers, and monitors.
*   Using a reference queue for self-checking verification in the Scoreboard.
*   Implementing scoreboard checks for data integrity and FIFO status flags.
*   Developing functional coverage for state transitions and read/write cross scenarios.
*   Integrating SystemVerilog Assertions (SVA) within the interface.
*   Running regression tests and analyzing simulation results.

## 11. Future Improvements
*   Add more corner-case scenarios and improve coverage quality.
*   Add or extend SystemVerilog Assertions where appropriate (e.g., checking internal pointers).
*   Improve randomized stimulus and constraint-based testing (e.g., randomizing delays between transactions).
*   Expand the regression report with clearer per-test summaries using bash/python scripts.
