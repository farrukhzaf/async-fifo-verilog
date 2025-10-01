`timescale 1ns / 1ps

module sync_w2r #(
    parameter ASIZE = 5
)(
    input rclk,
    input rrst_n,
    input [ASIZE:0] wptr,
    output reg [ASIZE:0] rq2_wptr 
);

    reg [ASIZE:0] rq1_wptr;
    
    always @(posedge rclk) begin
        if (!rrst_n)
            {rq2_wptr, rq1_wptr} <= 0;
        else
            {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
    end

endmodule