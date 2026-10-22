task run_test();
    reg [31:0] rdata0, rdata1;
    reg err_flag;
    reg [31:0] tcr_data;
    reg [63:0] dut_cnt;
    integer idx;
    integer test_cycle;
    begin
        $display("========================================");
        $display("====== TEST CASE: CNT CONTROL CHECK ====");
        $display("========================================");
        err = 0;

        $display("1. Check with div_en = 0");

        test_cycle = 50;
        test_bench.rst_n = 0;
        repeat (5) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (5) @(posedge test_bench.clk);
        //timer_en = 1, div_en = 0
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);

        repeat (test_cycle) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0
        dut_cnt = {rdata1, rdata0};

        if (dut_cnt == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] div_en = 0 | DUT = %0d | Golden = %0d", dut_cnt,
                     test_bench.u_tb_cnt.golden_cnt_snap);
        end else begin
            $display("[FAILED] div_en = 0 | DUT = %0d | Golden = %0d", dut_cnt,
                     test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end


        for (idx = 0; idx <= 8; idx = idx + 1) begin
            $display("[%0d] Check with div_en = 1, div_val = %0d", idx, idx);
            test_bench.rst_n = 0;
            repeat (5) @(posedge test_bench.clk);
            test_bench.rst_n = 1;
            repeat (5) @(posedge test_bench.clk);

            test_cycle = 10 * (1 << idx);
            //Set timer_en on: div_val = 1, div_en = 1, timer_en = 1
            tcr_data   = 32'h0000_0003 | (idx << 8);

            test_bench.write(12'h00, tcr_data, 4'hF);


            repeat (test_cycle) @(posedge test_bench.clk);

            test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
            test_bench.read(12'h04, rdata0, err_flag);  //read TDR0
            dut_cnt = {rdata1, rdata0};

            if (dut_cnt == test_bench.u_tb_cnt.golden_cnt_snap) begin
                $display("[PASSED] div_en = 1 & div_val = %0d | DUT = %0d | Golden = %0d", idx,
                         dut_cnt, test_bench.u_tb_cnt.golden_cnt_snap);
            end else begin
                $display("[FAILED] div_en = 1 & div_val = %0d | DUT = %0d | Golden = %0d", idx,
                         dut_cnt, test_bench.u_tb_cnt.golden_cnt_snap);
                err = err + 1;
            end
            //IMPROVE COVERAGE
            tcr_data = 32'h0000_0002 | (idx << 8);
            test_bench.write(12'h00, tcr_data, 4'hF);
            repeat (5) @(posedge test_bench.clk);

        end

        $display("3. Check with div_en = 0, div_val = 2");
        test_cycle = 50;
        test_bench.rst_n = 0;
        repeat (5) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (5) @(posedge test_bench.clk);

        test_bench.write(12'h00, 32'h0000_0201, 4'hF);

        repeat (test_cycle) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0

        dut_cnt = {rdata1, rdata0};

        if (dut_cnt == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] div_en = 0 & div_val = 2 | DUT = %0d | Golden = %0d", dut_cnt,
                     test_bench.u_tb_cnt.golden_cnt_snap);
        end else begin
            $display("[FAILED] div_en = 0 & div_val = 2 | DUT = %0d | Golden = %0d", dut_cnt,
                     test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end


        $display("4. Check counting after timer_en 1 -> 0 -> 1");

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        //Start timer div_en = 0
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);
        repeat (50) @(posedge test_bench.clk);
        //Stop timer
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        repeat (10) @(posedge test_bench.clk);

        //Change div_val = 4, div_en = 1
        test_bench.write(12'h00, 32'h0000_0402, 4'hF);
        //Set_timer = 1
        test_bench.write(12'h00, 32'h0000_0403, 4'hF);

        test_cycle = 160;
        repeat (test_cycle) @(posedge test_bench.clk);

        test_bench.read(12'h08, rdata1, err_flag);  //read TDR1
        test_bench.read(12'h04, rdata0, err_flag);  //read TDR0
        dut_cnt = {rdata1, rdata0};

        if (dut_cnt == test_bench.u_tb_cnt.golden_cnt_snap) begin
            $display("[PASSED] Counter works normally with new setup | DUT = %0d | Golden = %0d",
                     dut_cnt, test_bench.u_tb_cnt.golden_cnt_snap);
        end else begin
            $display("[FAILED] Counter incorrect after resume | DUT = %0d | Golden = %0d", dut_cnt,
                     test_bench.u_tb_cnt.golden_cnt_snap);
            err = err + 1;
        end

        $display("========================================");
        if (err == 0) $display("========= [PASSED] CNT_CONTROL_CHECK =========");
        else $display("========= [FAILED] CNT_CONTROL_CHECK ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask
