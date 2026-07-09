// ============================================================================
// File        : transaction.sv
// Description : Transaction/Sequence Item class defining the data packet 
//               passed between Testbench components via mailboxes.
// ============================================================================

class fifo_trans #(parameter DATA_WIDTH = 8);
  
  // 1. Stimulus (Inputs to DUT - Randomized by Generator)
  rand bit wr_en;                     // Write enable
  rand bit rd_en;                     // Read enable
  rand bit [DATA_WIDTH-1:0] data_in;  // Write data
  
  // 2. Response (Outputs from DUT - Sampled by Monitor)
  bit full;                           // FIFO full flag
  bit empty;                          // FIFO empty flag
  bit [DATA_WIDTH-1:0] data_out;      // Read data

  // 3. Constraints
  constraint c_no_idle {
    // Prevent idle cycles by ensuring at least one operation (read or write) is active
    !(wr_en == 0 && rd_en == 0);
  }

  // 4. Methods
  // Print transaction details to the console for debugging
  function void display(string name = "TRANS");
    $display("[%s] wr_en=%b, rd_en=%b, data_in=%0h | full=%b, empty=%b, data_out=%0h", 
             name, wr_en, rd_en, data_in, full, empty, data_out);
  endfunction
  
  // Deep copy method to safely pass objects through mailboxes without reference sharing
  function fifo_trans #(DATA_WIDTH) copy();
    copy = new();
    copy.wr_en    = this.wr_en;
    copy.rd_en    = this.rd_en;
    copy.data_in  = this.data_in;
    copy.full     = this.full;
    copy.empty    = this.empty;
    copy.data_out = this.data_out;
  endfunction

endclass
