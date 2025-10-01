`timescale 1ns / 1ps

module fifomem #(
    parameter ASIZE = 5,
    parameter DSIZE = 8
)(
    // Write domain
    input wclk,
    input wclken,
    input [DSIZE-1:0] wdata,
    input [ASIZE-1:0] waddr,
    
    // Read domain
    input [ASIZE-1:0] raddr,
    output [DSIZE-1:0] rdata
);

    localparam DEPTH = 1 << ASIZE;
    reg [DSIZE-1:0] mem[0:DEPTH-1];
    
    assign rdata = mem[raddr];
    
    always @(posedge wclk) begin
        if (wclken)
            mem[waddr] <= wdata;
    end

endmodule