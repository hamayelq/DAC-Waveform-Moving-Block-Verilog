`timescale 1ns / 1ps

module debouncer(
    input clk,  //25MHz clock?
    input reset,
    input clk_en,
    input in,

    output reg out
    );

    parameter [1:0] s0 = 0,
                    s1 = 1,
                    s2 = 2,
                    s3 = 3;

    reg [1:0] currState,
              nextState;

    reg [4:0] count;
    wire clk30ms;

    //30 ms count divider
    always @(posedge clk, posedge reset)
        if(reset || clk_en == 0)
            count <= 0;
        else
            if(count == 30 - 1)
                count <= 0;
            else
                count <= count + 1'b1;
        
    assign clk30ms = count == 0;

    always @(posedge clk, posedge reset)
        if(reset)
            currState <= s0;
        else
            if(clk30ms)
                currState <= nextState;
            else
                currState <= currState;

    //state machine logic
    always @(currState, in)
        case(currState)
            s0: begin
                    if(in)
                        nextState = s1;
                    else
                        nextState = s0;
                end

            s1: begin
                    if(in)
                        nextState = s2;
                    else
                        nextState = s0;
                end

            s2: begin
                    if(in)
                        nextState = s3;
                    else
                        nextState = s1;
                end

            s3: begin
                    if(in)
                        nextState = s3;
                    else
                        nextState = s2;
                end
        endcase

    //output here
    always @(posedge clk)
        if(currState == s3)
            out <= 1'b1;
        else if(currState == s0)
            out <= 1'b0;
        else
            out <= out;

endmodule