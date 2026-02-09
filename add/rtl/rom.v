module rom(
	input wire[31:0] inst_addr_i,
	output reg[31:0] inst_o
);
	
	reg[31:0] rom_men[0:4095]; //4096 32byte room
	
	always @(*)begin
		inst_o = rom_men[inst_addr_i >> 2];
	end

endmodule