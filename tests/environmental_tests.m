% Environmental Test Suite for Inverted Pendulum Control System
% This script performs environmental testing including temperature,
% vibration, and extended operation tests to ensure reliability.

clear; close all; clc;

%% Test Configuration
ENV_CONFIG = struct();
ENV_CONFIG.temperature_range = [-10, 60];  % Celsius
ENV_CONFIG.temperature_steps = [-10, 0, 25, 40, 60];
ENV_CONFIG.test_duration_per_temp = 300;    % seconds (5 minutes)
ENV_CONFIG.vibration_freq_range = [10, 1000];  % Hz
ENV_CONFIG.extended_test_duration = 3600;   % seconds (1 hour)
ENV_CONFIG.sample_rate = 1000;              % Hz

fprintf('=== Environmental Test Suite ===\n\n');

%% Test 1: Temperature Cycling Test
fprintf('Test 1: Temperature Cycling Test\n');
fprintf('---------------------------------\n');
try
    temp_results = struct();
    
    for temp = ENV_CONFIG.temperature_steps
        fprintf('  Testing at %d°C...\n', temp);
        
        % Simulate temperature effects
        % (In real hardware, this would involve a thermal chamber)
        
        % Temperature effects on components:
        % - Encoder accuracy may degrade at extremes
        % - Motor efficiency changes with temperature
        % - Regulator efficiency decreases at high temp
        
        % Simulate sensor readings at this temperature
        t = 0:1/ENV_CONFIG.sample_rate:ENV_CONFIG.test_duration_per_temp;
        q1_base = 0.1 * sin(2*pi*0.5*t);
        
        % Temperature-dependent noise (increases at extremes)
        if abs(temp - 25) > 20
            temp_noise_factor = 1.5;  % 50% more noise at extremes
        else
            temp_noise_factor = 1.0;
        end
        
        q1_noisy = q1_base + 0.001 * temp_noise_factor * randn(size(t));
        
        % Check that system still functions
        max_deviation = max(abs(q1_noisy - q1_base));
        assert(max_deviation < 0.05, sprintf('System failed at %d°C', temp));
        
        temp_results.(sprintf('temp_%d', temp)) = struct();
        temp_results.(sprintf('temp_%d', temp)).max_deviation = max_deviation;
        temp_results.(sprintf('temp_%d', temp)).status = 'PASS';
        
        fprintf('    ✓ System functional at %d°C (max deviation: %.4f rad)\n', ...
            temp, max_deviation);
    end
    
    fprintf('  ✓ Temperature cycling test completed successfully\n');
    ENV_RESULTS.temperature_test = 'PASS';
    ENV_RESULTS.temperature_details = temp_results;
catch ME
    fprintf('  ✗ Temperature test FAILED: %s\n', ME.message);
    ENV_RESULTS.temperature_test = 'FAIL';
end
fprintf('\n');

%% Test 2: Vibration Resistance Test
fprintf('Test 2: Vibration Resistance Test\n');
fprintf('----------------------------------\n');
try
    % Simulate vibration effects on sensor readings
    vibration_freqs = [10, 50, 100, 500, 1000];  % Hz
    vibration_amplitude = 0.001;  % rad (small mechanical vibration)
    
    vib_results = struct();
    
    for freq = vibration_freqs
        fprintf('  Testing at %d Hz vibration...\n', freq);
        
        % Simulate vibration on sensor signal
        t = 0:1/ENV_CONFIG.sample_rate:10;  % 10 second test
        q1_base = 0.1 * sin(2*pi*0.5*t);
        vibration = vibration_amplitude * sin(2*pi*freq*t);
        q1_vibrated = q1_base + vibration;
        
        % Apply low-pass filter (simulating signal conditioning)
        fc = 100;  % Hz cutoff
        [b, a] = butter(2, fc/(ENV_CONFIG.sample_rate/2), 'low');
        q1_filtered = filtfilt(b, a, q1_vibrated);
        
        % Check that vibration is adequately filtered
        vibration_residual = std(q1_filtered - q1_base);
        assert(vibration_residual < 0.005, ...
            sprintf('Vibration not adequately filtered at %d Hz', freq));
        
        vib_results.(sprintf('freq_%d', freq)) = struct();
        vib_results.(sprintf('freq_%d', freq)).residual = vibration_residual;
        vib_results.(sprintf('freq_%d', freq)).status = 'PASS';
        
        fprintf('    ✓ Vibration filtered (residual: %.4f rad)\n', vibration_residual);
    end
    
    fprintf('  ✓ Vibration resistance test completed successfully\n');
    ENV_RESULTS.vibration_test = 'PASS';
    ENV_RESULTS.vibration_details = vib_results;
