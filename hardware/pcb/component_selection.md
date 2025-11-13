# Component Selection Guide

## Overview
Detailed component selection guide with specifications, alternatives, and selection rationale for the inverted pendulum PCB design.

## Component Categories

### 1. Microcontroller (MCU)

#### Selected: STM32F407VGT6
**Specifications**:
- **Architecture**: ARM Cortex-M4F with FPU
- **Clock Speed**: 168 MHz
- **Flash**: 1 MB
- **RAM**: 192 KB
- **Package**: LQFP100 (14×14mm)
- **Peripherals**: 
  - 3× SPI (for encoders)
  - 2× 12-bit ADC (16 channels)
  - 2× 12-bit DAC
  - 14× Timers (PWM generation)
  - 6× UART
- **Operating Voltage**: 1.8-3.6V (3.3V typical)
- **Temperature Range**: -40°C to +85°C
- **Price**: ~$8-12 (quantity 10)

**Selection Rationale**:
- Floating-point unit accelerates control algorithm computation
- Multiple SPI peripherals for encoder interfaces
- High-resolution timers for precise PWM generation
- Rich peripheral set reduces need for external ICs
- Excellent documentation and toolchain support

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| STM32F303VCT6 | Lower cost, similar features | Lower clock (72 MHz) | ~$5-8 |
| ATmega2560 | Very low cost, Arduino compatible | 8-bit, insufficient performance | ~$3-5 |
| ESP32 | WiFi/Bluetooth built-in | More complex, higher power | ~$5-7 |

---

### 2. Motor Driver

#### Selected: DRV8871DDAR
**Specifications**:
- **Package**: SOIC-8 (5×6mm)
- **Supply Voltage**: 6.5V to 45V
- **Peak Current**: 3.6A
- **Continuous Current**: 2A
- **Features**:
  - Integrated H-bridge
  - Current sensing output
  - Overcurrent protection
  - Thermal shutdown
  - Sleep mode
- **Price**: ~$2-3 (quantity 10)

**Selection Rationale**:
- Integrated solution reduces component count
- Built-in current sensing simplifies design
- Protection features improve reliability
- Suitable current rating for application

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| L298N | Very common, dual H-bridge | Lower efficiency, external sense | ~$1-2 |
| BTS7960 | Higher current (43A) | More complex, higher cost | ~$3-5 |
| DRV8833 | Lower current (1.5A) | Insufficient for this application | ~$1-2 |

---

### 3. Quadrature Decoder

#### Selected: LS7366R-S
**Specifications**:
- **Package**: SOIC-24 (7.5×15.4mm)
- **Counter Size**: 32-bit
- **Interface**: SPI
- **Max Count Rate**: 12.5 MHz
- **Features**:
  - 4× quadrature decoders (use 2)
  - Index pulse capture
  - Count prescaler
  - Non-volatile registers
- **Price**: ~$4-6 (quantity 10)

**Selection Rationale**:
- Hardware decoding reduces MCU load
- 32-bit counter handles high-resolution encoders
- SPI interface is simple and fast
- Multiple channels allow future expansion

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| HCTL-2021 | Lower cost | 16-bit counter, older part | ~$2-3 |
| Software decode | No extra IC | Uses MCU resources | $0 |
| AS5048A | Absolute encoder support | More expensive, different use case | ~$5-7 |

---

### 4. Voltage Regulators

#### 3.3V Regulator: LM2596S-3.3
**Specifications**:
- **Package**: TO-263-5 (D2PAK)
- **Input Voltage**: 4.5V to 40V
- **Output Voltage**: 3.3V (fixed)
- **Output Current**: 3A max
- **Efficiency**: ~85% at 1A load
- **Switching Frequency**: 150 kHz
- **Price**: ~$1-2 (quantity 10)

#### 5V Regulator: LM2596S-5.0
**Specifications**:
- Same as 3.3V version, but 5V output
- **Price**: ~$1-2 (quantity 10)

**Selection Rationale**:
- Switching regulators provide high efficiency
- Adequate current rating
- Simple external circuit (few components)
- Low cost, widely available
- Matched parts simplify design

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| AMS1117-3.3 | LDO, simpler circuit | Lower efficiency at high current | ~$0.20 |
| TPS62133 | Higher efficiency (95%) | Higher cost, smaller package | ~$2-3 |
| LM317 | Adjustable output | Requires external resistors | ~$0.50 |

---

### 5. Current Sense Amplifier

#### Selected: INA199A1
**Specifications**:
- **Package**: SOT-23-8 (3×3mm)
- **Gain**: 50 V/V (A1 variant)
- **Common-Mode Voltage**: -16V to +80V
- **Bandwidth**: 10 kHz
- **Supply Voltage**: 2.7V to 26V
- **Price**: ~$1-2 (quantity 10)

**Selection Rationale**:
- High common-mode voltage range (suitable for 24V motor)
- Multiple gain options (A1=50, A2=100, A3=200)
- Small package saves board space
- Good bandwidth for control loop

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| INA219 | Digital output, I2C | More complex interface | ~$2-3 |
| ACS712 | Isolated, Hall-effect | Lower accuracy, larger package | ~$1-2 |
| MAX4080 | Higher bandwidth | Higher cost | ~$2-3 |

