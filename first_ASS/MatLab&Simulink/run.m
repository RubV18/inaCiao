% run.m - Main script to run the paint production system simulation - Scenario 1

% Clear workspace and close figures
clear;
clc;
close all;

% Initialize parameters
init;

% Convert parameters to structure for easier passing
params.alpha_R = alpha_R;
params.alpha_G = alpha_G;
params.alpha_B = alpha_B;
params.beta_R = beta_R;
params.beta_G = beta_G;
params.beta_B = beta_B;
params.gamma_RV = gamma_RV;
params.gamma_GV = gamma_GV;
params.gamma_BV = gamma_BV;
params.gamma_RS = gamma_RS;
params.gamma_GS = gamma_GS;
params.gamma_BS = gamma_BS;
params.delta_V = delta_V;
params.eta_V = eta_V;
params.kappa_R = kappa_R;
params.kappa_G = kappa_G;
params.kappa_B = kappa_B;
params.lambda_V = lambda_V;
params.alpha_S = alpha_S;
params.beta_S = beta_S;
params.sigma_R = sigma_R;
params.sigma_G = sigma_G;
params.sigma_B = sigma_B;
params.epsilon_V = epsilon_V;

% Time vector for simulation
t = tspan(1):dt:tspan(2);
num_steps = length(t);

% Initialize state and control history arrays
x_history = zeros(5, num_steps);
u_history = zeros(5, num_steps);

% Set initial state
x = initial_state;
x_history(:, 1) = x;

% Initialize controller states
error_int_R = 0;
error_int_G = 0;
error_int_B = 0;
error_int_S = 0;
prev_error_R = 0;
prev_error_G = 0;
prev_error_B = 0;
prev_error_S = 0;
prev_u_V = 0;

%Main simulation loop
for i = 1:num_steps-1
    % Current state
    R = x(1);
    G = x(2);
    B = x(3);
    V = x(4);
    S = x(5);

    % PID controller for red pigment
    [u_R, error_int_R] = pid_controller(R_ref, R, error_int_R, dt, Kp_R, Ki_R, Kd_R, prev_error_R);
    prev_error_R = R_ref - R;

    % PID controller for green pigment
    [u_G, error_int_G] = pid_controller(G_ref, G, error_int_G, dt, Kp_G, Ki_G, Kd_G, prev_error_G);
    prev_error_G = G_ref - G;

    % PID controller for blue pigment
    [u_B, error_int_B] = pid_controller(B_ref, B, error_int_B, dt, Kp_B, Ki_B, Kd_B, prev_error_B);
    prev_error_B = B_ref - B;

    % Relay controller for viscosity
    u_V = relay_controller(V_ref, V, V_delta, u_V_max, u_V_min, prev_u_V);
    prev_u_V = u_V;

    % PID controller for solvent
    [u_S, error_int_S] = pid_controller(S_ref, S, error_int_S, dt, Kp_S, Ki_S, Kd_S, prev_error_S);
    prev_error_S = S_ref - S;

    % Combine control inputs
    u = [u_R; u_G; u_B; u_V; u_S];
    u_history(:, i) = u;
    % Computing Mixing Efficiency
    pigment_rate = params.alpha_R*u_R + params.alpha_G*u_G + params.alpha_B*u_B;
    total_pigment_used = trapz(t, pigment_rate * ones(size(t)));  

    % Calculate energy consumption
    energy_rate = energy_factor_R*u_R^2 + energy_factor_G*u_G^2 + energy_factor_B*u_B^2 + ...
              energy_factor_V*u_V^2 + energy_factor_S*u_S^2;

    % Calculate Mixing Energy
    mixing_energy = trapz(t, energy_rate * ones(size(t)));

    % Calculate Solvent Emissions
    total_solvent_injected = trapz(t, params.alpha_S*u_S * ones(size(t)));
    solvent_emissions = total_solvent_injected - x_history(5,end);
    regulatory_limit = 10;  % Regulatory Limit arbitrarily
    
    % Simulate system for one time step using ODE45
    [~, x_step] = ode45(@(t, x) paint_system_ode(t, x, u, params), [0 dt], x);

    % Update state
    x = x_step(end, :)';
    x_history(:, i+1) = x;   
end

% -- After your simulation finishes:
final_R = x_history(1, end);
final_G = x_history(2, end);
final_B = x_history(3, end);

% -- Normalize to [0, 1] range by dividing by the max component to get the final RGB vector to show final paint output:
maxVal = max([final_R, final_G, final_B]);
if maxVal > 0
    colorRGB = [final_R, final_G, final_B] / maxVal;
else
    colorRGB = [0, 0, 0];
end

% Compute the Mixing Ratio Efficiency, Energy Efficiency and Environmental Impact:
final_paint_output = final_R + final_G + final_B;
material_efficiency = total_pigment_used / final_paint_output;
env_impact = solvent_emissions / regulatory_limit;
energy_efficiency = mixing_energy / final_paint_output;

% -- Display in a figure:
figure;
patch([0 1 1 0], [0 0 1 1], colorRGB, 'EdgeColor', 'none');
axis equal; axis off;
title(sprintf('Final Output Color = [%.2f, %.2f, %.2f]', colorRGB));


% Plot results
figure('Name', 'Paint Production System Simulation - Scenario : High-Gloss Exterior Paint', 'Position', [100, 100, 1200, 800]);

% Plot pigment concentrations
subplot(3, 2, 1);
plot(t, x_history(1, :), 'r-', t, x_history(2, :), 'g-', t, x_history(3, :), 'b-');
hold on;
plot(t, R_ref * ones(size(t)), 'r--', t, G_ref * ones(size(t)), 'g--', t, B_ref * ones(size(t)), 'b--');
hold off;
xlabel('Time');
ylabel('Concentration');
title('Pigment Concentrations');
legend('Red', 'Green', 'Blue', 'R_{ref}', 'G_{ref}', 'B_{ref}');
grid on;

% Plot viscosity
subplot(3, 2, 2);
plot(t, x_history(4, :), 'k-', t, V_ref * ones(size(t)), 'k--');
xlabel('Time');
ylabel('Viscosity');
title('Viscosity');
legend('Viscosity', 'V_{ref}');
grid on;

% Plot solvent concentration
subplot(3, 2, 3);
plot(t, x_history(5, :), 'm-', t, S_ref * ones(size(t)), 'm--');
xlabel('Time');
ylabel('Concentration');
title('Solvent Concentration');
legend('Solvent', 'S_{ref}');
grid on;

% Plot control inputs
subplot(3, 2, 4);
plot(t, u_history(1, :), 'r-', t, u_history(2, :), 'g-', t, u_history(3, :), 'b-', ...
     t, u_history(4, :), 'k-', t, u_history(5, :), 'm-');
xlabel('Time');
ylabel('Control Input');
title('Control Inputs');
legend('u_R', 'u_G', 'u_B', 'u_V', 'u_S');
grid on;

% Display performance metrics
fprintf('Performance Metrics - Scenario : High-Gloss Exterior Paint\n');

fprintf('Material Total Pigment Used: %.4f\n', total_pigment_used);
fprintf('Material Final Paint output: %.4f\n', final_paint_output);
fprintf('Material Efficiency : %.4f\n', material_efficiency);
fprintf('Mixing Energy: %.4f1\n', mixing_energy);
fprintf('Solvent Environments Impact: %.4f1\n', env_impact);

% Save results
save('paint_system_results_scenario1.mat', 'x_history', 'u_history', 'total_pigment_used', 'final_paint_output', 'material_efficiency', 'mixing_energy', 'env_impact', 't');