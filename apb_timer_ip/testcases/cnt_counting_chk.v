task run_test();
    reg [31:0] rdata0, rdata1;
    reg err_flag;
    begin
        $display("========================================");
        $display("====== TEST CASE: CNT_COUNTING_CHECK ===");
        $display("========================================");
        err = 0;

        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        test_bench.write(12'h14, 32'h0000_0000, 4'hF);
        test_bench.write(12'h1C, 32'h0000_0000, 4'hF);

        $display("1. Boundary of TDR0 (TDR0 -> TDR1)");
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);
        test_bench.write(12'h04, 32'hFFFF_FF00, 4'hF);  //Set TDR0
        //Set timer_en = 1
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);

        repeat (256) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0

        test_bench.write(12'h00, 32'h0000_0100, 4'hF);

        if (rdata1 == 32'h0000_0001) begin
            $display("[PASSED] TDR1 incremented correctly | TDR0 = %0h", rdata0);
        end else begin
            $display("[FAILED] TDR1 did not incremented | Expected: 1, Actual: %0h", rdata1);
            err = err + 1;
        end

        $display("2. Boundary of TDR1");
        test_bench.write(12'h08, 32'hFFFF_FFFF, 4'hF);
        test_bench.write(12'h04, 32'hFFFF_FF00, 4'hF);
        //Set timer_en = 1
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);

        repeat (256) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0

        test_bench.write(12'h00, 32'h0000_0100, 4'hF);

        if (rdata1 == 32'h0000_0000) begin
            $display("[PASSED] TDR1 overflowed to 0 correctly | TDR0 = %0h", rdata0);
        end else begin
            $display("[FAILED] TDR1 did not overflowed to 0 | Actual: %0h", rdata1);
            err = err + 1;
        end

        //Clear timer_en
        test_bench.write(12'h00, 32'h0000_0100, 4'hF);


        $display("3. Update TDR0/1 while counting");
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);
        //Set timer_en = 1
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);

        repeat (256) @(posedge test_bench.clk);
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);
        test_bench.write(12'h04, 32'hFFFF_FF00, 4'hF);  //Set TDR0

        repeat (256) @(posedge test_bench.clk);
        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1

        if (rdata1 == 32'h0000_0001) begin
            $display("[PASSED] Update successful | TDR1 = 1");
        end else begin
            $display("[FAILED] Update failed | TDR1: %0h", rdata1);
            err = err + 1;
        end

        //Clear timer_en
        test_bench.write(12'h00, 32'h0000_0100, 4'hF);



        $display("4. Timer disabled & Resumed (Clear Counter)");
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);
        //Set timer_en = 1
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);

        repeat (50) @(posedge test_bench.clk);
        test_bench.write(12'h00, 32'h0000_0100, 4'hF);

        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0
        if (rdata0 == 32'h0000_0000) begin
            $display("[PASSED] Counter reset to 0 when timer_en H-> L");
        end else begin
            $display("[FAILED] Counter NOT reset to 0 | Actual: %0h", rdata0);
            err = err + 1;
        end


        //Write value to TDR0/1 and read back while timer_en = 0
        test_bench.write(12'h04, 32'h0000_ABCD, 4'hF);
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0
        if (rdata0 == 32'h0000_ABCD) begin
            $display("[PASSED] APB write works normally when timer_en = 0");
        end else begin
            $display("[FAILED] APB write failed when timer_en = 0 | Actual: %0h", rdata0);
            err = err + 1;
        end

        $display("========================================");
        if (err == 0) $display("========= [PASSED] CNT_COUNTING_CHECK =========");
        else $display("========= [FAILED] CNT_COUNTING_CHECK ( %0d erros found ) =========", err);
        $display("========================================");
    end
endtask
