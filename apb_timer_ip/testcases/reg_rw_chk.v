task run_test();
    reg [31:0] read_val;
    reg err_flag;
    begin
        $display("========================================");
        $display("========= TEST CASE: REG RW CHECK =======");
        $display("========================================");
        err = 0;

        $display("Checking TCR");
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'h5555_5555, 4'hF);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  //write 0 to clear timer_en
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0501, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0501, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0501, 32'hFFFF_FFFF);
        //Clean timer_en
        test_bench.write(12'h00, 32'h0000_0500, 4'hF);


        $display("Checking TDR0");
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h04, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);
        test_bench.write(12'h04, 32'h5555_5555, 4'hF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h5555_5555, 32'hFFFF_FFFF);
        test_bench.write(12'h04, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'hAAAA_AAAA, 32'hFFFF_FFFF);
        test_bench.write(12'h04, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h5AA5_A55A, 32'hFFFF_FFFF);


        $display("Checking TDR1");
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h08, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);
        test_bench.write(12'h08, 32'h5555_5555, 4'hF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h5555_5555, 32'hFFFF_FFFF);
        test_bench.write(12'h08, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'hAAAA_AAAA, 32'hFFFF_FFFF);
        test_bench.write(12'h08, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h5AA5_A55A, 32'hFFFF_FFFF);


        $display("Checking TCMP0");
        test_bench.write(12'h0C, 32'h0000_0000, 4'hF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h0C, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);
        test_bench.write(12'h0C, 32'h5555_5555, 4'hF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h5555_5555, 32'hFFFF_FFFF);
        test_bench.write(12'h0C, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'hAAAA_AAAA, 32'hFFFF_FFFF);
        test_bench.write(12'h0C, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h5AA5_A55A, 32'hFFFF_FFFF);


        $display("Checking TCMP1");
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h10, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'hFFFF_FFFF, 32'hFFFF_FFFF);
        test_bench.write(12'h10, 32'h5555_5555, 4'hF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h5555_5555, 32'hFFFF_FFFF);
        test_bench.write(12'h10, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'hAAAA_AAAA, 32'hFFFF_FFFF);
        test_bench.write(12'h10, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h5AA5_A55A, 32'hFFFF_FFFF);


        $display("Checking TIER");
        test_bench.write(12'h14, 32'h0000_0000, 4'hF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h14, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.write(12'h14, 32'h5555_5555, 4'hF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.write(12'h14, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h14, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        //Clear TDR == TCMP
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);  //Clear TDR0
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);  //Clear TDR1
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);  //Clear int status

        $display("Checking TISR");
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);  //Clear interrupt
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h18, 32'h0000_0000, 4'hF);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h18, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h18, 32'h5555_5555, 4'hF);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h18, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h18, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);


        $display("Checking THCSR");
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //Clear TCMP1
        test_bench.write(12'h1C, 32'h0000_0000, 4'hF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h1C, 32'hFFFF_FFFF, 4'hF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.write(12'h1C, 32'h5555_5555, 4'hF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        test_bench.write(12'h1C, 32'hAAAA_AAAA, 4'hF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h1C, 32'h5AA5_A55A, 4'hF);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);


        $display("Checking UPDATE TCMP while operating");

        test_bench.write(12'h14, 32'h0000_0001, 4'hF);  //Set int_en = 1
        //Clear register
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);  //Clear TDR0
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);  //Clear TDR1
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //Clear TCMP1
        test_bench.write(12'h0C, 32'h0000_FFFF, 4'hF);  //Set TCMP0 = FFFF


        test_bench.write(12'h00, 32'h0000_0101, 4'hF);  //Set timer_en = 1

        //wait counter = 0FFF
        repeat (4096) @(posedge test_bench.clk);
        test_bench.write(12'h0C, 32'h0000_AAAA, 4'hF);  //write TCMP0 = AAAA
        if (test_bench.tim_pslverr == 1'b0) begin
            $display("[PASSED] Write TCMP0 successful without error");
        end else begin
            $display("[FAILED] Pslverr asserted while write TCMP0");
            err = err + 1;
        end

        wait (test_bench.tim_int == 1'b1);
        @(posedge test_bench.clk);
        #1;
        test_bench.read(12'h18, read_val, err_flag);
        if (test_bench.tim_int == 1'b1 && read_val[0] == 1'b1) begin
            $display("[PASSED] Interrupt assert correctly when counter reach AAAA");
        end else begin
            $display("[FAILED] Interupt did NOT assert when reaching new TCMP value");
            err = err + 1;
        end

        //Clean
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);

        $display("========================================");
        if (err == 0) $display("========= [PASSED] REG RW CHECK =========");
        else $display("========= [FAILED] REG_RW_CHECK ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask
