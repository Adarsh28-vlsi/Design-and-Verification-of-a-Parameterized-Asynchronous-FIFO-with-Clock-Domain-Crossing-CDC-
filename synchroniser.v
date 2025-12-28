module synchronizer #(
parameter WIDTH = 8,
parameter STAGES = 2
)(
input  wire             clk,
input  wire             rst_n,
input  wire [WIDTH-1:0] async_in,
output wire [WIDTH-1:0] sync_out
);
  reg [WIDTH-1:0] sync_regs [0:STAGES-1];

integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < STAGES; i = i + 1) begin
            sync_regs[i] <= {WIDTH{1'b0}};
        end
    end else begin
        sync_regs[0] <= async_in;
        for (i = 1; i < STAGES; i = i + 1) begin
            sync_regs[i] <= sync_regs[i-1];
        end
    end
end

assign sync_out = sync_regs[STAGES-1];
endmodule
