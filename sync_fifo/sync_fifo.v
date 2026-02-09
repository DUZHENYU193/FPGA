`timescale 1ps/1ps

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 128
)( 
    input  wire                     i_sys_clk,
    input  wire                     i_sys_rst_n,
    input  wire                     i_wren,
    input  wire [DATA_WIDTH-1:0]    i_wdata,
    input  wire                     i_rden,
    output wire [DATA_WIDTH-1:0]    o_rdata,
    output wire                     o_full,
    output wire                     o_empty

);
    //ifetch function to calculate data width
    function integer clog2(input integer value);
        begin
            value = value - 1;
            for (clog2 = 0; value > 0; clog2 = clog2 + 1)
                value = value >> 1;
        end
    endfunction

    //inverted fifo memory
    reg [DATA_WIDTH-1:0] mem_ram [0:DATA_DEPTH-1];

    reg [clog2(DATA_DEPTH)-1:0] wptr;
    reg [clog2(DATA_DEPTH)-1:0] rptr;
    reg [clog2(DATA_DEPTH):0]    fifo_count;

    //write pointer logic
    always @(posedge i_sys_clk or negedge i_sys_rst_n) begin
        if (!i_sys_rst_n)
            wptr <= 0;
        else if (i_wren && !o_full) 
            wptr <= wptr + 1;
        else 
            wptr <= wptr;    
    end

    //read pointer logic
    always @(posedge i_sys_clk or negedge i_sys_rst_n) begin
        if (!i_sys_rst_n)
            rptr <= 0;
        else if (i_rden && !o_empty) 
            rptr <= rptr + 1;
        else 
            rptr <= rptr;    
    end

    reg [DATA_WIDTH-1:0] r_data;
    //read data logic
    always @(posedge i_sys_clk or negedge i_sys_rst_n) begin
        if (!i_sys_rst_n)
            r_data <= 0;
        else if (i_rden && !o_empty)
            r_data <= mem_ram[rptr];
        else
            r_data <= r_data;    
    end
    

    integer i;
    //write data logic
    always @(posedge i_sys_clk or negedge i_sys_rst_n) begin
        if (!i_sys_rst_n) begin
            for (i = 0; i < DATA_DEPTH; i = i + 1) begin
                mem_ram[i] <= 0;
            end
        end else if (i_wren && !o_full) begin
            mem_ram[wptr] <= i_wdata;   //非阻塞赋值
        end
    end

    //fifo count logic
    always @(posedge i_sys_clk or negedge i_sys_rst_n) begin
        if (!i_sys_rst_n) 
            fifo_count <= 0;
        else if(i_wren && i_rden && !o_full && !o_empty)//read and write at the same time
            fifo_count <= fifo_count;
        else if (i_wren && !o_full)
            fifo_count <= fifo_count + 1;
        else if (i_rden && !o_empty) 
            fifo_count <= fifo_count - 1;
        else 
            fifo_count <= fifo_count;
    end

    //output signals
    assign o_full  = (fifo_count == DATA_DEPTH) ? 1'b1 : 1'b0;
    assign o_empty = (fifo_count == 0)          ? 1'b1 : 1'b0;
    assign o_rdata = r_data;

    
endmodule