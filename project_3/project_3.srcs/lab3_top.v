`timescale 1ns / 1ps

module lab3_top(
    input clk_fpga,
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
    output sclk
);

    //10KHz clk_en, refer to lab assignment
    // Fix this - 100kHz, also move to dac.v
    wire clk_en;
    reg [14:0] counter25k;

    always @(posedge clk_fpga, posedge reset)
        if(reset)
            counter25k <= 0;
        else if(counter25k <= 25000 - 1)
            counter25k <= 0;
        else
            counter25k <= counter25k + 1;

    assign clk_en = (counter25k == 25000 - 1) ? 1'b1 : 1'b0;

    wire locked; //locked signal
    
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
    
    // SPI
    assign SCLK = clk_10M;
//    assign CS = whatsignal;



    //debounce signals wtf do I do here???

    //instantiate vga_blocks
    vga_blocks u1(
        .clk(clk_25M),
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

//instantiate MMCM clock here
  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_25M),     // output clk_out1
    .clk_out2(clk_10M),     // output clk_out2
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_fpga));      // input clk_in1
    
    
endmodule