// ============================================================================
// File: coverage.sv
// Description: Functional coverage collector for the FIFO testbench.
// ============================================================================

class fifo_coverage #(parameter DATA_WIDTH = 8);
  
  fifo_trans #(DATA_WIDTH) trans;
  mailbox #(fifo_trans #(DATA_WIDTH)) mbx;

  // Coverage definitions
  covergroup cg_fifo;
    option.per_instance = 1;

    // Control signals
    cp_wr_en: coverpoint trans.wr_en;
    cp_rd_en: coverpoint trans.rd_en;
    cross_wr_rd: cross cp_wr_en, cp_rd_en;

    // Status flags
    cp_full: coverpoint trans.full {
      bins not_full = {0};
      bins is_full  = {1};
    }
    
    cp_empty: coverpoint trans.empty {
      bins not_empty = {0};
      bins is_empty  = {1};
    }

    // Data boundaries
    cp_data_in: coverpoint trans.data_in {
      bins min_val = {0};
      bins max_val = {(1<<DATA_WIDTH)-1};
      bins others  = default;
    }
  endgroup

  // Constructor
  function new(mailbox #(fifo_trans #(DATA_WIDTH)) mbx);
    this.mbx = mbx;
    cg_fifo = new();
  endfunction

  // Main execution task
  task run();
    forever begin
      mbx.get(trans);
      
      cg_fifo.sample();
      
      $display("[COVERAGE] Transaction sampled. Current coverage: %0.2f%%", cg_fifo.get_inst_coverage());
    end
  endtask
  
endclass
