module Syn_FIFO #(parameter DATA_WIDTH = 8, DEPTH = 16) (
  input  logic clk, rst_n, wr_en, rd_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic full, empty,
  output logic [DATA_WIDTH-1:0] data_out
);

  localparam ADDR_WIDTH = $clog2(DEPTH);
  
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
  
  logic [ADDR_WIDTH:0] wr_ptr, rd_ptr;
 
  //write
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      wr_ptr <= '0;
    end 
    else if(wr_en && !full) begin
      mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end
  
  //read
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      rd_ptr <= '0;
      data_out <= '0;
    end 
    else if(rd_en && !empty) begin
      data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  assign empty = (wr_ptr == rd_ptr);
  assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH])
              && (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

endmodule
