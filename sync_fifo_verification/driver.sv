// ============================================================================
// File: driver.sv
// Description: Drives transactions from the mailbox to the DUT interface.
// ============================================================================

class fifo_driver #(parameter DATA_WIDTH = 8);
  
  // Virtual interface and communication channels
  virtual fifo_if #(DATA_WIDTH) vif;
  fifo_trans #(DATA_WIDTH) trans;
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx; 
  event next;
  
  // Constructor
  function new(virtual fifo_if #(DATA_WIDTH) vif, 
               mailbox #(fifo_trans #(DATA_WIDTH)) mbx, 
               event next);
    this.vif = vif;
    this.mbx = mbx;
    this.next = next;
  endfunction
  
  // Reset task: Initialize DUT inputs
  task reset();
    wait(!vif.rst_n);
    $display("[DRIVER] DUT RESET");
    
    vif.driver_cb.wr_en   <= 1'b0;
    vif.driver_cb.rd_en   <= 1'b0;
    vif.driver_cb.data_in <= '0;
    
    wait(vif.rst_n);
    $display("[DRIVER] DUT RESET DONE");
  endtask
    
  // Main run task: Drive signals to DUT
  task run();
    forever begin
      mbx.get(trans);
      
      @(vif.driver_cb); 
      
      trans.display("DRIVER");
      
      vif.driver_cb.wr_en   <= trans.wr_en;
      vif.driver_cb.rd_en   <= trans.rd_en;
      vif.driver_cb.data_in <= trans.data_in;
      
      -> next;
    end
  endtask
  
endclass
