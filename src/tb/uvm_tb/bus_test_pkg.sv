`ifndef BUS_TEST_PKG_SV
`define BUS_TEST_PKG_SV
`include "uvm_macros.svh"
package bus_test_pkg;
  import uvm_pkg::*;
  import bus_env_pkg::*;
  import bus_seq_pkg::*;

  `include "bus_base_test.sv"
	`include "bus_pss_test.sv"

endpackage : bus_test_pkg
`endif
