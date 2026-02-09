module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 128
)(
    input                     i_sys_clk     ,
    input                     i_sys_rst_n   ,
    input                     i_wren        ,
    input  [DATA_WIDTH-1: 0]  i_wdata       ,
    input                     i_rden        ,
    output [DATA_WIDTH-1: 0]  o_rdata       ,
    output                    o_empty       ,
    output                    o_full        
);
    


fifo u_fifo(
    .clock (i_sys_clk   ),
    .data  (i_wdata     ),
    .rdreq (i_rden      ),
    .wrreq (i_wren      ),
    .empty (o_empty     ),
    .full  (o_full      ),
    .q     (o_rdata     )
);




endmodule