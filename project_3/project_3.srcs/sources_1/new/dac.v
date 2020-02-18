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
//module dac(
//    input [7:0] data,
//    input [7:0] mode,
//    input sck,
//    input rst,
//    output reg dout,
//    output reg sync
//);


////100KHz clk
//wire clk_100KHz;
//reg [6:0] counter100k;

//always @(posedge sck, posedge rst)    //keeping CS and SCLK synced, not from FPGA clock
//    if(rst)
//        counter100k <= 0;
//    else if(counter100k == 100-1)
//        counter100k <= 0;
//    else
//        counter100k <= counter100k + 1'b1;

//assign clk_100KHz = counter100k > 16; //down for 16 SCLK cycles


//reg [2:0] state;
//parameter reset = 0, idle = 1, load = 2;

//always @ (state) 
//    case (state)
//        reset:
//            begin
//                dout <= 1'b0;
//                sync <= 1'b1;
//            end
//        idle: 
//            begin
//            end
//        load:
//            begin
//            end
//    endcase

//always @ (posedge sck)
//    if(rst)
//        state = reset;
//    else 
//        case (state)
//        reset:
//            begin
//            end
//        idle:
//            begin
//            end
//        load:
//            begin
//            end
//        endcase

//endmodule

////use this one instead?

//`timescale 1ns / 1ps

module dac(
    input clk,                  // 10MHz MMCM Clock
    input reset,                // Reset pin
    input sel,            // 0 for DC constant, 1 for sawtooth
    output reg sync,
    output reg dout
    );

    reg [4:0] sawVal;

    //100KHz 
    reg [7:0] count;
    always @(posedge clk)
        if(count == 100 - 1)
            count <= 0;
        else
            count <= count + 1'b1;
    
    wire clk_en = count == 0;

    //shift reg
    reg [15:0] shiftReg;
    reg [4:0]  shiftState;
    
    // Control register
    parameter [7:0] ctl = 8'b0001_0010; // DAC A active, B power down, update DAC A from input register 

    always @(posedge clk, posedge reset)
        if(reset) begin
            sync <= 1;
            sawVal <= 0;
            shiftReg <= 0;
            shiftState <= 0;
        end

        else begin
            if(clk_en) begin
                //25 vals per cycle yaheard
                if(sawVal == 24)
                    sawVal <= 0;
                else
                    sawVal <= sawVal + 1'b1;
                
                if(sel == 1'b1)
                    shiftReg <= {ctl, 3'b0, sawVal};
                else 
                    shiftReg <= {ctl, 8'hff}; //constant 3.3V
                
                shiftState <= 1;
                sync <= 0;

            end

        if(shiftState <= 5'd16)
            sync <= 1;

        if(!sync) begin
            dout = shiftReg[15];
            shiftReg = {shiftReg[14:0], 1'b0};
            shiftState = shiftState + 1'b1;
        end
    end

endmodule
