`define DRIV_IF vif.driver_cb

class bus_driver extends uvm_driver #(bus_seq_item);
	
	`uvm_component_utils(bus_driver)
	
	bit [2:0] target;
	bit [1:0] source;

	virtual bus_if vif;
    
  function new (string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual bus_if)::get(null, "", "bus_if", vif)) 
    else begin
			`uvm_fatal("DRV", "Unable to get bus if!")
		end
  endfunction: build_phase
	
	virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    @(negedge vif.reset); // waits until reset signal goes from 1 to 0
    repeat(2) begin
      @(posedge vif.clk);
    end
    phase.drop_objection(this);
  endtask : reset_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    init_signal();
		fork 
			begin
				forever begin
					bus_seq_item trans;
				  seq_item_port.get_next_item(trans);
				  drive_item(trans);
				  seq_item_port.item_done();
		  	end 
			end 
			begin
				capture_item();
			end
		join
  endtask : run_phase	
	
  virtual task init_signal();
    `DRIV_IF.push_mbc 		<= 1'b0;
    `DRIV_IF.push_spi 		<= 1'b0;
    `DRIV_IF.push_uart 		<= 1'b0;
    `DRIV_IF.D_push_mbc 	<= 65'b0;
    `DRIV_IF.D_push_spi 	<= 65'b0;
    `DRIV_IF.D_push_uart 	<= 65'b0;
    `DRIV_IF.pop_mbc 			<= 1'b0;
    `DRIV_IF.pop_spi 			<= 1'b0;
    `DRIV_IF.pop_uart 		<= 1'b0;

    @(negedge vif.reset); // waits until reset signal goes from 1 to 0
    repeat(2) begin
      @(posedge vif.clk);
    end
  endtask : init_signal

	virtual task drive_item(bus_seq_item trans);
		
		@(posedge vif.clk);
		repeat(trans.delay) begin
      @(posedge vif.clk);
    end
		case (trans.source) 
			2'b00: begin // FUENTE 0 == HACER PUSH EN MBC
				`DRIV_IF.D_push_mbc <= trans.snt_pkt;
				`DRIV_IF.push_mbc <= 1'b1;
				@(posedge vif.clk);
				`DRIV_IF.push_mbc <= 1'b0;
				`DRIV_IF.D_push_mbc <= 65'b0;
			end
			2'b01: begin // FUENTE 1 == HACER PUSH EN SPI
				`DRIV_IF.D_push_spi <= trans.snt_pkt;
				`DRIV_IF.push_spi <= 1'b1;
				@(posedge vif.clk);
				`DRIV_IF.push_spi <= 1'b0;
				`DRIV_IF.D_push_spi <= 65'b0;
			end
			2'b10: begin // FUENTE 2 == HACER PUSH EN UART
				`DRIV_IF.D_push_uart <= trans.snt_pkt;
				`DRIV_IF.push_uart <= 1'b1;
				@(posedge vif.clk);
				`DRIV_IF.push_uart <= 1'b0;
				`DRIV_IF.D_push_uart <= 65'b0;
			end
			default: begin // SI ES DISTINTO A LOS CASOS ANTERIORES => REPORTAR ERROR DE FUENTE
				`uvm_fatal("DRV",$sformatf("Fuente Inválida, valor de source = %h", trans.source))
			end
		endcase
		trans.print();
	endtask : drive_item

	virtual task capture_item();
		forever begin
			//@(posedge vif.clk);
			repeat(5) begin
      	@(posedge vif.clk);
    	end
			@(posedge vif.clk);
			if (`DRIV_IF.pndng_mbc)	begin
				`DRIV_IF.pop_mbc <= 1; //Le hace pop al dato del mbc
		    @(posedge vif.clk);
		    `DRIV_IF.pop_mbc <= 0; //pone pop en bajo despues de un ciclo
			end 
			if (`DRIV_IF.pndng_spi) begin
				`DRIV_IF.pop_spi <= 1; //Le hace pop al dato del spi
		    @(posedge vif.clk);
		    `DRIV_IF.pop_spi <= 0;
			end
			if (`DRIV_IF.pndng_uart) begin	
				`DRIV_IF.pop_uart <= 1; //Le hace pop al dato del uart
		    @(posedge vif.clk);
		    `DRIV_IF.pop_uart <= 0;
			end	
		end		
	endtask : capture_item


endclass : bus_driver
