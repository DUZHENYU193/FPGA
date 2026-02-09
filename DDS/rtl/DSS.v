module DDS(
	input clk,
	input rst_n,
	input [2:0] f_sel,
	input en,
	
	output [7:0] dds_data
);

reg [8:0] addr;
reg [2:0] fword;

always @(*)begin
	case(f_sel)
		0:fword = 1;
		1:fword = 2;
		2:fword = 3;
		3:fword = 4;
		4:fword = 5;
		5:fword = 6;
		6:fword = 7;
		default:fword = 1;
	endcase
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		addr <= 9'b0;
	else if(en) 
		addr <= addr + fword;
	else
		addr <= 9'b0;
end
sinrom sinrom_inst(
	.address	(addr[8:1]),
	.clock	(clk),
	.q			(dds_data)
	);



endmodule