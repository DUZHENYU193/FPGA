module ram #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 64
)(
    input i_wrclk,
    input i_wrst_n,
    input i_wren,
    input [clog2(DATA_DEPTH-1)-1:0] i_waddr,
    input [DATA_WIDTH-1:0] i_wdata,

    input i_rdclk,
    input i_rdrst_n,
    input i_rden,
    input [clog2(DATA_DEPTH-1)-1:0] i_raddr,
    output [DATA_WIDTH-1:0] o_rdata
);
    
    function integer clog2(input integer number);
        begin
            for(clog2=0; number>0; clog2=clog2+1)
                number = number >> 1;
        end
    endfunction

    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] rdata_reg;
    integer i;

    // Write Operation in the Write Clock Domain
    always @(posedge i_wrclk or negedge i_wrst_n) begin
        if (!i_wrst_n) begin
            for (i = 0; i < DATA_DEPTH; i = i + 1) begin
                mem[i] <= 0;
            end
        end else if (i_wren) begin
            mem[i_waddr] <= i_wdata;
        end else begin
            mem[i_waddr] <= mem[i_waddr]; // No operation
        end
    end

    // Read Operation in the Read Clock Domain
    always @(posedge i_rdclk or negedge i_rdrst_n) begin
        if (!i_rdrst_n) begin
            rdata_reg <= 0;
        end else if (i_rden) begin
            rdata_reg <= mem[i_raddr];
        end else begin
            rdata_reg <= rdata_reg; // No operation
        end
    end

    assign o_rdata = rdata_reg;

    

endmodule