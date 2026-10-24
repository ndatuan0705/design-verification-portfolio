task run_test();
    reg [31:0] rdata;
    reg err_flag;
    reg [31:0] test_val;
    integer i;
    begin
        $display("================================================");
        $display("======== TEST CASE: APB_PSLVERR_CHECK ========");
        $display("================================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("1. Write Invalid div_val to TCR");

        test_bench.write(12'h00, 32'h0000_0100, 4'hF);

        for (i = 9; i <= 15; i = i + 1) begin
            test_val = (i << 8);
            @(posedge test_bench.clk) #1;
            //SETUP
            test_bench.tim_psel = 1'b1;
            test_bench.tim_penable = 1'b0;
            test_bench.tim_pwrite = 1'b1;
            test_bench.tim_paddr = 12'h00;
            test_bench.tim_pwdata = test_val;
            test_bench.tim_pstrb = 4'hF;

            @(posedge test_bench.clk) #1;
            //ACCESS
            test_bench.tim_penable = 1'b1;
            wait (test_bench.tim_pready == 1'b1);
            err_flag = test_bench.tim_pslverr;
            //IDLE
            @(posedge test_bench.clk) #1;
            test_bench.tim_psel = 1'b0;
            test_bench.tim_penable = 1'b0;
            test_bench.tim_pwrite = 1'b0;

            if (err_flag == 1'b1) begin
                $display("[PASSED] WRITE: %0h | PSLVERR is HIGH", test_val);
            end else begin
                $display("[FAILED] WRITE: %0h | PSLVERR is LOW", test_val);
                err = err + 1;
            end

            test_bench.read(12'h00, rdata, err_flag);
            if (rdata !== 32'h0000_0100) begin
                $display("[FAILED] TCR changed to %0h | Expected: 0x0100", rdata);
                err = err + 1;
            end
        end

        $display("Check valid div_val (0x0800)");
        test_val = 32'h0000_0800;
        @(posedge test_bench.clk) #1;
        //SETUP
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b1;
        test_bench.tim_paddr = 12'h00;
        test_bench.tim_pwdata = test_val;
        test_bench.tim_pstrb = 4'hF;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;
        wait (test_bench.tim_pready == 1'b1);
        err_flag = test_bench.tim_pslverr;
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b0;

        if (err_flag == 1'b0) begin
            $display("[PASSED] WRITE: %0h | PSLVERR is LOW", test_val);
        end else begin
            $display("[FAILED] WRITE: %0h | PSLVERR is HIGH", test_val);
            err = err + 1;
        end

        test_bench.read(12'h00, rdata, err_flag);
        if (rdata === 32'h0000_0800) begin
            $display("[PASSED] TCR update to %0h | Expected: 0x0800", rdata);
        end else begin
            err = err + 1;
            $display("[FAILED] TCR is %0h | Expected: 0x0800", rdata);
        end

        $display("2. Write Protection (timer_en = 1)");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h00, 32'h0000_0001, 4'hF);
        test_bench.read(12'h00, rdata, err_flag);
        if (rdata === 32'h0000_0001 && err_flag == 1'b0) begin
            $display("[PASSED] [2.1] Write 0x1 and Read back 0x1, Pslverr = 0");
        end else begin
            $display("[FAILED] [2.1] Failed to start timer");
            err = err + 1;
        end

        begin : WRITE_PROTECT_TEST
            reg [31:0] invalid_write[0:2];
            invalid_write[0] = 32'h0000_0103;  //div_val = 1, div_en = 1
            invalid_write[1] = 32'h0000_0100;  //div_val = 1, timer_en = 0
            invalid_write[2] = 32'h0000_0002;  //div_en = 1, timer_en = 0

            for (i = 0; i < 3; i = i + 1) begin
                test_val = invalid_write[i];
                @(posedge test_bench.clk) #1;
                //SETUP
                test_bench.tim_psel = 1'b1;
                test_bench.tim_penable = 1'b0;
                test_bench.tim_pwrite = 1'b1;
                test_bench.tim_paddr = 12'h00;
                test_bench.tim_pwdata = test_val;
                test_bench.tim_pstrb = 4'hF;

                @(posedge test_bench.clk) #1;
                //ACCESS
                test_bench.tim_penable = 1'b1;
                wait (test_bench.tim_pready == 1'b1);
                err_flag = test_bench.tim_pslverr;
                //IDLE
                @(posedge test_bench.clk) #1;
                test_bench.tim_psel = 1'b0;
                test_bench.tim_penable = 1'b0;
                test_bench.tim_pwrite = 1'b0;

                if (err_flag == 1'b1) begin
                    $display("[PASSED] [2.%0d] WRITE: %0h | PSLVERR is HIGH", i + 2, test_val);
                end else begin
                    $display("[FAILED] [2.%0d] WRITE: %0h | PSLVERR is LOW", i + 2, test_val);
                    err = err + 1;
                end

                test_bench.read(12'h00, rdata, err_flag);
                if (rdata !== 32'h0000_0001) begin
                    err = err + 1;
                    $display("[FAILED] Data changed to %0h", rdata);
                end
            end
        end : WRITE_PROTECT_TEST

        $display("3. Pslverr and Pready check");
        @(posedge test_bench.clk) #1;
        //SETUP
        test_bench.tim_psel = 1'b1;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b1;
        test_bench.tim_paddr = 12'h00;
        test_bench.tim_pwdata = 32'h0000_0900;
        test_bench.tim_pstrb = 4'hF;

        @(posedge test_bench.clk) #1;
        //ACCESS
        test_bench.tim_penable = 1'b1;

        wait (test_bench.tim_pready == 1'b1);

        if (test_bench.tim_pslverr == 1'b1) begin
            $display("[PASSED] Pslverr is HIGH when Pready is HIGH");
        end else begin
            $display("[FAILED] Pready is HIGH but PSLVERR is LOW");
            err = err + 1;
        end
        //IDLE
        @(posedge test_bench.clk) #1;
        test_bench.tim_psel = 1'b0;
        test_bench.tim_penable = 1'b0;
        test_bench.tim_pwrite = 1'b0;

        $display("================================================");
        if (err == 0) $display("========= [PASSED] APB_PSLVERR_CHECK =========");
        else $display("========= [FAILED] APB_PSLVERR_CHECK ( %0d erros found ) =========", err);
        $display("================================================");
    end
endtask
