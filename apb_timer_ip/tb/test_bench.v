module test_bench;
    reg clk, rst_n;
    reg  [11:0] tim_paddr;
    reg  [31:0] tim_pwdata;
    wire [31:0] tim_prdata;
    reg  [ 3:0] tim_pstrb;
    wire tim_pready, tim_pslverr, tim_int;
    reg tim_psel, tim_penable, tim_pwrite, dbg_mode;
    integer err;

    reg apb_psel_err, apb_penable_err;

    apb_timer_ip dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .tim_paddr  (tim_paddr),
        .tim_pwdata (tim_pwdata),
        .tim_prdata (tim_prdata),
        .tim_psel   (tim_psel),
        .tim_pstrb  (tim_pstrb),
        .tim_pslverr(tim_pslverr),
        .tim_penable(tim_penable),
        .tim_pwrite (tim_pwrite),
        .tim_pready (tim_pready),
        .tim_int    (tim_int),
        .dbg_mode   (dbg_mode)
    );

    //REFERENCE COUNTER
    wire [63:0] golden_cnt, golden_cnt_snap;
    //reg golden_cnt_cfg_en;
    //Task set value for golden counter
    /*task tsk_cfg_golden_cnt (input [63:0] val);
        begin
            golden_cnt_cfg = val;
            golden_cnt_cfg_en = 1'b1;
            @(posedge clk) #1;
            golden_cnt_cfg_en = 1'b0;
        end
    endtask */

    mod_golden_cnt u_tb_cnt (
        .clk            (clk),
        .rst_n          (rst_n),
        .psel           (tim_psel),
        .penable        (tim_penable),
        .pwrite         (tim_pwrite),
        .paddr          (tim_paddr),
        .pwdata         (tim_pwdata),
        .pready         (tim_pready),
        .dbg_mode       (dbg_mode),
        //.cnt_cfg_en   (golden_cnt_cfg_en),
        .golden_cnt_snap(golden_cnt_snap),
        .cnt            (golden_cnt)
    );

    `include "run_test.v"

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #5 rst_n = 1;
    end

    initial begin
        tim_psel        = 0;
        tim_pwrite      = 0;
        tim_penable     = 0;
        tim_paddr       = 0;
        tim_pwdata      = 0;
        tim_pstrb       = 0;
        dbg_mode        = 0;
        apb_psel_err    = 0;
        apb_penable_err = 0;
        err             = 0;
    end

    initial begin
        wait (rst_n == 1'b1);
        #10;
        run_test();

        #50;
        $finish;
    end

    task write(input [11:0] waddr, input [31:0] wdata, input [3:0] wstrb);
        begin
            $display("[t=%0d] [APB WRITE] Write at Addr: %0h | with Wdata: %0h | Write Strobe: %0b",
                     $time, waddr, wdata, wstrb);
            @(posedge clk) #1;
            //SETUP
            tim_psel    = 1'b1 & !apb_psel_err;
            tim_penable = 1'b0;
            tim_pwrite  = 1'b1;
            tim_paddr   = waddr;
            tim_pwdata  = wdata;
            tim_pstrb   = wstrb;
            @(posedge clk) #1;
            //ACCESS
            tim_penable = 1'b1 & !apb_penable_err;
            if (!apb_psel_err && !apb_penable_err) wait (tim_pready == 1'b1) #1;
            else repeat (2) @(posedge clk);
            //wait(tim_pready == 1'b1); #1;
            @(posedge clk) #1;
            //IDLE
            tim_psel    = 1'b0;
            tim_pwrite  = 1'b0;
            tim_penable = 1'b0;
            tim_pwdata  = 32'h0;
            tim_paddr   = 12'h0;
        end
    endtask

    task read(input [11:0] raddr, output [31:0] rdata, output error);
        begin
            @(posedge clk) #1;
            //SETUP
            tim_pwrite  = 1'b0;
            tim_penable = 1'b0;
            tim_psel    = 1'b1 & !apb_psel_err;
            tim_paddr   = raddr;
            @(posedge clk) #1;  //ACCESS
            tim_penable = 1'b1 & !apb_penable_err;
            if (!apb_psel_err && !apb_penable_err) wait (tim_pready == 1'b1) #1;
            else repeat (2) @(posedge clk);
            //wait(tim_pready == 1'b1); #1;
            rdata = tim_prdata;
            error = tim_pslverr;
            @(posedge clk) #1;  //IDLE
            tim_pwrite  = 1'b0;
            tim_psel    = 1'b0;
            tim_penable = 1'b0;
            tim_pwdata  = 32'h0;
            tim_paddr   = 12'h0;
            $display(
                "[t=%0d] [APB READ] Read at ADDR: %0h | with Read DATA: %0h | Error Occur: %0b",
                $time, raddr, rdata, error);
        end
    endtask

    task check_data(input [11:0] addr, input [31:0] actual_data, input [31:0] expected_data,
                    input [31:0] mask);
        begin
            if ((actual_data & mask) === (expected_data & mask)) begin
                $display("[t=%0d] [PASS] Address: %0h | Read DATA: %0h", $time, addr,
                         actual_data & mask);
            end else begin
                $display("[t=%0d] [FAILED] Address: %0h | Expected DATA: %0h | Actual DATA: %0h",
                         $time, addr, expected_data & mask, actual_data & mask);
                err = err + 1;
            end
        end
    endtask
endmodule


module mod_golden_cnt (
    input  wire        clk,
    rst_n,
    psel,
    penable,
    pwrite,
    input  wire [11:0] paddr,
    input  wire [31:0] pwdata,
    input  wire        dbg_mode,
    input  wire        pready,
    //input wire cnt_cfg_en,
    output reg  [63:0] golden_cnt_snap,
    output reg  [63:0] cnt
);

    reg tim_en;
    reg div_en;
    reg [3:0] div_val;
    reg halt_req;
    wire tcr_wr, tdr0_wr, tdr1_wr, thcsr_wr;

    assign tcr_wr   = psel & penable & pready & pwrite & (paddr == 12'h00);
    assign tdr0_wr  = psel & penable & pready & pwrite & (paddr == 12'h04);
    assign tdr1_wr  = psel & penable & pready & pwrite & (paddr == 12'h08);
    assign thcsr_wr = psel & penable & pready & pwrite & (paddr == 12'h1C);

    wire tdr0_rd = psel & penable & !pwrite & pready & (paddr == 12'h04);
    wire tdr1_rd = psel & penable & !pwrite & pready & (paddr == 12'h08);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tim_en   <= 1'b0;
            div_en   <= 1'b0;
            div_val  <= 4'h0;
            halt_req <= 1'b0;
        end else begin
            if (tcr_wr) begin
                tim_en <= pwdata[0];
                div_en <= pwdata[1];
                if (pwdata[11:8] <= 4'h8) div_val <= pwdata[11:8];
            end
            if (thcsr_wr) begin
                halt_req <= pwdata[0];
            end
        end
    end

    reg [31:0] pre_cnt;
    wire [31:0] div_max = div_en ? ((1 << div_val) - 1) : 0;
    wire is_halt = (dbg_mode & halt_req);

    wire tick = tim_en && !is_halt && (pre_cnt >= div_max);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_cnt <= 32'h0;
        end else if (tcr_wr) begin
            pre_cnt <= 32'h0;
        end else if (tim_en && !is_halt) begin
            if (pre_cnt >= div_max) pre_cnt <= 32'h0;
            else pre_cnt <= pre_cnt + 1;
        end
    end

    //Counter 64 bit
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 64'h0;
            golden_cnt_snap <= 64'h0;
        end else begin
            if (tdr0_rd || tdr1_rd) golden_cnt_snap <= cnt;
            if (tdr0_wr) cnt[31:0] <= pwdata;
            else if (tdr1_wr) cnt[63:32] <= pwdata;
            else if (tcr_wr && pwdata[0] == 1'b0 && tim_en) cnt <= 64'h00;
            else if (tick) cnt <= cnt + 1;
        end
    end
endmodule
