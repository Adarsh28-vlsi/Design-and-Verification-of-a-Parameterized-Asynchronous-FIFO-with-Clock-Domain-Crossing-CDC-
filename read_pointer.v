module read_pointer #(
parameter ADDR_WIDTH = 4
)(
input  wire                     rd_clk,
input  wire                     rd_rst_n,
input  wire                     rd_en,
input  wire                     empty,
input  wire [ADDR_WIDTH:0]      wr_ptr_gray_sync,
output reg  [ADDR_WIDTH:0]      rd_ptr_gray,
output wire [ADDR_WIDTH-1:0]    rd_addr,
output reg                      empty_flag,
output reg                      almost_empty_flag
);
reg [ADDR_WIDTH:0] rd_ptr_bin;
wire [ADDR_WIDTH:0] rd_ptr_bin_next;
wire [ADDR_WIDTH:0] rd_ptr_gray_next;
wire [ADDR_WIDTH:0] wr_ptr_bin_sync;

// Binary pointer increment
assign rd_ptr_bin_next = rd_ptr_bin + ((rd_en && !empty) ? 1'b1 : 1'b0);

// Binary to Gray conversion
assign rd_ptr_gray_next = rd_ptr_bin_next ^ (rd_ptr_bin_next >> 1);

// Read address (lower bits of binary pointer)
assign rd_addr = rd_ptr_bin[ADDR_WIDTH-1:0];

// Binary pointer register
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr_bin <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        rd_ptr_bin <= rd_ptr_bin_next;
    end
end

// Gray pointer register
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr_gray <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        rd_ptr_gray <= rd_ptr_gray_next;
    end
end

// Gray to binary conversion for synchronized write pointer
gray_to_binary #(
    .WIDTH(ADDR_WIDTH+1)
) u_g2b (
    .gray_in(wr_ptr_gray_sync),
    .bin_out(wr_ptr_bin_sync)
);

// Empty flag generation
// Empty when read pointer equals write pointer
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        empty_flag <= 1'b1;
    end else begin
        empty_flag <= (rd_ptr_bin_next == wr_ptr_bin_sync);
    end
end

// Almost empty flag (one read away from empty)
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        almost_empty_flag <= 1'b1;
    end else begin
        almost_empty_flag <= ((rd_ptr_bin_next + 1'b1) == wr_ptr_bin_sync);
    end
end
