task run_test();
    reg [31:0] read_val;
    reg read_err;
    begin
        $display("========================================");
        $display("========= TEST CASE: REG_INIT_CHECK =====");
        $display("========================================");
        err = 0;

        $display("Checking TCR");
        test_bench.read(12'h00, read_val, read_err);
        test_bench.check_data(12'h00, read_val, 32'h0000_0100, 32'hFFFF_FFFF);

        $display("Checking TDR0");
        test_bench.read(12'h04, read_val, read_err);
        test_bench.check_data(12'h04, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("Checking TDR1");
        test_bench.read(12'h08, read_val, read_err);
        test_bench.check_data(12'h08, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("Checking TCMP0");
        test_bench.read(12'h0C, read_val, read_err);
        test_bench.check_data(12'h0C, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

        $display("Checking TCMP1");
        test_bench.read(12'h10, read_val, read_err);
        test_bench.check_data(12'h10, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

        $display("Checking TIER");
        test_bench.read(12'h14, read_val, read_err);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("Checking TISR");
        test_bench.read(12'h18, read_val, read_err);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("Checking THCSR");
        test_bench.read(12'h1C, read_val, read_err);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("========================================");
        if(err==0) $display("========= [PASSED] REG_INIT_CHECK =========");
        else $display("========= [FAILED] REG_INIT_CHECK ( %0d erros found ) =========", err);
        $display("========================================");
    end
endtask