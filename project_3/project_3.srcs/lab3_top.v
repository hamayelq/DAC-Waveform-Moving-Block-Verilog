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
    output vSync
//    output CS,
//    output SCLK
    );

    wire clk_10M;
    wire clk_25M;

    //100KHz clk
    wire clk_100KHz;
    reg [6:0] counter100k;

    always @(posedge clk_10M, posedge reset)    //keeping CS and SCLK synced, not from FPGA clock
        if(reset)
            counter100k <= 0;
        else if(counter100k == 100-1)
            counter100k <= 0;
        else
            counter100k <= counter100k + 1'b1;
    
    assign clk_100KHz = counter100k > 16; //down for 16 SCLK cycles

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

    //33Hz clock, or 30ish ms for debouncer and vga movement logic i think
    wire clk30ms;
    reg [4:0] count;

    always @(posedge clk_25M, posedge reset)
        if(reset || clk_en == 0)
            count <= 0;
        else
            if(count == 30 - 1)
                count <= 0;
            else
                count <= count + 1'b1;
        
    assign clk30ms = count == 0;
    
   
    wire locked; //locked signal
    wire blank;
    wire [10:0] hCount;
    wire [10:0] vCount;
    wire u, d, l, r; //debounced
    wire [4:0] hPos;
    wire [3:0] vPos;
    wire [3:0] A, B, C, D;

    //instantiate MMCM clock here
    clk_wiz_0 mmcm_inst(
        // Clock out ports
        .clk_25M(clk_25M),     // output clk_25M
        .clk_10M(clk_10M),     // output clk_10M
         // Status and control signals
        .reset(reset), // input reset
        .locked(locked),       // output locked
        // Clock in ports
        .clk_in1(clk)
    );      // input clk_in1
    

    //7 seg display logic
    assign B = vPos >= 10 ? 4'b0001 : 4'b0000; //if above 10, first dig 1
    assign A = vPos >= 10 ? vPos - 10 : vPos; //display digit between 0 - 9
    assign D = hPos >= 10 ? 4'b0001 : 4'b0000; //same logic B
    assign C = hPos >= 10 ? hPos - 10 : hPos[3:0]; //same logic A

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
        .clk(clk30ms),
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

    // assign SCLK = clk_10M;
    // assign CS = clk_100KHz;

endmodule
