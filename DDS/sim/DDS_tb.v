`timescale 1ns/1ns

	module DDS_tb;

	reg clk;
	reg rst_n;
	reg [2:0] f_sel;
	wire [7:0] dds_data;

	DDS DDS_inst(
	.clk		(clk),
	.rst_n	(rst_n),
	.f_sel	(f_sel),
	.en		(1'b1),
	.dds_data(dds_data)
);


	initial clk = 0;
	always #10 clk = ~clk;
	
	initial begin 
		rst_n = 0;
		f_sel = 0;
		
		#200;
		rst_n = 1;
		#20000;
		f_sel = 1;
		#20000;
		f_sel = 2;
		#20000;		
		f_sel = 4;
		#20000;
		f_sel = 6;
		#20000;
		$stop;
		
	end

endmodule