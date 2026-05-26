function dxdt = paint_system_ode(t, x, u, params)
% PAINT_SYSTEM_ODE - ODE function for paint production system
%
% Inputs:
%   t - current time
%   x - current state [R; G; B; V; S]
%   u - control inputs [u_R; u_G; u_B; u_V; u_S]
%   params - structure containing all model parameters
%
% Outputs:
%   dxdt - state derivatives [dR/dt; dG/dt; dB/dt; dV/dt; dS/dt]

% Extract states
R = x(1);  % Red pigment concentration
G = x(2);  % Green pigment concentration
B = x(3);  % Blue pigment concentration
V = x(4);  % Viscosity
S = x(5);  % Solvent concentration

% Extract control inputs
u_R = u(1);  % Red pigment flow rate
u_G = u(2);  % Green pigment flow rate
u_B = u(3);  % Blue pigment flow rate
u_V = u(4);  % Viscosity additive input
u_S = u(5);  % Solvent flow rate

% Color mixing dynamics
dRdt = params.alpha_R * u_R - params.beta_R * R - params.gamma_RV * V * R - params.gamma_RS * S * R;
dGdt = params.alpha_G * u_G - params.beta_G * G - params.gamma_GV * V * G - params.gamma_GS * S * G;
dBdt = params.alpha_B * u_B - params.beta_B * B - params.gamma_BV * V * B - params.gamma_BS * S * B;

% Viscosity dynamics
dVdt = -params.delta_V * V + params.eta_V * u_V + ...
       params.kappa_R * R + params.kappa_G * G + params.kappa_B * B - ...
       params.lambda_V * S * V;

% Solvent concentration dynamics
dSdt = params.alpha_S * u_S - params.beta_S * S - ...
       params.sigma_R * R * S - params.sigma_G * G * S - params.sigma_B * B * S - ...
       params.epsilon_V * V * S;

% Combine state derivatives
dxdt = [dRdt; dGdt; dBdt; dVdt; dSdt];
end