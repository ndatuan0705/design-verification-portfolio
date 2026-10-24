task run_test();
    reg [31:0] rdata, rdata0, rdata1;
    reg err_flag;
    reg [63:0] dut_cnt;
    integer i;
    begin
        $display("================================================");
        $display("======== TEST CASE: INTERRUPT_CHECK ========");
        $display("================================================");
        err = 0;

        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        $display("1. Counter continue counting when interrupt occurs");
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);  //TCMP0 = FF
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //TCMP1 = 00
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //int_en = 1
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  //timer_en = 1

        repeat (300) @(posedge test_bench.clk);

        test_bench.read(12'h04, rdata0, err_flag);
        test_bench.read(12'h08, rdata1, err_flag);
        dut_cnt = {rdata1, rdata0};

        if (test_bench.tim_int == 1'b1 && dut_cnt > 32'd225) begin
            $display("[PASSED] Interrupt asserted and Counter continue to %0d > 225", dut_cnt);
        end else begin
            $display("[FAILED] tim_int = %0b | Counter = %0d time = %0d", test_bench.tim_int,
                     dut_cnt, $time);
            err = err + 1;
        end

        $display("2. After reset, timer can work normally");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b0) begin
            $display("[PASSED] Reset clear interrupt successfully");
        end else begin
            $display("[FAILED] Reset did NOT clear the interrupt ");
            err = err + 1;
        end

        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //TCMP1 = 00
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);  //TCMP0 = FF
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //int_en = 1
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  //timer_en = 1

        repeat (270) @(posedge test_bench.clk);
        if (test_bench.tim_int == 1'b1) begin
            $display("[PASSED] Interrupt asserted normally after reset");
        end else begin
            $display("[FAILED] Interrupt did NOT assert after reset | time: %0d", $time);
            err = err + 1;
        end

        $display("3. Interrupt pending: Set condition");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //TCMP1 = 00
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);  //TCMP0 = FF
        test_bench.write(12'h14, 32'h0000_0000, 4'hF);  //int_en = 0
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  //timer_en = 1

        repeat (270) @(posedge test_bench.clk);
        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b0 && rdata[0] == 1'b1) begin
            $display("[PASSED] tim_int = 0, TISR.int_st = 1 => Pending correctly");
        end else begin
            $display("[FAILED] tim_int = %0b | TISR.int_st = %0b", test_bench.tim_int, rdata[0]);
            err = err + 1;
        end

        $display("4. Interrupt pending: Clear condition");
        //Write 0
        test_bench.write(12'h18, 32'h0000_0000, 4'hF);
        test_bench.read(12'h18, rdata, err_flag);

        if (rdata[0] == 1'b1 && test_bench.tim_int == 1'b0) begin
            $display("[PASSED] Write 0 to TISR -> Remains 1");
        end else begin
            $display("[FAILED] Write 0 cleared TISR");
            err = err + 1;
        end

        //Write 1
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);
        test_bench.read(12'h18, rdata, err_flag);

        if (rdata[0] == 1'b0 && test_bench.tim_int == 1'b0) begin
            $display("[PASSED] Write 1 to TISR -> Cleared to 0");
        end else begin
            $display("[FAILED] Write 1 did NOT clear TISR");
            err = err + 1;
        end

        $display("5. Interrupt pending: Manual condition");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h04, 32'hFFFF_FFFF, 4'hF);  //TDR0 = max
        test_bench.write(12'h08, 32'hFFFF_FFFF, 4'hF);  //TDR1
        test_bench.write(12'h14, 32'h0000_0000, 4'hF);  //TIER = 0

        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b0 && rdata[0] == 1'b1) begin
            $display("[PASSED] Manual overflow -> tim_int = 0, TISR.int_st = 1");
        end else begin
            $display("[FAILED] Manual overflow failed");
            err = err + 1;
        end

        $display("6. Interrupt enable: Set condition");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //TCMP1 = 00
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);  //TCMP0 = FF
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //TIER = 1
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  //timer_en = 1

        repeat (270) @(posedge test_bench.clk);
        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b1 && rdata[0] == 1'b1) begin
            $display("[PASSED] tim_int = 1, TISR.int_st = 1 => Asserted correctly");
        end else begin
            $display("[FAILED] tim_int = %0b | TISR.int_st = %0b", test_bench.tim_int, rdata[0]);
            err = err + 1;
        end

        $display("7. Interrupt enable: Clear condition");
        //Write 0
        test_bench.write(12'h18, 32'h0000_0000, 4'hF);
        test_bench.read(12'h18, rdata, err_flag);

        if (rdata[0] == 1'b1 && test_bench.tim_int == 1'b1) begin
            $display("[PASSED] Write 0 to TISR -> Remains 1");
        end else begin
            $display("[FAILED] Write 0 cleared TISR");
            err = err + 1;
        end

        //Write 1
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);
        test_bench.read(12'h18, rdata, err_flag);

        if (rdata[0] == 1'b0 && test_bench.tim_int == 1'b0) begin
            $display("[PASSED] Write 1 to TISR -> TISR and tim_int cleared to 0");
        end else begin
            $display("[FAILED] Write 1 did NOT clear TISR");
            err = err + 1;
        end

        $display("8. Interrupt pending: Manual condition");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h04, 32'hFFFF_FFFF, 4'hF);  //TDR0 = max
        test_bench.write(12'h08, 32'hFFFF_FFFF, 4'hF);  //TDR1
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //TIER = 1

        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b1 && rdata[0] == 1'b1) begin
            $display("[PASSED] Manual overflow -> tim_int = 1, TISR.int_st = 1");
        end else begin
            $display("[FAILED] Manual overflow failed");
            err = err + 1;
        end

        $display("9. Mask condition");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);
        repeat (270) @(posedge test_bench.clk);
        test_bench.read(12'h18, rdata, err_flag);

        test_bench.write(12'h14, 32'h0000_0000, 4'hF);
        repeat (2) @(posedge test_bench.clk);
        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b0 && rdata[0] == 1'b1) begin
            $display("[PASSED] int_en = 0 -> tim_int is 0 but TISR remains 1");
        end else begin
            $display("[FAILED] Masking failed");
            err = err + 1;
        end

        $display("10. Once asserted, interrupt must be kept");
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //TIER = 1 open mask

        repeat (2) @(posedge test_bench.clk);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  //timer_en = 0

        repeat (10) @(posedge test_bench.clk);
        test_bench.read(12'h18, rdata, err_flag);

        if (test_bench.tim_int == 1'b1 && rdata[0] == 1'b1) begin
            $display("[PASSED] timer_en = 0 -> Interrupt and TISR still kept HIGH");
        end else begin
            $display("[FAILED] Interrupt lost after timer disabled");
            err = err + 1;
        end

        $display("11. Clear Priority");
        test_bench.rst_n = 0;
        repeat (2) @(posedge test_bench.clk);
        test_bench.rst_n = 1;
        repeat (2) @(posedge test_bench.clk);

        test_bench.write(12'h10, 32'h0000_0000, 4'hF);
        test_bench.write(12'h0C, 32'h0000_00FF, 4'hF);  //TCMP0 = FF
        test_bench.write(12'h00, 32'h0000_0001, 4'hF);  //timer_en = 1
        repeat (230) @(posedge test_bench.clk);
        for (i = 0; i < 40; i = i + 1) begin
            test_bench.write(12'h18, 32'h0000_0001, 4'hF);
        end

        test_bench.read(12'h18, rdata, err_flag);
        if (rdata[0] == 1'b0) begin
            $display("[PASSED] Software Clear successfully overrides Hardware Set");
        end else begin
            $display("[FAILED] Priority check failed. TISR is still 1");
            err = err + 1;
        end

        $display("================================================");
        if (err == 0) $display("========= [PASSED] INTERRUPT_CHECK =========");
        else $display("========= [FAILED] INTERRUPT_CHECK ( %0d erros found ) =========", err);
        $display("================================================");
    end
endtask
