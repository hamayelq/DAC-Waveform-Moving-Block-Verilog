`timescale 1ns / 1ps

module dac(
    input clk,                  // 10MHz MMCM Clock
    input reset,                // Reset pin
    input sel,            // 0 for DC constant, 1 for sawtooth
    output reg sync,
    output  dout
    );

    reg [4:0] sawVal;

    //100KHz 
    reg [7:0] count;
    always @(posedge clk)
        if(count == 100 - 1)
            count <= 0;
        else
            count <= count + 1'b1;
    
    wire clk_en = count > 16;
        
    //shift reg
    reg [15:0] shiftReg;
    reg [4:0]  shiftState;
    
    // Control register
    parameter [7:0] ctl = 8'b0000_0000; // DAC A active, B power down, update DAC A from input register 

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
                    shiftReg <= {ctl, sawVal, 3'b0};
                else if(sel == 1'b0)
                    shiftReg <= {ctl, 8'hff};
                else
                    shiftReg <= {ctl, 8'h00};
                    
                shiftState <= 1;
                sync <= 0;
            end

            if(shiftState <= 5'd16)
                sync <= 0;

            if(!sync) begin
            
                shiftReg = {shiftReg[14:0], shiftReg[0]};
                shiftState = shiftState + 1'b1;
            end
    end
    
    assign dout = shiftReg[15];

endmodule
