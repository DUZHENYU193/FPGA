module ifetch(
	//from pc address
	input wire[31:0] pc_addr_i,
	//from rom address
	input wire[31:0] rom_inst_i,
	//send to rom
	output wire[31:0] if2rom_addr_o,
	//send address and instruction to if_id
	output wire[31:0] inst_addr_o,
	output wire[31:0] inst_o
);
	
	assign if2rom_addr_o = pc_addr_i;
	assign inst_addr_o = pc_addr_i;
	assign inst_o = rom_inst_i;
	
	
	
	
	
endmodule