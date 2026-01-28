%% Control System Design Tools
clear; close all; clc;

load("data/ph_device_05.mat")

q20 = pi;
M = [Ph(1)  Ph(6)*cos(q20);
     Ph(6)*cos(q20)  Ph(2)];

F = [Ph(3)  0;
     0      Ph(4)];

K = [0  0;
     0  Ph(5)*cos(q20)];

T1 = [1; 0];

A = [zeros(2,2)  eye(2);
     -M\K       -M\F];

B = [zeros(2,1);
     M\T1];

C = [1 0 0 0;
     0 1 0 0];

D = [0; 0];

sys_ol = ss(A, B, C, D);
sys_siso = ss(A, B, C(1,:), 0);

fprintf('=== Control System Design Tools ===\n\n');

%% 1. PID Tuning Methods
fprintf('1. PID TUNING METHODS\n');
fprintf('====================\n\n');

sys_tf = tf(sys_siso);
[num, den] = tfdata(sys_tf, 'v');
[step_response, t_step] = step(sys_siso, 5);

K_ss = dcgain(sys_siso);
final_value = step_response(end);
target_value = 0.632 * final_value;
idx_63 = find(step_response >= target_value, 1);
if isempty(idx_63)
    idx_63 = length(step_response);
end
tau = t_step(idx_63);

idx_first = find(step_response > 0.01 * final_value, 1);
if isempty(idx_first)
    L = 0.1;
else
    L = t_step(idx_first);
end

fprintf('Process Parameters:\n');
fprintf('  Steady-state gain (K): %.4f\n', K_ss);
fprintf('  Time constant (tau): %.4f s\n', tau);
fprintf('  Dead time (L): %.4f s\n\n', L);

%% Ziegler-Nichols Tuning
fprintf('Ziegler-Nichols Tuning (Ultimate Gain Method):\n');
fprintf('-----------------------------------------------\n');

[mag, phase, w] = bode(sys_siso);
mag_db = 20*log10(squeeze(mag));
phase_deg = squeeze(phase);
idx_180 = find(phase_deg <= -180, 1);

if ~isempty(idx_180)
    w_u = w(idx_180);
    K_u = 1 / (10^(mag_db(idx_180)/20));
    P_u = 2*pi / w_u;
    
    fprintf('  Ultimate gain (Ku): %.4f\n', K_u);
    fprintf('  Ultimate period (Pu): %.4f s\n', P_u);
    
    Kp_zn = 0.6 * K_u;
    Ti_zn = 0.5 * P_u;
    Td_zn = 0.125 * P_u;
    
    fprintf('\n  Ziegler-Nichols PID Parameters:\n');
    fprintf('    Kp = %.4f\n', Kp_zn);
    fprintf('    Ti = %.4f s\n', Ti_zn);
    fprintf('    Td = %.4f s\n', Td_zn);
else
    fprintf('  Could not find ultimate gain (system may be too stable)\n');
    Kp_zn = 0; Ti_zn = 0; Td_zn = 0;
end

%% Cohen-Coon Tuning
fprintf('\nCohen-Coon Tuning:\n');
fprintf('------------------\n');

if L > 0 && tau > 0
    Kp_cc = (1/K_ss) * (tau/L) * (1.33 + 0.25*(L/tau));
    Ti_cc = L * (32 + 6*(L/tau)) / (13 + 8*(L/tau));
    Td_cc = L * 4 / (11 + 2*(L/tau));
    
    fprintf('  Cohen-Coon PID Parameters:\n');
    fprintf('    Kp = %.4f\n', Kp_cc);
    fprintf('    Ti = %.4f s\n', Ti_cc);
    fprintf('    Td = %.4f s\n', Td_cc);
else
    fprintf('  Invalid process parameters for Cohen-Coon\n');
    Kp_cc = 0; Ti_cc = 0; Td_cc = 0;
end

%% 2. Root Locus Analysis
fprintf('\n\n2. ROOT LOCUS ANALYSIS\n');
fprintf('======================\n\n');

s = tf('s');
if Kp_zn > 0
    Kp = Kp_zn;
    Ti = Ti_zn;
    Td = Td_zn;
else
    Kp = 10;
    Ti = 0.5;
    Td = 0.1;
end

