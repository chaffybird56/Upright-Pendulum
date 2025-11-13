# Sensor Interface Circuits

## Overview
This document describes the analogue and digital circuit designs for the inverted pendulum sensor system, including encoder interfaces, signal conditioning, and ADC conversion.

## Sensor Specifications

### Rotary Encoders
- **Type**: Incremental optical encoders (2 channels, quadrature output)
- **Resolution**: 2048 pulses per revolution (11-bit resolution)
- **Output**: A/B quadrature signals + index pulse
- **Power**: 5V DC, 100mA max per encoder

### Joint Angle Measurement
- **Joint 1 (Base)**: Direct encoder on motor shaft
- **Joint 2 (Pendulum Link)**: Encoder on joint axis
- **Measurement Range**: 0 to 2π radians (continuous rotation)

## Analogue Signal Conditioning

### Quadrature Decoder Circuit
```
Encoder A/B → Schmitt Trigger (74HC14) → Quadrature Decoder (LS7366R)
```

**Components:**
- **74HC14**: Hex Schmitt-trigger inverters for noise filtering
- **LS7366R**: 32-bit quadrature counter with SPI interface
- **Pull-up resistors**: 10kΩ on A/B channels
- **Decoupling capacitors**: 100nF ceramic + 10µF tantalum per IC

### Signal Conditioning Requirements
1. **Noise Filtering**: RC low-pass filter (fc = 10kHz) before Schmitt triggers
2. **Level Shifting**: 5V encoder signals to 3.3V logic (74LVC1T45)
3. **EMI Protection**: Ferrite beads on encoder power lines

## Digital Interface

### SPI Communication
- **Clock**: 1 MHz (well below 1kHz control loop requirement)
- **Mode**: SPI Mode 0 (CPOL=0, CPHA=0)
- **Chip Select**: GPIO pins for each encoder IC
- **Data Format**: 32-bit signed integer (counts)

### Microcontroller Interface
- **MCU**: STM32F4 series (ARM Cortex-M4)
- **SPI Peripheral**: SPI1 for encoder 1, SPI2 for encoder 2
- **Interrupt**: EXTI on encoder index pulses for absolute reference

## Circuit Schematics

### Encoder Interface Block Diagram
```
[Encoder] → [Schmitt Trigger] → [Quadrature Decoder] → [SPI] → [MCU]
     ↓              ↓                      ↓
  [Power]      [Filter]              [Level Shift]
```

### Component Selection Rationale
- **LS7366R**: Industry-standard quadrature decoder, handles high-speed counting
- **74HC14**: Provides hysteresis for noisy encoder signals
- **74LVC1T45**: Bidirectional level shifter, low propagation delay

## PCB Layout Considerations
- Keep encoder signals away from motor drive lines
- Use ground plane under encoder traces
- Place decoupling capacitors close to IC power pins
- Route SPI signals as differential pairs where possible

