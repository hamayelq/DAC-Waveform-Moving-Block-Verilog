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
    input sclk,
    input rst,
    output reg dout,
    output reg sync
);

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

always @ (posedge sclk)
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