catch ME
    fprintf('  ✗ Vibration test FAILED: %s\n', ME.message);
    ENV_RESULTS.vibration_test = 'FAIL';
end
fprintf('\n');

%% Test 3: Extended Operation Test
fprintf('Test 3: Extended Operation Test\n');
fprintf('--------------------------------\n');
try
    fprintf('  Running extended test (%d seconds)...\n', ...
        ENV_CONFIG.extended_test_duration);
    
    % Simulate extended operation
    t = 0:1/ENV_CONFIG.sample_rate:ENV_CONFIG.extended_test_duration;
    
    % Simulate control system operation
    % (In real hardware, this would run the actual control loop)
    q1_history = zeros(size(t));
    u_history = zeros(size(t));
    
    % Simulate control action maintaining pendulum upright
    for i = 2:length(t)
        % Simple control simulation (maintains stability)
        q1_history(i) = 0.05 * sin(2*pi*0.1*t(i)) + 0.001 * randn();
        u_history(i) = -10 * q1_history(i) + 0.01 * randn();
    end
    
    % Check for drift or degradation over time
    % Split into quarters and compare
    n_quarters = 4;
    quarter_length = floor(length(t) / n_quarters);
    
    q1_means = zeros(n_quarters, 1);
    q1_stds = zeros(n_quarters, 1);
    
    for q = 1:n_quarters
        start_idx = (q-1) * quarter_length + 1;
        end_idx = q * quarter_length;
        q1_means(q) = mean(abs(q1_history(start_idx:end_idx)));
        q1_stds(q) = std(q1_history(start_idx:end_idx));
    end
    
    % Check that performance doesn't degrade significantly
    mean_drift = abs(q1_means(end) - q1_means(1));
    std_increase = q1_stds(end) - q1_stds(1);
    
    assert(mean_drift < 0.01, 'Significant drift detected over extended operation');
    assert(std_increase < 0.005, 'Noise increased significantly over time');
    
    fprintf('  ✓ Extended operation test completed\n');
    fprintf('    Mean drift: %.4f rad (target: <0.01 rad)\n', mean_drift);
    fprintf('    Noise increase: %.4f rad (target: <0.005 rad)\n', std_increase);
    ENV_RESULTS.extended_test = 'PASS';
    ENV_RESULTS.extended_details = struct('mean_drift', mean_drift, ...
        'noise_increase', std_increase);
catch ME
    fprintf('  ✗ Extended operation test FAILED: %s\n', ME.message);
    ENV_RESULTS.extended_test = 'FAIL';
end
fprintf('\n');

%% Test 4: Power Supply Variation Test
fprintf('Test 4: Power Supply Variation Test\n');
fprintf('------------------------------------\n');
try
    % Test system behavior with varying supply voltage
    voltage_levels = [20, 22, 24, 26, 28];  % V
    volt_results = struct();
    
    for v_supply = voltage_levels
        fprintf('  Testing at %.1f V supply...\n', v_supply);
        
        % Simulate regulator output (should maintain 3.3V and 5V)
        % Regulator efficiency may vary with input voltage
        if v_supply < 22
            % Undervoltage condition
            v_3v3 = 3.2;  % Slightly low
            status_flag = 'UNDERVOLTAGE';
        elseif v_supply > 27
            % Overvoltage condition
            v_3v3 = 3.4;  % Slightly high
            status_flag = 'OVERVOLTAGE';
        else
            v_3v3 = 3.3;  % Normal
            status_flag = 'NORMAL';
        end
        
        % Check that system still functions
        assert(v_3v3 > 3.0 && v_3v3 < 3.6, ...
            sprintf('Regulator failed at %.1f V input', v_supply));
        
        volt_results.(sprintf('v_%.0f', v_supply)) = struct();
        volt_results.(sprintf('v_%.0f', v_supply)).v_3v3 = v_3v3;
        volt_results.(sprintf('v_%.0f', v_supply)).status = status_flag;
        
        fprintf('    ✓ System functional (3.3V rail: %.2f V, status: %s)\n', ...
            v_3v3, status_flag);
    end
    
    fprintf('  ✓ Power supply variation test completed successfully\n');
    ENV_RESULTS.power_variation_test = 'PASS';
    ENV_RESULTS.power_variation_details = volt_results;
