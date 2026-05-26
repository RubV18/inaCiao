% init.m - Parameter initialization for paint production system - Scenario : High-Gloss Exterior Paint
% This file contains all parameters needed for the model

% Simulation parameters
tspan = [0 50];  % Simulation time span [start end]
dt = 0.1;         % Time step for simulation
dt2 = 0.06;

% Initial conditions
R0 = 0.7;         % Initial red pigment concentration
G0 = 0.7;         % Initial green pigment concentration
B0 = 0.7;         % Initial blue pigment concentration
V0 = 1.5;         % Initial viscosity
S0 = 0.4;         % Initial solvent concentration
initial_state = [R0; G0; B0; V0; S0];

% Reference values (setpoints) - Scenario 2: High-Gloss Exterior Paint
R_ref = 2.0;      % High red pigment concentration
G_ref = 0.9;      % Low green pigment concentration
B_ref = 1.8;      % High blue pigment concentration
V_ref = 1.2;      % Lower viscosity (thinner paint)
S_ref = 0.7;      % Higher solvent concentration (faster drying)

% Color mixing parameters
alpha_R = 1.0;    % Input gain for red pigment
alpha_G = 1.0;    % Input gain for green pigment
alpha_B = 1.0;    % Input gain for blue pigment
beta_R = 0.05;    % Natural degradation rate for red pigment
beta_G = 0.04;    % Natural degradation rate for green pigment
beta_B = 0.03;    % Natural degradation rate for blue pigment

% Coupling coefficients between pigments and viscosity
gamma_RV = 0.02;  % Effect of viscosity on red pigment
gamma_GV = 0.02;  % Effect of viscosity on green pigment
gamma_BV = 0.02;  % Effect of viscosity on blue pigment

% Coupling coefficients between pigments and solvent
gamma_RS = 0.03;  % Effect of solvent on red pigment
gamma_GS = 0.03;  % Effect of solvent on green pigment
gamma_BS = 0.03;  % Effect of solvent on blue pigment

% Viscosity parameters
delta_V = 0.51;    % Natural viscosity reduction rate
eta_V = 0.6;      % Viscosity additive effectiveness
kappa_R = 0.15;   % Impact of red pigment on viscosity
kappa_G = 0.12;   % Impact of green pigment on viscosity
kappa_B = 0.10;   % Impact of blue pigment on viscosity
lambda_V = 0.2;   % Solvent's effect on reducing viscosity

% Solvent parameters
alpha_S = 0.7;    % Solvent input gain
beta_S = 0.08;    % Solvent evaporation rate
sigma_R = 0.05;   % Absorption rate of solvent by red pigment
sigma_G = 0.05;   % Absorption rate of solvent by green pigment
sigma_B = 0.05;   % Absorption rate of solvent by blue pigment
epsilon_V = 0.03; % Effect of viscosity on solvent retention

% PID controller parameters for red pigment
Kp_R = 2.0;       % Proportional gain
Ki_R = 0.5;       % Integral gain
Kd_R = 0.1;       % Derivative gain

% PID controller parameters for green pigment
Kp_G = 2.0;       % Proportional gain
Ki_G = 0.5;       % Integral gain
Kd_G = 0.1;       % Derivative gain

% PID controller parameters for blue pigment
Kp_B = 2.0;       % Proportional gain
Ki_B = 0.5;       % Integral gain
Kd_B = 0.1;       % Derivative gain

% Relay controller parameters for viscosity
V_delta = 0.2;    % Hysteresis band
u_V_max = 0.32;    % Maximum viscosity additive input
u_V_min = 0.28;    % Minimum viscosity additive input

% PID controller parameters for solvent
Kp_S = 1.7;       % Proportional gain
Ki_S = 0.6;       % Integral gain
Kd_S = 0.1;       % Derivative gain

% Energy and material consumption parameters
energy_factor_R = 0.1;  % Energy consumption factor for red pigment pump
energy_factor_G = 0.1;  % Energy consumption factor for green pigment pump
energy_factor_B = 0.1;  % Energy consumption factor for blue pigment pump
energy_factor_V = 0.2;  % Energy consumption factor for viscosity additive
energy_factor_S = 0.15; % Energy consumption factor for solvent pump

% Display initialization message
disp('Paint production system parameters initialized for Scenario 2: High-Gloss Exterior Paint');
