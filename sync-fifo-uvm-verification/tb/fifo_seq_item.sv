class fifo_seq_item extends uvm_sequence_item;

    rand logic [DATA_WIDTH-1:0] data_in;
    rand logic wr_en, rd_en;
    logic full, empty, rst_n;
    logic [DATA_WIDTH-1:0] data_out;

    int WR_EN_ON_DIST = 50;
    int RD_EN_ON_DIST = 50;

    `uvm_object_utils_begin(fifo_seq_item)
        `uvm_field_int(data_in, UVM_ALL_ON)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(rd_en, UVM_ALL_ON)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(full, UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
        `uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction

    constraint wr_en_con {
        wr_en dist {
            1 := WR_EN_ON_DIST,
            0 := (100 - WR_EN_ON_DIST)
        };
    }

    constraint rd_en_con {
        rd_en dist {
            1 := RD_EN_ON_DIST,
            0 := (100 - RD_EN_ON_DIST)
        };
    }
endclass
