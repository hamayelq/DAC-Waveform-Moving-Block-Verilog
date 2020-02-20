`timescale 1ns / 1ps

module dac(
    input clk,                  // 10MHz MMCM Clock
    input reset,                // Reset pin
    input sel,            // 0 for DC constant, 1 for sawtooth
    output sync,
    output  dout
    );

    reg [7:0] sawVal = 8'h0f;
        
    // Value of control register
    parameter [7:0] ctl_reg = 8'b0000_0000; // DAC A active, B power down, update DAC A from input register 

    //100KHz clock enable signal (for data transfer)
    reg [7:0] count_100;
    always @(negedge clk)
        if(count_100 == 100 - 1)
            count_100 <= 0;
        else
            count_100 <= count_100 + 1'b1;
    
    wire clk_en = (count_100 == 0);
    
    // State machine logic
    parameter [2:0] rst    = 3'b000,
                    idle   = 3'b001, 
                    load   = 3'b010, 
                    shift  = 3'b011, 
                    unload = 3'b100;
                      
    reg [2:0] state, next_state;
    wire finish;
    reg [15:0] shift_reg;
    
    // Handle reset
    always @ (negedge clk, posedge reset)
        if(reset)
            state <= rst;
        else
            state <= next_state;
    
    // Handle state switching logic
    always @ (state, finish, clk_en)
        case (state)
        // Reset state. Pull sync high, reset shift reg, bring dout low
            rst: begin
                next_state = idle;
            end
        // Wait for clock_enable
            idle: begin
                if(clk_en)
                    next_state = load;
                else 
                    next_state = idle;
            end
        // Load shift register with data
            load: begin
                next_state = shift;
            end
        // Return to idle when finish shifting
            shift: begin
                if(finish)
                    next_state = idle;
                else 
                    next_state = shift;
            end
        endcase


// 5-bit counter, from 0 to 15;
reg [4:0] count_16;
always @ (negedge clk)
    // Get everything ready, load up shift reg, reset count
    if(state == load) begin
        count_16 <= 0;
        if(sel) 
            shift_reg <= {ctl_reg, 8'hff};
        else 
            shift_reg <= {ctl_reg, sawVal};
    end
    // Start shifting, increment counter
    else if (state == shift) begin
        count_16 <= count_16 + 1'b1;
        shift_reg <= {shift_reg[14:0], 1'b0};
    end

assign finish = (count_16 == 5'd15);
assign dout = shift_reg[15];                        // Sdata = MSB
assign sync = (state == shift) ? 1'b0 : 1'b1;       // Pull low only on shifting

endmodule
