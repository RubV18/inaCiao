function [u, error_int] = pid_controller(reference, current, error_int, dt, Kp, Ki, Kd, prev_error)
% PID_CONTROLLER - Implements a PID controller
%
% Inputs:
%   reference - setpoint value
%   current - current process value
%   error_int - integral of error (state)
%   dt - time step
%   Kp - proportional gain
%   Ki - integral gain
%   Kd - derivative gain
%   prev_error - previous error for derivative calculation
%
% Outputs:
%   u - control signal
%   error_int - updated integral of error

% Calculate error
error = reference - current;

% Update integral term
error_int = error_int + error * dt;

% Calculate derivative term
if nargin < 8
    error_deriv = 0;
else
    error_deriv = (error - prev_error) / dt;
end

% Calculate control signal
u = Kp * error + Ki * error_int + Kd * error_deriv;

% Limit control signal to prevent excessive values
u = max(0, min(u, 1));  % Assuming control range is [0, 1]
end