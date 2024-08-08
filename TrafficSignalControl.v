`timescale 1ns / 1ps

// Define constants
`define TRUE  1'b1
`define FALSE 1'b0
`define RED   2'd0
`define YELLOW 2'd1
`define GREEN 2'd2

// State definition
`define S0 3'd0  // GREEN
`define S1 3'd1  // YELLOW
`define S2 3'd2  // RED
`define S3 3'd3  // RED (for HWY)
`define S4 3'd4  // RED (for CNTRY)

// Delays
`define Y2RDELAY 3 // Yellow to red delay
`define R2GDELAY 2 // Red to green delay

module sig_control (
    output reg [1:0] hwy, cntry, // 2-bit outputs for the states of signals
    input wire X,                // If TRUE, indicates that there is a car on the country road, otherwise FALSE
    input wire clock, clear      // Clock and clear inputs
);

// Internal state variables
reg [2:0] state, next_state;
reg [3:0] counter; // Counter for delays

// Signal controller starts in S0 state
initial begin
    state = `S0;
    next_state = `S0;
    hwy = `GREEN;
    cntry = `RED;
    counter = 0;
end

// State changes only at the positive edge of the clock
always @(posedge clock) begin
    if (clear) begin
        state <= `S0;
        counter <= 0;
    end else begin
        state <= next_state;
        if (counter > 0) counter <= counter - 1;
    end
end

// Compute values of main signal (hwy) and country signal (cntry)
always @(state) begin
    case (state)
        `S0: begin
            hwy = `GREEN;
            cntry = `RED;
            counter = `Y2RDELAY;
        end
        `S1: begin
            hwy = `YELLOW;
            cntry = `RED;
            counter = `Y2RDELAY;
        end
        `S2: begin
            hwy = `RED;
            cntry = `RED;
            counter = `R2GDELAY;
        end
        `S3: begin
            hwy = `RED;
            cntry = `GREEN;
            counter = 0; // No delay
        end
        `S4: begin
            hwy = `RED;
            cntry = `YELLOW;
            counter = `Y2RDELAY;
        end
        default: begin
            hwy = `RED;
            cntry = `RED;
            counter = 0;
        end
    endcase
end

// State machine using case statements
always @(posedge clock) begin
    if (clear) 
        next_state <= `S0;
    else if (counter == 0) begin
        case (state)
            `S0: next_state <= (X ? `S1 : `S0);
            `S1: next_state <= `S2;
            `S2: next_state <= `S3;
            `S3: next_state <= (X ? `S3 : `S4);
            `S4: next_state <= `S0;
            default: next_state <= `S0;
        endcase
    end
end

endmodule
