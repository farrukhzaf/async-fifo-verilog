`timescale 1ns / 1ps

module async_fifo #(
    parameter DSIZE = 8,
    parameter ASIZE = 5,
    parameter ALMOST_FULL_THRESHOLD = 4,
    parameter ALMOST_EMPTY_THRESHOLD = 2
)(
    // Write clock domain
    input wclk,
    input wrst_n,
    input winc,
    input [DSIZE-1:0] wdata,
    output wfull,
    output walmostfull,
    
    // Read clock domain
    input rclk,
    input rrst_n,
    input rinc,
    output [DSIZE-1:0] rdata,
    output rempty,
    output ralmostempty
);

    // Internal signals
    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0] wptr, rptr;
    wire [ASIZE:0] wq2_rptr, rq2_wptr;
    
    // Instantiate write pointer and full generation logic
    wptr_full #(
        .ASIZE(ASIZE),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)
    ) wptr_full_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wq2_rptr(wq2_rptr),
        .waddr(waddr),
        .wptr(wptr),
        .wfull(wfull),
        .walmostfull(walmostfull)
    );
    
    // Instantiate read pointer and empty generation logic
    rptr_empty #(
        .ASIZE(ASIZE),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) rptr_empty_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rq2_wptr(rq2_wptr),
        .raddr(raddr),
        .rptr(rptr),
        .rempty(rempty),
        .ralmostempty(ralmostempty)
    );
    
    // Instantiate FIFO memory
    fifomem #(
        .ASIZE(ASIZE),
        .DSIZE(DSIZE)
    ) fifomem_inst (
        .wclk(wclk),
        .wclken(winc & !wfull),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .rdata(rdata)
    );
    
    // Synchronize read pointer to write clock domain
    sync_r2w #(
        .ASIZE(ASIZE)
    ) sync_r2w_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rptr(rptr),
        .wq2_rptr(wq2_rptr)
    );
    
    // Synchronize write pointer to read clock domain
    sync_w2r #(
        .ASIZE(ASIZE)
    ) sync_w2r_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .wptr(wptr),
        .rq2_wptr(rq2_wptr)
    );

endmodule
