class bus_env extends uvm_env;
  `uvm_component_utils(bus_env)
	
	bus_agent a0;
	bus_scoreboard sb0;
	bus_coverage cov0;

	function new(string name="bus_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new
	
	virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a0   = bus_agent::type_id::create("a0", this);
    sb0  = bus_scoreboard::type_id::create("sb0", this);
		cov0 = bus_coverage::type_id::create("cov0", this);
  endfunction : build_phase 
	
	virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a0.monitor.out_port.connect(sb0.out_export);
    a0.monitor.in_port.connect(sb0.in_export);
		a0.monitor.out_port.connect(cov0.analysis_export);
  endfunction : connect_phase 

endclass : bus_env
