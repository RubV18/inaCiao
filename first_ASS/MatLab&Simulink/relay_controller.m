    function u = relay_controller(reference, current, delta, u_max, u_min, prev_u)
    % RELAY_CONTROLLER - Implements a relay controller with hysteresis
    %
    % Inputs:
    %   reference - setpoint value
    %   current - current process value
    %   delta - hysteresis band
    %   u_max - maximum control output
    %   u_min - minimum control output
    %   prev_u - previous control output
    %
    % Outputs:
    %   u - control signal
    
    if current < reference - delta
        u = u_max;
    elseif current > reference + delta
        u = u_min;
    else
        u = prev_u;  % Maintain previous value within hysteresis band
    end
    end