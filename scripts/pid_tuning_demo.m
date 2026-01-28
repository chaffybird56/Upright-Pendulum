%% PID Tuning Demonstration
clear; close all; clc;

%% Load System
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

sys_siso = ss(A, B, C(1,:), 0);

%% Get Process Parameters
[step_response, t_step] = step(sys_siso, 5);
K_ss = dcgain(sys_siso);
final_value = step_response(end);
target_value = 0.632 * final_value;
idx_63 = find(step_response >= target_value, 1);
tau = t_step(idx_63);
idx_first = find(step_response > 0.01 * final_value, 1);
L = t_step(idx_first);

%% Ziegler-Nichols Tuning
[mag, phase, w] = bode(sys_siso);
mag_db = 20*log10(squeeze(mag));
phase_deg = squeeze(phase);
idx_180 = find(phase_deg <= -180, 1);

if ~isempty(idx_180)
    w_u = w(idx_180);
    K_u = 1 / (10^(mag_db(idx_180)/20));
    P_u = 2*pi / w_u;
    
    Kp_zn = 0.6 * K_u;
    Ti_zn = 0.5 * P_u;
    Td_zn = 0.125 * P_u;
    
    % PID Controller
    s = tf('s');
    s = tf('s');
    Ki_zn = Kp_zn / Ti_zn;
    Kd_zn = Kp_zn * Td_zn;
    pid_zn = Kp_zn + Ki_zn/s + Kd_zn*s;
    sys_cl_zn = feedback(pid_zn * sys_siso, 1);
else
    Kp_zn = 10; Ti_zn = 0.5; Td_zn = 0.1;
    s = tf('s');
    Ki_zn = Kp_zn / Ti_zn;
    Kd_zn = Kp_zn * Td_zn;
    pid_zn = Kp_zn + Ki_zn/s + Kd_zn*s;
    sys_cl_zn = feedback(pid_zn * sys_siso, 1);
end

%% Cohen-Coon Tuning
if L > 0 && tau > 0
    Kp_cc = (1/K_ss) * (tau/L) * (1.33 + 0.25*(L/tau));
    Ti_cc = L * (32 + 6*(L/tau)) / (13 + 8*(L/tau));
    Td_cc = L * 4 / (11 + 2*(L/tau));
    
    Ki_cc = Kp_cc / Ti_cc;
    Kd_cc = Kp_cc * Td_cc;
    pid_cc = Kp_cc + Ki_cc/s + Kd_cc*s;
    sys_cl_cc = feedback(pid_cc * sys_siso, 1);
else
    Kp_cc = Kp_zn; Ti_cc = Ti_zn; Td_cc = Td_zn;
    sys_cl_cc = sys_cl_zn;
end

%% Plot Comparison
figure('Position', [100, 100, 1400, 600]);

subplot(1, 2, 1);
step(sys_cl_zn, sys_cl_cc, 5);
title('Step Response: Ziegler-Nichols vs Cohen-Coon');
legend('Ziegler-Nichols', 'Cohen-Coon', 'Location', 'best');
grid on;
xlabel('Time (s)');
ylabel('Amplitude');

subplot(1, 2, 2);
bode(pid_zn * sys_siso, pid_cc * sys_siso);
title('Bode Plot: Ziegler-Nichols vs Cohen-Coon');
legend('Ziegler-Nichols', 'Cohen-Coon', 'Location', 'best');
grid on;

%% Display Results
fprintf('=== PID Tuning Comparison ===\n\n');
fprintf('Ziegler-Nichols Parameters:\n');
fprintf('  Kp = %.4f, Ti = %.4f s, Td = %.4f s\n', Kp_zn, Ti_zn, Td_zn);
fprintf('\nCohen-Coon Parameters:\n');
fprintf('  Kp = %.4f, Ti = %.4f s, Td = %.4f s\n', Kp_cc, Ti_cc, Td_cc);

[step_zn, t_zn] = step(sys_cl_zn, 5);
[step_cc, t_cc] = step(sys_cl_cc, 5);

final_zn = step_zn(end);
final_cc = step_cc(end);

overshoot_zn = ((max(step_zn) - final_zn) / final_zn) * 100;
overshoot_cc = ((max(step_cc) - final_cc) / final_cc) * 100;

fprintf('\nPerformance Metrics:\n');
fprintf('  Ziegler-Nichols: Overshoot = %.2f%%\n', overshoot_zn);
fprintf('  Cohen-Coon: Overshoot = %.2f%%\n', overshoot_cc);

f = gcf;
exportgraphics(f, 'pid_tuning_comparison.png', 'Resolution', 300);
fprintf('\nFigure saved as: pid_tuning_comparison.png\n');
