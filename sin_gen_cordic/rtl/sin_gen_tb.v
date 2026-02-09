`timescale 1ns/1ps

module sin_gen_tb();
    reg         clk;
    reg         rst_n;
    reg         en;
    reg  [7:0]  freq_word;
    wire [15:0] sin_out;

    sin_gen uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .en       (en),
        .freq_word(freq_word),
        .sin_out  (sin_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        en = 0;
        freq_word = 8'd15; 
        
        #100 rst_n = 1;
        #20  en = 1;

        #5000 freq_word = 8'd12;
        #5000 freq_word = 8'd8;
        #5000 freq_word = 8'd4;
        #5000 freq_word = 8'd1;        
        #10000 $stop;
    end
endmodule