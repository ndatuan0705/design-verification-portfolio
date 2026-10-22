module counter (
    input  wire        rst_n,
    input  wire        clk,
    input  wire        tdr0_wr_sel,
    input  wire        tdr1_wr_sel,
    input  wire        cnt_en,
    input  wire        timer_en_fall,
    input  wire [ 3:0] wstrb,
    input  wire [31:0] wdata,
    output wire [63:0] count
);

    wire [31:0] tdr0, tdr1, tdr0_pre, tdr1_pre, tdr0_pre_val, tdr1_pre_val;
    wire [63:0] count_pre;
    reg [31:0] TDR0, TDR1;

    //TDR1 WRITE ACCESS
    assign tdr1_pre[7:0] = (wstrb[0] & tdr1_wr_sel) ? wdata[7:0] : tdr1[7:0];
    assign tdr1_pre[15:8] = (wstrb[1] & tdr1_wr_sel) ? wdata[15:8] : tdr1[15:8];
    assign tdr1_pre[23:16] = (wstrb[2] & tdr1_wr_sel) ? wdata[23:16] : tdr1[23:16];
    assign tdr1_pre[31:24] = (wstrb[3] & tdr1_wr_sel) ? wdata[31:24] : tdr1[31:24];

    assign tdr1_pre_val = (timer_en_fall) ? 32'h00 : tdr1_pre;

    assign tdr1 = (cnt_en) ? count_pre[63:32] : TDR1;

    //COUNT INCREASE
    assign count_pre = count + 1'b1;

    //TDR0 WRITE ACCESS
    assign tdr0_pre[7:0] = (wstrb[0] & tdr0_wr_sel) ? wdata[7:0] : tdr0[7:0];
    assign tdr0_pre[15:8] = (wstrb[1] & tdr0_wr_sel) ? wdata[15:8] : tdr0[15:8];
    assign tdr0_pre[23:16] = (wstrb[2] & tdr0_wr_sel) ? wdata[23:16] : tdr0[23:16];
    assign tdr0_pre[31:24] = (wstrb[3] & tdr0_wr_sel) ? wdata[31:24] : tdr0[31:24];

    assign tdr0_pre_val = (timer_en_fall) ? 32'h00 : tdr0_pre;

    assign tdr0 = (cnt_en) ? count_pre[31:0] : TDR0;

    assign count = {TDR1, TDR0};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            TDR0 <= 32'h00;
            TDR1 <= 32'h00;
        end else begin
            TDR0 <= tdr0_pre_val;
            TDR1 <= tdr1_pre_val;
        end
    end
endmodule
