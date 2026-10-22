task run_test();
    reg [31:0] rdata0, rdata1, rdata_thcsr;
    reg err_flag;
    reg [63:0] dut_cnt_1, dut_cnt_2;
    begin
        $display("========================================");
        $display("======== TEST CASE: CNT HALT CHECK ======");
        $display("========================================");
        err = 0;

        $display("1. Valid Halt Request (dbg_mode = 1)");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.dbg_mode = 1'b1;

        test_bench.write(12'h00, 32'h0000_0001, 4'hF);
        repeat (20) @(posedge test_bench.clk);

        test_bench.write(12'h1C, 32'h0000_0001, 4'hF);
        repeat (5) @(posedge test_bench.clk);

        test_bench.read(12'h1C, rdata_thcsr, err_flag);
        if (rdata_thcsr[1] == 1'b1) begin
            $display("[PASSED] halt_ack is asserted");
        end else begin
            $display("[FAILED] halt_ack is NOT asserted");
            err = err + 1;
        end

        test_bench.read(12'h08, rdata1, err_flag);
        test_bench.read(12'h04, rdata0, err_flag);
        dut_cnt_1 = {rdata1, rdata0};

        repeat (20) @(posedge test_bench.clk);
        test_bench.read(12'h08, rdata1, err_flag);
        test_bench.read(12'h04, rdata0, err_flag);
        dut_cnt_2 = {rdata1, rdata0};

        if (dut_cnt_1 == dut_cnt_2 && dut_cnt_2 == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] Counter successfully HALTED at %0d", dut_cnt_2);
        end else begin
            $display(
                "[FAILED] Counter did not halt or mismatch | cnt1 = %0d | cnt2 = %0d | golden = %0d",
                dut_cnt_1, dut_cnt_2, test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end

        $display("Resuming counter (halt_req = 0)");
        test_bench.write(12'h1C, 32'h0000_0000, 4'hF);
        repeat (20) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);
        test_bench.read(12'h04, rdata0, err_flag);
        dut_cnt_1 = {rdata1, rdata0};

        if (dut_cnt_1 > dut_cnt_2 && dut_cnt_1 == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] Counter successfully RESUMED at value %0d", dut_cnt_1);
        end else begin
            $display("[FAILED] Counter resume error | DUT = %0d | Golden = %0d", dut_cnt_1,
                     test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end

        $display("2. Invalid Halt Request (dbg_mode = 0)");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.dbg_mode = 1'b0;

        test_bench.write(12'h00, 32'h0000_0001, 4'hF);
        repeat (20) @(posedge test_bench.clk);

        test_bench.write(12'h1C, 32'h0000_0001, 4'hF);
        repeat (5) @(posedge test_bench.clk);

        test_bench.read(12'h1C, rdata_thcsr, err_flag);
        if (rdata_thcsr[1] == 1'b0) begin
            $display("[PASSED] halt_ack is 0");
        end else begin
            $display("[FAILED] halt_ack is incorrectly asserted");
            err = err + 1;
        end

        test_bench.read(12'h08, rdata1, err_flag);
        test_bench.read(12'h04, rdata0, err_flag);
        dut_cnt_1 = {rdata1, rdata0};

        repeat (20) @(posedge test_bench.clk);
        test_bench.read(12'h08, rdata1, err_flag);
        test_bench.read(12'h04, rdata0, err_flag);
        dut_cnt_2 = {rdata1, rdata0};

        if (dut_cnt_2 > dut_cnt_1 && dut_cnt_2 == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] Counter did not halt, continued counting to %0d", dut_cnt_2);
        end else begin
            $display(
                "[FAILED] Counter behavior wrong when dbg_mode = 0 | cnt1 = %0d | cnt2 = %0d | golden = %0d",
                dut_cnt_1, dut_cnt_2, test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end

        $display("========================================");
        if (err == 0) $display("========= [PASSED] CNT_HALT_CHECK =========");
        else $display("========= [FAILED] CNT_HALT_CHECK ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask
