# 🎯 Inverted Pendulum Control System

> **Imagine balancing a stick on your finger.** Now imagine doing it automatically with a robot. This project does exactly that—using advanced control theory, custom electronics, and real-time software to keep an inverted pendulum perfectly balanced.

---

## 🎬 See It In Action

<div align="center">
  
https://github.com/user-attachments/assets/7126a784-6d52-4681-a8f2-ded9851cf9db
  
</div>

---

## 🧠 What's the Big Idea? (Simple Explanation)

Think of balancing a broomstick on your palm. You can see where the stick is (the angle), but you can't directly feel how fast it's moving. Yet your brain somehow figures it out and moves your hand to keep it balanced.

**This project replicates that process:**

1. **Sensors** measure the pendulum's angle (like your eyes seeing the stick)
2. **A "smart guesser"** (called an observer) figures out how fast it's moving (like your brain estimating speed)
3. **A controller** calculates the right motor command to keep it balanced (like your hand moving)
4. **Custom circuits** translate these commands into actual motor movements

The magic happens 1000 times per second—fast enough that the pendulum never falls!

---

## 🎯 What This Project Includes

This is a **complete mechatronics system** combining:

- ✅ **Control Theory**: State-feedback control with full-state observer
- ✅ **Hardware Design**: Custom analogue and digital circuits for sensors and actuators
- ✅ **Power Management**: Efficient power supplies and protection circuits
- ✅ **Signal Processing**: Filtering and conditioning for clean sensor data
- ✅ **PCB Design**: Complete printed circuit board design workflow
- ✅ **Testing Infrastructure**: Comprehensive functional and environmental tests

---

## 🖼️ How It Works (Visual)

<div align="center">
  <img width="489" height="387" alt="Inverted pendulum schematic" src="https://github.com/user-attachments/assets/f4cb9196-2bcc-4371-b61f-13483633afde" />
  <br/>
  <sub><b>Mechanism Overview.</b> A rotary base (joint 1) moves the pendulum link (joint 2). Sensors measure angles; the controller estimates velocities and commands the motor.</sub>
</div>

---

## 🔧 System Architecture

### The Control Problem

The pendulum has **two joints**:
- **Joint 1** (base): Can rotate horizontally
- **Joint 2** (pendulum): The link that needs to stay upright

We can **measure** the angles ($q_1$, $q_2$), but we **can't directly measure** how fast they're changing ($\dot{q}_1$, $\dot{q}_2$). However, the controller needs all four values to work properly.

### The Solution: Observer-Based Control

Instead of measuring everything, we:

1. **Predict** what the velocities should be (using a mathematical model)
2. **Compare** our predictions to the actual measured angles
3. **Correct** our predictions based on the difference
4. **Control** the motor using these corrected estimates

This happens continuously in a feedback loop running at **1 kHz** (1000 times per second).

---

## 🛠️ Hardware Implementation

### Sensor Interface Circuits

**Encoders** measure joint angles with high precision:
- **Type**: Incremental optical encoders (2048 pulses/revolution)
- **Interface**: Quadrature decoding via LS7366R ICs
- **Signal Conditioning**: Noise filtering and level shifting
- **Communication**: SPI interface to microcontroller

📄 **Details**: See [`hardware/circuits/sensor_interface.md`](hardware/circuits/sensor_interface.md)

### Actuator Drive Circuits

**DC Motor** drives the base to balance the pendulum:
- **Power**: 24V DC, 2A continuous (5A peak)
- **Driver**: DRV8871 H-bridge with integrated current sensing
- **Control**: 20 kHz PWM for smooth operation
- **Protection**: Overcurrent and thermal shutdown

📄 **Details**: See [`hardware/circuits/actuator_drive.md`](hardware/circuits/actuator_drive.md)

### Power Management

**Efficient power distribution** for all subsystems:
- **24V Input**: Main power supply (wall adapter or battery)
- **3.3V Regulator**: For microcontroller and digital logic (85% efficiency)
- **5V Regulator**: For encoder power (88% efficiency)
- **Protection**: Overvoltage, undervoltage, and overcurrent protection

📄 **Details**: See [`hardware/circuits/power_management.md`](hardware/circuits/power_management.md)

### Signal Processing

**Clean, accurate sensor data** through:
- **Anti-aliasing Filters**: Remove high-frequency noise before ADC
- **Current Sensing**: Precise motor current measurement (1.2 mA resolution)
- **Voltage Monitoring**: System voltage tracking for diagnostics
- **Digital Filtering**: Software filters for angle rate estimation

📄 **Details**: See [`hardware/circuits/signal_processing.md`](hardware/circuits/signal_processing.md)

