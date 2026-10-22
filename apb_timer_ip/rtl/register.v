module register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire        halt_ack,
    input  wire [11:0] addr,
    input  wire [31:0] wdata,
    input  wire [63:0] count,
    input  wire [ 3:0] wstrb,
    output reg         timer_en,
    output reg         div_en,
    output wire        tdr0_wr_sel,
    output wire        tdr1_wr_sel,
    output reg  [ 3:0] div_val,
    output wire        reg_err,
    output wire        tim_int,
    output reg         halt_req,
    output wire [31:0] rdata
);

    //TCR REGISTER
    wire timer_en_pre, div_en_pre;
    wire [3:0] div_val_pre;
    wire tcr_wr_sel, div_not_valid, err_assert, div_val_change, div_en_change;
    wire [31:0] TCR;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_en <= 1'b0;
            div_en   <= 1'b0;
            div_val  <= 4'b0001;
        end else begin
            timer_en <= timer_en_pre;
            div_en   <= div_en_pre;
            div_val  <= div_val_pre;
        end
    end
    assign TCR = {20'b0, div_val[3:0], 6'b0, div_en, timer_en};

    assign timer_en_pre = (wstrb[0] & tcr_wr_sel & !reg_err) ? wdata[0] : timer_en;
    assign div_en_pre = (!reg_err & tcr_wr_sel & wstrb[0]) ? wdata[1] : div_en;
    assign div_val_pre = (wstrb[1] & tcr_wr_sel & !reg_err) ? wdata[11:8] : div_val;

    assign tcr_wr_sel = (addr == 12'h00) & wr_en;

    assign div_not_valid = (wdata[11:8] > 8) & wstrb[1];
    assign div_en_change = timer_en & wstrb[0] & (wdata[1] != div_en);
    assign div_val_change = (wdata[11:8] != div_val) & timer_en & wstrb[1];

    assign err_assert = div_not_valid | div_en_change | div_val_change;
    assign reg_err = tcr_wr_sel & err_assert;

    //TDR DECODER
    assign tdr1_wr_sel = (addr[11:0] == 12'h08) & wr_en;
    assign tdr0_wr_sel = (addr[11:0] == 12'h04) & wr_en;

    //TCMP REGISTER

    //TCMP0 REGISTER
    wire tcmp0_wr_sel;
    reg [31:0] TCMP0;
    wire [31:0] tcmp0_pre;
    assign tcmp0_wr_sel = (addr[11:0] == 12'h0C) & wr_en;
    assign tcmp0_pre[7:0] = (wstrb[0] & tcmp0_wr_sel) ? wdata[7:0] : TCMP0[7:0];
    assign tcmp0_pre[15:8] = (wstrb[1] & tcmp0_wr_sel) ? wdata[15:8] : TCMP0[15:8];
    assign tcmp0_pre[23:16] = (wstrb[2] & tcmp0_wr_sel) ? wdata[23:16] : TCMP0[23:16];
    assign tcmp0_pre[31:24] = (wstrb[3] & tcmp0_wr_sel) ? wdata[31:24] : TCMP0[31:24];

    //TCMP1 REGISTER
    wire tcmp1_wr_sel;
    reg [31:0] TCMP1;
    wire [31:0] tcmp1_pre;
    assign tcmp1_wr_sel = (addr[11:0] == 12'h10) & wr_en;
    assign tcmp1_pre[7:0] = (wstrb[0] & tcmp1_wr_sel) ? wdata[7:0] : TCMP1[7:0];
    assign tcmp1_pre[15:8] = (wstrb[1] & tcmp1_wr_sel) ? wdata[15:8] : TCMP1[15:8];
    assign tcmp1_pre[23:16] = (wstrb[2] & tcmp1_wr_sel) ? wdata[23:16] : TCMP1[23:16];
    assign tcmp1_pre[31:24] = (wstrb[3] & tcmp1_wr_sel) ? wdata[31:24] : TCMP1[31:24];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            TCMP0 <= 32'hFFFF_FFFF;
            TCMP1 <= 32'hFFFF_FFFF;
        end else begin
            TCMP0 <= tcmp0_pre;
            TCMP1 <= tcmp1_pre;
        end
    end

    //TIER REGISTER
    reg int_en;
    wire tier_wr_sel, int_en_pre;
    assign tier_wr_sel = (addr[11:0] == 12'h14) & wr_en;
    assign int_en_pre  = (tier_wr_sel & wstrb[0]) ? wdata[0] : int_en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) int_en <= 1'b0;
        else int_en <= int_en_pre;
    end

    //TISR REGISTER
    reg  int_st;
    wire int_set;
    wire int_st_pre, tisr_wr_sel, int_clear;
    assign tisr_wr_sel = (addr[11:0] == 12'h18) ? 1'b1 : 1'b0;
    assign int_clear = (wdata[0] == 1'b1) & wstrb[0] & tisr_wr_sel;
    assign int_set = (count[63:0] == {TCMP1, TCMP0}) ? 1'b1 : 1'b0;
    assign int_st_pre = (int_clear) ? 1'b0 : ((int_set) ? 1'b1 : int_st);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) int_st <= 1'b0;
        else int_st <= int_st_pre;
    end

    //INTERRUPT
    assign tim_int = int_en & int_st;

    //TIMER HALT CONTROL STATUS REGISTER -- THCSR
    wire halt_req_pre, thcsr_wr_sel;
    assign thcsr_wr_sel = (addr[11:0] == 12'h1C) & wr_en;
    assign halt_req_pre = (wstrb[0] & thcsr_wr_sel) ? wdata[0] : halt_req;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) halt_req <= 1'b0;
        else halt_req <= halt_req_pre;
    end

    reg [31:0] rdata_mux;

    always @(*) begin
        rdata_mux = 32'h0;
        case (addr)
            12'h00:  rdata_mux = TCR;
            12'h04:  rdata_mux = count[31:0];  //TDR0 REGISTER
            12'h08:  rdata_mux = count[63:32];  //TDR1 REGISTER
            12'h0C:  rdata_mux = TCMP0;
            12'h10:  rdata_mux = TCMP1;
            12'h14:  rdata_mux = {31'b0, int_en};  //TIER REGISTER
            12'h18:  rdata_mux = {31'b0, int_st};  //TISR REGISTER
            12'h1C:  rdata_mux = {30'b0, halt_ack, halt_req};  //THCSR REGISTER
            default: rdata_mux = 32'h0;
        endcase
    end
    assign rdata = (rd_en) ? rdata_mux : 32'h0;
endmodule
