# Missing Files Note

## Required but Not Included

The following file is referenced in the code but is not included in this repository:

- **`ph_device_05.mat`**: System identification parameters file
  - **Referenced in**: 
    - `script_phase.m` (line 3)
    - `tests/functional_tests.m` (line 96)
  - **Contains**: `Ph` vector with physical parameters for the pendulum system
  - **Note**: This file contains device-specific calibration data and should be generated through system identification or provided separately

## Data Files Included

The following hardware test data files are included:
- `qm_actual-15.mat` - Measured angles with 15× observer scaling
- `qm_actual-20.mat` - Measured angles with 20× observer scaling  
- `um_actual-15.mat` - Input voltages with 15× observer scaling
- `um_actual-20.mat` - Input voltages with 20× observer scaling

## Usage

To run `script_phase.m` or the functional tests, you will need to:
1. Perform system identification to generate `ph_device_05.mat`, OR
2. Use your own parameter file and update the load statements accordingly

