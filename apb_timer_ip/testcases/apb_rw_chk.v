task run_test();
    reg [31:0] rdata;
    reg err_flag;
    begin
        $display("========================================");
        $display("===== TEST CASE: APB_RW_CHECK (PREADY) ===");
        $display("========================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("1. Check Wait State during WRITE");
        //SETUP
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel    = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b1;
        test_bench.tim_paddr   = 12'h04;
        test_bench.tim_pwdata  = 32'hAA55_AA55;
        test_bench.tim_pstrb   = 4'hF;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;

        if (test_bench.tim_pready == 1'b1) begin
            $display(
                "[FAILED] WRITE: Pready is HIGH immediately when Penable asserted (Missing Wait State)");
            err = err + 1;
        end else begin
            $display("[PASSED] WRITE: Pready is LOW at 1st cycle of Access Phase (Wait State)");
        end

        wait (test_bench.tim_pready == 1'b1);
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel    = 1'b0;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b0;

        $display("2. Check Wait State during READ");
        repeat (2) @(posedge test_bench.clk);
        //SETUP
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel    = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b0;
        test_bench.tim_paddr   = 12'h04;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;

        if (test_bench.tim_pready == 1'b1) begin
            $display(
                "[FAILED] READ: Pready is HIGH immediately when Penable asserted (Missing Wait State)");
            err = err + 1;
        end else begin
            $display("[PASSED] READ: Pready is LOW at 1st cycle of Access Phase (Wait State)");
        end

        wait (test_bench.tim_pready == 1'b1);
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel    = 1'b0;
        test_bench.tim_penable = 1'b0;

        $display("========================================");
        if (err == 0) $display("========= [PASSED] APB_RW_CHECK (PREADY) =========");
        else
            $display(
                "========= [FAILED] APB_RW_CHECK (PREADY) ( %0d erros found ) =========", err
            );
        $display("========================================");
    end
endtask
