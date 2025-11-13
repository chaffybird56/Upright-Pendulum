# Signal Processing Circuits

## Overview
Analogue signal processing circuits for sensor data conditioning, filtering, and ADC interfacing in the inverted pendulum control system.

## Signal Processing Chain

### Complete Signal Path
```
[Encoder] → [Quadrature Decoder] → [Digital Filter] → [MCU]
[Current Sense] → [Amplifier] → [Anti-aliasing Filter] → [ADC] → [MCU]
[Voltage Sense] → [Divider] → [Filter] → [ADC] → [MCU]
```

## Analogue Signal Conditioning

### Encoder Signal Conditioning
**Purpose**: Clean up noisy encoder signals before digital processing

**Circuit**: RC Low-Pass Filter + Schmitt Trigger
- **Cutoff Frequency**: 10 kHz (well above encoder max frequency)
- **Components**: R = 1kΩ, C = 15nF (fc ≈ 10.6 kHz)
- **Schmitt Trigger**: 74HC14 (hysteresis: 0.5V typical)

**Noise Reduction**:
- Common-mode noise rejection via differential routing
- EMI filtering via ferrite beads on encoder cables
- Shielding: Twisted-pair encoder cables

### Current Sense Signal Processing

**Shunt Resistor Amplification**
- **Shunt**: 0.1Ω, 2W (INA199 internal or external)
- **Amplifier**: INA199A1 (gain = 50 V/V)
- **Output Range**: 0-2.5V (for 0-5A current)
- **Bandwidth**: 10 kHz (sufficient for control loop)

**Anti-Aliasing Filter**
- **Type**: 2nd-order Sallen-Key low-pass
- **Cutoff**: 500 Hz (Nyquist = 1 kHz, safety margin)
- **Components**: 
  - R1 = R2 = 10kΩ
  - C1 = 22nF, C2 = 10nF
  - Op-amp: MCP6002 (rail-to-rail, 3.3V supply)

**Filter Transfer Function**:
```
H(s) = 1 / (1 + s*R1*C1 + s²*R1*R2*C1*C2)
fc ≈ 1 / (2π√(R1*R2*C1*C2)) ≈ 500 Hz
```

### Voltage Sense Signal Processing

**Voltage Divider**
- **Input**: 24V motor supply
- **Divider Ratio**: 10:1 (24V → 2.4V max)
- **Resistors**: R1 = 90kΩ, R2 = 10kΩ (1% tolerance)
- **Power Rating**: R1 = 0.25W, R2 = 0.125W

**Low-Pass Filtering**
- **RC Filter**: R = 10kΩ, C = 1µF
- **Cutoff**: 16 Hz (removes PWM ripple, 20 kHz)
- **Purpose**: Smooth voltage measurement

**ADC Interface**
- **Input Range**: 0-3.3V (MCU ADC)
- **Resolution**: 12-bit (0.8 mV per LSB)
- **Sampling Rate**: 1 kHz (matches control loop)

## Digital Signal Processing

### Encoder Count Processing
**Quadrature Decoding**:
- Hardware decoder (LS7366R) handles counting
- MCU reads 32-bit count via SPI
- Conversion to angle: `θ = (count / CPR) * 2π`

**Angle Rate Estimation**:
- **Method 1**: Numerical differentiation (backward difference)
  ```
  ω[k] = (θ[k] - θ[k-1]) / Ts
  ```
- **Method 2**: Kalman filter (used in observer)
- **Filtering**: Moving average or low-pass filter to reduce noise

### ADC Sampling Strategy

**Synchronized Sampling**:
- All ADC channels sampled simultaneously (MCU feature)
- Trigger: Timer interrupt at 1 kHz
- Channels:
  1. Motor current (INA199 output)
  2. Motor voltage (voltage divider)
  3. System voltage (24V monitor)
  4. Temperature (NTC thermistor)

**Oversampling for Noise Reduction**:
- Sample at 4 kHz, average to 1 kHz
- Reduces noise by √4 = 2×
- Improves effective resolution by 1 bit

## Filter Design

### Digital Low-Pass Filter (Angle Rates)
**Purpose**: Reduce noise from numerical differentiation

**Filter Type**: 2nd-order Butterworth IIR
**Cutoff**: 50 Hz (well below Nyquist of 500 Hz)

**Transfer Function** (bilinear transform):
```
H(z) = (b0 + b1*z⁻¹ + b2*z⁻²) / (1 + a1*z⁻¹ + a2*z⁻²)
```

**MATLAB Design**:
```matlab
[b, a] = butter(2, 50/(1000/2), 'low');
```

### Notch Filter (PWM Ripple)
**Purpose**: Remove 20 kHz PWM switching noise

**Filter Type**: 2nd-order IIR notch
**Center Frequency**: 20 kHz
**Bandwidth**: 2 kHz

**Implementation**: Optional, if PWM noise affects measurements

## Calibration and Compensation

### ADC Offset Calibration
- **Method**: Sample with inputs shorted to ground
- **Storage**: EEPROM or flash memory
- **Application**: Subtract offset from all readings

### Gain Calibration
- **Current Sense**: Apply known current, measure output
- **Voltage Sense**: Apply known voltage, measure output
- **Storage**: Calibration coefficients in non-volatile memory

### Temperature Compensation
- **NTC Thermistor**: Monitor system temperature
- **Application**: Compensate sensor readings if temperature-dependent

## Signal Integrity

### Grounding Strategy
- **Separate Grounds**: Analog ground (AGND) and digital ground (DGND)
- **Connection**: Single-point connection near ADC
- **Purpose**: Prevent digital noise from coupling into analog signals

### Shielding
- **Encoder Cables**: Shielded twisted-pair
- **Current Sense**: Keep traces short, away from switching nodes
- **ADC Inputs**: Guard rings around sensitive inputs

### PCB Layout Guidelines
- **Analog Section**: Isolated from digital section
- **Component Placement**: Keep filters close to ADC
- **Trace Routing**: Minimize loop areas, use ground planes

## Component Selection

| Component | Part Number | Key Spec | Purpose |
|-----------|------------|----------|---------|
| Current Amp | INA199A1 | Gain=50, BW=10kHz | Current sensing |
| Op-Amp | MCP6002 | Rail-to-rail, 3.3V | Anti-aliasing filter |
| ADC | STM32F4 Internal | 12-bit, 1 MSPS | Signal digitization |
| Quadrature Decoder | LS7366R | 32-bit, SPI | Encoder processing |

## Performance Specifications

### Signal Processing Metrics
- **Angle Resolution**: 0.0015 rad (11-bit encoder)
- **Current Resolution**: 1.2 mA (12-bit ADC, 5A range)
- **Voltage Resolution**: 0.8 mV (12-bit ADC, 3.3V range)
- **Update Rate**: 1 kHz (all channels synchronized)
- **Latency**: <1 ms (from sensor to control output)

