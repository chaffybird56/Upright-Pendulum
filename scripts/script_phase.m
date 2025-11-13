clear;

load("data/ph_device_05.mat")

q10 = 0;
q20 = pi;

Ts = 0.001;

X0=[0; 0.95*pi; 0; 0];

M = [Ph(1)  Ph(6)*cos(q20);
            Ph(6)*cos(q20)  Ph(2)];

F = [Ph(3)  0;
              0          Ph(4)];

K =  [0  0;
      0  Ph(5)*cos(q20)];

T1 = [1; 0];


A = [zeros(2,2)  eye(2);
     -M\K   -M\F];

B= [zeros(2,1);
    M\T1];

C=[1 0 0 0;
   0 1 0 0];



p = [-10+10j, -10-10j, -15, -18];

%% Task 1
% 1. Compute open-loop characteristic polynomial
OLChar = poly(eig(A));

% 2. Compute desired characteristic poly
a = flip (OLChar(2:5));

% 3. Compute the controllability matrices
Pc = [B A*B A^2*B A^3*B];
Ac = [zeros(3, 1) eye(3);
        -a];
Bc = [0 0 0 1]';
PcBar = [Bc Ac*Bc Ac^2*Bc Ac^3*Bc];

CLChar = poly(p);
alpha = flip(CLChar(2:5));


% 4. Compute similarity transformation
Tinv = PcBar*inv(Pc);

% 5. Compute state feedback gain Kc
Kc = alpha-a;

% 6. Compute state feedback gain
K = Kc*Tinv

eig (A-(B*K))



%% Task 2
Po = [C
    C*A
    C*A^2
    C*A^3];

rank(Po)

%% Task 3

% Observer closed-loop poles
pole_scaler = 5;
observer_poles = pole_scaler*[-10+10j, -10-10j, -15, -18]; 
% Choose poles faster than state-feedback poles? because we want the observer to estimate teh system states faster than teh system dynamics cant have it lagging behind the actual states

% Compute observer gain (L)
L = place(A', C', observer_poles)'; % Use transpose for place function

% Display observer gain
disp('Observer Gain Matrix (L):');
disp(L);

% Verify the observer closed-loop poles
A_observer = A - L * C;
observer_eigenvalues = eig(A_observer);

disp('Observer Closed-Loop Poles:');
disp(observer_eigenvalues);

Kf = K;

%% Graphing
q_sim = qm.signals.values;
u_sim = u.signals.values;
t = qm.time;

plot( t',q_sim(:,1));
hold on;
plot( t',q_sim(:,2));
title ("Joint positions over time p_o = " + pole_scaler + "p");
ylabel('Position (rad)');
xlabel('Time (s)');
legend('q1', 'q2');
hold off;

f = gcf;
exportgraphics(f,"sim_"+pole_scaler+".png",'Resolution',1200)



