module apb_timer_ip (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tim_psel,
    input  wire        tim_pwrite,
    input  wire        tim_penable,
    input  wire        dbg_mode,
    input  wire [11:0] tim_paddr,
    input  wire [31:0] tim_pwdata,
    input  wire [ 3:0] tim_pstrb,
    output wire        tim_pready,
    tim_pslverr,
    tim_int,
    output wire [31:0] tim_prdata
);

    wire wr_en, rd_en, reg_err;
    wire [11:0] addr;
    wire [31:0] wdata, rdata;
    wire [3:0] div_val, wstrb;
    wire div_en, halt_req, halt_ack, timer_en, timer_en_fall, cnt_en;
    wire tdr0_wr_sel, tdr1_wr_sel;
    wire [63:0] count;

    register u_register (
        .wr_en(wr_en),
        .rd_en(rd_en),
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata),
        .reg_err(reg_err),
        .wstrb(wstrb),
        .div_val(div_val),
        .div_en(div_en),
        .halt_req(halt_req),
        .halt_ack(halt_ack),
        .timer_en(timer_en),
        .tdr0_wr_sel(tdr0_wr_sel),
        .tdr1_wr_sel(tdr1_wr_sel),
        .count(count),
        .tim_int(tim_int)
    );

    apb_slave u_apb_slave (
        .clk(clk),
        .rst_n(rst_n),
        .tim_psel(tim_psel),
        .tim_pwrite(tim_pwrite),
        .tim_penable(tim_penable),
        .tim_pstrb(tim_pstrb),
        .tim_paddr(tim_paddr),
        .tim_pwdata(tim_pwdata),
        .tim_prdata(tim_prdata),
        .tim_pready(tim_pready),
        .tim_pslverr(tim_pslverr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wdata(wdata),
        .rdata(rdata),
        .addr(addr),
        .reg_err(reg_err),
        .wstrb(wstrb)
    );

    counter_control u_counter_control (
        .clk(clk),
        .rst_n(rst_n),
        .div_val(div_val),
        .div_en(div_en),
        .halt_req(halt_req),
        .dbg_mode(dbg_mode),
        .timer_en(timer_en),
        .cnt_en(cnt_en),
        .timer_en_fall(timer_en_fall),
        .halt_ack(halt_ack)
    );

    counter u_counter (
        .clk(clk),
        .rst_n(rst_n),
        .tdr0_wr_sel(tdr0_wr_sel),
        .tdr1_wr_sel(tdr1_wr_sel),
        .cnt_en(cnt_en),
        .timer_en_fall(timer_en_fall),
        .wstrb(wstrb),
        .wdata(wdata),
        .count(count)
    );

endmodule
