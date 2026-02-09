`timescale 1ns/1ns

module sin_gen_tb;
	reg clk;
	reg rst_n;
	reg [7:0]freq_word;
	wire [15:0] sin_out;
	
	sin_gen sin_gen_inst(
	.clk			(clk),
	.rst_n		(rst_n),
	.en			(1'b1),
	.freq_word	(freq_word),
	.sin_out		(sin_out)
);

	initial clk = 0;
	always #5 clk = ~clk;
	
	initial begin
		rst_n = 0;
		freq_word = 0;
		#200;
		rst_n = 1;
		freq_word = 1;
		#20000;
		freq_word = 2;
		#20000;
		freq_word = 4;
		#20000;
		freq_word = 8;
		#20000;
		$stop;
	end

endmodule