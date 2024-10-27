int num_of_trans = 20;
class bus_virtual_seq extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_virtual_seq)
  
  function new(string name = "bus_virtual_seq");
    super.new(name);
  endfunction : new

	virtual function bit get_trans(bus_seq_item trans);
    return (trans.randomize() with {
      op_type inside {MBC2SPI, MBC2UART, SPI2MBC, SPI2UART, UART2MBC, UART2SPI, MBCBRCST, SPIBRCST, UARTBRCST};
    });
  endfunction : get_trans
  
	virtual task body;
		bus_seq_item trans;
		repeat(num_of_trans) begin
		  trans = bus_seq_item::type_id::create("trans");
		  start_item(trans);
		  if(!get_trans(trans))begin
		    `uvm_fatal("BUS_SEQ", "Randomized trans failed!")
		  end
		  finish_item(trans);
		end
  endtask : body
endclass
