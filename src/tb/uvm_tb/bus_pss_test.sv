class bus_pss_test extends uvm_test;
	`uvm_component_utils(bus_pss_test)
	
	bus_env e0;	
	virtual bus_if vif;
	int file; 
	bus_seq seq;

	function new(string name="bus_pss_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

	 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e0 = bus_env::type_id::create("e0", this);
		
		if (!uvm_config_db#(virtual bus_if)::get(this,"", "bus_if", vif))
        `uvm_fatal ("TEST", "Did not get vif")	

		uvm_config_db#(virtual bus_if)::set(this,"e0.a0.*","bus_if", vif);
		seq = bus_seq::type_id::create("seq");
  endfunction : build_phase 
/*
	virtual function void start_of_simulation_phase (uvm_phase phase);
   uvm_root top = uvm_root::get();
	endfunction
*/
	virtual task run_phase (uvm_phase phase);
		`uvm_info(get_full_name(), $sformatf("pss_run_solution"),UVM_LOW)
		super.run_phase(phase);
		phase.raise_objection(this);
    pss__pkg::pss_run_solution();
		#10
    phase.drop_objection(this);
	endtask : run_phase

	virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

  //---------------------------------------
  // run phase
  //---------------------------------------   
	function void report_phase(uvm_phase phase);
		string pss_test;
		uvm_report_server svr;
		super.report_phase(phase);
		// ***************************************************************
		// Esto es para obtener el nombre del test a traves de los argumentos pasados en tiempo de corrida
		pss_test = obtener_pss_test_name(); // se retorna el nombre de la prueba
		// ***************************************************************
		svr = uvm_report_server::get_server();
		if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
		  `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
		  `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
		  `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
			file = $fopen ("results.txt", "a");
			$fdisplay(file, "Test name: %s",pss_test);
      $fdisplay(file, "FAIL");
      $fdisplay(file, "---------------------------------------------");
      $fdisplay(file, " ");
      $fclose(file);
		end
		else begin
		  `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
		  `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
		  `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
			file = $fopen ("results.txt", "a");
			$fdisplay(file, "Test name: %s",pss_test);
      $fdisplay(file, "PASS");
      $fdisplay(file, "Total coverage %0.2f",$get_coverage());
      $display("Total coverage %0.2f",$get_coverage());
      $fdisplay(file, "---------------------------------------------");
      $fdisplay(file, " ");
      $fclose(file);
		end
	endfunction 

	function string obtener_pss_test_name(); // esta funcion se encarga de obtener el nombre de la prueba PSS
		string argumentos[$]; // cola con todos los argumentos pasados en la linea de comandos con ./simv
    uvm_cmdline_processor clp; // clase de tipo definido por UVM
    clp = uvm_cmdline_processor::get_inst(); // obtengo la instancia de la linea de comandos
    clp.get_args(argumentos); // se retorna una cola con la linea de comandos y se guarda en argumentos
		foreach (argumentos[i]) begin // recorro todas las posiciones de la cola
      if (argumentos[i] == "-pss_test") begin // si encuentro el switch -pss_test
        return argumentos[i+1]; // retorno el valor del siguiente argumento
      end // dado que corresponde SI o SI con el nombre del test
    end
  endfunction	: obtener_pss_test_name
	

endclass : bus_pss_test
