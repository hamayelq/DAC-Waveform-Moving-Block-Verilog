`timescale 1ns / 1ps

//need to sample every 30ms so around 33Hz

module debouncer(
    input clk, //25MHz clock
    input reset,
    input clk_en, //1KHz clk_en, need to divide this to 33Hz roughly using counter, where do we use it?
    input in,

    output out //debounced button
    );

    reg currState;
    reg nxtState;

    always @(posedge clk, posedge reset)
        if(reset)
            currState <= 1'b0;
        else
            currState <= nxtState;
    
    always @(currState, in)
        case(currState)
            1'b0: if(in == 1)
                    nxtState = 1'b1;
                  else 
                    nxtState = 1'b0;
            1'b1: if(in == 0)
                    nxtState = 1'b0;
                  else
                    nxtState = 1'b1;
            default: nxtState = 1'b0;
        endcase

    assign out = currState == 1'b1;

endmodule

