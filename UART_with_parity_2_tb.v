`timescale 1ns / 1ps

module UART_with_parity_2_tb;

    // Parameters
    parameter CLK_PERIOD = 20;  // 50 MHz clock period (20ns)
    parameter SIMULATION_CYCLES = 100000; // Adjust based on baud rate
    
    // Testbench signals
    reg CLOCK_50;
    reg KEY0;           // Clear signal (active low)
    reg KEY1;           // Ready clear signal (active low)
    reg GPIO_01;        // UART Rx input
    wire GPIO_00;       // UART Tx output
    wire [7:0] LED;     // LED outputs
    
    // Internal monitoring signals
    reg [7:0] expected_data;
    reg [7:0] received_data;
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Instantiate the Unit Under Test (UUT)
    UART_with_parity_2 uut (
        .CLOCK_50(CLOCK_50),
        .KEY0(KEY0),
        .KEY1(KEY1),
        .GPIO_01(GPIO_01),
        .GPIO_00(GPIO_00),
        .LED(LED)
    );
    
    // Clock generation - 50 MHz
    initial begin
        CLOCK_50 = 0;
    end
    
    always #(CLK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
    
    // Connect Tx to Rx for loopback testing
    always @(*) begin
        GPIO_01 = GPIO_00;
    end
    
    // Monitor LED changes (which reflect received data)
    always @(LED) begin
        if (LED !== 8'bx && LED !== 8'bz) begin
            received_data = LED;
            
            // Check if received data matches expected
            if (received_data == expected_data) begin
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
            end
            test_count = test_count + 1;
        end
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        KEY0 = 1'b1;        // Not in clear state
        KEY1 = 1'b1;        // Not in ready clear state
        GPIO_01 = 1'b1;     // UART idle state is high
        expected_data = 8'h09; // Expected data matches data_in in your module
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Apply reset
        KEY0 = 1'b0;  // Active low reset
        #1000;        // Hold reset for 1us
        KEY0 = 1'b1;  // Release reset
        
        // Wait for transmission and reception
        // At 115200 baud, each bit takes ~8.68us, so a full frame takes ~86.8us
        // Wait for multiple transmissions since wr_en is always high
        #300000; // Wait 300us for multiple transmissions
        
        // Test reset functionality
        KEY0 = 1'b0;  // Apply reset
        #1000;
        KEY0 = 1'b1;  // Release reset
        #100000;      // Wait for more transmissions
        
        // Test KEY1 (ready clear) functionality
        KEY1 = 1'b0;  // Apply ready clear
        #1000;
        KEY1 = 1'b1;  // Release ready clear
        #100000;      // Wait for more transmissions
        
        #10000;
        // Simulation will end here
    end
    
    // Timeout watchdog
    initial begin
        #1000000; // 1ms timeout
        // Simulation will timeout here if needed
    end


endmodule