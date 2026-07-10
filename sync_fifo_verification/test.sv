// ============================================================================
// File: test.sv
// Description: Top-level test class that configures and runs the environment.
// ============================================================================

class fifo_test #(parameter DATA_WIDTH = 8);
  
  // Environment instance
  fifo_env #(DATA_WIDTH) env;
  
  // Constructor
  function new(virtual fifo_if #(DATA_WIDTH) vif);
    env = new(vif); 
  endfunction
  
  // Main execution task
  task run();
    // Set number of transactions for the generator
    env.gen.count = 50;
    
    // Start the environment
    env.run();
  endtask
  
endclass
