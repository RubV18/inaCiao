clear;
clc;

%GOAL: Minimize the sum of the tardiness


%% SETS
N_JOBS = 6;
%list of jobs indexes
JOBS = 1:N_JOBS;

%% PARAMETERS
p = [6 9 7 5 8 10]'; % Processing times
d = [25 30 22 28 27 35]'; % Due dates

% Setup times si,j
setup = [inf 3 4 2 3 5;
         2 inf 5 4 3 2;
         3 2 inf 3 5 4;
         4 3 2 inf 4 3;
         3 5 4 2 inf 3;
         5 4 2 3 4 inf];

M = 1000; % Big M constant

%% VARIABLES
C = optimvar('C', N_JOBS, 'LowerBound', 0); % Completion times
S = optimvar('S', N_JOBS, 'LowerBound', 0); % Start times
x = optimvar('x', N_JOBS, N_JOBS, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1); % Sequencing vars
Tard = optimvar('Tard', N_JOBS, 'LowerBound', 0); % Tardiness

%% PROBLEM DEFINITION
prob = optimproblem;

% Objective: Minimize total tardiness
prob.Objective = sum(Tard);

%% CONSTRAINTS
cons1 = optimconstr(N_JOBS*N_JOBS - N_JOBS);
count = 1;
for i = JOBS
    for j = JOBS
        if i ~= j
            cons1(count) = S(j) >= C(i) + setup(i,j) - M*(1 - x(i,j));
            count = count + 1;
        end
    end
end
prob.Constraints.cons1 = cons1;

cons2 = optimconstr(N_JOBS);
for j = JOBS
    cons2(j) = sum(x(:,j)) <= 1; % at most one predecessor
end
prob.Constraints.cons2 = cons2;

cons3 = optimconstr(N_JOBS);
for i = JOBS
    cons3(i) = sum(x(i,:)) <= 1; % at most one successor
end
prob.Constraints.cons3 = cons3;

cons4 = optimconstr(N_JOBS);
for i = JOBS
    cons4(i) = C(i) == S(i) + p(i);
end
prob.Constraints.cons4 = cons4;

cons5 = optimconstr(N_JOBS);
for i = JOBS
    cons5(i) = Tard(i) >= C(i) - d(i);
end
prob.Constraints.cons5 = cons5;

cons6 = optimconstr(N_JOBS);
for i = JOBS
    cons6(i) = x(i,i) == 0;
end
prob.Constraints.cons6 = cons6;

% Ensure exactly one job has no predecessor (starting job)
cons7 = optimconstr(1);
cons7(1) = sum(sum(x)) == N_JOBS - 1; % N_JOBS - 1 links
prob.Constraints.cons7 = cons7;

% Container 4 must be in position 2
cons8 = optimconstr(1);
cons8(1) = sum(x(:,4)) == 1; % exactly one predecessor
prob.Constraints.cons8 = cons8;

cons9 = optimconstr(1);
cons9(1) = sum(x(4,:)) == 1; % exactly one successor
prob.Constraints.cons9 = cons9;

%% SOLVE
opts = optimoptions('intlinprog','Display','iter');
tic
[sol,fval,exitflag,output] = solve(prob,'Options',opts);
%[sol, fval, exitflag, output] = solve(prob);

disp(sol.Tard);
disp(['Total tardiness: ', num2str(fval)]);
toc



%% JOB SEQUENCE

% Reconstruct job sequence from x matrix
sequence = zeros(N_JOBS,1);
used = zeros(N_JOBS,1);

% Find the starting job (the one with no predecessors)
start_job = -1;
for i = 1:N_JOBS
    if sum(sol.x(:,i)) == 0
        start_job = i;
        break;
    end
end

% Reconstruct sequence
current = start_job;
for k = 1:N_JOBS
    sequence(k) = current;
    used(current) = 1;
    for next = 1:N_JOBS
        if sol.x(current,next) > 0.5 % Use 0.5 threshold because of numerical precision
            current = next;
            break;
        end
    end
end

% Display the optimal sequence
disp('Optimal job sequence:');
disp(sequence');


%% GANTT graph
gantt_scheduling(sol.S, sol.C, sequence, N_JOBS);
