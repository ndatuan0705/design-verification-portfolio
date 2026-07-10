// ============================================================================
// File: environment.sv
// Description: Environment class that instantiates and connects all TB components.
// ============================================================================

class fifo_env #(parameter DATA_WIDTH = 8);
  
  // TB Components
  fifo_gen        #(DATA_WIDTH) gen;
  fifo_driver     #(DATA_WIDTH) drv;
  fifo_monitor    #(DATA_WIDTH) mon;
  fifo_scoreboard #(DATA_WIDTH) sco;
  
  virtual fifo_if #(DATA_WIDTH) vif;
  
  // Mailboxes and synchronization events
  mailbox #(fifo_trans #(DATA_WIDTH)) Gen_Drv_mbx;
  mailbox #(fifo_trans #(DATA_WIDTH)) Mon_Scb_mbx;
  
  event next;
  event done;
  
  // Constructor
  function new(virtual fifo_if #(DATA_WIDTH) vif);
    this.vif = vif;
    
    // Active Path
    Gen_Drv_mbx = new(); 
    gen = new(Gen_Drv_mbx, next, done);
    drv = new(vif, Gen_Drv_mbx, next);
    
    // Passive Path
    Mon_Scb_mbx = new();
    mon = new(vif, Mon_Scb_mbx);
    sco = new(Mon_Scb_mbx);
  endfunction
  
  // Pre-test phase: Initialize and reset DUT
  task pre_test();
    $display("[ENVIRONMENT] === STARTING PRE-TEST PHASE ===");
    drv.reset();
  endtask
  
  // Test phase: Run components concurrently
  task test();
    $display("[ENVIRONMENT] === STARTING TEST PHASE ===");
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
  
  // Post-test phase: Wait for completion and drain pipelines
  task post_test();
    $display("[ENVIRONMENT] === STARTING POST-TEST PHASE ===");
    wait(done.triggered);
    repeat(20) @(vif.driver_cb);
  endtask
  
  // Main execution flow
  task run();
    pre_test();
    test();
    post_test();
    
    $display("TEST FINISHED: Total Trans = %0d | PASS = %0d | FAIL = %0d", 
             sco.trans_count, sco.match_count, sco.err_count);
    $finish;
  endtask
  
endclass
