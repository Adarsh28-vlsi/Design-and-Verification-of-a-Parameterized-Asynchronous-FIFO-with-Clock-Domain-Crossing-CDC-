// Read clock domain
module topmodule ( 
input  wire                     rd_clk,
input  wire                     rd_rst_n,
input  wire                     rd_en,
output wire [DATA_WIDTH-1:0]    rd_data,
output wire                     empty,
output wire                     almost_empty 
);
// Internal signals
wire [ADDR_WIDTH:0] wr_ptr_gray;
wire [ADDR_WIDTH:0] rd_ptr_gray;
wire [ADDR_WIDTH:0] wr_ptr_gray_sync;
wire [ADDR_WIDTH:0] rd_ptr_gray_sync;
wire [ADDR_WIDTH-1:0] wr_addr;
wire [ADDR_WIDTH-1:0] rd_addr;

// Write pointer and Gray code generation
write_pointer #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_write_pointer (
    .wr_clk(wr_clk),
    .wr_rst_n(wr_rst_n),
    .wr_en(wr_en),
    .full(full),
    .rd_ptr_gray_sync(rd_ptr_gray_sync),
    .wr_ptr_gray(wr_ptr_gray),
    .wr_addr(wr_addr),
    .full_flag(full),
    .almost_full_flag(almost_full)
);

// Read pointer and Gray code generation
read_pointer #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_read_pointer (
    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),
    .empty(empty),
    .wr_ptr_gray_sync(wr_ptr_gray_sync),
    .rd_ptr_gray(rd_ptr_gray),
    .rd_addr(rd_addr),
    .empty_flag(empty),
    .almost_empty_flag(almost_empty)
);

// Synchronizer: Write pointer to read clock domain
synchronizer #(
    .WIDTH(ADDR_WIDTH+1)
) u_sync_wr2rd (
    .clk(rd_clk),
    .rst_n(rd_rst_n),
    .async_in(wr_ptr_gray),
    .sync_out(wr_ptr_gray_sync)
);

// Synchronizer: Read pointer to write clock domain
synchronizer #(
    .WIDTH(ADDR_WIDTH+1)
) u_sync_rd2wr (
    .clk(wr_clk),
    .rst_n(wr_rst_n),
    .async_in(rd_ptr_gray),
    .sync_out(rd_ptr_gray_sync)
);

// Dual-port memory
fifo_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_fifo_memory (
    .wr_clk(wr_clk),
    .wr_en(wr_en && !full),
    .wr_addr(wr_addr),
    .wr_data(wr_data),
    .rd_clk(rd_clk),
    .rd_addr(rd_addr),
    .rd_data(rd_data)
);
