module sin_gen(
	input 			clk		,
	input 			rst_n		,
	input 			en			,
	input [7:0]		freq_word,
	output [15:0]	sin_out
);

	reg [7:0] addr;

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			addr <= 'd0;
		else if(en)
			addr <= addr + freq_word;
	end
	sinrom sinrom_inst(
	.address		(addr),
	.clock		(clk),
	.q				(sin_out)
	);
	
	
endmodule