Ki = Kp / Ti;
Kd = Kp * Td;
pid_controller = Kp + Ki/s + Kd*s;
sys_cl = feedback(pid_controller * sys_siso, 1);

figure('Position', [100, 100, 1200, 800]);

subplot(2, 3, 1);
rlocus(sys_siso);
title('Root Locus (Open-Loop)');
grid on;
xlabel('Real Axis');
ylabel('Imaginary Axis');

subplot(2, 3, 2);
pzmap(sys_cl);
title('Closed-Loop Pole-Zero Map');
grid on;
xlabel('Real Axis');
ylabel('Imaginary Axis');

fprintf('Closed-loop poles:\n');
poles_cl = pole(sys_cl);
for i = 1:length(poles_cl)
    fprintf('  Pole %d: %.4f %+.4fi\n', i, real(poles_cl(i)), imag(poles_cl(i)));
end

%% 3. Bode Plot Analysis
fprintf('\n\n3. BODE PLOT ANALYSIS\n');
fprintf('====================\n\n');

subplot(2, 3, 3);
bode(sys_siso);
title('Bode Plot (Open-Loop)');
grid on;

subplot(2, 3, 4);
bode(pid_controller * sys_siso);
title('Bode Plot (With PID Controller)');
grid on;

[Gm, Pm, Wcg, Wcp] = margin(pid_controller * sys_siso);

fprintf('Stability Margins:\n');
fprintf('  Gain margin: %.4f dB at %.4f rad/s\n', 20*log10(Gm), Wcg);
fprintf('  Phase margin: %.4f degrees at %.4f rad/s\n', Pm, Wcp);

if Gm > 1 && Pm > 0
    fprintf('  System is STABLE\n');
else
    fprintf('  System is UNSTABLE or marginally stable\n');
end

%% 4. Step Response Analysis
fprintf('\n\n4. STEP RESPONSE ANALYSIS\n');
fprintf('=========================\n\n');

subplot(2, 3, 5);
step(sys_cl, 5);
title('Step Response (Closed-Loop)');
grid on;
xlabel('Time (s)');
ylabel('Amplitude');

[step_response_cl, t_cl] = step(sys_cl, 5);
final_value_cl = step_response_cl(end);

idx_10 = find(step_response_cl >= 0.1 * final_value_cl, 1);
idx_90 = find(step_response_cl >= 0.9 * final_value_cl, 1);
if ~isempty(idx_10) && ~isempty(idx_90)
    rise_time = t_cl(idx_90) - t_cl(idx_10);
    fprintf('  Rise time (10%%-90%%): %.4f s\n', rise_time);
end

settling_band = 0.02 * abs(final_value_cl);
idx_settle = find(abs(step_response_cl - final_value_cl) > settling_band, 1, 'last');
if ~isempty(idx_settle)
    settling_time = t_cl(idx_settle);
    fprintf('  Settling time (2%% band): %.4f s\n', settling_time);
else
    settling_time = t_cl(end);
    fprintf('  Settling time: > %.4f s\n', settling_time);
end

max_value = max(step_response_cl);
if max_value > final_value_cl
    overshoot = ((max_value - final_value_cl) / final_value_cl) * 100;
    fprintf('  Overshoot: %.2f%%\n', overshoot);
else
    fprintf('  Overshoot: 0%%\n');
end

ss_error = abs(1 - final_value_cl);
fprintf('  Steady-state error: %.4f\n', ss_error);

%% 5. Comparison
subplot(2, 3, 6);
step(sys_siso, sys_cl, 5);
title('Step Response Comparison');
legend('Open-Loop', 'Closed-Loop with PID', 'Location', 'best');
grid on;
xlabel('Time (s)');
ylabel('Amplitude');

%% Save Results
fprintf('\n\n5. RESULTS SUMMARY\n');
fprintf('==================\n\n');
fprintf('All plots have been generated.\n');
fprintf('PID Controller Parameters:\n');
fprintf('  Kp = %.4f\n', Kp);
fprintf('  Ki = %.4f\n', Ki);
fprintf('  Kd = %.4f\n', Kd);

f = gcf;
exportgraphics(f, 'control_design_analysis.png', 'Resolution', 300);
fprintf('\nFigure saved as: control_design_analysis.png\n');

fprintf('\n=== Analysis Complete ===\n');
