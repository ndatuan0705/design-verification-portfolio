class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    fifo_agent agent;
    fifo_scoreboard scb;
    fifo_coverage cov;
    fifo_env_config cfg;

    function new(string name = "fifo_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(fifo_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "Failed to get Config Object!")

        if (cfg.has_scoreboard) scb = fifo_scoreboard::type_id::create("scb", this);
        if (cfg.has_coverage) cov = fifo_coverage::type_id::create("cov", this);

        agent = fifo_agent::type_id::create("agent", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect monitor analysis port to enabled components
        if (cfg.has_scoreboard) agent.mon.mon_ap.connect(scb.item_collected_export);

        if (cfg.has_coverage) agent.mon.mon_ap.connect(cov.analysis_export);
    endfunction
endclass
