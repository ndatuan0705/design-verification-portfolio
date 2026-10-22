class fifo_coverage extends uvm_subscriber #(fifo_seq_item);
    `uvm_component_utils(fifo_coverage)

    fifo_seq_item m_item;

    covergroup cg;
        option.per_instance = 1;

        // Transition Coverage
        cp_full_flag: coverpoint m_item.full {
            bins full_assert = (0 => 1); bins full_drop = (1 => 0);
        }

        cp_empty_flag: coverpoint m_item.empty {
            bins empty_assert = (0 => 1); bins empty_drop = (1 => 0);
        }

    
        cp_wr_en: coverpoint m_item.wr_en {
            bins wr_en_flag[] = {0, 1};
        }

        cp_rd_en: coverpoint m_item.rd_en {bins rd_en_flag[] = {0, 1};}

        cp_full: coverpoint m_item.full {bins not_full = {0}; bins is_full = {1};}

        cp_empty: coverpoint m_item.empty {bins not_empty = {0}; bins is_empty = {1};}

        // Cross Coverage
        cross_write_full: cross cp_wr_en, cp_full{
            // FEAT_05
            bins overflow_attempt = binsof (cp_wr_en) intersect {1} && binsof (cp_full) intersect {1};
        }

        cross_read_empty: cross cp_rd_en, cp_empty{
            // FEAT_06
            bins underflow_attempt = binsof(cp_rd_en) intersect {1} && 
                               binsof(cp_empty) intersect {
                1
            };
        }

        cross_wr_rd: cross cp_wr_en, cp_rd_en, cp_full, cp_empty {
            // FEAT_7
            bins valid_concurrent_rw = binsof(cp_wr_en) intersect {1} &&
                                binsof(cp_rd_en) intersect {1} &&
                                binsof(cp_full) intersect {0} &&
                                binsof(cp_empty) intersect {0};
        }
    endgroup

    function new(string name = "fifo_coverage", uvm_component parent);
        super.new(name, parent);
        cg = new();  
    endfunction

    // Analysis Export
    virtual function void write(fifo_seq_item t);
        m_item = t;  
        cg.sample();  
    endfunction

    /*function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("=== FUNCTIONAL COVERAGE: %0.2f%% ===", cg.get_inst_coverage()), UVM_NONE);
  endfunction */
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(get_type_name(), $sformatf("TOTAL COVERAGE: %0.2f%%", cg.get_inst_coverage()),
                  UVM_NONE)

        `uvm_info(get_type_name(), $sformatf(
                  "FULL TRANSITION: %0.2f%%", cg.cp_full_flag.get_coverage()), UVM_NONE)

        `uvm_info(get_type_name(), $sformatf(
                  "EMPTY TRANSITION: %0.2f%%", cg.cp_empty_flag.get_coverage()), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("WR_EN: %0.2f%%", cg.cp_wr_en.get_coverage()),
                  UVM_NONE)

        `uvm_info(get_type_name(), $sformatf("RD_EN: %0.2f%%", cg.cp_rd_en.get_coverage()),
                  UVM_NONE)

        `uvm_info(get_type_name(), $sformatf("FULL STATE: %0.2f%%", cg.cp_full.get_coverage()),
                  UVM_NONE)

        `uvm_info(get_type_name(), $sformatf("EMPTY STATE: %0.2f%%", cg.cp_empty.get_coverage()),
                  UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(
                  "CROSS WRITE_FULL: %0.2f%%", cg.cross_write_full.get_coverage()), UVM_NONE)

        `uvm_info(get_type_name(), $sformatf(
                  "CROSS READ_EMPTY: %0.2f%%", cg.cross_read_empty.get_coverage()), UVM_NONE)

        `uvm_info(get_type_name(), $sformatf("CROSS WR_RD: %0.2f%%", cg.cross_wr_rd.get_coverage()),
                  UVM_NONE)
    endfunction
endclass
