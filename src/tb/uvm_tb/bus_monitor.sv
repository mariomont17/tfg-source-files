
class bus_monitor extends uvm_monitor;
  `uvm_component_utils(bus_monitor)

  virtual bus_if vif;

	// cola con los datos a los que se hace push
  bus_seq_item trans_q[$];
	int num_xfers = 0; // numero de paquetes a los que se hace push
	semaphore key; // declaro un semáforo para que los 2 procesos puedan usar la misma estructura de datos num_xfers 
	
  uvm_analysis_port#(bus_seq_item) in_port; // puerto de entrada (los objetos que introduce el driver en las fifos de entrada)
  uvm_analysis_port#(bus_seq_item) out_port; // puerto de salida (los objetos que extrae el driver desde las fifos de salida)

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(virtual bus_if)::get(null, "", "bus_if", vif)) 
    else begin
      `uvm_fatal("MON", "Unable to get bus if!")
    end
    in_port = new("in_port", this);
    out_port = new("out_port", this);
  endfunction : build_phase 

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase 

  virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		init_signal();
		key = new(1);
    fork 
      in_monitor(); 
			out_monitor();
    join
  endtask : run_phase

  virtual task in_monitor(); // captura los datos que se enviaron al DUT (REQUEST == IN)
    bus_seq_item request;
    forever begin
			@(posedge vif.clk);
			if(vif.push_mbc) begin // hubo push en fifo del MBC
				`uvm_info("MON", $sformatf("PUSH EN MBC"), UVM_DEBUG)
        request = bus_seq_item::type_id::create("request");
				request.snt_pkt = vif.D_push_mbc;
				request.target = vif.D_push_mbc[64:62];
				request.source = vif.D_push_mbc[61:60];
				in_port.write(request);
				key.get(1); // obtengo llave alterar variable num_xfers
				num_xfers = num_xfers + 1;
				if (request.target == 3'b111) begin // push dos veces porque en broadcast el paquete se recibe dos veces (i.e. una vez en cada terminal)
					num_xfers = num_xfers + 1;
				end
				key.put(1); // vuelvo a poner la llave del semaforo
      end
			if(vif.push_spi) begin // hubo push en fifo del SPI
				`uvm_info("MON", $sformatf("PUSH EN SPI"), UVM_DEBUG)
        request = bus_seq_item::type_id::create("request");
				request.snt_pkt = vif.D_push_spi;
				request.target = vif.D_push_spi[64:62];
				request.source = vif.D_push_spi[61:60];
				in_port.write(request);
				key.get(1); // obtengo llave alterar variable num_xfers
				num_xfers = num_xfers + 1;
				if (request.target == 3'b111) begin // push dos veces porque en broadcast el paquete se recibe dos veces (i.e. una vez en cada terminal)
					num_xfers = num_xfers + 1;
				end
				key.put(1); // vuelvo a poner la llave del semaforo
      end
			if(vif.push_uart) begin // hubo push en fifo del UART
				`uvm_info("MON", $sformatf("PUSH EN UART"), UVM_DEBUG)
        request = bus_seq_item::type_id::create("request");
				request.snt_pkt = vif.D_push_uart;
				request.target = vif.D_push_uart[64:62];
				request.source = vif.D_push_uart[61:60];
				in_port.write(request);
				key.get(1); // obtengo llave alterar variable num_xfers
				num_xfers = num_xfers + 1;
				if (request.target == 3'b111) begin // push dos veces porque en broadcast el paquete se recibe dos veces (i.e. una vez en cada terminal)
					num_xfers = num_xfers + 1;
				end
				key.put(1); // vuelvo a poner la llave del semaforo
      end
    end
  endtask : in_monitor

  virtual task out_monitor(); // captura los datos que salen del DUT (LEGACY == OUT)
    bus_seq_item legacy;
		bus_seq_item aux;
    forever begin : forever_block
			@(negedge vif.clk);
			if ((num_xfers == 0) && (vif.pop_mbc || vif.pop_spi || vif.pop_uart)) begin 
			// checks if transaction's queue is empty and if any pop signal has been triggered
				`uvm_error("MON", $psprintf("Se realizó pop con %0d transacciones por procesar", num_xfers))
			end else begin 
				if (vif.pop_mbc && (vif.D_pop_mbc[64:60] != 5'b00000)) begin // pop en MBC
					`uvm_info("MON", $sformatf("POP EN MBC"), UVM_DEBUG)
					legacy = bus_seq_item::type_id::create("legacy");
					key.get(1); // obtengo llave alterar variable num_xfers
					num_xfers = num_xfers - 1;
					key.put(1); // vuelvo a poner la llave del semaforo
					legacy.target = 3'b000;
					legacy.source = vif.D_pop_mbc[64:62];
					legacy.rcv_pkt = vif.D_pop_mbc;
					out_port.write(legacy);
				end
				if (vif.pop_spi && (vif.D_pop_spi[64:60] != 5'b00000)) begin // pop en SPI
					`uvm_info("MON", $sformatf("POP EN SPI"), UVM_DEBUG)
					legacy = bus_seq_item::type_id::create("legacy");
					key.get(1); // obtengo llave alterar variable num_xfers
					num_xfers = num_xfers - 1;
					key.put(1); // vuelvo a poner la llave del semaforo
					legacy.target = 3'b001;
					legacy.source = vif.D_pop_spi[64:62];
					legacy.rcv_pkt = vif.D_pop_spi;
					out_port.write(legacy);
				end
				if (vif.pop_uart && (vif.D_pop_uart[64:60] != 5'b00000)) begin // pop en UART
					`uvm_info("MON", $sformatf("POP EN UART"), UVM_DEBUG)
					legacy = bus_seq_item::type_id::create("legacy");
					key.get(1); // obtengo llave alterar variable num_xfers
					num_xfers = num_xfers - 1;
					key.put(1); // vuelvo a poner la llave del semaforo
					legacy.target = 3'b010;
					legacy.source = vif.D_pop_uart[64:62];
					legacy.rcv_pkt = vif.D_pop_uart;
					out_port.write(legacy);
				end
			end
    end
  endtask : out_monitor

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if(num_xfers > 0) begin
      `uvm_warning("MON", $psprintf("No se recibieron %0d trans. debido a OVERFLOW en alguna FIFO", num_xfers))
    end
  endfunction : report_phase


  virtual task init_signal();

    @(negedge vif.reset); // waits until reset signal goes from 1 to 0
    repeat(2) begin
      @(posedge vif.clk);
    end

  endtask : init_signal


	virtual function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name != "run")
      return;

    if (num_xfers != 0) begin // no se termina la prueba hasta que se reciban todos los paquetes generados!
      phase.raise_objection(this);
      fork
        delay_phase_end(phase);
      join_none
    end
  endfunction


  virtual task delay_phase_end(uvm_phase phase);
    //wait ((trans_q.size() == 0) || ($time == 1000));
		fork // se termina la prueba hasta que num_xfers sea cero o bien hayan pasado 100 tiempos de simulación (tiempo limite)!
			begin
    		wait (num_xfers == 0); 
			end
    	begin 
				#50; 
			end
		join_any
    phase.drop_objection(this);
  endtask


endclass : bus_monitor
