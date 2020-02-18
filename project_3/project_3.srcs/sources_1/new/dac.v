`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2020 03:19:31 PM
// Design Name: 
// Module Name: dac
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module dac(
    input [7:0] data,
    input [7:0] mode,
    input sck,
    input rst,
    output reg dout,
    output reg sync
);


//100KHz clk
wire clk_100KHz;
reg [6:0] counter100k;

always @(posedge sck, posedge reset)    //keeping CS and SCLK synced, not from FPGA clock
    if(reset)
        counter100k <= 0;
    else if(counter100k == 100-1)
        counter100k <= 0;
    else
        counter100k <= counter100k + 1'b1;

assign clk_100KHz = counter100k > 16; //down for 16 SCLK cycles


reg [2:0] state;
parameter reset = 0, idle = 1, load = 2;

always @ (state) 
    case (state)
        reset:
            begin
                dout <= 1'b0;
                sync <= 1'b1;
            end
        idle: 
            begin
            end
        load:
            begin
            end
    endcase

always @ (posedge sck)
    if(rst)
        state = reset;
    else 
        case (state)
        reset:
            begin
            end
        idle:
            begin
            end
        load:
            begin
            end
        endcase

endmodule
