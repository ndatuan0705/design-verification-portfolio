module apb_slave (
    input  wire        tim_psel,
    input  wire        tim_pwrite,
    input  wire        tim_penable,
    input  wire        reg_err,
    input  wire        rst_n,
    input  wire        clk,
    input  wire [ 3:0] tim_pstrb,
    input  wire [11:0] tim_paddr,
    input  wire [31:0] tim_pwdata,
    input  wire [31:0] rdata,
    output wire        wr_en,
    output wire        rd_en,
    output wire [31:0] wdata,
    output wire [31:0] tim_prdata,
    output wire        tim_pready,
    output wire        tim_pslverr,
    output wire [11:0] addr,
    output wire [ 3:0] wstrb
);

    localparam [1:0] IDLE = 2'b00, SETUP = 2'b01, WAIT_STATE = 2'b10, ACCESS = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (tim_psel && !tim_penable) next_state = SETUP;
            end
            SETUP: begin
                if (tim_psel && tim_penable) next_state = WAIT_STATE;
                else if (!tim_psel) next_state = IDLE;
            end
            WAIT_STATE: begin
                next_state = ACCESS;
            end
            ACCESS: begin
                if (tim_psel && !tim_penable) begin
                    next_state = SETUP;
                end else if (!tim_psel) begin
                    next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    assign tim_pready = (current_state == ACCESS);
    assign wr_en = (current_state == ACCESS) && tim_pwrite;
    assign rd_en = (current_state == ACCESS) && !tim_pwrite;
    assign tim_pslverr = (current_state == ACCESS) ? reg_err : 1'b0;

    assign wstrb = tim_pstrb;
    assign addr = tim_paddr;
    assign wdata = tim_pwdata;
    assign tim_prdata = rdata;

    /*
wire wr_en_pre, rd_en_pre;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_en <= 1'b0;
        rd_en <= 1'b0;
    end else begin
        wr_en <= wr_en_pre;
        rd_en <= rd_en_pre;
    end
end

assign wr_en_pre = tim_pwrite & tim_penable & tim_pse & (!wr_en);
assign rd_en_pre = tim_psel & tim_penable & (!tim_pwrite) & (!rd_en);
assign tim_pready = wr_en | rd_en;
assign addr = tim_paddr;
assign wdata = tim_pwdata;
assign tim_prdata = rdata;
assign tim_pslverr = reg_err;
assign wstrb = tim_pstrb;
*/
endmodule
