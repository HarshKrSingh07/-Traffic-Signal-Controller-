`timescale 1ns / 1ps

// Define constants
`define TRUE  1'b1
`define FALSE 1'b0

module stimulus;
    wire [1:0] MAIN_SIG, CNTRY_SIG;
    reg CAR_ON_CNTRY_RD;
    reg CLOCK, CLEAR;

    // Dump signals to a VCD file
    initial begin
        $dumpfile("traffic_light_controller.vcd");
        $dumpvars(0, stimulus);
    end

    // Instantiate the sig_control module
    sig_control SC (
        .hwy(MAIN_SIG),
        .cntry(CNTRY_SIG),
        .X(CAR_ON_CNTRY_RD),
        .clock(CLOCK),
        .clear(CLEAR)
    );

    // Set up monitor
    initial begin
        $monitor($time, " Main Sig = %b, Country Sig = %b, Car_on_cntry = %b", MAIN_SIG, CNTRY_SIG, CAR_ON_CNTRY_RD);
    end

    // Set up clock
    initial begin
        CLOCK = `FALSE;
        forever #5 CLOCK = ~CLOCK; // Clock period of 10ns
    end

    // Control clear signal
    initial begin
        CLEAR = `TRUE;
        repeat (5) @ (negedge CLOCK);
        CLEAR = `FALSE;
    end

    // Apply stimulus
    initial begin
        CAR_ON_CNTRY_RD = `FALSE;
        #200 CAR_ON_CNTRY_RD = `TRUE;
        #100 CAR_ON_CNTRY_RD = `FALSE;
        #200 CAR_ON_CNTRY_RD = `TRUE;
        #100 CAR_ON_CNTRY_RD = `FALSE;
        #200 CAR_ON_CNTRY_RD = `TRUE;
        #100 CAR_ON_CNTRY_RD = `FALSE;
        #100 $stop;
    end
endmodule
