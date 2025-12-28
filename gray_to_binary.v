module gray_to_binary #(
parameter WIDTH = 5
)(
input  wire [WIDTH-1:0] gray_in,
output reg  [WIDTH-1:0] bin_out
);
  integer i;
always @(*) begin
    bin_out[WIDTH-1] = gray_in[WIDTH-1];
    for (i = WIDTH-2; i >= 0; i = i - 1) begin
        bin_out[i] = bin_out[i+1] ^ gray_in[i];
    end
end
endmodule
