class bus_agent extends uvm_agent;
	`uvm_component_utils(bus_agent)
	
	bus_sqr sqr;
	bus_driver driver;
	bus_monitor monitor;
	
	function new(string name = "bus_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

	virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = bus_sqr::type_id::create("sqr", this);
    driver = bus_driver::type_id::create("driver", this);
    monitor = bus_monitor::type_id::create("monitor", this);
  endfunction : build_phase 

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sqr.seq_item_export);
  endfunction : connect_phase 

	
endclass : bus_agent
