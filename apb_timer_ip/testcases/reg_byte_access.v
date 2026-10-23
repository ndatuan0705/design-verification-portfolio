task run_test();
    reg [31:0] read_val;
    reg err_flag;
    begin
        $display("========================================");
        $display("====== TEST CASE: REG_BYTE_ACCESS ======");
        $display("========================================");
        err = 0;

        $display("Checking TCR BYTE ACCESS");
        test_bench.write(12'h00, 32'h0000_0100, 4'hF);
        test_bench.write(12'h00, 32'h0000_0103, 4'h1);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0103, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'h0000_0102, 4'hF);  //off timer_en but hold div_en
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  //Clear

        test_bench.write(12'h00, 32'hFFFF_F5FF, 4'h2);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0500, 32'hFFFF_FFFF);
        //test_bench.write(12'h00, 32'h0000_0100, 4'hF); //Clear
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  //Clear

        test_bench.write(12'h00, 32'hFFFF_FFFF, 4'h4);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);  //Clear

        test_bench.write(12'h00, 32'h5555_5555, 4'h3);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0501, 32'hFFFF_FFFF);
        //No clear
        test_bench.write(12'h00, 32'hFFFF_FFFF, 4'hC);
        test_bench.read(12'h00, read_val, err_flag);
        test_bench.check_data(12'h00, read_val, 32'h0000_0501, 32'hFFFF_FFFF);

        //Clear TCR
        test_bench.write(12'h00, 32'h0000_0500, 4'hF);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);


        $display("Checking TDR0 BYTE ACCESS");
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);

        test_bench.write(12'h04, 32'h1111_1111, 4'h1);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h0000_0011, 32'hFFFF_FFFF);

        test_bench.write(12'h04, 32'h2222_2222, 4'h2);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h0000_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h04, 32'h3333_3333, 4'h4);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h0033_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h04, 32'h4444_4444, 4'h8);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h04, 32'h5555_5555, 4'h3);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.write(12'h04, 32'h6666_6666, 4'hC);
        test_bench.read(12'h04, read_val, err_flag);
        test_bench.check_data(12'h04, read_val, 32'h6666_5555, 32'hFFFF_FFFF);



        $display("Checking TDR1 BYTE ACCESS");
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);

        test_bench.write(12'h08, 32'h1111_1111, 4'h1);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h0000_0011, 32'hFFFF_FFFF);

        test_bench.write(12'h08, 32'h2222_2222, 4'h2);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h0000_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h08, 32'h3333_3333, 4'h4);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h0033_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h08, 32'h4444_4444, 4'h8);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h08, 32'h5555_5555, 4'h3);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.write(12'h08, 32'h6666_6666, 4'hC);
        test_bench.read(12'h08, read_val, err_flag);
        test_bench.check_data(12'h08, read_val, 32'h6666_5555, 32'hFFFF_FFFF);



        $display("Checking TCMP0 BYTE ACCESS");
        test_bench.write(12'h0C, 32'hFFFF_FFFF, 4'hF);

        test_bench.write(12'h0C, 32'h1111_1111, 4'h1);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'hFFFF_FF11, 32'hFFFF_FFFF);

        test_bench.write(12'h0C, 32'h2222_2222, 4'h2);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'hFFFF_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h0C, 32'h3333_3333, 4'h4);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'hFF33_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h0C, 32'h4444_4444, 4'h8);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h0C, 32'h5555_5555, 4'h3);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.write(12'h0C, 32'h6666_6666, 4'hC);
        test_bench.read(12'h0C, read_val, err_flag);
        test_bench.check_data(12'h0C, read_val, 32'h6666_5555, 32'hFFFF_FFFF);



        $display("Checking TCMP1 BYTE ACCESS");
        test_bench.write(12'h10, 32'hFFFF_FFFF, 4'hF);

        test_bench.write(12'h10, 32'h1111_1111, 4'h1);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'hFFFF_FF11, 32'hFFFF_FFFF);

        test_bench.write(12'h10, 32'h2222_2222, 4'h2);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'hFFFF_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h10, 32'h3333_3333, 4'h4);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'hFF33_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h10, 32'h4444_4444, 4'h8);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.write(12'h10, 32'h5555_5555, 4'h3);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.write(12'h10, 32'h6666_6666, 4'hC);
        test_bench.read(12'h10, read_val, err_flag);
        test_bench.check_data(12'h10, read_val, 32'h6666_5555, 32'hFFFF_FFFF);



        $display("Checking TIER BYTE ACCESS");
        test_bench.write(12'h14, 32'h0000_0000, 4'hF);

        test_bench.write(12'h14, 32'h1111_1111, 4'h1);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h14, 32'h2222_2222, 4'h2);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h14, 32'h3333_3333, 4'h4);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h14, 32'h4444_4444, 4'h8);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h14, 32'h6666_6666, 4'h3);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        test_bench.write(12'h14, 32'h7777_7777, 4'hC);
        test_bench.read(12'h14, read_val, err_flag);
        test_bench.check_data(12'h14, read_val, 32'h0000_0000, 32'hFFFF_FFFF);



        $display("Checking THCSR BYTE ACCESS");
        test_bench.write(12'h1C, 32'h0000_0000, 4'hF);

        test_bench.write(12'h1C, 32'h1111_1111, 4'h1);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h1C, 32'h2222_2222, 4'h2);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h1C, 32'h3333_3333, 4'h4);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h1C, 32'h4444_4444, 4'h8);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h1C, 32'h6666_6666, 4'h3);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        test_bench.write(12'h1C, 32'h7777_7777, 4'hC);
        test_bench.read(12'h1C, read_val, err_flag);
        test_bench.check_data(12'h1C, read_val, 32'h0000_0000, 32'hFFFF_FFFF);



        $display("Checking TISR BYTE ACCESS");
        //B1
        test_bench.write(12'h08, 32'h0000_0000, 4'hF);  //TDR1 = 0
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);  //TDR0 = 0
        test_bench.write(12'h10, 32'h0000_0000, 4'hF);  //TCMP1 = 0
        test_bench.write(12'h0C, 32'h0000_0002, 4'hF);  //TCMP0 = 2
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);  //Set timer_en = 1
        repeat (10) @(posedge test_bench.clk);
        //B2-5
        test_bench.write(12'h18, 32'hFFFF_FFFF, 4'h2);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h18, 32'hFFFF_FFFF, 4'h4);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h18, 32'hFFFF_FFFF, 4'h8);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.write(12'h18, 32'hFFFF_FFFF, 4'hC);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0001, 32'hFFFF_FFFF);
        //B6
        test_bench.write(12'h18, 32'h0000_0001, 4'h1);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);
        //B7
        test_bench.write(12'h04, 32'h0000_0000, 4'hF);
        test_bench.write(12'h00, 32'h0000_0101, 4'hF);
        repeat (10) @(posedge test_bench.clk);
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        //B8
        test_bench.write(12'h18, 32'h0000_0001, 4'h3);
        test_bench.read(12'h18, read_val, err_flag);
        test_bench.check_data(12'h18, read_val, 32'h0000_0000, 32'hFFFF_FFFF);

        /*Clean
        test_bench.write(12'h00, 32'h0000_0000, 4'hF);
        test_bench.write(12'h14, 32'h0000_0001, 4'hF);
        test_bench.write(12'h18, 32'h0000_0001, 4'hF);
        */

        $display("========================================");
        if (err == 0) $display("========= [PASSED] REG_BYTE_ACCESS =========");
        else $display("========= [FAILED] REG_BYTE_ACCESS ( %0d errros found ) =========", err);
        $display("========================================");
    end
endtask
