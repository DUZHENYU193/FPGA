module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 64
)(
    input i_wrclk,
    input i_wrst_n,
    input i_wren,
    input [DATA_WIDTH-1:0] i_wdata,

    input i_rdclk,
    input i_rdrst_n,
    input i_rden,
    output [DATA_WIDTH-1:0] o_rdata,
    output o_full,
    output o_empty
);

    reg [clog2(DATA_DEPTH-1):0] r_wrptr;//[6:0] Write pointer
    reg [clog2(DATA_DEPTH-1):0] r_rdptr;//[6:0] Read pointer
    wire [clog2(DATA_DEPTH-1)-1:0] w_wraddr;//[5:0] Write address to RAM
    wire [clog2(DATA_DEPTH-1)-1:0] w_rdaddr;//[5:0]

    assign w_wraddr = r_wrptr[clog2(DATA_DEPTH-1)-1:0];//keep lower bits for address
    assign w_rdaddr = r_rdptr[clog2(DATA_DEPTH-1)-1:0];//send to RAM, it matches depth



    // Calculate address width
    function integer clog2(input integer number);
        begin
            for(clog2=0; number>0; clog2=clog2+1)
                number = number >> 1;
        end
    endfunction

    // Write Pointer Logic
    always @(posedge i_wrclk or negedge i_wrst_n) begin
        if (!i_wrst_n) begin
            r_wrptr <= 0;
        end else if (i_wren && !o_full) begin
            r_wrptr <= r_wrptr + 1;
        end
    end

    // Read Pointer Logic
    always @(posedge i_rdclk or negedge i_rdrst_n) begin
        if (!i_rdrst_n) begin
            r_rdptr <= 0;
        end else if (i_rden && !o_empty) begin
            r_rdptr <= r_rdptr + 1;
        end
    end

    //gray code conversion functions could be added here for pointer synchronization
    reg [clog2(DATA_DEPTH-1):0] r_wrptr_gray_sync;
    reg [clog2(DATA_DEPTH-1):0] r_rdptr_gray_sync;

    always @(posedge i_wrclk or negedge i_wrst_n) begin
        if (!i_wrst_n) begin
            r_wrptr_gray_sync <= 0;
        end else begin
            r_wrptr_gray_sync <= r_wrptr ^ (r_wrptr >> 1);
        end
    end

    always @(posedge i_rdclk or negedge i_rdrst_n) begin
        if (!i_rdrst_n) begin
            r_rdptr_gray_sync <= 0;
        end else begin
            r_rdptr_gray_sync <= r_rdptr ^ (r_rdptr >> 1);
        end
    end

    // Synchronize read pointer to write clock domain
    reg [clog2(DATA_DEPTH-1):0] r_rdptr_gray_d0;
    reg [clog2(DATA_DEPTH-1):0] r_rdptr_gray_d1;

    always @(posedge i_wrclk or negedge i_wrst_n) begin
        if (!i_wrst_n) begin
            r_rdptr_gray_d0 <= 0;
            r_rdptr_gray_d1 <= 0;
        end else begin
            r_rdptr_gray_d0 <= r_rdptr_gray_sync;
            r_rdptr_gray_d1 <= r_rdptr_gray_d0;
        end
    end

    // Synchronize write pointer to read clock domain
    reg [clog2(DATA_DEPTH-1):0] r_wrptr_gray_d0;
    reg [clog2(DATA_DEPTH-1):0] r_wrptr_gray_d1;

    always @(posedge i_rdclk or negedge i_rdrst_n) begin
        if (!i_rdrst_n) begin
            r_wrptr_gray_d0 <= 0;
            r_wrptr_gray_d1 <= 0;
        end else begin
            r_wrptr_gray_d0 <= r_wrptr_gray_sync;
            r_wrptr_gray_d1 <= r_wrptr_gray_d0;
        end
    end


    // Full and Empty Flag Logic
    //read point that MSB and next MSB inverted, rest same equals write pointer
    assign o_full = (r_wrptr_gray_sync == {~r_rdptr_gray_d1[clog2(DATA_DEPTH-1):clog2(DATA_DEPTH-1)-1], 
                    r_rdptr_gray_d1[clog2(DATA_DEPTH-1)-2:0]});
    
    //empty when both pointers are equal
    assign o_empty = (r_wrptr_gray_sync == r_rdptr_gray_d1);
    //combinational logic may cause metastability, consider using flip-flops for synchronization

    // Instantiate RAM module
    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) u_ram (
        .i_wrclk(i_wrclk),
        .i_wrst_n(i_wrst_n),
        .i_wren(i_wren),
        .i_waddr(w_wraddr),//without MSB
        .i_wdata(i_wdata),

        .i_rdclk(i_rdclk),
        .i_rdrst_n(i_rdrst_n),
        .i_rden(i_rden),
        .i_raddr(w_rdaddr),//without MSB
        .o_rdata(o_rdata)
    );

    
endmodule