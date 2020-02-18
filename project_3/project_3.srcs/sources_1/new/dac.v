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

//use this one instead?

`timescale 1ns / 1ps

module DAC(
    input SCLK,
    input CS,
    input reset,
    output reg OUT

    );

    reg [15:0] data;

    parameter [3:0] s0 = 0,
                    s1 = 1,
                    s2 = 2,
                    s3 = 3,
                    s4 = 4,
                    s5 = 5,
                    s6 = 6,
                    s7 = 7,
                    s8 = 8,
                    s9 = 9;

    reg [4:0] currState;
    reg [4:0] nextState;

    reg shiftState; //binary shift yes or no

    always @(posedge SCLK, posedge reset)
        if(reset) begin
            data <= 16b'0;
            currState <= s0;
            nextState <= s0;
            shiftState <= 1'b0;
            OUT <= 1'b0;
        end

        else if(CS == 0) begin
            shiftState <= 1'b0;
            OUT <= data[15];
            data <= {data[14:0], 1'b0}
        end

        else if (CS == 1) begin
            currState <= nextState;
            if(!shiftState)
                case(currState)
                    s0: begin
                        data <= {8'b0, 8'b0};
                        nextState <= s1;
                        shiftState <= 1'b1;
                        end
                    s1: begin
                        data <= {8'b0, 8'b00011000};
                        nextState <= s2;
                        shiftState <= 1'b1;
                        end
                    s2: begin
                        data <= {8'b0, 8'b00110010};
                        nextState <= s3;
                        shiftState <= 1'b1;
                
                        
                        //noclue if this works man
`timescale 1ns / 1ps

module DAC(
    input clk,
    input reset,
    input selDC,
    input selSaw,

    output SCLK,
    output reg SYNC,
    );

    assign SCLK = clk;

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

    always @(negedge clk, posedge reset)
        if(reset) begin
            SYNC <= 1;
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
                
                if(selSaw)
                    shiftReg <= {8'b0, sawVal, 3'b0};
                else if (selDC)
                    shiftReg <= {8'b0, 8'hff}; //constant 3.3V
                else
                    shiftReg <= {8'b0, 8'b0};
                
                shiftState <= 1;
                SYNC <= 0;

            end

        if(shiftState <= 5'd16)
            SYNC <= 1;

        if(!SYNC) begin
            shiftReg <= {shiftReg[14:0], shiftReg[15]};
            shiftState <= shiftState + 1'b1;
        end
    end

endmodule
