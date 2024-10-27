`ifndef BUS_SEQ_ITEM_SV
`define BUS_SEQ_ITEM_SV

typedef enum bit [3:0] {
	MBC2SPI		= 4'b0000,
	MBC2UART	= 4'b0001,
	SPI2MBC		= 4'b0010,
	SPI2UART	= 4'b0011,
	UART2MBC	= 4'b0100,
	UART2SPI	= 4'b0101,
	MBCBRCST	= 4'b0110,
	SPIBRCST	= 4'b0111,
	UARTBRCST	= 4'b1000
} trans_code;
`include "uvm_macros.svh"
import uvm_pkg::*;
class bus_seq_item extends uvm_sequence_item;
	
	bit [64:0] 			rcv_pkt;
	bit [64:0]			snt_pkt;	
	rand bit [2:0] 	target;
	rand bit [1:0] 	source;
  rand bit [59:0] pkt;
	rand trans_code op_type;
	rand bit [3:0]	delay; 
	
	constraint c_delay {
    delay inside {[6:10]};
  }
	
  `uvm_object_utils_begin(bus_seq_item)
    `uvm_field_int (target, UVM_DEC)
    `uvm_field_int (source, UVM_DEC)
    `uvm_field_int (pkt, UVM_HEX)
		`uvm_field_int (rcv_pkt, UVM_HEX)
		`uvm_field_int (snt_pkt, UVM_HEX)
		`uvm_field_enum(trans_code, op_type, UVM_ALL_ON);
  `uvm_object_utils_end 
	

	function new(string name = "bus_seq_item");
    super.new(name);
  endfunction

	extern virtual function void print ();
	
	function void concatenate_pkg ();
		this.snt_pkt = {this.target, this.source, this.pkt};
	endfunction

endclass : bus_seq_item

function void bus_seq_item::print ();
  `uvm_info ("BUS_SEQ_ITEM", $sformatf ("target = %0h", target), UVM_HIGH)
	`uvm_info ("BUS_SEQ_ITEM", $sformatf ("source = %0h", source), UVM_HIGH)
	`uvm_info ("BUS_SEQ_ITEM", $sformatf ("pkt = %0h", pkt), UVM_HIGH)
	`uvm_info ("BUS_SEQ_ITEM", $sformatf ("op_type = %s", op_type), UVM_HIGH)
	`uvm_info ("BUS_SEQ_ITEM", $sformatf ("snt_pkt = %0h", snt_pkt), UVM_HIGH)
  `uvm_info ("BUS_SEQ_ITEM", $sformatf ("rcv_pkt = %0h", rcv_pkt), UVM_HIGH)
endfunction


`endif

