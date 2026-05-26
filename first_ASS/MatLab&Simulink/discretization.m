% Define discrete time vector (using the same tspan and dt2 for discr.)
t_discrete = tspan(1):dt2:tspan(2);

% Initialize the discrete state matrix.
% Assuming initial_state is a column vector representing the state at time t = 0.
x_discrete = zeros(length(initial_state), length(t_discrete));
x_discrete(:, 1) = initial_state;

% Euler integration loop
for k = 1:length(t_discrete)-1
    % Compute the state derivative at the current discrete time step
    dx = paint_system_ode(0, x_discrete(:, k), u, params);
    
    % Update the state using Euler's method
    x_discrete(:, k+1) = x_discrete(:, k) + dt2 * dx;
end

% Calculate the error matrix between continuous and discrete solutions
% x_history and x_discrete are both of size [number_of_states x num_steps]

x_history_interp = interp1(t, x_history', t_discrete)'; 
error_matrix = abs(x_history_interp - x_discrete);
% Plot the error for each state variable


figure;

% Red Pigment (R)
subplot(3,2,1);
plot(t_discrete, error_matrix(1, :), 'b-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error in R (kg/m^3)');
title('Error in Red Pigment');

% Green Pigment (G)
subplot(3,2,2);
plot(t_discrete, error_matrix(2, :), 'g-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error in G (kg/m^3)');
title('Error in Green Pigment');

% Blue Pigment (B)
subplot(3,2,3);
plot(t_discrete, error_matrix(3, :), 'r-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error in B (kg/m^3)');
title('Error in Blue Pigment');

% Viscosity (V)
subplot(3,2,4);
plot(t_discrete, error_matrix(4, :), 'k-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error in V (Pa·s)');
title('Error in Viscosity');

% Solvent Concentration (S)
subplot(3,2,5);
plot(t_discrete, error_matrix(5, :), 'm-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error in S (dimensionless)');
title('Error in Solvent Concentration');

% Optionally, display maximum error for each state in the command window:
fprintf('Maximum error in R: %.4f\n', max(error_matrix(1, :)));
fprintf('Maximum error in G: %.4f\n', max(error_matrix(2, :)));
fprintf('Maximum error in B: %.4f\n', max(error_matrix(3, :)));
fprintf('Maximum error in V: %.4f\n', max(error_matrix(4, :)));
fprintf('Maximum error in S: %.4f\n', max(error_matrix(5, :)));

save('paint_system_results_scenario_dics_VS_contnuos.mat', 'x_discrete', 'x_history', 'error_matrix', 't');



% Assume: 
% - 't' is the time vector for the continuous simulation,
% - 'x_history' contains the continuous simulation states [R; G; B; V; S],
% - 't_discrete' is the discrete time vector,
% - 'x_discrete' contains the discrete simulation states [R; G; B; V; S].

figure('Name', 'Continuous vs. Discrete Simulation Results', 'Position', [100, 100, 1200, 800]);

% Plot Red Pigment (R)
subplot(3,1,1);
plot(t, x_history(1, :), 'b-', 'LineWidth', 1);
hold on;
stem(t_discrete, x_discrete(1, :), 'ro', 'filled');
xlabel('Time (s)');
ylabel('Red Pigment (kg/m^3)');
legend('Continuous (ode45)', 'Discrete (Euler)', 'Location', 'Best');
title('Red Pigment Concentration');
grid on;
hold off;

% Plot Viscosity (V)
subplot(3,1,2);
plot(t, x_history(4, :), 'b-', 'LineWidth', 1);
hold on;
stem(t_discrete, x_discrete(4, :), 'ro', 'filled');
xlabel('Time (s)');
ylabel('Viscosity (Pa·s)');
legend('Continuous (ode45)', 'Discrete (Euler)', 'Location', 'Best');
title('Viscosity');
grid on;
hold off;

% Plot Solvent Concentration (S)
subplot(3,1,3);
plot(t, x_history(5, :), 'b-', 'LineWidth', 2);
hold on;
stem(t_discrete, x_discrete(5, :), 'ro', 'filled');
xlabel('Time (s)');
ylabel('Solvent Concentration (dimensionless)');
legend('Continuous (ode45)', 'Discrete (Euler)', 'Location', 'Best');
title('Solvent Concentration');
grid on;
hold off;
