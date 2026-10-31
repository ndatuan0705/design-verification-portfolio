task run_test();
    reg [31:0] rdata0, rdata1;
    reg err_flag;
    begin
        $display("================================================");
        $display("======== TEST CASE: APB_MULTIPLE_ACCESS ========");
        $display("================================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("1. Multiple Access WW-RR");
        //WRITE - WRITE
        @(posedge test_bench.clk) #1;
        //SETUP
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b1;
        test_bench.tim_paddr = 12'h04;
        test_bench.tim_pwdata = 32'hAAAA_BBBB;
        test_bench.tim_pstrb = 4'hF;

        @(posedge test_bench.clk) #1;
        //ACCESS - WRITE TDR0
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1);
        //Return SETUP
        @(posedge test_bench.clk) #1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_paddr  = 12'h08;
        test_bench.tim_pwdata = 32'hCCCC_DDDD;

        @(posedge test_bench.clk) #1;
        //ACCESS - WRITE TDR1
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1);
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b0;
        repeat (2) @(posedge test_bench.clk);

        // READ - READ
        @(posedge test_bench.clk) #1;
        //SETUP - TDR0
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b0;
        test_bench.tim_paddr = 12'h04;
        @(posedge test_bench.clk) #1;
        //ACCESS - READ TDR0
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1) #1;
        rdata0 = test_bench.tim_prdata;

        @(posedge test_bench.clk) #1;
        //SETUP - READ TDR1
        test_bench.tim_penable = 1'b0;
        test_bench.tim_paddr   = 12'h08;
        @(posedge test_bench.clk) #1;
        //ACCESS - READ TDR1
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1) #1;
        rdata1 = test_bench.tim_prdata;

        @(posedge test_bench.clk) #1;
        //IDLE
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;

        if (rdata0 === 32'hAAAA_BBBB && rdata1 === 32'hCCCC_DDDD) begin
            $display("[PASSED] WW-RR successful. Data match");
        end else begin
            $display(
                "[FAILED] WW-RR mismatched! Expected: AAAA_BBBB / CCCC_DDDD | Actual: %0h / %0h",
                rdata0, rdata1);
            err = err + 1;
        end

        $display("2. Multiple Access WR-WR");

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);
        //WRITE TDR0
        @(posedge test_bench.clk) #1;
        //SETUP
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b1;
        test_bench.tim_paddr = 12'h04;
        test_bench.tim_pwdata = 32'h1111_2222;
        test_bench.tim_pstrb = 4'hF;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1) #1;
        //READ - TDR0
        @(posedge test_bench.clk) #1;
        //SETUP - READ TDR0
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b0;
        test_bench.tim_paddr   = 12'h04;
        @(posedge test_bench.clk) #1;
        //ACCESS - READ TDR0
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1) #1;
        rdata0 = test_bench.tim_prdata;

        //WRITE TDR1
        @(posedge test_bench.clk) #1;
        //SETUP
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b1;
        test_bench.tim_paddr   = 12'h08;
        test_bench.tim_pwdata  = 32'h3333_4444;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1);
        //READ - TDR1
        @(posedge test_bench.clk) #1;
        //SETUP - READ TDR1
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite  = 1'b0;
        test_bench.tim_paddr   = 12'h08;
        @(posedge test_bench.clk) #1;
        //ACCESS - READ TDR1
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1) #1;
        rdata1 = test_bench.tim_prdata;
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;

        if (rdata0 === 32'h1111_2222 && rdata1 === 32'h3333_4444) begin
            $display("[PASSED] WR-WR successful. Data match");
        end else begin
            $display(
                "[FAILED] WR-WR mismatched! Expected: 1111_2222 / 3333_4444 | Actual: %0h / %0h",
                rdata0, rdata1);
            err = err + 1;
        end
        //FORCE COVERAGE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b1;
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;

        $display("================================================");
        if (err == 0) $display("========= [PASSED] APB_MULTIPLE_ACCESS =========");
        else $display("========= [FAILED] APB_MULTIPLE_ACCESS ( %0d erros found ) =========", err);
        $display("================================================");
    end
endtask
