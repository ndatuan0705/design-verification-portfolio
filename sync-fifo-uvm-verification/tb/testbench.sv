`timescale 1ns / 1ps
`include "uvm_macros.svh"
`include "fifo_pkg.sv"
`include "fifo_if.sv"
module tb_top;
    import uvm_pkg::*;
    import fifo_pkg::*;

    logic clk;


    initial begin
        clk = 0;
        forever #5 clk = ~clk;  //10ns
    end


    fifo_if vif (clk);
    initial vif.rst_n = 1'b0;

    Syn_FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .clk(clk),
        .rst_n(vif.rst_n),
        .wr_en(vif.wr_en),
        .rd_en(vif.rd_en),
        .data_in(vif.data_in),
        .data_out(vif.data_out),
        .full(vif.full),
        .empty(vif.empty)
    );


    initial begin
        $display("[TB_TOP] SIMULATION STARTED");
        $display("[TB_TOP] =============================");

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);


        uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top", "vif", vif);


        run_test();
    end
endmodule
