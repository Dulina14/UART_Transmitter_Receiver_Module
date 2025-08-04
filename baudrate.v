// Baud rate generator module for 115200 baud
module baudrate (
    input wire clk_50m,                    // 50 MHz clock input
    output reg Rxclk_en,                   // Receiver clock enable output
    output reg Txclk_en                    // Transmitter clock enable output
);
    parameter CLKS_PER_BIT = 434;          // Number of 50 MHz clock cycles per bit at 115200 baud (50e6 / 115200 ≈ 434)
    reg [9:0] counter = 0;                 // 10-bit counter to track clock cycles (up to 1023, sufficient for 434)

    always @(posedge clk_50m) begin        // Sequential logic triggered on the positive edge of the 50 MHz clock
        counter <= counter + 1;            // Increment the counter on each clock cycle
        if (counter == CLKS_PER_BIT - 1) begin // Check if counter reaches one baud period (433 cycles)
            counter <= 0;                  // Reset counter to 0 to start a new baud period
            Rxclk_en <= 1'b1;              // Set receiver clock enable high for one cycle
            Txclk_en <= 1'b1;              // Set transmitter clock enable high for one cycle
        end else begin
            Rxclk_en <= 1'b0;              // Keep receiver clock enable low otherwise
            Txclk_en <= 1'b0;              // Keep transmitter clock enable low otherwise
        end
    end
endmodule