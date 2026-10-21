class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        fifo_env_config cfg;
        super.build_phase(phase);
        //get cái hộp từ cơ sở dữ liệu
        if (!uvm_config_db#(fifo_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "Failed to get Config Object!");
        //Mở hộp lấy interface ra xài
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);

            @(vif.driver_cb);

            `uvm_info(get_type_name(), $sformatf(
                      "wr_en = %0b, rd_en = %0b, data_in = %0b", req.wr_en, req.rd_en, req.data_in),
                      UVM_LOW);

            vif.driver_cb.rst_n   <= req.rst_n;
            vif.driver_cb.wr_en   <= req.wr_en;
            vif.driver_cb.rd_en   <= req.rd_en;
            vif.driver_cb.data_in <= req.data_in;

            seq_item_port.item_done();
        end
    endtask
endclass
