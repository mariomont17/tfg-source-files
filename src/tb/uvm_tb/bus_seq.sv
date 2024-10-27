class bus_seq extends uvm_sequence#(bus_seq_item);
	`uvm_object_utils(bus_seq)
  
	trans_code op_type;
	bit [3:0] delay;
	bit [59:0] pkt;
  bit [2:0] target;
  bit [1:0] src;

	extern function new(string name="bus_seq");
  extern virtual task body();
  extern virtual task write(input bit [2:0]         target,
                            input bit [1:0]         src,
                            input bit [59:0]  			pkt,
                            input trans_code 				op_type,
														input bit [3:0]					delay,
                            input bus_sqr 					seqr,
                            input uvm_sequence_base parent = null);

endclass

function bus_seq::new(string name="bus_seq");
   super.new(name);
endfunction

task bus_seq::body();
  bus_seq_item trans;
  trans = bus_seq_item::type_id::create("trans");
  `uvm_info ("BUS_SEQ", $sformatf("before start item, pkt = %h", pkt), UVM_DEBUG)
  start_item(trans);
	trans.op_type = this.op_type;
	trans.delay = this.delay;
	trans.pkt = this.pkt;
  trans.target = this.target;
  trans.source = this.src;
  trans.concatenate_pkg();
	`uvm_info ("BUS_SEQ", $sformatf("before finish item, pkt = %h", trans.snt_pkt), UVM_DEBUG)
  finish_item(trans);
endtask

task bus_seq::write(input bit [2:0]         target,
                    input bit [1:0]         src,
								    input bit [59:0]  			pkt,
                    input trans_code 				op_type,
										input bit [3:0]					delay,
                    input bus_sqr 					seqr,
                    input uvm_sequence_base parent = null);

  this.target = target;
  this.src = src;
  this.pkt = pkt;
  this.op_type = op_type;
	this.delay = delay;	
  this.start(seqr, parent);
endtask




