class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)
    fifo_driver drv;
    fifo_monitor mon;
    fifo_sequencer seqr;
    fifo_env_config cfg;
    function new(string name = "fifo_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //get object cấu hình
        if (!uvm_config_db#(fifo_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "Failed to get Config Object!")

        //monitor luôn đc tạo dù active hay passive
        mon = fifo_monitor::type_id::create("mon", this);

        //kiểm tra active
        if (cfg.is_active == UVM_ACTIVE) begin
            drv  = fifo_driver::type_id::create("drv", this);
            seqr = fifo_sequencer::type_id::create("seqr", this);
        end

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass
