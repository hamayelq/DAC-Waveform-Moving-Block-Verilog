`timescale 1ns / 1ps

module lab3_top(
    input clk_fpga,
    input reset,
    input uBtn,
    input dBtn,
    input lBtn,
    input rBtn,
    input sel,

    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output [6:0] seg,
    output [3:0] an,
    output hSync,
    output vSync,
    
    output sync,
    output sdata,
    output sck
    );

    wire clk_10M;
    wire clk_25M;

    //1KHz clk_en, refer to lab assignment
    wire clk_en;
    reg [14:0] counter25k;

    always @(posedge clk_25M, posedge reset)
        if(reset)
            counter25k <= 0;
        else if(counter25k <= 25000 - 1)
            counter25k <= 0;
        else
            counter25k <= counter25k + 1;

    assign clk_en = counter25k == 25000 - 1; //1KHz

    wire locked; //locked signal
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
    assign sck = clk_10M;

    //instantiate MMCM clock here
    clk_wiz_0 mmcm_inst(
        // Clock out ports
        .clk_out1(clk_25M),     // output clk_25M
        .clk_out2(clk_10M),     // output clk_10M
         // Status and control signals
        .reset(reset), // input reset
        .locked(locked),       // output locked
        // Clock in ports
        .clk_in1(clk_fpga)
    );      // input clk_in1
    
    //debounce signals wtf do I do here???
    debouncer b1(
        .clk(clk_25M),
        .reset(reset),
        .clk_en(clk_en),
        .in(uBtn),
        .out(u)
    );

    debouncer b2(
        .clk(clk_25M),
        .reset(reset),
        .clk_en(clk_en),
        .in(dBtn),
        .out(d)
    );

    debouncer b3(
        .clk(clk_25M),
        .reset(reset),
        .clk_en(clk_en),
        .in(rBtn),
        .out(r)
    );

    debouncer b4(
        .clk(clk_25M),
        .reset(reset),
        .clk_en(clk_en),
        .in(lBtn),
        .out(l)
    );

    //instantiate vga_blocks
    vga_blocks u1(
        .clk(clk_25M),
        .rBtn(r),
        .lBtn(l),
        .uBtn(u),
        .dBtn(d),
        .reset(reset),
        .hPos(hPos),
        .vPos(vPos),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hSync(hSync),
        .vSync(vSync)
    );

    seven_seg u3(
        .clk(clk_25M),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .ANODE(an),
        .SEG_TOP(seg)
    );
    
    dac d1(
        .clk(clk_10M),
        .reset(reset),
        .sel(sel),
        .sync(sync),
        .dout(sdata)
    );

endmodule