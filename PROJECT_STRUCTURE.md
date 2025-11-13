# Project Structure

This document describes the organization and naming conventions used in the Inverted Pendulum Control System project.

## Directory Structure

```
Upright-Pendulum-main/
├── README.md                    # Main project documentation
├── LICENSE                      # MIT License
├── PROJECT_STRUCTURE.md         # This file
├── .gitignore                   # Git ignore rules
│
├── model1.slx                  # Simulink control model (original)
├── model1.1.slx                # Simulink control model (updated)
│
├── script_phase.m               # Controller and observer design script
├── actual_graph.m               # Hardware data visualization script
│
├── qm_actual-15.mat            # Hardware test data (15× observer, angles)
├── qm_actual-20.mat            # Hardware test data (20× observer, angles)
├── um_actual-15.mat            # Hardware test data (15× observer, input)
├── um_actual-20.mat            # Hardware test data (20× observer, input)
│
├── hardware/
│   ├── circuits/
│   │   ├── sensor_interface.md      # Encoder circuit design
│   │   ├── actuator_drive.md        # Motor driver circuits
│   │   ├── power_management.md      # Power supply design
│   │   └── signal_processing.md     # Signal conditioning circuits
│   └── pcb/
│       ├── design_workflow.md        # PCB design process
│       └── component_selection.md    # Component analysis and selection
│
└── tests/
    ├── README.md                    # Test documentation
    ├── functional_tests.m           # Functional validation suite
    └── environmental_tests.m         # Environmental testing suite
```

## File Naming Conventions

### MATLAB Scripts
- **Lowercase with underscores**: `script_phase.m`, `actual_graph.m`
- **Descriptive names**: Clearly indicate file purpose
- **No spaces**: Use underscores for readability

### Simulink Models
- **Lowercase with version numbers**: `model1.slx`, `model1.1.slx`
- **Incremental versioning**: Use decimal numbers for updates

### Data Files
- **Descriptive prefixes**: `qm_` for measured angles, `um_` for input voltages
- **Suffixes indicate conditions**: `-15`, `-20` for observer pole scaling factors
- **Format**: `.mat` for MATLAB data files

### Documentation Files
- **Lowercase with underscores**: `sensor_interface.md`
- **Descriptive names**: Clearly indicate content
- **Format**: `.md` for Markdown files

## Data File Conventions

### Hardware Test Data
- `qm_actual-{scaling}.mat`: Measured joint angles (q1, q2)
  - Contains: `qm_actual.signals.values`, `qm_actual.time`
- `um_actual-{scaling}.mat`: Applied motor input voltages
  - Contains: `um` (input voltage data)

### Parameter Files
- `ph_device_05.mat`: System identification parameters
  - Contains: `Ph` vector with physical parameters

## Script Dependencies

### script_phase.m
- **Requires**: `ph_device_05.mat` (system parameters)
- **Generates**: Controller gain `K`, observer gain `L`
- **Outputs**: Simulation plots, gain matrices

### actual_graph.m
- **Requires**: `qm_actual-{scaling}.mat`, `um_actual-{scaling}.mat`
- **Configurable**: `pole_scaler` variable (default: 16.39)
- **Outputs**: Hardware test result plots

### Test Scripts
- **functional_tests.m**: Self-contained, uses simulated data
- **environmental_tests.m**: Self-contained, uses simulated data
- **Both**: Generate test reports and result files

## Hardware Documentation Structure

### Circuits (`hardware/circuits/`)
Each circuit document follows a consistent structure:
1. Overview
2. Specifications
3. Circuit Design
4. Component Selection
5. PCB Layout Considerations
6. Performance Specifications

### PCB Design (`hardware/pcb/`)
- **design_workflow.md**: Complete design process
- **component_selection.md**: Detailed component analysis

## Testing Structure

### Test Organization
- **Functional Tests**: Component-level validation
- **Environmental Tests**: System-level reliability testing
- **Test Results**: Saved as `.mat` files and text reports

## Version Control

### Git Ignore Rules
- MATLAB temporary files (`.asv`, `.autosave`)
- Generated images (`.png`, `.fig`)
- Build artifacts (`.mex*`)
- Test result files (`*_test_results.mat`)

### Recommended Practices
- Commit source files (`.m`, `.slx`, `.md`)
- Commit data files (`.mat`) if small (<10MB)
- Use descriptive commit messages
- Tag releases with version numbers