### PCB Design

**Complete printed circuit board** design:
- **4-Layer Stackup**: Signal, ground, power planes
- **Component Selection**: Detailed analysis and alternatives
- **Layout Guidelines**: Thermal management, EMI reduction
- **Manufacturing**: Gerber files, BOM, assembly notes

📄 **Details**: 
- [`hardware/pcb/design_workflow.md`](hardware/pcb/design_workflow.md)
- [`hardware/pcb/component_selection.md`](hardware/pcb/component_selection.md)

---

## 🧪 Testing Infrastructure

### Functional Tests

Comprehensive validation of all system components:
- ✅ Sensor accuracy and noise levels
- ✅ Actuator response time and characteristics
- ✅ Control loop stability
- ✅ Observer performance
- ✅ Signal processing accuracy
- ✅ Power management

📄 **Details**: See [`tests/functional_tests.m`](tests/functional_tests.m)

### Environmental Tests

Reliability testing under various conditions:
- 🌡️ **Temperature**: Operation from -10°C to 60°C
- 📳 **Vibration**: Resistance to 10-1000 Hz mechanical vibration
- ⏱️ **Extended Operation**: 1-hour continuous operation test
- ⚡ **Power Variation**: Behavior with 20-28V input voltage
- 🔄 **Thermal Cycling**: Rapid temperature change stress test

📄 **Details**: See [`tests/environmental_tests.m`](tests/environmental_tests.m)

**Run Tests**:
```matlab
% Functional tests
run('tests/functional_tests.m')

% Environmental tests
run('tests/environmental_tests.m')
```

---

## 📊 Results

### Simulink Model

<div align="center">
  <img width="1364" height="598" alt="Simulink output-feedback model" src="https://github.com/user-attachments/assets/3a961c7f-32f5-4fa5-b72f-3da6a6880622" />
  <br/>
  <sub><b>Control System Implementation.</b> Observer estimates unmeasured states; controller applies state-feedback using estimates.</sub>
</div>

### Hardware Performance

After tuning the observer speed:
- **20× scaling**: System stabilized but showed oscillation
- **15× scaling**: Smooth behavior with minimal control effort

<div align="center">
  <img width="792" height="625" alt="Angles and input with 15x observer" src="https://github.com/user-attachments/assets/b8629492-9a30-47a2-9251-c27f8793486b" />
  <br/>
  <sub><b>Hardware Results.</b> Joint angles (top) and motor voltage (bottom) with observer poles at 15× the controller poles.</sub>
</div>

---

## 🧮 The Mathematics (Technical Deep Dive)

### System Model

The pendulum dynamics are linearized about the upright position:

$$
\dot{x} = A x + B u, \qquad y = C x
$$

where the state vector is:

$$
x = \begin{bmatrix} q_1 & q_2 & \dot{q}_1 & \dot{q}_2 \end{bmatrix}^\top
$$

and only angles are measured:

$$
y = \begin{bmatrix} q_1 & q_2 \end{bmatrix}^\top
$$

### State-Feedback Control

If all states were available, the control law would be:

$$
u = -K x \quad \Rightarrow \quad \dot{x} = (A - B K) x
$$

The gain matrix $K$ is designed via **pole placement** to achieve desired closed-loop eigenvalues:

$$
\lambda_{desired} = \{-10 \pm 10j,\ -15,\ -18\}
$$

These poles provide:
- **Fast response** (real parts around -10 to -18)
- **Good damping** (complex poles with damping ratio ~0.707)
- **Stability** (all poles in left half-plane)

### Full-State Observer

Since velocities are not measured, we use an observer:

$$
\dot{\hat{x}} = A \hat{x} + B u + L(y - C \hat{x})
$$

The correction term $L(y - C\hat{x})$ drives the estimate toward the true state. The observer gain $L$ is designed so that $(A - LC)$ has eigenvalues **15× faster** than the controller poles, ensuring rapid convergence.

### Estimation Error Dynamics

The estimation error $\tilde{x} = x - \hat{x}$ evolves as:

$$
\dot{\tilde{x}} = (A - L C) \tilde{x}
$$

By making $(A - LC)$ stable with fast eigenvalues, the error decays quickly, so $\hat{x} \approx x$ during operation.

### Output-Feedback Control

The actual control law uses the state estimate:

$$
u = -K \hat{x}
$$

The **separation principle** guarantees that if both $(A - BK)$ and $(A - LC)$ are stable, the combined system is stable.

---

## 💻 Implementation Details

### Software

