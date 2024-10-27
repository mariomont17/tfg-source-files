class bus_sqr extends uvm_sequencer#(bus_seq_item);

  `uvm_component_utils(bus_sqr) 

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
  	super.build_phase (phase);
  endfunction : build_phase
	
	task run_phase(uvm_phase phase);
  	super.run_phase(phase);
  endtask	: run_phase

endclass
