task run_test();
    reg [31:0] read_val;
    reg err_flag;
    begin
        $display("========================================");
        $display("====== TEST CASE: REG RESERVED CHECK ====");
        $display("========================================");
        err = 0;

        $display("Checking RESERVED ADDRESS 0x20");
        test_bench.write(12'h20, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h20, read_val, err_flag);
        test_bench.check_data(12'h20, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("Checking RESERVED ADDRESS 0xFFC");
        test_bench.write(12'hFFC, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'hFFC, read_val, err_flag);
        test_bench.check_data(12'hFFC, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        $display("========================================");
        if(err==0) $display("========= [PASSED] REG RESERVED CHECK =========");
        else $display("========= [FAILED] REG_RESERVED_CHECK ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask