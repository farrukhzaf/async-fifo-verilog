`timescale 1ns / 1ps

module sync_r2w #(
    parameter ASIZE = 5
)(
    input wclk,
    input wrst_n,
    input [ASIZE:0] rptr,
    output reg [ASIZE:0] wq2_rptr 
);

    reg [ASIZE:0] wq1_rptr;
    
    always @(posedge wclk) begin
        if (!wrst_n)
            {wq2_rptr, wq1_rptr} <= 0;
        else
            {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr};
    end

endmodule