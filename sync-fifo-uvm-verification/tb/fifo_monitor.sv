class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
    uvm_analysis_port #(fifo_seq_item) mon_ap;
    virtual fifo_if vif;

    function new(string name = "fifo_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        fifo_env_config cfg;
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        if (!uvm_config_db#(fifo_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "Failed to get Config Object!");

        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            fifo_seq_item mon_item;
            @(vif.monitor_cb);
            mon_item = fifo_seq_item::type_id::create("mon_item");
            mon_item.rst_n = vif.monitor_cb.rst_n;
            mon_item.wr_en = vif.monitor_cb.wr_en;
            mon_item.rd_en = vif.monitor_cb.rd_en;
            mon_item.data_in = vif.monitor_cb.data_in;
            mon_item.full = vif.monitor_cb.full;
            mon_item.empty = vif.monitor_cb.empty;
            mon_item.data_out = vif.monitor_cb.data_out;
            `uvm_info(get_type_name(), $sformatf(
                      "full = %0b, empty = %0b, data_out = %0b",
                      mon_item.full,
                      mon_item.empty,
                      mon_item.data_out
                      ), UVM_HIGH);
            mon_ap.write(mon_item);
        end
    endtask
endclass