---

### 6. Logic ICs

#### Schmitt Trigger: 74HC14
**Specifications**:
- **Package**: SOIC-14 (8.75×5.3mm)
- **Type**: Hex inverter with Schmitt trigger
- **Supply Voltage**: 2V to 6V (5V typical)
- **Hysteresis**: ~0.5V typical
- **Price**: ~$0.20-0.50 (quantity 10)

**Selection Rationale**:
- Provides noise filtering via hysteresis
- Multiple inverters in one package
- Low cost, widely available
- Standard logic family

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| 74LVC14 | 3.3V compatible | Slightly higher cost | ~$0.30-0.60 |
| 74AHC14 | Higher speed | Overkill for this application | ~$0.40-0.70 |

#### Op-Amp: MCP6002
**Specifications**:
- **Package**: SOIC-8 (5×6mm)
- **Type**: Dual rail-to-rail op-amp
- **Supply Voltage**: 1.8V to 6V (3.3V typical)
- **Bandwidth**: 1 MHz
- **Input Offset**: 2 mV max
- **Price**: ~$0.50-1 (quantity 10)

**Selection Rationale**:
- Rail-to-rail input/output (works with 3.3V supply)
- Dual op-amp (one package for filter circuits)
- Low cost, adequate performance
- Suitable for anti-aliasing filters

**Alternatives**:
| Part | Pros | Cons | Price |
|------|------|------|-------|
| LM358 | Very low cost | Not rail-to-rail, higher offset | ~$0.10-0.30 |
| TL072 | Low noise | Requires ±12V supply | ~$0.50-1 |
| OPA2340 | Higher precision | Higher cost | ~$1-2 |

---

### 7. Protection Components

#### TVS Diode: SMBJ24A
**Specifications**:
- **Package**: SMB (DO-214AA)
- **Standoff Voltage**: 24V
- **Breakdown Voltage**: 26.7V min
- **Peak Power**: 600W
- **Price**: ~$0.20-0.50 (quantity 10)

**Selection Rationale**:
- Protects against overvoltage transients
- Suitable for 24V supply
- Small package, low cost
- Industry standard part

---

### 8. Passive Components

#### Resistors
- **Power Resistors**: 0.1Ω, 2W (current sense shunt)
- **Precision Resistors**: 1% tolerance for voltage dividers
- **Standard Resistors**: 5% tolerance for general use
- **Package**: 0805 (SMT) for most, 1206 for power

#### Capacitors
- **Ceramic**: 100nF, 1µF (decoupling)
- **Tantalum**: 10µF, 100µF (power filtering)
- **Electrolytic**: 1000µF (input filtering)
- **Package**: 0805 for ceramic, through-hole for large values

#### Inductors
- **Regulator Inductors**: 47µH, 3A (for LM2596)
- **Package**: SMT power inductor
- **DCR**: Low DC resistance for efficiency

---

## Selection Summary Table

| Category | Part Number | Key Parameter | Cost (qty 10) |
|----------|-------------|---------------|---------------|
| MCU | STM32F407VGT6 | 168 MHz, 1MB Flash | $8-12 |
| Motor Driver | DRV8871DDAR | 3.6A peak | $2-3 |
| Quadrature Decoder | LS7366R-S | 32-bit, SPI | $4-6 |
| 3.3V Regulator | LM2596S-3.3 | 3A, 85% eff | $1-2 |
| 5V Regulator | LM2596S-5.0 | 3A, 88% eff | $1-2 |
| Current Sense | INA199A1 | 50 V/V gain | $1-2 |
| Schmitt Trigger | 74HC14 | Hex inverter | $0.20-0.50 |
| Op-Amp | MCP6002 | Dual, rail-to-rail | $0.50-1 |
| TVS Diode | SMBJ24A | 24V protection | $0.20-0.50 |
| **Total (ICs)** | | | **~$18-30** |
| **Passives** | | | **~$5-10** |
| **Connectors** | | | **~$5-10** |
| **Total BOM** | | | **~$28-50** |

---

## Design Considerations

### Temperature Range
- **Commercial**: 0°C to +70°C (lower cost)
- **Industrial**: -40°C to +85°C (selected for reliability)
- **Extended**: -55°C to +125°C (military, not needed)

### Package Selection
- **SMT Preferred**: Smaller, lower cost, better performance
- **Through-Hole**: Only for connectors and large capacitors
- **Package Size**: Balance between size and manufacturability

### Availability and Sourcing
- **Primary**: Digi-Key, Mouser (reliable, good stock)
- **Secondary**: LCSC, Arrow (backup suppliers)
- **Long-Term**: Ensure parts are not end-of-life

### Cost Optimization
- **Volume Discounts**: Order in larger quantities
- **Alternative Parts**: Consider pin-compatible alternatives
- **Package Consolidation**: Use multi-channel ICs where possible

