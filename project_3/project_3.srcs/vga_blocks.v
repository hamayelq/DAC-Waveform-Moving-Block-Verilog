`timescale 1ns / 1ps

module vga_blocks(
    input clk,
    input rBtn,
    input lBtn,
    input uBtn,
    input dBtn,
    input blank,
    input reset,
    input [10:0] vcount,
    input [10:0] hcount,
    output [4:0] hPos,
    output [3:0] vPos,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b
    );

    reg [4:0] horPos;
    reg [3:0] vertPos;
    reg pressed = 0; //to prevent button being held changing block position

    wire blockConstraint; //constraints within which block may be drawn on screen
                          //similar to blank, not quite
    parameter zeroes = 4'b0;
    parameter ones = 4'b0;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            horPos = 0;
            vertPos = 0;
            pressed = 0;
        end

        else if(uBtn && vertPos != 0 && !pressed) begin
            vertPos = vertPos - 1'b1;
            pressed = 1'b1;
        end

        else if(dBtn && vertPos != 14 && !moved) begin
            vertPos = vertPos + 1'b1;
            pressed = 1'b1;
        end

        else if(lBtn && horPos != 0 && !moved) begin
            horPos = horPos - 1'b1;
            pressed = 1'b1;
        end
        
        else if(rBtn && horPos != 19 && !moved) begin
            horPos = horPos + 1'b1;
            pressed = 1'b1;
        end

        else if(!rBtn && !lBtn && !uBtn && !dBtn) //open to input
            pressed = 1'b0;
        
        else begin  //preventing latches
            horPos = horPos;
            vertPos = vertPos;
            pressed = pressed;
        end
    end

    assign blockConstraint = (vcount >= 32 * verPos && vcount <= 32 * verPos + 32)
                                &&
                             (hcount >= 32 * horPos && hcount <= 32 * horPos + 32);

    assign hPos = horPos;
    assign vPos = vertPos;

    assign r = blank ? zeroes : blockConstraint ? ones : zeroes;
    assign g = blank ? zeroes : blockConstraint ? ones : zeroes;
    assign b = blank ? zeroes : blockConstraint ? ones : zeroes;

endmodule