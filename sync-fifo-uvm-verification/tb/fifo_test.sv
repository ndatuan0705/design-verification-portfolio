class fifo_base_test extends uvm_test;
    `uvm_component_utils(fifo_base_test)
    fifo_env env;
    fifo_env_config cfg;
    virtual fifo_if vif;
    T_INIT_RESET_seq init_reset_seq;

    function new(string name = "fifo_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg = fifo_env_config::type_id::create("cfg");
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Failed to get Virtual Interface!")
        cfg.vif = vif;
        cfg.is_active = UVM_ACTIVE;
        uvm_config_db#(fifo_env_config)::set(this, "*", "cfg", cfg);
        env = fifo_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        //phase.raise_objection(this);

        init_reset_seq = T_INIT_RESET_seq::type_id::create("init_reset_seq");
        init_reset_seq.start(env.agent.seqr);
        //#50ns;
        //`uvm_info(get_type_name(), "End of testcase", UVM_LOW);
        //phase.drop_objection(this);
    endtask
endclass

class test_reset_on_the_fly extends fifo_base_test;
    `uvm_component_utils(test_reset_on_the_fly)
    T_RESET_ON_THE_FLY_seq reset_seq;

    function new(string name = "test_reset_on_the_fly", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.run_phase(phase);
        #10ns;
        reset_seq = T_RESET_ON_THE_FLY_seq::type_id::create("reset_seq");

        reset_seq.start(env.agent.seqr);
        #50ns;
        `uvm_info(get_type_name(), "End of testcase", UVM_LOW);

        phase.drop_objection(this);
    endtask
endclass

class test_fill_then_empty extends fifo_base_test;
    `uvm_component_utils(test_fill_then_empty)
    T_FILL_THEN_EMPTY_seq fill_empty_seq;

    function new(string name = "test_fill_then_empty", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.run_phase(phase);
        #10ns;
        fill_empty_seq = T_FILL_THEN_EMPTY_seq::type_id::create("fill_empty_seq");
        fill_empty_seq.start(env.agent.seqr);
        #50ns;
        `uvm_info(get_type_name(), "End of testcase", UVM_LOW);

        phase.drop_objection(this);
    endtask
endclass

class test_overflow_underflow_attempt extends fifo_base_test;
    `uvm_component_utils(test_overflow_underflow_attempt)
    T_OVERFLOW_UNDERFLOW_ATTEMPT_seq ovf_seq;

    function new(string name = "test_overflow_underflow_attempt", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.run_phase(phase);
        ovf_seq = T_OVERFLOW_UNDERFLOW_ATTEMPT_seq::type_id::create("ovf_seq");

        ovf_seq.start(env.agent.seqr);
        #50ns;
        `uvm_info(get_type_name(), "End of testcase", UVM_LOW);

        phase.drop_objection(this);
    endtask
endclass

class test_concurrent_rw extends fifo_base_test;
    `uvm_component_utils(test_concurrent_rw)
    T_CONCURRENT_RW_seq concurrent_seq;

    function new(string name = "test_concurrent_rw", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.run_phase(phase);
        #10ns;
        concurrent_seq = T_CONCURRENT_RW_seq::type_id::create("concurrent_seq");

        concurrent_seq.start(env.agent.seqr);
        #50ns;
        `uvm_info(get_type_name(), "End of testcase", UVM_LOW);

        phase.drop_objection(this);
    endtask
endclass

class test_regression extends fifo_base_test;

    `uvm_component_utils(test_regression)

    T_REGRESSION_seq regression_seq;

    function new(string name = "test_regression", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        super.run_phase(phase);

        regression_seq = T_REGRESSION_seq::type_id::create("regression_seq");

        regression_seq.start(env.agent.seqr);

        #50ns;

        phase.drop_objection(this);

    endtask

endclass
