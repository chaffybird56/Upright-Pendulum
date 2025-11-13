# PCB Design Workflow and Component Selection

## Overview
This document outlines the complete PCB design workflow for the inverted pendulum control system, including component selection criteria, schematic design, layout guidelines, and manufacturing considerations.

## Design Workflow

### Phase 1: Requirements Analysis
1. **Functional Requirements**
   - Control loop: 1 kHz update rate
   - Sensor interfaces: 2x quadrature encoders
   - Actuator: 24V DC motor, 2A continuous
   - Communication: SPI, UART (for debugging)

2. **Performance Requirements**
   - Power: 24V @ 5A peak
   - Signal integrity: <1% error on sensor readings
   - EMI: Pass FCC Class B (if applicable)
   - Temperature: -10°C to +60°C operating range

3. **Physical Constraints**
   - Board size: 100mm × 80mm (4-layer)
   - Mounting: 4x M3 mounting holes
   - Connectors: Standard headers for sensors/actuator

### Phase 2: Component Selection

#### Selection Criteria
1. **Performance**: Meets or exceeds specifications
2. **Availability**: In-stock, multiple suppliers
3. **Cost**: Balance between performance and budget
4. **Package**: Suitable for PCB assembly (prefer surface-mount)
5. **Reliability**: Industrial/commercial temperature range

#### Component Selection Matrix

| Component Category | Selected Part | Rationale | Alternatives Considered |
|-------------------|---------------|-----------|------------------------|
| **MCU** | STM32F407VGT6 | ARM Cortex-M4, FPU, 168 MHz, 1MB Flash | STM32F303, ATmega2560 |
| **Motor Driver** | DRV8871DDAR | 3.6A peak, integrated current sense | L298N, BTS7960 |
| **Quadrature Decoder** | LS7366R-S | 32-bit counter, SPI interface | HCTL-2021, MCU software decode |
| **3.3V Regulator** | LM2596S-3.3 | 3A, 85% efficiency, TO-263 | AMS1117-3.3, TPS62133 |
| **5V Regulator** | LM2596S-5.0 | 3A, matched to 3.3V regulator | LM2596S-5.0 (selected) |
| **Current Sense Amp** | INA199A1 | 50 V/V gain, 10 kHz BW | INA219, ACS712 |
| **Schmitt Trigger** | 74HC14 | Hex inverter, hysteresis | 74LVC14, 74AHC14 |
| **Op-Amp** | MCP6002 | Rail-to-rail, 3.3V supply | LM358, TL072 |
| **TVS Diode** | SMBJ24A | 24V protection, 600W peak | P6KE24A, SMAJ24A |

#### Component Sourcing
- **Primary Supplier**: Digi-Key, Mouser
- **Backup Suppliers**: LCSC, Arrow
- **BOM Cost Target**: <$50 per board (excluding connectors/cables)

### Phase 3: Schematic Design

#### Schematic Organization
1. **Power Section**: Input protection, regulators, power sequencing
2. **MCU Section**: STM32F4, crystal, reset circuit, programming header
3. **Sensor Interface**: Encoder circuits, signal conditioning
4. **Actuator Interface**: Motor driver, current sensing
5. **Communication**: SPI, UART headers, debug interface

#### Design Rules
- **Net Classes**: Power (24V, 5V, 3.3V), Signal, Ground
- **Component Naming**: U1-U99 (ICs), R1-R999 (resistors), C1-C999 (capacitors)
- **Reference Designators**: Follow standard conventions
- **Annotations**: Add notes for critical circuits

#### Critical Circuits
1. **Power Sequencing**: Ensure MCU boots before motor enable
2. **Current Sensing**: High-precision resistors, Kelvin connections
3. **Encoder Interface**: Noise filtering, proper termination
4. **Motor Driver**: Bootstrap circuit, dead-time generation

### Phase 4: PCB Layout

#### Stackup (4-Layer)
```
Layer 1: Signal (top) + components
Layer 2: Ground plane
Layer 3: Power planes (24V, 5V, 3.3V)
Layer 4: Signal (bottom) + components
```

#### Layout Guidelines

**Power Distribution**:
- Wide traces for high current (≥50 mils for motor current)
- Multiple vias for power planes (reduce resistance)
- Decoupling capacitors close to ICs (≤5mm)

**Signal Routing**:
- Differential pairs for SPI (100Ω impedance)
- Keep encoder signals away from motor drive
- Minimize trace lengths for high-speed signals

**Grounding**:
- Separate analog and digital grounds
- Single-point connection near ADC
- Ground plane under all sensitive circuits

**Thermal Management**:
- Large copper pours for heat dissipation
- Thermal vias under power components
- Heatsinks on motor driver and regulators

**EMI Reduction**:
- Ground plane under switching regulators
- Filtering on all power inputs
- Shielding around sensitive analog circuits

#### Component Placement Strategy
1. **Power Section**: Top-left corner (near input connector)
2. **MCU**: Center of board (minimize trace lengths)
3. **Sensor Interface**: Right side (near encoder connectors)
4. **Actuator Interface**: Bottom (near motor connector)
5. **Regulators**: Distributed near loads

