# Test Infrastructure

This directory contains comprehensive test suites for validating the inverted pendulum control system, including functional tests, environmental tests, and performance validation.

## Test Suites

### Functional Tests (`functional_tests.m`)

Comprehensive functional testing of all system components:

1. **Sensor Reading Test**: Validates encoder accuracy and noise levels
2. **Actuator Response Test**: Verifies motor response time and current characteristics
3. **Control Loop Stability Test**: Ensures closed-loop system stability and damping
4. **Observer Performance Test**: Validates state observer design and convergence
5. **Signal Processing Test**: Tests ADC resolution and filter performance
6. **Power Management Test**: Verifies voltage regulation and power sequencing

**Usage**:
```matlab
run('tests/functional_tests.m')
```

**Output**: 
- Console output with test results
- `functional_test_results.mat` with detailed test data

### Environmental Tests (`environmental_tests.m`)

Environmental and reliability testing:

1. **Temperature Cycling Test**: System operation across temperature range (-10°C to 60°C)
2. **Vibration Resistance Test**: System performance under mechanical vibration (10-1000 Hz)
3. **Extended Operation Test**: Long-duration stability test (1 hour continuous operation)
4. **Power Supply Variation Test**: System behavior with varying input voltage (20-28V)
5. **Thermal Stress Test**: Rapid thermal cycling stress test (10 cycles)

**Usage**:
```matlab
run('tests/environmental_tests.m')
```

**Output**:
- Console output with test results
- `environmental_test_results.mat` with detailed test data
- `environmental_test_report.txt` text report

## Test Configuration

Both test suites use configurable parameters that can be adjusted in the scripts:

- **Sample Rate**: 1000 Hz (matches control loop)
- **Test Duration**: Varies by test (typically 5-60 minutes)
- **Tolerance Levels**: Configurable thresholds for pass/fail criteria

## Running Tests

### Individual Test Suites
```matlab
% Run functional tests
cd tests
functional_tests

% Run environmental tests
environmental_tests
```

### Batch Testing
Create a master test script to run all tests sequentially:

```matlab
% Run all tests
run_all_tests
```

## Test Results Interpretation

### Functional Tests
- **PASS**: Component meets all specifications
- **FAIL**: Component does not meet specifications (check error messages)

### Environmental Tests
- **PASS**: System operates correctly under environmental conditions
- **FAIL**: System degraded or failed under stress (check details)

## Integration with Hardware

These test scripts are designed to work with both simulation and hardware:

1. **Simulation Mode**: Uses simulated sensor data and system models
2. **Hardware Mode**: Interfaces with actual hardware via data acquisition

To enable hardware testing, modify the data acquisition sections to interface with your hardware (e.g., via serial port, SPI, or data acquisition card).

## Continuous Integration

These tests can be integrated into a CI/CD pipeline:

```bash
# Example: Run tests in MATLAB and check exit code
matlab -batch "run('tests/functional_tests.m'); exit(max([0, sum(contains(struct2cell(TEST_RESULTS), 'FAIL'))]))"
```

## Test Coverage

### Hardware Components Tested
- ✅ Sensors (encoders)
- ✅ Actuators (DC motor)
- ✅ Power management circuits
- ✅ Signal processing circuits
- ✅ Control algorithms
- ✅ State observer

### Environmental Conditions Tested
- ✅ Temperature extremes
- ✅ Vibration
- ✅ Extended operation
- ✅ Power supply variations
- ✅ Thermal cycling

## Future Enhancements

Potential additions to the test infrastructure:

1. **Automated Test Execution**: Script to run all tests and generate reports
2. **Hardware-in-the-Loop Testing**: Direct hardware interface for real-time testing
3. **Performance Benchmarking**: Quantitative performance metrics and comparisons
4. **Regression Testing**: Compare results across system revisions
5. **Visualization Tools**: Plot test results and generate graphs

## Notes

- Tests use simulated data when hardware is not available
- Modify test parameters based on your specific hardware specifications
- Some tests require extended runtime (e.g., 1-hour extended operation test)
- Ensure MATLAB toolboxes are available (Signal Processing Toolbox for filters)

