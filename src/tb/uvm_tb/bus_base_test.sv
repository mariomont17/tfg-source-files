class bus_base_test extends uvm_test;
	`uvm_component_utils(bus_base_test)
	
	bus_env e0;	
	virtual bus_if vif;

	bus_virtual_seq seq;

	function new(string name="bus_base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

	 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e0 = bus_env::type_id::create("e0", this);
		
		if (!uvm_config_db#(virtual bus_if)::get(this,"", "bus_if", vif))
        `uvm_fatal ("TEST", "Did not get vif")	

		uvm_config_db#(virtual bus_if)::set(this,"e0.a0.*","bus_if", vif);
		
    seq = bus_virtual_seq::type_id::create("seq");
  endfunction : build_phase 

	virtual task run_phase (uvm_phase phase);
		phase.raise_objection(this);
    seq.start(e0.a0.sqr);
		#10
    phase.drop_objection(this);
	endtask : run_phase

	virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

  //---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------   
 function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction 

endclass : bus_base_test
