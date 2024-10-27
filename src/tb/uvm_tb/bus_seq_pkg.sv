`ifndef BUS_SEQ_PKG_SV
`define BUS_SEQ_PKG_SV
`include "uvm_macros.svh"
package bus_seq_pkg;

  import uvm_pkg::*;
  import bus_env_pkg::*;

  `include "bus_virtual_seq.sv"
	`include "bus_seq.sv"

endpackage : bus_seq_pkg
`endif
