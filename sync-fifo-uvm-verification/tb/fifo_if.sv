import fifo_pkg::*;
interface fifo_if (
    input logic clk
);

    logic wr_en;
    logic rd_en;
    logic full;
    logic empty;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic rst_n;


    clocking driver_cb @(posedge clk);
        default input #1step output #1ns;
        output data_in, wr_en, rd_en, rst_n;
        input data_out, full, empty;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1step;
        input full, empty, data_out, data_in, wr_en, rd_en, rst_n;
    endclocking

    modport DRIVER(clocking driver_cb, input clk);
    modport MONITOR(clocking monitor_cb, input clk);


    property p_reset_behavior;
        @(posedge clk) (!rst_n) |-> (empty == 1'b1 && full == 1'b0);
    endproperty

    assert_p_reset_behavior :
    assert property (p_reset_behavior)
    else $error("[SVA FAIL] Rule 0: Reset behavior violated!");

    property p_not_full_and_empty;
        @(posedge clk) disable iff (!rst_n) !(empty && full);
    endproperty

    assert_p_not_full_and_empty :
    assert property (p_not_full_and_empty)
    else $error("[SVA FAIL] Rule 1: FIFO is both FULL and EMPTY simultaneously!");


    property p_no_xz_flags;
        @(posedge clk) disable iff (!rst_n) !$isunknown(
            {full, empty}
        );
    endproperty

    assert_p_no_xz_flags :
    assert property (p_no_xz_flags)
    else $error("[SVA FAIL] Rule 2: Full or Empty flag contains X/Z state!");

    property p_hold_full;
        @(posedge clk) disable iff (!rst_n) (full && wr_en && !rd_en) |=> full;
    endproperty

    assert_p_hold_full :
    assert property (p_hold_full)
    else $error("[SVA FAIL] Rule 3: Hold-Full violation (Full flag dropped unexpectedly)!");

    property p_hold_empty;
        @(posedge clk) disable iff (!rst_n) (empty && rd_en && !wr_en) |=> empty;
    endproperty

    assert_p_hold_empty :
    assert property (p_hold_empty)
    else $error("[SVA FAIL] Rule 4: Hold-Empty violation (Empty flag dropped unexpectedly)!");


    property p_valid_data_out;
        @(posedge clk) disable iff (!rst_n) (rd_en && !empty) |=> !$isunknown(
            data_out
        );
    endproperty

    assert_p_valid_data_out :
    assert property (p_valid_data_out)
    else $error("[SVA FAIL] Rule 5: Read data out contains X/Z values!");
endinterface
