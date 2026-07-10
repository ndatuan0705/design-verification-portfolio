// ============================================================================
// File: scoreboard.sv
// Description: Reference model and result checker for the FIFO.
// ============================================================================

class fifo_scoreboard #(parameter DATA_WIDTH = 8);
  
  // Transaction handle and mailbox
  fifo_trans #(DATA_WIDTH) trans;
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx;
  
  // Reference queue
  bit [DATA_WIDTH-1:0] ref_queue [$];
  
  // Statistics counters
  int trans_count;
  int err_count;
  int match_count;
  
  // Constructor
  function new(mailbox #(fifo_trans #(DATA_WIDTH)) mbx);
    this.mbx = mbx;
  endfunction
  
  // Main execution task
  task run();
    bit [DATA_WIDTH-1:0] expected_data;
    
    forever begin
      mbx.get(trans);
      trans_count++;
      
      // Process write: Update reference queue
      if (trans.wr_en && !trans.full) begin
        ref_queue.push_back(trans.data_in); 
        $display("[SCOREBOARD] Pushed data: %0h into Queue", trans.data_in);
      end
      
      // Process read: Compare DUT output with expected data
      if (trans.rd_en && !trans.empty) begin
        expected_data = ref_queue.pop_front(); 
        
        if (expected_data == trans.data_out) begin
          match_count++;
          $display("[SCOREBOARD] PASS! Match found for data: %0h", trans.data_out);
        end 
        else begin
          err_count++;
          $error("[SCOREBOARD] FAIL! Expected: %0h, but DUT output: %0h", expected_data, trans.data_out);
        end
      end
      
    end
  endtask
  
endclass
