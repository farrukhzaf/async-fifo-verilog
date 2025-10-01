`timescale 1ns / 1ps

module tb_async_fifo;

    // Parameters
    parameter DSIZE = 8;
    parameter ASIZE = 5;
    parameter ALMOST_FULL_THRESHOLD = 4;
    parameter ALMOST_EMPTY_THRESHOLD = 2;
    parameter WCLK_PERIOD = 10;  // 100 MHz
    parameter RCLK_PERIOD = 12.5; // 80 MHz
    
    // Write clock domain signals
    reg wclk;
    reg wrst_n;
    reg winc;
    reg [DSIZE-1:0] wdata;
    wire wfull;
    wire walmostfull;
    
    // Read clock domain signals
    reg rclk;
    reg rrst_n;
    reg rinc;
    wire [DSIZE-1:0] rdata;
    wire rempty;
    wire ralmostempty;
    
    // Test variables
    integer i;
    
    // Instantiate the FIFO
    async_fifo #(
        .DSIZE(DSIZE),
        .ASIZE(ASIZE),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) dut (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wdata(wdata),
        .wfull(wfull),
        .walmostfull(walmostfull),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rdata(rdata),
        .rempty(rempty),
        .ralmostempty(ralmostempty)
    );
    
    // Write clock generation (100 MHz)
    initial begin
        wclk = 0;
        forever #(WCLK_PERIOD/2) wclk = ~wclk;
    end
    
    // Read clock generation (80 MHz)
    initial begin
        rclk = 0;
        forever #(RCLK_PERIOD/2) rclk = ~rclk;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        wrst_n = 0;
        rrst_n = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;
        
        $display("\n=== Starting FIFO Test ===");
        
        // Apply reset
        #50;
        wrst_n = 1;
        rrst_n = 1;
        $display("Time=%0t: Reset released", $time);
        
        #100;
        
        // Test 1: Write 10 words to empty FIFO
        $display("\n=== Test 1: Write to Empty FIFO ===");
        for (i = 0; i < 10; i = i + 1) begin
            #WCLK_PERIOD;
            if (!wfull) begin
                winc = 1;
                wdata = i;
                $display("Time=%0t: Writing data=%0d", $time, wdata);
                #WCLK_PERIOD;
                winc = 0;
            end
        end
        
        #200;
        
        // Test 2: Read 10 words from FIFO
        $display("\n=== Test 2: Read from FIFO ===");
        for (i = 0; i < 10; i = i + 1) begin
            #RCLK_PERIOD;
            if (!rempty) begin
                rinc = 1;
                #RCLK_PERIOD;
                $display("Time=%0t: Read data=%0d", $time, rdata);
                rinc = 0;
            end
        end
        
        #200;
        
        // Test 3: Fill FIFO completely
        $display("\n=== Test 3: Fill FIFO Completely ===");
        i = 0;
        while (i < 40 && !wfull) begin
            #WCLK_PERIOD;
            winc = 1;
            wdata = 8'hA0 + i;
            $display("Time=%0t: Writing data=%h, Full=%0b, AlmostFull=%0b", 
                     $time, wdata, wfull, walmostfull);
            #WCLK_PERIOD;
            winc = 0;
            i = i + 1;
        end
        if (wfull) begin
            $display("Time=%0t: FIFO Full after %0d writes", $time, i);
        end
        
        #200;
        
        // Test 4: Read until empty
        $display("\n=== Test 4: Read Until Empty ===");
        i = 0;
        while (i < 40 && !rempty) begin
            #RCLK_PERIOD;
            rinc = 1;
            #RCLK_PERIOD;
            $display("Time=%0t: Read data=%h, Empty=%0b, AlmostEmpty=%0b", 
                     $time, rdata, rempty, ralmostempty);
            rinc = 0;
            i = i + 1;
        end
        if (rempty) begin
            $display("Time=%0t: FIFO Empty after %0d reads", $time, i);
        end
        
        #200;
        
        // Test 5: Simultaneous read and write
        $display("\n=== Test 5: Simultaneous Read and Write ===");
        fork
            // Writer
            begin
                for (i = 0; i < 20; i = i + 1) begin
                    #WCLK_PERIOD;
                    if (!wfull) begin
                        winc = 1;
                        wdata = 8'hC0 + i;
                        $display("Time=%0t: Writing data=%h", $time, wdata);
                        #WCLK_PERIOD;
                        winc = 0;
                    end
                end
            end
            
            // Reader
            begin
                #100;
                for (i = 0; i < 20; i = i + 1) begin
                    #RCLK_PERIOD;
                    if (!rempty) begin
                        rinc = 1;
                        #RCLK_PERIOD;
                        $display("Time=%0t: Read data=%h", $time, rdata);
                        rinc = 0;
                    end
                end
            end
        join
        
        #500;
        
        // Test 6: Burst write and read
        $display("\n=== Test 6: Burst Write and Read ===");
        
        // Burst write
        for (i = 0; i < 15; i = i + 1) begin
            #WCLK_PERIOD;
            winc = 1;
            wdata = 8'hD0 + i;
            $display("Time=%0t: Burst writing data=%h", $time, wdata);
        end
        #WCLK_PERIOD;
        winc = 0;
        
        #100;
        
        // Burst read
        for (i = 0; i < 15; i = i + 1) begin
            #RCLK_PERIOD;
            rinc = 1;
            #RCLK_PERIOD;
            $display("Time=%0t: Burst reading data=%h", $time, rdata);
        end
        rinc = 0;
        
        #500;
        
        $display("\n=== Simulation Complete ===");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);
    end

endmodule
