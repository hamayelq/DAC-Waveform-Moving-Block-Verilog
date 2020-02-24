`timescale 1ns / 1ps

module lab3_tb;

// Inputs
reg clk;
reg reset;
reg [8:0] sel;

// Outputs
wire sync;
wire dout;

// Instantiate UUT
dac utt (
    .clk(clk),
    .reset(reset),
    .sel(sel),
    .sync(sync),
    .dout(dout)
);

// Emulate clock
always begin
    clk = 1'b0;
    #1;
    clk = 1'b1;
    #1;
end

initial begin
    sel = 9'b0;
    reset = 0;
    #10;
    reset = 1;
    #100;
    reset = 0;
end

endmodule
