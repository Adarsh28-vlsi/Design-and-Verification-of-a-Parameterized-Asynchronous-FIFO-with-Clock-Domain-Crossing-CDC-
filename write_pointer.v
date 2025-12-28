module write_pointer #(
parameter ADDR_WIDTH = 4
)(
input  wire                     wr_clk,
input  wire                     wr_rst_n,
input  wire                     wr_en,
input  wire                     full,
input  wire [ADDR_WIDTH:0]      rd_ptr_gray_sync,
output reg  [ADDR_WIDTH:0]      wr_ptr_gray,
output wire [ADDR_WIDTH-1:0]    wr_addr,
output reg                      full_flag,
output reg                      almost_full_flag
);
reg [ADDR_WIDTH:0] wr_ptr_bin;
wire [ADDR_WIDTH:0] wr_ptr_bin_next;
wire [ADDR_WIDTH:0] wr_ptr_gray_next;
wire [ADDR_WIDTH:0] rd_ptr_bin_sync;

// Binary pointer increment
assign wr_ptr_bin_next = wr_ptr_bin + ((wr_en && !full) ? 1'b1 : 1'b0);

// Binary to Gray conversion
assign wr_ptr_gray_next = wr_ptr_bin_next ^ (wr_ptr_bin_next >> 1);

// Write address (lower bits of binary pointer)
assign wr_addr = wr_ptr_bin[ADDR_WIDTH-1:0];

// Binary pointer register
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr_bin <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        wr_ptr_bin <= wr_ptr_bin_next;
    end
end

// Gray pointer register
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr_gray <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        wr_ptr_gray <= wr_ptr_gray_next;
    end
end

// Gray to binary conversion for synchronized read pointer
gray_to_binary #(
    .WIDTH(ADDR_WIDTH+1)
) u_g2b (
    .gray_in(rd_ptr_gray_sync),
    .bin_out(rd_ptr_bin_sync)
);

// Full flag generation
// Full when write pointer + 1 equals read pointer
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        full_flag <= 1'b0;
    end else begin
        full_flag <= (wr_ptr_bin_next == {~rd_ptr_bin_sync[ADDR_WIDTH:ADDR_WIDTH-1], 
                                          rd_ptr_bin_sync[ADDR_WIDTH-2:0]});
    end
end

// Almost full flag (one location away from full)
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        almost_full_flag <= 1'b0;
    end else begin
        almost_full_flag <= ((wr_ptr_bin_next + 1'b1) == 
                             {~rd_ptr_bin_sync[ADDR_WIDTH:ADDR_WIDTH-1], 
                              rd_ptr_bin_sync[ADDR_WIDTH-2:0]});
    end
end
