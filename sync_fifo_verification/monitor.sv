// ============================================================================
// File: monitor.sv
// Description: Passively monitors DUT signals and broadcasts transactions 
//              to both Scoreboard and Coverage via separate mailboxes.
// ============================================================================

class fifo_monitor #(parameter DATA_WIDTH = 8);
  
  virtual fifo_if #(DATA_WIDTH) vif;
  
  // Two separate mailboxes to prevent data contention
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx_scb;
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx_cov;
  
  // Constructor updated to accept two mailboxes
  function new(virtual fifo_if #(DATA_WIDTH) vif, 
               mailbox #(fifo_trans #(DATA_WIDTH)) mbx_scb,
               mailbox #(fifo_trans #(DATA_WIDTH)) mbx_cov);
    this.vif = vif;
    this.mbx_scb = mbx_scb;
    this.mbx_cov = mbx_cov;
  endfunction

  task run();
    fifo_trans #(DATA_WIDTH) trans;
    bit pending_read; 
    
    forever begin
      @(vif.monitor_cb);
      
      // 1. Process read from the previous cycle
      if (pending_read) begin
        trans = new();
        trans.rd_en    = 1;
        trans.data_out = vif.monitor_cb.data_out; 
        trans.empty    = 0; 
        
        trans.display("MONITOR [READ OUT]");
        mbx_scb.put(trans); // Send to Scoreboard
        mbx_cov.put(trans); // Send to Coverage
      end
      
      // 2. Process immediate write
      if (vif.monitor_cb.wr_en && !vif.monitor_cb.full) begin
        trans = new();
        trans.wr_en   = 1;
        trans.data_in = vif.monitor_cb.data_in;
        trans.full    = vif.monitor_cb.full;
        
        trans.display("MONITOR [WRITE IN]");
        mbx_scb.put(trans); // Send to Scoreboard
        mbx_cov.put(trans); // Send to Coverage
      end
      
      // 3. Set pending read flag for the next cycle
      if (vif.monitor_cb.rd_en && !vif.monitor_cb.empty) begin
        pending_read = 1;
      end else begin
        pending_read = 0;
      end
      
    end
  endtask
  
endclass
