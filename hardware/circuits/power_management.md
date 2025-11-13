# Power Management Circuits

## Overview
Comprehensive power management system for the inverted pendulum, including voltage regulation, power sequencing, and protection circuits.

## Power Requirements

### System Power Budget
| Subsystem | Voltage | Current (Typ) | Current (Peak) | Power |
|-----------|---------|--------------|----------------|-------|
| Motor Drive | 24V | 1.5A | 5A | 36W (120W peak) |
| MCU + Digital | 3.3V | 150mA | 300mA | 0.5W |
| Encoders | 5V | 200mA | 400mA | 1W |
| Analog Circuits | ±12V | 50mA | 100mA | 1.2W |
| **Total** | - | - | - | **~39W (123W peak)** |

## Primary Power Supply

### 24V DC Input
- **Source**: External 24V, 5A switching adapter
- **Input Protection**:
  - TVS diode (SMBJ24A) for overvoltage protection
  - Reverse polarity protection (P-channel MOSFET + Schottky)
  - Input fuse: 6.3A slow-blow
- **Input Filtering**: 1000µF electrolytic + 100nF ceramic

## Voltage Regulators

### 3.3V Digital Supply (MCU, Logic)
**Regulator**: LM2596S-3.3 (Buck Converter)
- **Input**: 24V
- **Output**: 3.3V @ 3A max
- **Efficiency**: ~85% at 1A load
- **Ripple**: <50mV with proper filtering
- **Components**:
  - Inductor: 47µH, 3A (low DCR)
  - Input cap: 100µF + 100nF
  - Output cap: 220µF + 100nF
  - Feedback resistors: 1.2kΩ + 3.3kΩ

### 5V Encoder Supply
**Regulator**: LM2596S-5.0 (Buck Converter)
- **Input**: 24V
- **Output**: 5V @ 1A max
- **Efficiency**: ~88% at 500mA
- **Filtering**: Same as 3.3V supply

### ±12V Analog Supply
**Regulator**: ICL7660 (Charge Pump) + LM317/LM337
- **Input**: 24V
- **Output**: +12V @ 100mA, -12V @ 100mA
- **Use**: Op-amp power supplies (if needed for signal conditioning)
- **Alternative**: Use single-supply op-amps to eliminate negative rail

## Power Sequencing

### Startup Sequence
1. **24V applied** → Input protection active
2. **3.3V regulator** → Powers MCU (enable via power-good signal)
3. **5V regulator** → Powers encoders (after MCU ready)
4. **Motor enable** → Software-controlled via GPIO

### Shutdown Sequence
1. **Motor disabled** → Software command
2. **Encoders powered down** → GPIO control
3. **MCU enters low-power mode** → Or full shutdown

## Power Monitoring

### Voltage Monitoring
- **Channels**: 24V, 3.3V, 5V
- **Method**: Voltage dividers → MCU ADC
- **Alarm Thresholds**:
  - 24V: <20V (undervoltage) or >28V (overvoltage)
  - 3.3V: <3.0V or >3.6V
  - 5V: <4.5V or >5.5V

### Current Monitoring
- **Motor Current**: Via DRV8871 current sense output
- **System Current**: Shunt resistor on 24V input (0.01Ω)
- **ADC Sampling**: 1 kHz (matches control loop)

## Protection Circuits

### Overcurrent Protection
- **Hardware**: Current sense comparator (LM393)
- **Threshold**: 5.5A (110% of motor peak)
- **Action**: Latch motor driver enable low
- **Reset**: Software command or power cycle

### Thermal Protection
- **Sensor**: NTC thermistor on motor driver heatsink
- **Threshold**: 85°C
- **Action**: Reduce PWM duty cycle or disable motor

### Brownout Protection
- **MCU Internal**: STM32 brownout detector (2.0V threshold)
- **External**: Voltage monitor IC (TPS3809) for 24V supply
- **Action**: Safe shutdown sequence

## Power Efficiency Optimization

### Switching Frequency Selection
- **3.3V/5V Regulators**: 150 kHz (good efficiency, manageable EMI)
- **Motor PWM**: 20 kHz (reduces switching losses)

### Load-Dependent Efficiency
- **Light Load**: Use LDO for 3.3V (better efficiency <100mA)
- **Heavy Load**: Use buck converter (better efficiency >200mA)
- **Implementation**: Load switch to select regulator

## PCB Layout Guidelines

### Power Plane Design
- **24V Plane**: Thick traces (≥80 mils), multiple vias
- **Ground Planes**: Separate analog and digital grounds, single-point connection
- **Decoupling**: Place capacitors close to ICs (≤5mm)

### Thermal Management
- **Heatsinks**: On motor driver (DRV8871) and regulators
- **Thermal Vias**: Under power components
- **Copper Pours**: Maximize for heat dissipation

### EMI Reduction
- **Filtering**: LC filters on all power inputs
- **Shielding**: Ground plane under switching regulators
- **Routing**: Keep switching nodes away from sensitive analog signals

## Component Selection Summary

| Component | Part Number | Key Spec | Rationale |
|-----------|------------|----------|-----------|
| 3.3V Regulator | LM2596S-3.3 | 3A, 85% eff | High efficiency, adequate current |
| 5V Regulator | LM2596S-5.0 | 3A, 88% eff | Matched performance |
| Input Protection | SMBJ24A | 24V TVS | Overvoltage protection |
| Current Sense | INA199 | 50V/V gain | Accurate current monitoring |
| Power Monitor | TPS3809 | Adjustable threshold | Brownout detection |

