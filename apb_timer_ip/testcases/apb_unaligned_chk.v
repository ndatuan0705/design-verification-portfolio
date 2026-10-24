task run_test();
    reg [31:0] rdata;
    reg err_flag;
    begin
        $display("========================================");
        $display("===== TEST CASE: APB_UNALIGNED_CHECK ====");
        $display("========================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("Set initial values to register to check after");
        test_bench.write(12'h00, 32'h0000_0800, 4'hF);  //TCR div_val = 8
        test_bench.write(12'h04, 32'h1111_1111, 4'hF);  //TDR0
        test_bench.write(12'h08, 32'h2222_2222, 4'hF);  //TDR1

        $display("Write to unaligned address");
        test_bench.write(12'h01, 32'hAAAA_AAAA, 4'hF);
        test_bench.write(12'h02, 32'hBBBB_BBBB, 4'hF);
        test_bench.write(12'h03, 32'hCCCC_CCCC, 4'hF);

        test_bench.write(12'h05, 32'hDDDD_DDDD, 4'hF);
        test_bench.write(12'h06, 32'hEEEE_EEEE, 4'hF);
        test_bench.write(12'h07, 32'hFFFF_FFFF, 4'hF);

        test_bench.write(12'h09, 32'h9999_9999, 4'hF);
        test_bench.write(12'h0A, 32'h8888_8888, 4'hF);

        $display("Checking if aligned register are preserved");
        //READ TCR
        test_bench.read(12'h00, rdata, err_flag);
        if (rdata === 32'h0000_0800) begin
            $display("[PASSED] TCR is unchanged: %0h", rdata);
        end else begin
            $display("[FAILED] TCR is changed | Expected: 0x0000_0800 | Actual: %0h", rdata);
            err = err + 1;
        end

        //READ TDR0
        test_bench.read(12'h04, rdata, err_flag);
        if (rdata === 32'h1111_1111) begin
            $display("[PASSED] TDR0 is unchanged: %0h", rdata);
        end else begin
            $display("[FAILED] TDR0 is changed | Expected: 0x1111_1111 | Actual: %0h", rdata);
            err = err + 1;
        end

        //READ TDR1
        test_bench.read(12'h08, rdata, err_flag);
        if (rdata === 32'h2222_2222) begin
            $display("[PASSED] TDR1 is unchanged: %0h", rdata);
        end else begin
            $display("[FAILED] TDR1 is changed | Expected: 0x2222_2222 | Actual: %0h", rdata);
            err = err + 1;
        end

        $display("========================================");
        if (err == 0) $display("========= [PASSED] APB_UNALIGNED_CHECK =========");
        else $display("========= [FAILED] APB_UNALIGNED_CHECK ( %0d erros found ) =========", err);
        $display("========================================");
    end
endtask
