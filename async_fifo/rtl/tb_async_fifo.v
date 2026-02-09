`timescale 1ps/1ps
`define WCLK_PERIOD 20
`define RCLK_PERIOD 50


module tb_async_fifo;
parameter DATA_WIDTH = 8;
parameter DATA_DEPTH = 128;
    reg wrclk;
    reg wrst_n;
    reg wren;
    reg [DATA_WIDTH-1:0] wdata;

    reg rdclk;
    reg rdrst_n;
    reg rden;
    wire [DATA_WIDTH-1:0] rdata;
    wire full;
    wire empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) uut (
        .i_wrclk(wrclk),
        .i_wrst_n(wrst_n),
        .i_wren(wren),
        .i_wdata(wdata),
        .i_rdclk(rdclk),
        .i_rdrst_n(rdrst_n),
        .i_rden(rden),
        .o_rdata(rdata),
        .o_full(full),
        .o_empty(empty)
    );

    // Clock generation
    initial begin
        wrclk = 0;
        forever #(`WCLK_PERIOD/2) wrclk = ~wrclk;
    end

    initial begin
        rdclk = 0;
        forever #(`RCLK_PERIOD/2) rdclk = ~rdclk;
    end

    // Testbench procedure
    initial begin
        $vcdpluson;
        // Initialize signals
        wrst_n = 0;
        rdrst_n = 0;
        wren = 0;
        rden = 0;
        wdata = 0;

        // Release resets
        #30;
        wrst_n = 1;
        rdrst_n = 1;

        // Write data to FIFO
        repeat (DATA_DEPTH + 10) begin
            @(posedge wrclk);
            if (!full) begin
                wdata = $random % 256;
                wren = 1;
            end else begin
                wren = 0;
            end
        end
        wren = 0;

        // Read data from FIFO
        repeat (DATA_DEPTH + 10) begin
            @(posedge rdclk);
            if (!empty) begin
                rden = 1;
            end else begin
                rden = 0;
            end
        end
        rden = 0;

        // Finish simulation
        // rgb(234, 25, 220);
        $vcdplusoff;
        $finish;
    end
    
endmodule