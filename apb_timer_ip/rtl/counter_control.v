module counter_control (
    input  wire [3:0] div_val,
    input  wire       rst_n,
    input  wire       clk,
    input  wire       div_en,
    input  wire       halt_req,
    input  wire       timer_en,
    input  wire       dbg_mode,
    output wire       cnt_en,
    output wire       timer_en_fall,
    output wire       halt_ack
);

    wire cnt_rst;
    wire [7:0] limit;
    reg timer_en_delay;
    reg [7:0] int_cnt;

    //Fall edge detector
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) timer_en_delay <= 1'b0;
        else timer_en_delay <= timer_en;
    end
    assign timer_en_fall = !timer_en & timer_en_delay;

    //Set Limit, reset internal counter value and halt request
    assign halt_ack = halt_req & dbg_mode;
    assign limit = (1 << div_val) - 1;
    assign cnt_rst = !div_en | !timer_en | (limit == int_cnt);

    //Counter enable and select counter mode
    wire count_with_clk, count_with_div_val, count_with_no_div;
    assign count_with_clk = !div_en & timer_en;
    assign count_with_div_val = (div_val != 4'b0) & div_en & timer_en & (int_cnt == limit);
    assign count_with_no_div = (div_val == 4'b0) & div_en & timer_en;


    assign count_en = count_with_clk | count_with_div_val | count_with_no_div;
    assign cnt_en = count_en & !(dbg_mode & halt_req);


    //Internal Counter
    wire count_div_en;
    wire [7:0] int_counter_val, int_cnt_pre;

    assign count_div_en = timer_en & div_en & (div_val != 4'b0);
    assign int_counter_val = (count_div_en) ? (int_cnt + 1'b1) : int_cnt;
    assign int_cnt_pre = (halt_ack) ? int_cnt : ((cnt_rst) ? 8'h0 : int_counter_val);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) int_cnt <= 8'h0;
        else int_cnt <= int_cnt_pre;
    end
endmodule
