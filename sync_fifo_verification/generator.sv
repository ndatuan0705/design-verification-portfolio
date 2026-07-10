// ============================================================================
// File        : generator.sv
// Description : Generator class responsible for creating randomized 
//               transactions and sending them to the Driver via a mailbox.
// ============================================================================

class fifo_gen #(parameter DATA_WIDTH = 8);
  
  // 1. Variables and Communication Channels
  fifo_trans #(DATA_WIDTH) trans;           
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx;  // Mailbox to send data to Driver
  
  int count; // Number of transactions to generate
  
  // Synchronization events
  event next; 
  event done; 
  
  // 2. Constructor
  function new(mailbox #(fifo_trans #(DATA_WIDTH)) mbx, event next, event done);
    this.mbx = mbx;
    this.next = next;
    this.done = done;
  endfunction

  // 3. Main Execution Task
  task run();
    repeat(count) begin
      trans = new(); 
      // Randomize stimulus and halt simulation if randomization fails
      if (!trans.randomize()) begin
        $fatal("[GEN] Fatal Error: Randomization failed!");
      end
      
      trans.display("GEN"); 
      mbx.put(trans);       // Send transaction to Driver
      
      @(next);              // Wait for Driver's acknowledgment
    end
    
    -> done; // Trigger done event when all transactions are generated
  endtask

endclass
