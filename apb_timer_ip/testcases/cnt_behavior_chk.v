task run_test();
    reg [31:0] rdata0, rdata1;
    reg err_flag;
    begin
        $display("================================================");
        $display("======== TEST CASE: CNT_BEHAVIOR_CHECK =========");
        $display("================================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);


        $display("1. Hardware Auto-Clear vs APB Write");

        $display("1.1 timer_en H->L auto-clears TDR0/TDR1");
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  // div_en = 0, div_val = 0, timer_en = 0
        test_bench.write(12'h04, 32'h1234_5678, 4'hF);  // TDR0
        test_bench.write(12'h08, 32'h9ABC_DEF0, 4'hF);  // TDR1
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  // timer_en = 1
        repeat (10) @(posedge test_bench.clk);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  // timer_en = 0 -> HW auto-clear
        test_bench.read(12'h04, rdata0, err_flag);
        test_bench.read(12'h08, rdata1, err_flag);
        if (rdata0 === 32'h0000_0000 && rdata1 === 32'h0000_0000) begin
            $display("[PASSED] [1.1] TDR1:TDR0 cleared when timer_en falls");
        end else begin
            $display("[FAILED] [1.1] Expected: 0 / 0 | Actual TDR1 / TDR0: %0h / %0h", rdata1,
                     rdata0);
            err = err + 1;
        end

        $display("1.2 APB write right after auto-clear is not lost");
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  // timer_en = 1
        repeat (10) @(posedge test_bench.clk);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  // timer_en = 0 -> HW auto-clear
        test_bench.write(12'h04, 32'h5555_5555, 4'hF);  // APB write right after
        test_bench.read(12'h04, rdata0, err_flag);
        if (rdata0 === 32'h5555_5555) begin
            $display("[PASSED] [1.2] TDR0 = 0x5555_5555 (APB write after auto-clear kept)");
        end else begin
            $display("[FAILED] [1.2] Expected: 5555_5555 | Actual TDR0: %0h", rdata0);
            err = err + 1;
        end

        $display("1.3 APB write before stop is overwritten by auto-clear");
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  // timer_en = 1
        test_bench.write(12'h04, 32'hAAAA_AAAA, 4'hF);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  // timer_en = 0 -> HW auto-clear
        test_bench.read(12'h04, rdata0, err_flag);
        if (rdata0 === 32'h0000_0000) begin
            $display("[PASSED] [1.3] TDR0 = 0 after stop");
        end else begin
            $display("[FAILED] [1.3] Expected: 0 | Actual TDR0: %0h", rdata0);
            err = err + 1;
        end

        $display("2. APB Write vs Hardware Increment");

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  // div_en = 0 
        repeat (20) @(posedge test_bench.clk);
        test_bench.write(12'h04, 32'hAAAA_AAAA, 4'hF);  // collides with HW increment
        test_bench.read(12'h04, rdata0, err_flag);
        test_bench.read(12'h08, rdata1, err_flag);

        if (rdata0 >= 32'hAAAA_AAAA && rdata0 <= 32'hAAAA_AAAA + 32'd32 && rdata1 === 32'h0) begin
            $display("[PASSED] [2.1] TDR0 = %0h (write won, then kept counting)", rdata0);
        end else begin
            $display(
                "[FAILED] [2.1] Expected: AAAA_AAAA..AAAA_AACA / 0 | Actual TDR0 / TDR1: %0h / %0h",
                rdata0, rdata1);
            err = err + 1;
        end

        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  // stop timer

        $display("================================================");
        if (err == 0) $display("========= [PASSED] CNT_BEHAVIOR_CHECK =========");
        else $display("========= [FAILED] CNT_BEHAVIOR_CHECK ( %0d erros found ) =========", err);
        $display("================================================");
    end
endtask
