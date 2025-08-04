module uart_rx (
    input wire i_Clock,
    input wire i_Rx_Serial,
    output wire o_Rx_DV,
    output wire [7:0] o_Rx_Byte,
    output wire o_Parity_Error
);
    parameter CLKS_PER_BIT = 434;
    parameter s_IDLE         = 3'b000;
    parameter s_RX_START_BIT = 3'b001;
    parameter s_RX_DATA_BITS = 3'b010;
    parameter s_RX_PARITY    = 3'b011;
    parameter s_RX_STOP_BIT  = 3'b100;
    parameter s_CLEANUP      = 3'b101;

    reg r_Rx_Data_R = 1'b1;
    reg r_Rx_Data = 1'b1;
    reg [9:0] r_Clock_Count = 0;
    reg [2:0] r_Bit_Index = 0;
    reg [7:0] r_Rx_Byte = 0;
    reg r_Rx_DV = 0;
    reg [2:0] r_SM_Main = 0;
    reg r_Parity = 0;
    reg r_Parity_Check = 0;

    // Double-register input to avoid metastability
    always @(posedge i_Clock) begin
        r_Rx_Data_R <= i_Rx_Serial;
        r_Rx_Data <= r_Rx_Data_R;
    end

    // State machine for UART reception
    always @(posedge i_Clock) begin
        case (r_SM_Main)
            s_IDLE: begin
                r_Rx_DV <= 1'b0;
                r_Clock_Count <= 0;
                r_Bit_Index <= 0;
                if (r_Rx_Data == 1'b0) begin
                    r_SM_Main <= s_RX_START_BIT;
                end else begin
                    r_SM_Main <= s_IDLE;
                end
            end

            s_RX_START_BIT: begin
                if (r_Clock_Count == (CLKS_PER_BIT - 1) / 2) begin
                    if (r_Rx_Data == 1'b0) begin
                        r_Clock_Count <= 0;
                        r_SM_Main <= s_RX_DATA_BITS;
                    end else begin
                        r_SM_Main <= s_IDLE;
                    end
                end else begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main <= s_RX_START_BIT;
                end
            end

            s_RX_DATA_BITS: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main <= s_RX_DATA_BITS;
                end else begin
                    r_Clock_Count <= 0;
                    r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                    if (r_Bit_Index < 7) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_SM_Main <= s_RX_DATA_BITS;
                    end else begin
                        r_Bit_Index <= 0;
                        r_SM_Main <= s_RX_PARITY;
                    end
                end
            end

            s_RX_PARITY: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main <= s_RX_PARITY;
                end else begin
                    r_Clock_Count <= 0;
                    r_Parity <= r_Rx_Data;
                    r_Parity_Check <= (^r_Rx_Byte) == r_Rx_Data; // True if parity matches
                    r_SM_Main <= s_RX_STOP_BIT;
                end
            end

            s_RX_STOP_BIT: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main <= s_RX_STOP_BIT;
                end else begin
                    r_Rx_DV <= r_Parity_Check; // Valid only if parity matches
                    r_Clock_Count <= 0;
                    r_SM_Main <= s_CLEANUP;
                end
            end

            s_CLEANUP: begin
                r_SM_Main <= s_IDLE;
                r_Rx_DV <= 1'b0;
            end

            default: r_SM_Main <= s_IDLE;
        endcase
    end

    assign o_Rx_DV = r_Rx_DV;
    assign o_Rx_Byte = r_Rx_Byte;
    assign o_Parity_Error = ~r_Parity_Check; // High if parity check fails
endmodule
