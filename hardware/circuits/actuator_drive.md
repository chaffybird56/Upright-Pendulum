# Actuator Drive Circuits

## Overview
Digital and analogue circuits for driving the DC motor actuator in the inverted pendulum system, including PWM generation, motor driver selection, and current sensing.

## Actuator Specifications

### DC Motor
- **Type**: Brushed DC servo motor
- **Rated Voltage**: 24V DC
- **Rated Current**: 2A continuous, 5A peak
- **Torque Constant**: 0.05 N⋅m/A
- **Back-EMF Constant**: 0.05 V/(rad/s)

## Digital PWM Generation

### PWM Controller
- **MCU**: STM32F4 timer peripheral (TIM1 or TIM8)
- **Frequency**: 20 kHz (above audible range, reduces ripple)
- **Resolution**: 12-bit (4096 levels)
- **Dead Time**: 100ns (prevents shoot-through)

### PWM Signal Processing
```
[MCU PWM] → [Gate Driver] → [H-Bridge] → [Motor]
```

## Analogue Motor Driver Circuit

### H-Bridge Configuration
**Driver IC**: DRV8871 (3.6A peak, 2A continuous)

**Key Features:**
- Integrated current sensing
- Overcurrent protection
- Thermal shutdown
- Direction and brake control

### Circuit Topology
```
VCC (24V)
  │
  ├─[DRV8871]─┬─ Motor+ ─┐
  │           │          │
  │           └─ Motor- ─┘
  │
  └─[Decoupling: 100µF + 100nF]
```

### Gate Driver Circuit (if using discrete MOSFETs)
- **Driver IC**: IR2104 (high/low side driver)
- **MOSFETs**: N-channel IRF540N (33A, 100V)
- **Bootstrap Capacitor**: 1µF ceramic
- **Gate Resistor**: 10Ω (limits di/dt)

## Current Sensing

### Shunt Resistor Method
- **Shunt**: 0.1Ω, 2W power resistor
- **Amplifier**: INA199 current shunt monitor (gain = 50)
- **ADC**: 12-bit, 1 MSPS (MCU internal)
- **Bandwidth**: 10 kHz (sufficient for control loop)

### Current Limit Protection
- Hardware comparator on current sense signal
- Threshold: 4.5A (90% of peak rating)
- Action: Disable PWM immediately on overcurrent

## Signal Conditioning

### Voltage Sensing
- **Divider**: 10:1 ratio (24V → 2.4V max)
- **Filter**: RC low-pass (fc = 1 kHz)
- **ADC Channel**: MCU ADC1, 12-bit resolution

### Back-EMF Measurement
- **Method**: Measure motor terminal voltage during PWM off-time
- **Sampling**: Synchronized with PWM switching
- **Use**: Velocity estimation (alternative to encoder differentiation)

## Power Management

### Motor Power Supply
- **Input**: 24V DC wall adapter or battery
- **Filtering**: LC filter (100µH + 1000µF) to reduce PWM ripple
- **Protection**: 5A fuse, reverse polarity protection (Schottky diode)

### Logic Power Supply
- **Voltage**: 3.3V (from 24V via switching regulator)
- **Regulator**: LM2596S-3.3 (3A, 85% efficiency)
- **Filtering**: 10µF + 100nF output capacitors

## PCB Design Notes
- **Thermal Management**: Large copper pours for heat dissipation
- **Current Paths**: Wide traces (≥50 mils) for motor current
- **Isolation**: Separate ground planes for digital and motor power
- **EMI**: Snubber circuits (RC) across motor terminals

## Component Selection Rationale
- **DRV8871**: Integrated solution reduces PCB complexity
- **20 kHz PWM**: Balances efficiency and noise
- **Current sensing**: Enables torque control and protection
- **Isolation**: Prevents ground loops and noise coupling

