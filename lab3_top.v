`timescale 1ns / 1ps

module lab3_top(
    input clk,
    input reset,
    input uBtn,
    input dBtn,
    input lBtn,
    input rBtn,

    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output [6:0] SEG,
    output [3:0] ANODE,
    output hSync,
    output vSync,
    output CS,
    output SCLK
    );

    wire clk_10M;
    wire clk_25M;

    //10KHz clk_en, refer to lab assignment
    wire clk_en;
    reg [14:0] counter25k;

    always @(posedge clk, posedge reset)
        if(reset)
            counter25k <= 0;
        else if(counter25k <= 25000 - 1)
            counter25k <= 0;
        else
            counter25k <= counter25k + 1;

    assign clk_en = counter25k = 25000 - 1;

    wire locked; //locked signal
    //instantiate MMCM clock here
    
    wire [10:0] hCount;
    wire [10:0] vCount;
    wire u, d, l, r; //debounced
    wire [4:0] hPos;
    wire [3:0] vPos;
    wire [3:0] A, B, C, D;

    //7 seg display logic
    assign B = vPos >= 10 ? 4'b0001 : 4'b0000; //if above 10, first dig 1
    assign A = vPos >= 10 ? vPos - 10 : vPos; //display digit between 0 - 9
    assign D = hPos >= 10 ? 4'b0001 : 4'b0000; //same logic B
    assign C = hPos >= 10 ? hPos - 10 : hPos[3:0]; //same logic A

    //debounce signals wtf do I do here???

    //instantiate vga_blocks
    vga_blocks u1(
        .clk(whatdoiputhere),
        .rBtn(r),
        .lBtn(l),
        .uBtn(u),
        .dBtn(d),
        .blank(blank),
        .reset(reset),
        .vcount(vCount),
        .hcount(hCount),
        .hPos(hPos),
        .vPos(vPos),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue)
    );

    //instantiate vga display
    vga_controller_640_60 u2(
        .rst(reset), 
        .pixel_clk(clk_25M), 
        .HS(hSync), 
        .VS(vSync), 
        .hcount(hCount), 
        .vcount(vCount), 
        .blank(blank)
    );

    seven_seg u3(
        .clk(clk_25M),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .ANODE(ANODE),
        .SEG_TOP(SEG)
    );

    assign SCLK = clk_10M;
    assign CS = whatsignal;

endmodule