package fifo_pkg;
    //Import UVM base and macros
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //Global Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    //Include file class
    `include "fifo_seq_item.sv"
    `include "fifo_env_config.sv"
    `include "fifo_sequence.sv"
    `include "fifo_sequencer.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_agent.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_coverage.sv"
    `include "fifo_env.sv"
    `include "fifo_test.sv"
endpackage
