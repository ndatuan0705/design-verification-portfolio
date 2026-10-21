class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)
    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction
endclass

class T_INIT_RESET_seq extends fifo_sequence;
    `uvm_object_utils(T_INIT_RESET_seq)
    function new(string name = "T_INIT_RESET_seq");
        super.new(name);
    endfunction
    task body();
        fifo_seq_item seq_item;
        seq_item = fifo_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 0;
        seq_item.wr_en = 0;
        seq_item.rd_en = 0;
        finish_item(seq_item);
    endtask
endclass

class T_RESET_ON_THE_FLY_seq extends fifo_sequence;
    `uvm_object_utils(T_RESET_ON_THE_FLY_seq)
    function new(string name = "T_RESET_ON_THE_FLY_seq");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item seq_item;
        repeat (10) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            finish_item(seq_item);
        end
        seq_item = fifo_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 0;
        seq_item.wr_en = 0;
        seq_item.rd_en = 0;
        finish_item(seq_item);
        repeat (10) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            finish_item(seq_item);
        end
    endtask
endclass

class T_FILL_THEN_EMPTY_seq extends fifo_sequence;
    `uvm_object_utils(T_FILL_THEN_EMPTY_seq)

    function new(string name = "T_FILL_THEN_EMPTY_seq");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item seq_item;
        repeat (DEPTH) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            seq_item.wr_en = 1;
            seq_item.rd_en = 0;
            finish_item(seq_item);
        end

        repeat (DEPTH) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            seq_item.wr_en = 0;
            seq_item.rd_en = 1;
            finish_item(seq_item);
        end
    endtask
endclass

class T_OVERFLOW_UNDERFLOW_ATTEMPT_seq extends fifo_sequence;
    `uvm_object_utils(T_OVERFLOW_UNDERFLOW_ATTEMPT_seq)

    function new(string name = "T_OVERFLOW_UNDERFLOW_ATTEMPT_seq");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item seq_item;
        repeat (DEPTH + 10) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            seq_item.wr_en = 1;
            seq_item.rd_en = 0;
            finish_item(seq_item);
        end

        repeat (DEPTH + 20) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            seq_item.wr_en = 0;
            seq_item.rd_en = 1;
            finish_item(seq_item);
        end
    endtask
endclass

class T_CONCURRENT_RW_seq extends fifo_sequence;
    `uvm_object_utils(T_CONCURRENT_RW_seq)

    int read_dist  = 90;
    int write_dist = 90;
    function new(string name = "T_CONCURRENT_RW_seq");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item seq_item;
        repeat (200) begin
            seq_item = fifo_seq_item::type_id::create("seq_item");
            seq_item.RD_EN_ON_DIST = read_dist;
            seq_item.WR_EN_ON_DIST = write_dist;
            start_item(seq_item);
            if (!seq_item.randomize()) `uvm_error(get_type_name(), "Randomization failed!")
            seq_item.rst_n = 1;
            finish_item(seq_item);
        end
    endtask
endclass

class T_REGRESSION_seq extends uvm_sequence #(fifo_seq_item);

    `uvm_object_utils(T_REGRESSION_seq)

    T_FILL_THEN_EMPTY_seq            fill_seq;
    T_OVERFLOW_UNDERFLOW_ATTEMPT_seq ovf_seq;
    T_CONCURRENT_RW_seq              concurrent_seq;
    T_RESET_ON_THE_FLY_seq           reset_seq;

    function new(string name = "T_REGRESSION_seq");
        super.new(name);
    endfunction

    task body();

        fill_seq = T_FILL_THEN_EMPTY_seq::type_id::create("fill_seq");
        fill_seq.start(m_sequencer);

        ovf_seq = T_OVERFLOW_UNDERFLOW_ATTEMPT_seq::type_id::create("ovf_seq");
        ovf_seq.start(m_sequencer);

        concurrent_seq = T_CONCURRENT_RW_seq::type_id::create("concurrent_seq");
        concurrent_seq.start(m_sequencer);

        reset_seq = T_RESET_ON_THE_FLY_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer);

    endtask

endclass
