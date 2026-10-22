task run_test();
    reg [31:0] rdata;
    reg err_flag;
    begin
        $display("========================================");
        $display("====== TEST CASE: APB PROTOCOL CHECK ====");
        $display("========================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("1. Normal APB Test");
        test_bench.write(12'h04, 32'h3333_3333, 4'hF);
        test_bench.read(12'h04, rdata, err_flag);
        test_bench.check_data(12'h04, rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        $display("2. Wrong protocol test: penable does not assert");
        test_bench.apb_penable_err = 1;
        test_bench.write(12'h04, 32'h5555_5555, 4'hF);
        test_bench.apb_penable_err = 0;

        test_bench.read(12'h04, rdata, err_flag);
        test_bench.check_data(12'h04, rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        $display("3. Wrong protocol test: psel does not assert");
        test_bench.apb_psel_err = 1;
        test_bench.write(12'h04, 32'h7777_7777, 4'hF);
        test_bench.apb_psel_err = 0;

        test_bench.read(12'h04, rdata, err_flag);
        test_bench.check_data(12'h04, rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        $display("========================================");
        if (err == 0) $display("========= [PASSED] APB_PROTOCOL_CHECK =========");
        else $display("========= [FAILED] APB_PROTOCOL_CHECK ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask
