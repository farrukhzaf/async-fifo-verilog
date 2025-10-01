`timescale 1ns / 1ps

module wptr_full #(
    parameter ASIZE = 5,
    parameter ALMOST_FULL_THRESHOLD = 4
)(
    input wclk,
    input wrst_n,
    input winc,
    input [ASIZE:0] wq2_rptr,
    
    output wire [ASIZE-1:0] waddr,
    output reg [ASIZE:0] wptr,
    output reg wfull,
    output reg walmostfull
);

    reg [ASIZE:0] wbin;
    wire [ASIZE:0] wbinnext, wgraynext;
    wire wfull_val;
    wire walmostfull_val;
    wire [ASIZE:0] wq2_rbin, wbin_rbin_diff;
    
    // Binary and Gray code pointer generation
    assign wbinnext = (winc & !wfull) ? wbin + 1 : wbin;
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    
    always @(posedge wclk) begin
        if (!wrst_n)
            {wbin, wptr} <= 0;
        else
            {wbin, wptr} <= {wbinnext, wgraynext};
    end
    
    assign waddr = wbin[ASIZE-1:0];
    
    // FIFO full condition
    assign wfull_val = (wgraynext == {~wq2_rptr[ASIZE:ASIZE-1], 
                                       wq2_rptr[ASIZE-2:0]});
    
    always @(posedge wclk) begin
        if (!wrst_n)
            wfull <= 1'b0;
        else 
            wfull <= wfull_val;
    end
    
    // FIFO almost full condition - Gray to binary conversion
    assign wq2_rbin[ASIZE] = wq2_rptr[ASIZE];
    
    generate
        genvar k;
        for (k = ASIZE-1; k >= 0; k = k - 1) begin : gray2bin
            assign wq2_rbin[k] = wq2_rbin[k+1] ^ wq2_rptr[k];
        end
    endgenerate
    
    // Calculate available space with wraparound handling
    assign wbin_rbin_diff = (wq2_rbin > wbinnext) ? 
                            (wq2_rbin - wbinnext) : 
                            (wq2_rbin - wbinnext + (1 << ASIZE));
    
    assign walmostfull_val = (wbin_rbin_diff <= ALMOST_FULL_THRESHOLD);
    
    always @(posedge wclk) begin
        if (!wrst_n) 
            walmostfull <= 1'b0; 
        else        
            walmostfull <= walmostfull_val;
    end

endmodule