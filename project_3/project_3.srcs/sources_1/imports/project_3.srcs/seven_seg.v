`timescale 1ns / 1ps

module seven_seg (
    input clk,
    //setting up inputs as described in lab description
    input [3:0] A,
    input [3:0] B,
    input [3:0] C,
    input [3:0] D,
    
    //setting up outputs
    output reg [3:0] ANODE,
    output reg [6:0] SEG_TOP   //seven segment display
    );

    reg clk_en; //pulse
    reg [15:0] counter; //2^15 = 32768 > 31250
    
    reg [1:0] SEL = 2'b00;  //current anode
    reg [3:0] switchChoice; //what values to decode
    
    
    always @(posedge clk)
        begin
            if(counter == 31250 - 1)
                begin
                    counter <= 0;
                    clk_en <= 1;
                end
            else
                begin
                    counter <= counter + 1'b1;
                    clk_en <= 0;
                end
         end
         
    always @(posedge clk)
        if(clk_en) SEL <= SEL + 1'b1; //incerement SEL when clock edge hits
        
    always @(posedge clk_en)
        begin
        if(clk_en)
            begin
                case(SEL)
                    0: switchChoice = A;
                    1: switchChoice = B;
                    2: switchChoice = C;
                    3: switchChoice = D;
                endcase
                
                case(SEL)
                    0: ANODE = 4'b1110;
                    1: ANODE = 4'b1101;
                    2: ANODE = 4'b1011;
                    3: ANODE = 4'b0111;
                endcase
             end
       end
       
    parameter display0 = 7'b0000001;
    parameter display1 = 7'b1001111;
    parameter display2 = 7'b0010010;
    parameter display3 = 7'b0000110;
    parameter display4 = 7'b1001100;
    parameter display5 = 7'b0100100;
    parameter display6 = 7'b0100000;
    parameter display7 = 7'b0001111;
    parameter display8 = 7'b0000000;
    parameter display9 = 7'b0000100;
    parameter displayA = 7'b0001000;
    parameter displayB = 7'b1100000;
    parameter displayC = 7'b0110001;
    parameter displayD = 7'b1000010;
    parameter displayE = 7'b0110000;
    parameter displayF = 7'b0111000;
    
    always @(switchChoice)
        begin
            case(switchChoice)
                4'b0000: SEG_TOP = display0;
                4'b0001: SEG_TOP = display1;
                4'b0010: SEG_TOP = display2;
                4'b0011: SEG_TOP = display3;
                4'b0100: SEG_TOP = display4;
                4'b0101: SEG_TOP = display5;
                4'b0110: SEG_TOP = display6;
                4'b0111: SEG_TOP = display7;
                4'b1000: SEG_TOP = display8;
                4'b1001: SEG_TOP = display9;
                4'b1010: SEG_TOP = displayA;
                4'b1011: SEG_TOP = displayB;
                4'b1100: SEG_TOP = displayC;
                4'b1101: SEG_TOP = displayD;
                4'b1110: SEG_TOP = displayE;
                4'b1111: SEG_TOP = displayF;
            endcase
        end
             
endmodule