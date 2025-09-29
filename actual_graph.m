clear;
close all;

pole_scaler = 16.39;

load("qm_actual-"+pole_scaler+".mat");
load("um_actual-"+pole_scaler+".mat");

q = qm_actual.signals.values;
t = qm_actual.time;
u = um;

tl = tiledlayout(2, 1);

nexttile;
plot( t',q(:,1));
hold on;
plot( t',q(:,2));
title ("Joint positions over time, p_o = " + pole_scaler + "p");
ylabel('Position (rad)');
xlabel('Time (s)');
legend('q1', 'q2');
hold off;

nexttile;
plot(t', u(:,2));
title ("Input voltage over time, p_o = " + pole_scaler + "p");
ylabel('Input voltage (V)');
xlabel('Time (s)');


f = gcf;
exportgraphics(f,"actual_"+pole_scaler+".png",'Resolution',1200)