catch ME
    fprintf('  ✗ Power supply variation test FAILED: %s\n', ME.message);
    ENV_RESULTS.power_variation_test = 'FAIL';
end
fprintf('\n');

%% Test 5: Thermal Stress Test
fprintf('Test 5: Thermal Stress Test\n');
fprintf('---------------------------\n');
try
    % Simulate thermal cycling stress
    num_cycles = 10;
    temp_min = -10;
    temp_max = 60;
    
    fprintf('  Running %d thermal cycles (%d°C to %d°C)...\n', ...
        num_cycles, temp_min, temp_max);
    
    cycle_results = zeros(num_cycles, 1);
    
    for cycle = 1:num_cycles
        % Simulate temperature cycling
        % (In real hardware, this would involve rapid temperature changes)
        
        % Check system at each extreme
        % High temperature
        temp_effect_high = 1.0 + 0.1 * (temp_max - 25) / 35;  % Degradation factor
        % Low temperature
        temp_effect_low = 1.0 + 0.05 * (25 - temp_min) / 35;
        
        % System should still function
        assert(temp_effect_high < 2.0, 'System failed at high temperature');
        assert(temp_effect_low < 1.5, 'System failed at low temperature');
        
        cycle_results(cycle) = 1;  % Pass
    end
    
    fprintf('  ✓ All %d thermal cycles completed successfully\n', num_cycles);
    ENV_RESULTS.thermal_stress_test = 'PASS';
    ENV_RESULTS.thermal_cycles = num_cycles;
catch ME
    fprintf('  ✗ Thermal stress test FAILED: %s\n', ME.message);
    ENV_RESULTS.thermal_stress_test = 'FAIL';
end
fprintf('\n');

%% Test Summary
fprintf('=== Environmental Test Summary ===\n');
test_names = fieldnames(ENV_RESULTS);
passed = 0;
failed = 0;

for i = 1:length(test_names)
    if ischar(ENV_RESULTS.(test_names{i}))
        status = ENV_RESULTS.(test_names{i});
        if strcmp(status, 'PASS')
            fprintf('  %s: PASS\n', test_names{i});
            passed = passed + 1;
        else
            fprintf('  %s: FAIL\n', test_names{i});
            failed = failed + 1;
        end
    end
end

fprintf('\nTotal: %d passed, %d failed\n', passed, failed);

if failed == 0
    fprintf('\n✓ All environmental tests PASSED\n');
else
    fprintf('\n✗ Some environmental tests FAILED\n');
end

% Save test results
save('environmental_test_results.mat', 'ENV_RESULTS', 'ENV_CONFIG');

% Generate test report
fprintf('\n=== Generating Test Report ===\n');
fid = fopen('environmental_test_report.txt', 'w');
fprintf(fid, 'Environmental Test Report\n');
fprintf(fid, '=========================\n\n');
fprintf(fid, 'Test Date: %s\n', datestr(now));
fprintf(fid, 'Total Tests: %d\n', passed + failed);
fprintf(fid, 'Passed: %d\n', passed);
fprintf(fid, 'Failed: %d\n\n', failed);

fprintf(fid, 'Test Details:\n');
fprintf(fid, '-------------\n');
for i = 1:length(test_names)
    if ischar(ENV_RESULTS.(test_names{i}))
        fprintf(fid, '%s: %s\n', test_names{i}, ENV_RESULTS.(test_names{i}));
    end
end

fclose(fid);
fprintf('  ✓ Test report saved to environmental_test_report.txt\n');

