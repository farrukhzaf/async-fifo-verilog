# Asynchronous FIFO

A parameterized asynchronous FIFO (First-In-First-Out) implementation in Verilog with Gray code pointer synchronization and programmable almost-full/empty threshold flags.

## Features

- **Dual Clock Domain Support**: Independent read and write clock domains
- **Gray Code Synchronization**: Safe clock domain crossing using Gray code pointers
- **Parameterizable Design**: Configurable data width, FIFO depth, and threshold values
- **Status Flags**: 
  - Full/Empty flags
  - Almost-full/Almost-empty programmable thresholds
- **Robust Synchronization**: Two-stage synchronizers for metastability prevention
- **Modular Architecture**: Clean separation of concerns with dedicated modules

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DSIZE` | 8 | Data width in bits |
| `ASIZE` | 5 | Address width (FIFO depth = 2^ASIZE) |
| `ALMOST_FULL_THRESHOLD` | 4 | Threshold for almost-full flag |
| `ALMOST_EMPTY_THRESHOLD` | 2 | Threshold for almost-empty flag |

## Module Hierarchy

```
async_fifo (Top Module)
├── wptr_full (Write pointer and full flag generation)
├── rptr_empty (Read pointer and empty flag generation)
├── fifomem (Dual-port RAM)
├── sync_r2w (Read-to-write clock domain synchronizer)
└── sync_w2r (Write-to-read clock domain synchronizer)
```

## Port Description

### Write Clock Domain
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `wclk` | Input | 1 | Write clock |
| `wrst_n` | Input | 1 | Write reset (active low) |
| `winc` | Input | 1 | Write increment/enable |
| `wdata` | Input | DSIZE | Write data |
| `wfull` | Output | 1 | FIFO full flag |
| `walmostfull` | Output | 1 | FIFO almost full flag |

### Read Clock Domain
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `rclk` | Input | 1 | Read clock |
| `rrst_n` | Input | 1 | Read reset (active low) |
| `rinc` | Input | 1 | Read increment/enable |
| `rdata` | Output | DSIZE | Read data |
| `rempty` | Output | 1 | FIFO empty flag |
| `ralmostempty` | Output | 1 | FIFO almost empty flag |

## Usage Example

```verilog
async_fifo #(
    .DSIZE(16),                    // 16-bit data width
    .ASIZE(4),                     // 16-entry FIFO (2^4)
    .ALMOST_FULL_THRESHOLD(3),     // Almost full when 3 or fewer slots available
    .ALMOST_EMPTY_THRESHOLD(2)     // Almost empty when 2 or fewer entries present
) fifo_inst (
    // Write interface
    .wclk(wr_clk),
    .wrst_n(wr_rst_n),
    .winc(wr_en),
    .wdata(wr_data),
    .wfull(full),
    .walmostfull(almost_full),
    
    // Read interface
    .rclk(rd_clk),
    .rrst_n(rd_rst_n),
    .rinc(rd_en),
    .rdata(rd_data),
    .rempty(empty),
    .ralmostempty(almost_empty)
);
```

## Design Details

### Clock Domain Crossing
The design uses Gray code encoding for pointers when crossing clock domains. Gray code ensures that only one bit changes at a time, minimizing the risk of metastability during synchronization.

### Full and Empty Detection
- **Full condition**: Detected when write pointer catches up to read pointer (with MSB bits inverted)
- **Empty condition**: Detected when read pointer equals write pointer

### Almost Full/Empty Logic
The almost-full and almost-empty flags use Gray-to-binary conversion to calculate the current occupancy and compare against programmable thresholds.

## File Structure

```
rtl/
├── async_fifo.v      - Top-level module
├── fifomem.v         - Dual-port memory
├── wptr_full.v       - Write pointer and full flag logic
├── rptr_empty.v      - Read pointer and empty flag logic
├── sync_r2w.v        - Read-to-write synchronizer
└── sync_w2r.v        - Write-to-read synchronizer
```

## Simulation

(Add your testbench information here)

```bash
# Example simulation commands
iverilog -o fifo_sim rtl/*.v tb/async_fifo_tb.v
vvp fifo_sim
gtkwave dump.vcd
```

## Timing Considerations

- Ensure proper timing constraints for clock domain crossing paths
- Two-stage synchronizers add 2 clock cycle latency
- Almost-full/empty flags may have additional combinational delay due to Gray-to-binary conversion

## Known Limitations

- Memory has asynchronous read (combinational output)
- Almost-full/empty calculations add combinational depth
- No built-in overflow/underflow error flags

## Future Enhancements

- [ ] Add data counter for occupancy monitoring
- [ ] Implement overflow/underflow error detection
- [ ] Add optional registered memory output
- [ ] Parameterizable synchronizer stages
- [ ] Formal verification properties

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Mohammad Farukh Zafar

## References

- Clifford E. Cummings, "Simulation and Synthesis Techniques for Asynchronous FIFO Design"
- Gray code clock domain crossing techniques

---

**Note**: This FIFO has been tested and verified. See the testbench in `tb/` directory for usage examples.
