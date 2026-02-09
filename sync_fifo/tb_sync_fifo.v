`timescale 1ps/1ps
`define CLK_PERIOD 20

module tb_sync_fifo;
    
    parameter DATA_WIDTH = 16;
    parameter DATA_DEPTH = 128;
    
    reg                     i_sys_clk;
    reg                     i_sys_rst_n;
    reg                     i_wren;
    reg  [DATA_WIDTH-1:0]   i_wdata;
    reg                     i_rden;
    wire [DATA_WIDTH-1:0]   o_rdata;
    wire                    o_full;
    wire                    o_empty;

    // Instantiate the sync_fifo module
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) uut (
        .i_sys_clk(i_sys_clk),
        .i_sys_rst_n(i_sys_rst_n),
        .i_wren(i_wren),
        .i_wdata(i_wdata),
        .i_rden(i_rden),
        .o_rdata(o_rdata),
        .o_full(o_full),
        .o_empty(o_empty)
    );

    // Clock generation
    initial begin
        i_sys_clk = 0;
        forever #(`CLK_PERIOD/2) i_sys_clk = ~i_sys_clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        i_sys_rst_n = 0;
        i_wren = 0;
        i_wdata = 0;
        i_rden = 0;

        // Release reset
        #15;
        i_sys_rst_n = 1;

        // Write data to FIFO
        repeat (10) begin
            @(negedge i_sys_clk);
            i_wren = 1;
            i_wdata = $random % 256; // Random data
        end

        @(negedge i_sys_clk);
        i_wren = 0;

        // Read data from FIFO
        repeat (10) begin
            @(negedge i_sys_clk);
            i_rden = 1;
        end

        @(negedge i_sys_clk);
        i_rden = 0;

        // Finish simulation
        #50;
        $finish;
    end

endmodule