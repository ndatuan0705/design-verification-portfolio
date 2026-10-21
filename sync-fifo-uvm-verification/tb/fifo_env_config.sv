class fifo_env_config extends uvm_object;
    `uvm_object_utils(fifo_env_config)

    virtual fifo_if vif;
    // Flag ON/OFF (default: ON)
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit has_scoreboard = 1;
    bit has_coverage = 1;

    function new(string name = "fifo_env_config");
        super.new(name);
    endfunction
endclass