### Phase 5: Design Review

#### Checklist
- [ ] All power rails have proper decoupling
- [ ] Current paths can handle peak currents
- [ ] Signal integrity: impedance matching, termination
- [ ] Thermal: Power dissipation within limits
- [ ] EMI: Switching nodes isolated from sensitive signals
- [ ] Manufacturing: Component spacing, via sizes, drill holes
- [ ] Testability: Test points for critical signals

#### Simulation (if available)
- **Power Integrity**: IR drop analysis
- **Signal Integrity**: Crosstalk, reflections
- **Thermal**: Temperature distribution
- **EMI**: Radiated emissions estimation

### Phase 6: Manufacturing Preparation

#### Gerber Files
- **Layers**: Top, Bottom, Inner1 (GND), Inner2 (Power), Solder Mask, Silkscreen
- **Drill Files**: Through-hole and via drills
- **Pick-and-Place**: Component placement file
- **BOM**: Bill of Materials with part numbers

#### Assembly Notes
- **SMT Assembly**: Reflow profile, component orientation
- **Through-Hole**: Manual assembly for connectors
- **Testing**: In-circuit test points, programming headers

#### Design for Manufacturing (DFM)
- **Minimum Trace Width**: 6 mils (standard PCB)
- **Minimum Via Size**: 8 mil drill, 16 mil pad
- **Component Spacing**: ≥10 mils between components
- **Solder Mask**: 4 mil clearance around pads

### Phase 7: Prototyping and Testing

#### Prototype Build
1. **Order PCBs**: 3-5 boards for initial testing
2. **Component Procurement**: Order BOM with 10% overage
3. **Assembly**: SMT assembly service or manual
4. **Inspection**: Visual inspection, continuity testing

#### Hardware Testing
1. **Power-Up**: Verify all voltages correct
2. **MCU Programming**: Flash test firmware
3. **Sensor Testing**: Verify encoder readings
4. **Actuator Testing**: Motor drive functionality
5. **Integration**: Full system test

#### Iteration
- **Rev 1.0**: Initial prototype
- **Rev 1.1**: Fix critical issues
- **Rev 2.0**: Production-ready design

## Component Selection Deep Dive

### MCU Selection: STM32F407VGT6
**Why This Part**:
- ARM Cortex-M4 with FPU (fast math for control algorithms)
- 168 MHz clock (sufficient for 1 kHz control loop)
- Multiple SPI peripherals (for encoders)
- High-resolution timers (for PWM generation)
- Rich peripheral set (ADC, UART, etc.)
- Good documentation and community support

**Alternatives**:
- **STM32F303**: Lower cost, but less performance
- **ATmega2560**: 8-bit, insufficient for complex control

### Motor Driver Selection: DRV8871
**Why This Part**:
- Integrated H-bridge (reduces component count)
- Built-in current sensing (simplifies design)
- Overcurrent and thermal protection
- Suitable current rating (3.6A peak)

**Alternatives**:
- **L298N**: Older, less efficient, external current sense needed
- **BTS7960**: Higher current, but more complex

### Regulator Selection: LM2596S Series
**Why This Part**:
- Switching regulator (high efficiency)
- Adequate current rating (3A)
- Simple external circuit
- Low cost, widely available

**Alternatives**:
- **AMS1117**: LDO, lower efficiency at high current
- **TPS62133**: More efficient, but higher cost

## PCB Design Tools

### Recommended Tools
- **Schematic/PCB**: KiCad (free, open-source) or Altium Designer
- **Simulation**: LTSpice (free) for circuit simulation
- **3D View**: KiCad 3D viewer or Altium 3D
- **DFM Check**: Online DFM tools (JLCPCB, PCBWay)

### Design Files Structure
```
pcb/
├── schematics/
│   ├── power_supply.sch
│   ├── mcu.sch
│   ├── sensors.sch
│   └── actuator.sch
├── layout/
│   ├── board.kicad_pcb
│   └── 3d_models/
├── manufacturing/
│   ├── gerbers/
│   ├── drill_files/
│   └── bom.csv
└── documentation/
    ├── design_workflow.md (this file)
    └── assembly_notes.md
```

## Cost Optimization

### Design Choices for Cost Reduction
1. **4-Layer PCB**: Necessary for signal integrity, but increases cost
2. **Component Selection**: Balance performance vs. cost
3. **Assembly**: SMT assembly reduces labor cost
4. **Volume**: Higher volume reduces per-unit cost

### Estimated Costs (per board)
- **PCB Fabrication**: $10-20 (4-layer, 10 boards)
- **Components**: $30-40 (BOM)
- **Assembly**: $15-25 (SMT assembly service)
- **Total**: $55-85 per assembled board

## Future Improvements

### Potential Enhancements
1. **Wireless Communication**: Add Bluetooth/WiFi module
2. **Data Logging**: SD card interface
3. **Display**: OLED screen for status display
4. **Additional Sensors**: IMU for absolute angle reference
5. **Modular Design**: Separate control board and power board

