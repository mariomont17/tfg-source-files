class bus_coverage extends uvm_subscriber #(bus_seq_item);
	`uvm_component_utils(bus_coverage)
  bus_seq_item trans;
	
	covergroup cg_bus_xfer;
    cp_bus_target: coverpoint trans.rcv_pkt[64:62] { // TARGET
      bins tg_mbc   = {3'b000};
      bins tg_spi   = {3'b001};
      bins tg_uart  = {3'b010};
      bins tg_brcst = {3'b111}; 
    }
    cp_bus_src: coverpoint trans.rcv_pkt[61:60] { // SOURCE
      bins src_mbc  = {2'b00};
      bins src_spi  = {2'b01};
      bins src_uart = {2'b10};
    }
    cc_bus_xfer: cross cp_bus_target, cp_bus_src { // CRUCE ENTRE TARGET Y SOURCE CON EXCEPCIÓN DE TARGET == SOURCE
      ignore_bins cc_1 = cc_bus_xfer with (cp_bus_target == {3'b000} && cp_bus_src == {2'b00});
      ignore_bins cc_2 = cc_bus_xfer with (cp_bus_target == {3'b001} && cp_bus_src == {2'b01});
      ignore_bins cc_3 = cc_bus_xfer with (cp_bus_target == {3'b010} && cp_bus_src == {2'b10});
    }
	endgroup : cg_bus_xfer
	
  function new (string name = "bus_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_bus_xfer = new();
  endfunction

	virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase 

  function void write (T t);
    $cast(trans, t);
    cg_bus_xfer.sample();    
  endfunction : write
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("COV", $sformatf("Overall:  %3.2f %% coverage achieved",  cg_bus_xfer.get_coverage()), UVM_LOW);
    `uvm_info("COV", $sformatf("cp_bus_target:  %3.2f %% coverage achieved",  cg_bus_xfer.cp_bus_target.get_coverage()), UVM_LOW);
    `uvm_info("COV", $sformatf("cp_bus_src:  %3.2f %% coverage achieved",  cg_bus_xfer.cp_bus_src.get_coverage()), UVM_LOW);
    `uvm_info("COV", $sformatf("cc_bus_xfer:  %3.2f %% coverage achieved",  cg_bus_xfer.cc_bus_xfer.get_coverage()), UVM_LOW);
   
  endfunction : report_phase      
  
endclass
