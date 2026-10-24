task run_test();
    reg [31:0] read_val;
    reg err_flag;
    begin
        $display("========================================");
        $display("====== TEST CASE: REG_ONE_HOT_CHECK ====");
        $display("========================================");
        err = 0;

        test_bench.write(12'h00, 32'h0000_0200, 4'hF);
        test_bench.write(12'h04, 32'h0000_0001, 4'hF);
        test_bench.write(12'h08, 32'h0000_0002, 4'hF);
        test_bench.write(12'h0C, 32'h0000_0004, 4'hF);
        test_bench.write(12'h10, 32'h0000_0008, 4'hF);
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);
        test_bench.write(12'h1C, 32'h0000_0000, 4'hF);

        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0200, 32'hFFFF_FFFF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h0000_0002, 32'hFFFF_FFFF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h0000_0004, 32'hFFFF_FFFF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h0000_0008, 32'hFFFF_FFFF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("========================================");
        if (err == 0) $display("========= [PASSED] REG_ONE_HOT_CHECK =========");
        else $display("========= [FAILED] REG_ONE_HOT_CHECK ( %0d erros found ) =========", err);
        $display("========================================");
    end
endtask
