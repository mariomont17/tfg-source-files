import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "bus_top_pkg.sv"
//import bus_top_pkg::*;


module bus_tb;
	reg clk;	
	reg reset;
	
	bus_if vif(.clk(clk), .reset(reset));
	
	always #1 clk =~ clk;

	tec_riscv_bus DUT (

    .clk					(clk),
    .reset				(reset),
    .pndng_mbc		(vif.pndng_mbc),
    .pndng_spi		(vif.pndng_spi),
    .pndng_uart		(vif.pndng_uart),
    .push_mbc			(vif.push_mbc),
    .push_spi			(vif.push_spi),
    .push_uart		(vif.push_uart),
    .pop_mbc			(vif.pop_mbc),
    .pop_spi			(vif.pop_spi),
    .pop_uart			(vif.pop_uart),
    .D_pop_mbc		(vif.D_pop_mbc),
    .D_pop_spi		(vif.D_pop_spi),
    .D_pop_uart		(vif.D_pop_uart),
    .D_push_mbc		(vif.D_push_mbc),
    .D_push_spi		(vif.D_push_spi),
    .D_push_uart	(vif.D_push_uart)

  );

	initial begin
		clk = 1'b0;
    reset = 1'b0;
		@(posedge clk);
		reset = 1'b1;
    repeat(5) begin
      @(posedge clk);
    end
    reset = 1'b0;
	end
	

	initial begin
   // uvm_config_db#(virtual bus_if)::set(null,"uvm_test_top","bus_if", vif);
		 uvm_config_db#(virtual bus_if)::set(null, "", "bus_if", vif);
    run_test ();
  end

	initial begin : DUMP
		$fsdbDumpfile("bus_top.fsdb"); 
    $fsdbDumpvars(0, bus_tb);
	end 

	 always@(posedge clk) begin
    if ($time > 100000)begin
      $display("Test_bench: Tiempo límite de prueba en el testbench alcanzado");
      $finish;
    end
  end
	

endmodule
