# UART_Transmitter_Receiver_Module

## UART Implementation on FPGA (DE0-Nano)

This repository contains the Verilog implementation of a UART transceiver with even parity, designed and verified on the **DE0-Nano FPGA board**. The project includes transmitter and receiver modules, a baud-rate generator, and a complete testbench for simulation and hardware validation.

## 🔧 Project Summary

- **Course**: EN2111 – Electronic Circuit Design  
- **Institute**: Department of Electronic & Telecommunication Engineering, University of Moratuwa  
## 🚀 Features

- **Baud Rate**: 115200 bps (using a 50 MHz clock, 434 clocks/bit)
- **8-bit UART Frame**: Start bit, 8 data bits (LSB first), even parity, stop bit
- **Modules**:
  - Baud-rate generator
  - UART transmitter (`uart_tx.v`)
  - UART receiver (`uart_rx.v`)
- **Even Parity Support**: Added to enhance data reliability
- **FPGA Target**: DE0-Nano (Cyclone IV)
- **Toolchain**: Intel Quartus Prime v20.1

## 🧪 Simulation & Testing

### ✅ Simulation
- **Tool**: ModelSim / QuestaSim
- **Setup**:
  - Generates 50 MHz clock
  - Simulates loopback (TX → RX)
  - Checks received data against expected value
- **Result**: Successful transmission of 0x09 (with even parity) detected correctly

### ✅ Hardware Verification

- **On-Board Loopback**: TX and RX connected internally on one board
  - LEDs show correct received byte
- **Cross-Board Test**: Two boards communicate via UART
  - Board A sends 0x09
  - Board B receives, left-shifts, and sends back 0x12
  - Board A receives and displays 0x12

## 🔌 FPGA Pin Assignments

| Signal     | DE0-Nano Pin | Description                  |
|------------|--------------|------------------------------|
| CLOCK_50   | R8           | 50 MHz system clock          |
| GPIO_00    | D3           | UART TX output               |
| GPIO_01    | C3           | UART RX input                |
| LED[7:0]   | A15...L3     | 8-bit received data display  |
| KEY0       | J15          | Reset (active-low)           |
| KEY1       | E1           | Ready-clear (active-low)     |

## 📷 Results

- Simulated waveform confirms accurate UART framing and parity
- RTL viewer confirms correct module hierarchy
- Real-time LED output shows accurate loopback and response in cross-board communication

## 📌 Improvements (Future Work)

- Add configurable transmit byte and baud rate via switches
- Include error detection flags (framing, overrun)
- Add FIFO buffer or interrupt interface for enhanced performance
