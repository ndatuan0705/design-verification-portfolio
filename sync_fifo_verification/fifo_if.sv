// ============================================================================
// File: fifo_if.sv
// Description: SystemVerilog Interface connecting the Testbench and DUT.
// Includes Clocking Blocks for synchronization, Modports for access control, 
// and SystemVerilog Assertions (SVA) for protocol checking.
// ============================================================================

interface fifo_if #(parameter DATA_WIDTH = 8, DEPTH = 16) (input logic clk, rst_n);
  
  logic wr_en, rd_en, full, empty;
  logic [DATA_WIDTH-1:0] data_in, data_out;
  
  // 2. Clocking Blocks (Avoid Race Conditions)
  
  // Driver clocking block: Drives inputs to DUT, samples outputs from DUT
  clocking driver_cb @(posedge clk);
    default input #1step output #1ns;
    output data_in, wr_en, rd_en;
    input data_out, full, empty;
  endclocking
  
  // Monitor clocking block: Passively samples all signals
  clocking monitor_cb @(posedge clk);
    default input #1step;
    input full, empty, data_out, data_in, wr_en, rd_en;
  endclocking
  
  // 3. Modports (Access Restrictions)
  modport DRIVER (clocking driver_cb, input clk, rst_n);
  modport MONITOR (clocking monitor_cb, input clk, rst_n);
  
  // 4. SystemVerilog Assertions (Protocol Checkers)
  
  // Rule 1: FIFO cannot be full and empty simultaneously
  property p_not_full_and_empty;
    @(posedge clk) disable iff (!rst_n) 
    !(empty && full);
  endproperty
  assert_p_not_full_and_empty: assert property (p_not_full_and_empty)
    else $error("[SVA FAIL] Rule 1: FIFO is both FULL and EMPTY!");
      
  // Rule 2: Status flags must not contain X or Z values
  property p_no_xz_flags;
    @(posedge clk) disable iff (!rst_n) 
    !$isunknown({full, empty});
  endproperty
  assert_p_no_xz_flags: assert property (p_no_xz_flags)
    else $error("[SVA FAIL] Rule 2: Full or Empty flag has X/Z value!");
      
  // Rule 3: Hold-Full - If full and write occurs without read, it must remain full
  property p_hold_full;
    @(posedge clk) disable iff(!rst_n)
    (full && wr_en && !rd_en) |=> full; 
  endproperty
  assert_p_hold_full: assert property (p_hold_full)
    else $error("[SVA FAIL] Rule 3: Full flag dropped unexpectedly!");
      
  // Rule 4: Hold-Empty - If empty and read occurs without write, it must remain empty
  property p_hold_empty;
    @(posedge clk) disable iff(!rst_n)
    (empty && rd_en && !wr_en) |=> empty;
  endproperty
  assert_p_hold_empty: assert property (p_hold_empty)
    else $error("[SVA FAIL] Rule 4: Empty flag dropped unexpectedly!");
  
  // Rule 5: Data Integrity - Valid read operation must not output X/Z data
  property p_valid_data_out;
    @(posedge clk) disable iff(!rst_n)
    (rd_en && !empty) |=> !$isunknown(data_out);
  endproperty
  assert_p_valid_data_out: assert property (p_valid_data_out)
    else $error("[SVA FAIL] Rule 5: Read data contains X/Z!");

endinterface
