%%
% first_prob.m
% MILP vs. Modified-NEH comparison for a re-entrant 5-stage flow-shop
% ───────────────────────────────────────────────────────────────────

clear;  clc;

%% 1.  Processing-time data  -----------------------------------------
% Retrieval (1) → Transport (2) → Verification-1 (3) → Customs (4) → Verification-2 (5)
p = [ 6 7 5 6 8 ;              % Retrieval
      5 6 7 5 6 ;              % Transport
      3 2 4 3 2 ;              % Verification-1
      9 8 7 6 9 ;              % Customs
      3 2 4 3 2 ];             % Verification-2

[seqHeur, Sheur, makespanHeur] = NEH_Modified(p);
[numStages,numJobs] = size(p);

%% 2.  Pair-specific Big-M table ------------------------------------
M = 1e02; 

%% 3.  Build MILP ----------------------------------------------------
prob   = optimproblem('ObjectiveSense','min');

Cmax = optimvar('Cmax','LowerBound',0);                                                  % Total Makespan
s    = optimvar('s',numStages,numJobs,'LowerBound',0);                                   % Start Times
x    = optimvar('x',3,numJobs,numJobs,'Type','integer','LowerBound',0,'UpperBound',1);   % State Vars
y    = optimvar('y',numJobs,numJobs,'Type','integer','LowerBound',0,'UpperBound',1);     % Additional Binary var for Reentrant Machine

prob.Objective = Cmax;

% 3-a  Precendence Constraint: Pass through a flowshop of four machines and five stages (Verification stage is being used twice)
%                              Constraint n.5 guarantees a job finishes customs before starting its second verification.
k = 0;  prec = optimconstr(numStages*numJobs,1);
for j = 1:numJobs
    k=k+1; prec(k) = s(2,j) >= s(1,j)+p(1,j);
    k=k+1; prec(k) = s(3,j) >= s(2,j)+p(2,j);
    k=k+1; prec(k) = s(5,j) >= s(4,j)+p(4,j);
    k=k+1; prec(k) = s(4,j) >= s(3,j)+p(3,j);
    k=k+1; prec(k) = Cmax   >= s(5,j)+p(5,j);
end
prob.Constraints.Precedence = prec;

% 3-b  machines 1,2,4 capacity (disjunctive)
machineStages = [1 2 4];
nD = 3*numJobs*(numJobs-1);
D1 = optimconstr(nD,1);  D2 = optimconstr(nD,1);  k = 0;
for m = 1:3
    st = machineStages(m);
    for i = 1:numJobs
        for j = 1:numJobs
            if i~=j
                k = k+1;
                D1(k) = s(st,i)+p(st,i) <= s(st,j) + M*(1 - x(m,i,j));
                D2(k) = s(st,j)+p(st,j) <= s(st,i) + M*(    x(m,i,j));
            end
        end
    end
end
prob.Constraints.Mach1 = D1;
prob.Constraints.Mach2 = D2;

% 3-c  single verifier for stages 3 & 5: Custom Inspections (3) and
%                                        Verification checkpoint (5)
nR = numJobs*(numJobs-1);
R1 = optimconstr(nR,1);  R2 = optimconstr(nR,1);  k = 0;
for i = 1:numJobs
    for j = 1:numJobs
        if i~=j
            k = k+1;
            % y(i,j) decides whether job i’s second pass plus customs finishes before job j can even start its first pass.
            R1(k) = s(5,i)+p(5,i) <= s(3,j) + M*(1 - y(i,j));
            R2(k) = s(5,j)+p(5,j) <= s(3,i) + M*(    y(i,j));
            % The single verification machine is never processing two jobs at once, 
            % even though each job visits it twice
        end
    end
end
prob.Constraints.Ver1 = R1;
prob.Constraints.Ver2 = R2;

% 3-d  symmetry & diagonal cuts for x:  xSym forces a unique ordering direction for every job pair on every machine
%                                       removes mirror-image solutions.	
%                                       Shrinks the branch-and-bound tree ~×2
xSym = optimconstr(3*numJobs*(numJobs-1)/2 ,1);  c = 0;
for m = 1:3
    for i = 1:numJobs
        for j = i+1:numJobs
            
            c=c+1;  xSym(c) = x(m,i,j)+x(m,j,i) == 1;
        end
        prob.Constraints.(sprintf('xdiag_m%d_i%d',m,i)) = x(m,i,i)==0;
    end
end
prob.Constraints.xSym = xSym;

