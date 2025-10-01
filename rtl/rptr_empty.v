`timescale 1ns / 1ps

module rptr_empty #(
    parameter ASIZE = 5,
    parameter ALMOST_EMPTY_THRESHOLD = 2
)(
    input rclk,
    input rrst_n,
    input rinc,
    input [ASIZE:0] rq2_wptr,
    
    output wire [ASIZE-1:0] raddr,
    output reg [ASIZE:0] rptr,
    output reg rempty,
    output reg ralmostempty
);

    reg [ASIZE:0] rbin;
    wire [ASIZE:0] rbinnext, rgraynext;
    wire rempty_val;
    wire ralmostempty_val;
    wire [ASIZE:0] rq2_wbin, rbin_wbin_diff;
    
    // Binary and Gray code pointer generation
    assign rbinnext = (rinc & (!rempty)) ? rbin + 1'b1 : rbin;
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    
    always @(posedge rclk) begin
        if (!rrst_n)
            {rbin, rptr} <= 0;
        else
            {rbin, rptr} <= {rbinnext, rgraynext};
    end
    
    assign raddr = rbin[ASIZE-1:0];
    
    // FIFO empty condition
    assign rempty_val = (rgraynext == rq2_wptr);
    
    always @(posedge rclk) begin
        if (!rrst_n)
            rempty <= 1'b1;
        else
            rempty <= rempty_val;
    end
    
    // FIFO almost empty condition - Gray to binary conversion
    assign rq2_wbin[ASIZE] = rq2_wptr[ASIZE];
    
    generate
        genvar k;
        for (k = ASIZE-1; k >= 0; k = k - 1) begin : gray2bin
            assign rq2_wbin[k] = rq2_wbin[k+1] ^ rq2_wptr[k];
        end
    endgenerate
    
    // Calculate occupancy with wraparound handling
    assign rbin_wbin_diff = (rbinnext > rq2_wbin) ? 
                            (rq2_wbin + (1 << ASIZE) - rbinnext) : 
                            (rq2_wbin - rbinnext);
    
    assign ralmostempty_val = (rbin_wbin_diff <= ALMOST_EMPTY_THRESHOLD);
    
    always @(posedge rclk) begin
        if (!rrst_n)
            ralmostempty <= 1'b1;
        else
            ralmostempty <= ralmostempty_val;
    end

endmodule