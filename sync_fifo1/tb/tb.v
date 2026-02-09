`timescale 1ns/1ps
`define CLK_PERILOD 20

module tb;

    parameter DATA_WIDTH = 8;
    parameter DATA_DEPTH = 128;

    reg                     r_sys_clk   ;
    reg                     r_sys_rst_n ;
    reg                     r_wren      ;
    reg  [DATA_WIDTH-1: 0]  r_wdata     ;
    reg                     r_rden      ;
    wire [DATA_WIDTH-1: 0]  w_rdata     ;
    wire                    w_empty     ;
    wire                    w_full      ;

    // clk gen
    initial begin
        r_sys_clk = 1'b0;
        forever #(`CLK_PERILOD/2) r_sys_clk = ~r_sys_clk;
    end

    // rst gen
    initial begin
        r_sys_rst_n = 1'b0;
        #(`CLK_PERILOD*2);
        r_sys_rst_n = 1'b1;
    end

    initial begin
        r_wren  = 1'b0;
        r_wdata = {DATA_WIDTH{1'b0}};
        r_rden  = 1'b0;
        #(`CLK_PERILOD*5);

        // write data
        repeat (DATA_DEPTH) begin
            @(posedge r_sys_clk);
            r_wren  = 1'b1;
            r_wdata = r_wdata + 1'b1;
        end
        @(posedge r_sys_clk);
        r_wren = 1'b0;

        #(`CLK_PERILOD*10);

        // read data
        repeat (DATA_DEPTH) begin
            @(posedge r_sys_clk);
            r_rden = 1'b1;
        end
        @(posedge r_sys_clk);
        r_rden = 1'b0;

        #(`CLK_PERILOD*10);
        $stop;
    end

    // DUT inst
    sync_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DATA_DEPTH (DATA_DEPTH)
    ) u_sync_fifo (
        .i_sys_clk   (r_sys_clk   ),
        .i_sys_rst_n (r_sys_rst_n ),
        .i_wren      (r_wren      ),
        .i_wdata     (r_wdata     ),
        .i_rden      (r_rden      ),
        .o_rdata     (w_rdata     ),
        .o_empty     (w_empty     ),
        .o_full      (w_full      )
    );

endmodule