% 3-e  symmetry & diagonal cuts for y:  Gives one consistent global order for the verifier across all jobs
%                                       removes contradictory self-precedence. 
%                                       ySym has the same pruning effect above

ySym = optimconstr(numJobs*(numJobs-1)/2 ,1);  c = 0;
for i = 1:numJobs
    for j = i+1:numJobs
        
        c=c+1;  ySym(c) = y(i,j)+y(j,i) == 1;
    end
    prob.Constraints.(sprintf('ydiag%d',i)) = y(i,i)==0;
end
prob.Constraints.ySym = ySym;

%% 4.  Solve ----------------------------------------------------------
opts = optimoptions('intlinprog','Display','iter');
tic
sol = solve(prob,'Solver','intlinprog','Options',opts);
runtimeMILP = toc;

S  = reshape(sol.s,numStages,[]);    % 5x5 matrix
makespanMILP = sol.Cmax;

%% 5.  Heuristic ------------------------------------------------------
tic
[seqHeur, Sheur, makespanHeur] = NEH_Modified(p);
runtimeHeur  = toc;
[makespanHeur, startHeur] = evalMakespan(seqHeur,p);

%% 6.  Print results --------------------------------------------------
for st = 1:numStages
    fprintf('Stage %d start times:\n',st);
    for j = 1:size(S,2)
        fprintf('  Job %2d : %6.2f\n',j,S(st,j));
    end
end

fprintf('\nMILP makespan  : %.2f   (%.2f s)\n',makespanMILP,runtimeMILP);
fprintf('Heuristic ms   : %.2f   (%.3f s)\n',makespanHeur,runtimeHeur);
fprintf('Heuristic Sequence: %i \n',seqHeur);
fprintf('Gap = %.2f %%\n\n',100*(makespanHeur-makespanMILP)/makespanMILP);

fprintf('MILP runtime: %2f s \n', runtimeMILP);
fprintf('Heurstic runtime: %2f s \n', runtimeHeur);


%% 7.  Gantt charts ----------------------------------------------------
figure('Position',[50 50 1200 300]);
tiledlayout(1,2,"TileSpacing","compact")

colors = lines(numJobs);                 % one colour per job
jobNames = arrayfun(@(j)sprintf('Job %d',j),1:numJobs,'uni',0);

% ---------- MILP panel -----------------------------------------------
nexttile, hold on
hLegend = gobjects(1,numJobs);           % store one handle per job
for j = 1:numJobs
    for st = 1:numStages
        h = rectangle('Position',[S(st,j) , 6-st , p(st,j) , 0.8], ...
                      'FaceColor',colors(j,:) , 'EdgeColor','none');
        % centre label
        text( S(st,j)+p(st,j)/2 , 6-st+0.4 , sprintf('J%d',j) , ...
              'HorizontalAlignment','center','VerticalAlignment','middle', ...
              'Color','w','FontSize',7,'FontWeight','bold');
        if st == 1                      % grab one handle per job for legend
            hLegend(j) = h;
        end
    end
end
title(sprintf('MILP  (C_{max}=%.0f)',makespanMILP))
yticks(1:5), yticklabels({'V2','Cust','V1','Tran','Retr'})
xlabel('time (min)'), box on
hLegend = gobjects(numJobs,1);
for j = 1:numJobs
    hLegend(j) = plot(nan,nan,'s', ...             % invisible dummy
        'MarkerFaceColor',colors(j,:), ...
        'MarkerEdgeColor',colors(j,:), ...
        'Visible','off');
end
legend(hLegend, jobNames,'Location','eastoutside');hold off

% ---------- Heuristic panel ------------------------------------------
[~,Hseq] = sort(startHeur(1,:));         % same colouring order
nexttile, hold on
for jj = 1:numJobs
    j = Hseq(jj);                        % plot in permutation order
    for st = 1:numStages
        rectangle('Position',[startHeur(st,j) , 6-st , p(st,j) , 0.8], ...
                  'FaceColor',colors(j,:) , 'EdgeColor','none');
        text( startHeur(st,j)+p(st,j)/2 , 6-st+0.4 , sprintf('J%d',j) , ...
              'HorizontalAlignment','center','VerticalAlignment','middle', ...
              'Color','w','FontSize',7,'FontWeight','bold');
    end
end
title(sprintf('Heuristic  (C_{max}=%.0f)',makespanHeur))
yticks(1:5), yticklabels({'V2','Cust','V1','Tran','Retr'})
xlabel('time (min)'), box on
hold off