1. **System Identification**: Linearize pendulum model and identify parameters
2. **Controller Design**: Compute $K$ via pole placement
3. **Observer Design**: Compute $L$ with poles 15× faster than controller
4. **Simulink Model**: Implement observer and controller blocks
5. **Real-Time Execution**: Run at 1 kHz on STM32F4 microcontroller

### Hardware

1. **Sensors**: Optical encoders with quadrature decoding
2. **Actuator**: 24V DC motor with H-bridge driver
3. **Processing**: STM32F407VGT6 microcontroller (ARM Cortex-M4)
4. **Power**: Multi-rail power supply with protection circuits
5. **PCB**: Custom 4-layer board with optimized layout

---

## 📁 Project Structure

```
Upright-Pendulum-main/
├── README.md                    # This file
├── LICENSE                      # MIT License
│
├── model1.slx                  # Simulink control model
├── model1.1.slx                # Updated Simulink model
│
├── script_phase.m               # Controller and observer design
├── actual_graph.m               # Hardware data visualization
│
├── *.mat                        # Hardware test data files
│
├── hardware/
│   ├── circuits/
│   │   ├── sensor_interface.md      # Encoder circuit design
│   │   ├── actuator_drive.md        # Motor driver circuits
│   │   ├── power_management.md     # Power supply design
│   │   └── signal_processing.md     # Signal conditioning
│   └── pcb/
│       ├── design_workflow.md       # PCB design process
│       └── component_selection.md   # Component analysis
│
└── tests/
    ├── README.md                    # Test documentation
    ├── functional_tests.m           # Functional validation
    └── environmental_tests.m         # Environmental testing
```

---

## 🚀 Getting Started

### Prerequisites

- **MATLAB** (R2018b or later) with:
  - Control System Toolbox
  - Simulink
  - Signal Processing Toolbox (for tests)
- **Hardware** (optional, for physical implementation):
  - Inverted pendulum rig
  - STM32F4 development board or custom PCB
  - Encoders, motor, power supply

### Running the Code

1. **Design Controller and Observer**:
   ```matlab
   run('script_phase.m')
   ```

2. **Simulate in Simulink**:
   - Open `model1.slx` or `model1.1.slx`
   - Run simulation
   - Analyze results

3. **Visualize Hardware Data**:
   ```matlab
   run('actual_graph.m')
   ```

4. **Run Tests**:
   ```matlab
   run('tests/functional_tests.m')
   run('tests/environmental_tests.m')
   ```

---

## 📌 Key Design Decisions

### Observer Speed vs. Noise

- **Faster observers** track better but amplify sensor noise
- **Slower observers** are more robust but lag behind
- **Sweet spot**: Observer poles ~15× faster than controller poles

### Actuator Limits

- Motor voltage limited to ±24V
- Unmodeled friction affects performance
- Current limiting protects hardware

### Signal Processing

- **1 kHz sampling rate**: Matches control loop frequency
- **Anti-aliasing filters**: Prevent high-frequency noise aliasing
- **Digital filters**: Smooth angle rate estimates

---

## 🎓 Learning Resources

### Control Theory Concepts

- **State-Space Representation**: Modern control theory foundation
- **Pole Placement**: Direct eigenvalue assignment method
- **Observers**: State estimation from partial measurements
- **Separation Principle**: Independent controller/observer design

### Hardware Design Concepts

- **Sensor Interfaces**: Encoder decoding, signal conditioning
- **Motor Control**: PWM, H-bridge drivers, current sensing
- **Power Management**: Voltage regulation, protection circuits
- **PCB Design**: Layout, thermal management, EMI reduction

---

## 🧠 Glossary

**State Feedback** — Control law $u = -Kx$ using full state vector  
**Full-State Observer** — Estimator $\dot{\hat{x}} = A\hat{x} + Bu + L(y - C\hat{x})$ that reconstructs unmeasured states  
**Pole Placement** — Design method choosing eigenvalues of $(A-BK)$ or $(A-LC)$ to shape system dynamics  
**Separation Principle** — Allows independent design of controller ($K$) and observer ($L$); stability of both implies closed-loop stability  
**Quadrature Decoder** — Circuit that converts encoder A/B signals into position counts  
**H-Bridge** — Motor driver circuit allowing bidirectional current flow  
**PWM** — Pulse-width modulation for efficient motor control  

---

## 📄 License

MIT License — see [`LICENSE`](LICENSE) file for details.

---

## 🙏 Acknowledgments

This project demonstrates the integration of:
- Control systems theory
- Embedded systems design
- Analog and digital circuit design
- PCB layout and manufacturing
- System testing and validation

A complete mechatronics system from theory to hardware! 🎯
