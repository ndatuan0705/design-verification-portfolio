class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) item_collected_export;

    logic [DATA_WIDTH-1:0] ref_q[$];  //reference_model save data_in value from monitor
    fifo_seq_item item_q[$];  //save seq_item value from monitor
    logic [DATA_WIDTH-1:0] expected_data;
    bit read_pending;
    int match_count = 0;
    int error_count = 0;
    function new(string name = "fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write(fifo_seq_item seq_item);
        `uvm_info(get_type_name(), $sformatf("Received transaction:\n%s", seq_item.sprint()),
                  UVM_LOW);
        if (!seq_item.rst_n) begin
            ref_q.delete();
            item_q.delete();
            read_pending = 0;
        end else begin
            item_q.push_back(seq_item);
        end
    endfunction

    task run_phase(uvm_phase phase);
        fifo_seq_item current_item;

        forever begin
            wait (item_q.size() > 0);
            current_item = item_q.pop_front();

            // Check FEAT_03 and FEAT_04 (Full/Empty Flag)
            if (current_item.full !== (ref_q.size() == DEPTH)) begin
                `uvm_error(get_type_name(), $sformatf("Full flag mismatch! Act: %0b, Exp size: %0d",
                                                      current_item.full, ref_q.size()))
                error_count++;
            end

            if (current_item.empty !== (ref_q.size() == 0)) begin
                `uvm_error(get_type_name(), $sformatf(
                                                "Empty flag mismatch! Act: %0b, Exp size: %0d",
                                                current_item.empty, ref_q.size()))
                error_count++;
            end

            if (read_pending) begin
                check_data_out(expected_data, current_item.data_out);
                read_pending = 0;
            end

            if ((current_item.wr_en == 1) && !current_item.full) begin
                ref_q.push_back(current_item.data_in);
            end
            if ((current_item.rd_en == 1) && !current_item.empty) begin
                expected_data = ref_q.pop_front();
                read_pending  = 1;
            end

        end
    endtask

    virtual function void check_data_out(logic [DATA_WIDTH-1:0] expected_data,
                                         logic [DATA_WIDTH-1:0] actual_data);
        if (expected_data === actual_data) begin
            `uvm_info(get_type_name(), $sformatf("Correct: data_out matches: %0h", actual_data),
                      UVM_HIGH)
            match_count++;
        end else begin
            `uvm_error(
                get_type_name(), $sformatf(
                "Error: data_out mismatch! Expected: %0h, Actual: %0h", expected_data, actual_data))
            error_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Total successful transactions: %0d", match_count),
                  UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Total failed transactions: %0d", error_count),
                  UVM_MEDIUM)
    endfunction

endclass
