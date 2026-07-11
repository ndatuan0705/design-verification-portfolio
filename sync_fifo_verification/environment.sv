// ============================================================================
// File: fifo_env.sv
// Description: Environment class that instantiates and connects all TB components,
//              now including the Coverage collector.
// ============================================================================

class fifo_env #(parameter DATA_WIDTH = 8);
  
  // TB Components
  fifo_gen        #(DATA_WIDTH) gen;
  fifo_driver     #(DATA_WIDTH) drv;
  fifo_monitor    #(DATA_WIDTH) mon;
  fifo_scoreboard #(DATA_WIDTH) sco;
  fifo_coverage   #(DATA_WIDTH) cov; // Added Coverage component
  
  virtual fifo_if #(DATA_WIDTH) vif;
  
  // Mailboxes
  mailbox #(fifo_trans #(DATA_WIDTH)) Gen_Drv_mbx;
  mailbox #(fifo_trans #(DATA_WIDTH)) Mon_Scb_mbx;
  mailbox #(fifo_trans #(DATA_WIDTH)) Mon_Cov_mbx; // Added Coverage mailbox
  
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
    Mon_Cov_mbx = new(); // Instantiate Coverage mailbox
    
    // Connect monitor to BOTH mailboxes
    mon = new(vif, Mon_Scb_mbx, Mon_Cov_mbx);
    
    sco = new(Mon_Scb_mbx);
    cov = new(Mon_Cov_mbx); // Connect coverage to its mailbox
  endfunction
  
  task pre_test();
    $display("[ENVIRONMENT] === STARTING PRE-TEST PHASE ===");
    drv.reset();
  endtask
  
  task test();
    $display("[ENVIRONMENT] === STARTING TEST PHASE ===");
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
      cov.run(); // Run Coverage concurrently
    join_any
  endtask
  
  task post_test();
    $display("[ENVIRONMENT] === STARTING POST-TEST PHASE ===");
    wait(done.triggered);
    repeat(20) @(vif.driver_cb);
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
    
    $display("TEST FINISHED: Total Trans = %0d | PASS = %0d | FAIL = %0d", 
             sco.trans_count, sco.match_count, sco.err_count);
    
    // Print final Coverage score before finishing
    $display("FINAL COVERAGE = %0.2f%%", cov.cg_fifo.get_coverage());
    
    $finish;
  endtask
  
endclass
