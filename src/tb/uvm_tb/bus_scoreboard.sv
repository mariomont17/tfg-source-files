`uvm_analysis_imp_decl(_out) // uno para las transacciones que salen
`uvm_analysis_imp_decl(_in) // otro para las que entran
class bus_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(bus_scoreboard)

  uvm_analysis_imp_out#(bus_seq_item, bus_scoreboard) out_export;
  uvm_analysis_imp_in#(bus_seq_item, bus_scoreboard) in_export;

  bus_seq_item exp_trans_q[$];
  bus_seq_item act_trans_q[$];

	bus_seq_item act_trans_array [bit[64:0]];
	bus_seq_item exp_trans_array [bit[64:0]];

  function new(string name = "bus_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    out_export = new("out_export", this);
    in_export = new("in_export", this);
  endfunction : build_phase 

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase 

	function void write_out(bus_seq_item trans);
    `uvm_info("SCB", "Received transaction from FIFO_OUT", UVM_DEBUG)
    trans.print();
    act_trans_q.push_back(trans); // cola con paquetes recibidos
		act_trans_array[trans.rcv_pkt] = trans; // arreglo asociativo con paquetes recibidos
  endfunction : write_out

	function void write_in(bus_seq_item trans);
    `uvm_info("SCB", "Received transaction from FIFO_IN", UVM_DEBUG)
    trans.print();
    exp_trans_q.push_back(trans); // cola con paquetes enviados
		exp_trans_array[trans.snt_pkt] = trans; // arreglo asociativo con paquetes enviados
  endfunction : write_in
	
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		fork 
			compare_bus_trans();
		join_none
	endtask : run_phase

	task compare_bus_trans();
		bus_seq_item act_trans; // actual
		bus_seq_item exp_trans; // expected
		bus_seq_item aux; 			// auxiliar
		bit [64:0] idx;					// index
		bus_seq_item aux_asoc_array [bit[64:0]];
		forever begin
			wait((exp_trans_q.size() > 0) && (act_trans_q.size() > 0));
			aux = bus_seq_item::type_id::create("aux");
			aux = act_trans_q.pop_front();
			idx = aux.rcv_pkt;
			if(exp_trans_array.exists(idx)) begin  // si el indice de paquete recibido existe en el arreglo de paquetes transmitidos, PASS
				exp_trans = bus_seq_item::type_id::create("exp_trans");
				exp_trans = exp_trans_array[idx]; // transaccion esperada
				//`uvm_info("SCB", $sformatf("Matched pkt, expected = %h actual = %h", exp_trans.snt_pkt, aux.rcv_pkt), UVM_DEBUG)
				`uvm_info("SCB",$sformatf("----------- :: DATA Match:: -----------------"), UVM_LOW)
        `uvm_info("SCB",$sformatf("Expected Data: %0h", exp_trans.snt_pkt), UVM_LOW)
        `uvm_info("SCB",$sformatf("Actual Data  : %0h", aux.rcv_pkt), UVM_LOW)
        `uvm_info("SCB",          "---------------------------------------------", UVM_LOW)
				if (exp_trans.target != 3'b111) begin// si el target/destino no es un broadcast -> se elimina del arreglo asociativo
					exp_trans_array.delete(idx);
				end else begin // SI ES OPERACION DE BROADCAST
					if (aux_asoc_array.exists(idx)) begin // si ya esta en el array de comparados al menos una vez
						exp_trans_array.delete(idx); // entonces se elimina del arreglo asociativo
						aux_asoc_array.delete(idx);
					end else begin
						aux_asoc_array[idx] = aux; // si no existe, se guarda una vez
					end
				end
			end else begin // si los datos no coinciden, se advierte al usuario, dado que se generó un error 
				`uvm_error("SCB", "----------- :: DATA Mismatch:: -------------")
				`uvm_info("SCB","Expected Data: ???", UVM_LOW)
        `uvm_info("SCB",$sformatf("Actual Data  : %0h", idx), UVM_LOW)
				`uvm_info("SCB", "Actual data isn't in Expected assoc array", UVM_LOW)
        `uvm_info("SCB", "---------------------------------------------", UVM_LOW)
			end
		end
		
		
	endtask

	virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if(exp_trans_array.size() > 0) begin
			`uvm_info("SCB", "---------------------------------------------", UVM_LOW)
      `uvm_warning("SCB", $psprintf("The Expected asoc array hasn't completed %0d", exp_trans_array.size()))
			`uvm_info("SCB", "Transfers in Expected assoc array:", UVM_LOW)
      `uvm_info("SCB", "---------------------------------------------", UVM_LOW)
			foreach (exp_trans_array[index]) begin
				`uvm_info("SCB",$sformatf("Transfer  : %0h", exp_trans_array[index].snt_pkt), UVM_LOW)
			end
			`uvm_info("SCB", "---------------------------------------------", UVM_LOW)
    end
  endfunction : report_phase

endclass : bus_scoreboard
